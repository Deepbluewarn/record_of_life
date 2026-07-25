import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_of_life/data/location.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/forms/shot_form.dart';

// Sticky Capture Mode: 상단 카메라 프리뷰 항상 표시, 확인 시 자동 촬영 + 저장.
// 뒤로가기만 탈출구.
class CaptureModePage extends ConsumerStatefulWidget {
  final Roll roll;
  const CaptureModePage({super.key, required this.roll});

  @override
  ConsumerState<CaptureModePage> createState() => _CaptureModePageState();
}

class _CaptureModePageState extends ConsumerState<CaptureModePage> {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _initError;
  bool _permanentlyDenied = false;
  LocationAccess _locationAccess = LocationAccess.granted;

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    final a = await checkLocationAccess();
    if (mounted) setState(() => _locationAccess = a);
  }

  Future<void> _requestLocation() async {
    final a = await requestLocationAccess();
    if (!mounted) return;
    setState(() => _locationAccess = a);
    if (a == LocationAccess.permanentlyDenied) {
      await Geolocator.openAppSettings();
    } else if (a == LocationAccess.serviceDisabled) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _initCamera() async {
    // 웹은 permission_handler 미지원 — camera 패키지가 브라우저 프롬프트 처리.
    if (!kIsWeb) {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _permanentlyDenied = true;
            _initError = '카메라 권한이 영구 거부됨';
          });
        }
        return;
      }
      if (!status.isGranted) {
        if (mounted) setState(() => _initError = '카메라 권한 거부됨');
        return;
      }
    }
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _initError = '사용 가능한 카메라 없음');
        return;
      }
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
    } catch (e) {
      if (mounted) setState(() => _initError = '카메라 초기화 실패: $e');
    }
  }

  Future<void> _retry() async {
    setState(() {
      _initError = null;
      _permanentlyDenied = false;
      _initFuture = _initCamera();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 확인 버튼과 프리뷰 탭이 공유하는 저장 흐름.
  Future<void> _handleConfirm(Roll currentRoll, int nextFrame) async {
    final form = ref.read(newShotFormProvider(null));
    if (!form.isValid) return;

    if (nextFrame > currentRoll.totalShots) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('총 매수 초과'),
          content: Text(
            '이 롤의 총 매수는 ${currentRoll.totalShots}입니다. #$nextFrame을 계속 기록할까요?\n'
            '(필름 실물이 여유분을 허용하는 경우에 유효)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('계속'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    final pos = await tryGetPosition();
    final imagePath = await _capture();
    final shot = form
        .toShot(rollId: currentRoll.id)
        .copyWith(
          idx: nextFrame,
          gpsLat: pos?.lat,
          gpsLng: pos?.lng,
          imagePath: imagePath ?? form.imagePath,
        );

    await ref.read(shotProvider(currentRoll.id).notifier).addShot(shot);
    ref.read(newShotFormProvider(null).notifier).resetForNextShot();
    HapticFeedback.mediumImpact();

    if (!mounted) return;
    final justCompleted = nextFrame == currentRoll.totalShots;
    final handedness = ref.read(settingsProvider).value?.handedness;
    final width = MediaQuery.of(context).size.width;
    final margin = handedness == Handedness.left
        ? EdgeInsets.only(left: 16, right: width * 0.35, bottom: 16)
        : EdgeInsets.only(left: width * 0.35, right: 16, bottom: 16);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            justCompleted
                ? '#$nextFrame 저장 · 롤 촬영 완료 🎞'
                : '#$nextFrame 저장됨',
          ),
          duration: Duration(milliseconds: justCompleted ? 2200 : 900),
          behavior: SnackBarBehavior.floating,
          margin: margin,
        ),
      );
  }

  Future<String?> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) {
      return null;
    }
    try {
      final xfile = await c.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final target =
          '${dir.path}/shots/${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
      final targetFile = File(target);
      await targetFile.parent.create(recursive: true);
      await xfile.saveTo(target);
      return target;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rollState = ref.watch(
      rollProvider(RollFilter(rollId: widget.roll.id)),
    );
    final currentRoll = rollState.when(
      data: (s) => s.rolls.isNotEmpty ? s.rolls.first : widget.roll,
      loading: () => widget.roll,
      error: (_, __) => widget.roll,
    );

    final nextFrame = currentRoll.shotsDone + 1;
    final total = currentRoll.totalShots;

    return Scaffold(
      appBar: AppBar(title: Text('입력 모드 · $nextFrame / $total')),
      body: SafeArea(
        child: Column(
          children: [
            _PreviewArea(
              controller: _controller,
              initFuture: _initFuture,
              initError: _initError,
              permanentlyDenied: _permanentlyDenied,
              onRetry: _retry,
              onTapPreview: () => _handleConfirm(currentRoll, nextFrame),
            ),
            _LocationHint(
              access: _locationAccess,
              onTap: _requestLocation,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ShotForm(),
              ),
            ),
            _ConfirmBar(
              nextFrame: nextFrame,
              onConfirm: () => _handleConfirm(currentRoll, nextFrame),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final CameraController? controller;
  final Future<void>? initFuture;
  final String? initError;
  final bool permanentlyDenied;
  final VoidCallback onRetry;

  const _PreviewArea({
    required this.controller,
    required this.initFuture,
    required this.initError,
    required this.permanentlyDenied,
    required this.onRetry,
    required this.onTapPreview,
  });

  final VoidCallback onTapPreview;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _placeholder('웹에서는 실시간 카메라 미지원');
    }
    if (initError != null) {
      return _errorPlaceholder(initError!);
    }
    return FutureBuilder<void>(
      future: initFuture,
      builder: (context, snap) {
        final c = controller;
        if (snap.connectionState != ConnectionState.done || c == null) {
          return _placeholder('카메라 준비 중...');
        }
        // 프리뷰 자체가 셔터. 야외에서 확인 버튼까지 안 내려도 됨.
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapPreview,
          child: AspectRatio(
            aspectRatio: c.value.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(c),
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: _ShutterHint(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder(String msg) => Container(
    height: 200,
    color: AppColors.surface,
    alignment: Alignment.center,
    child: Text(msg, style: const TextStyle(color: AppColors.inkMuted)),
  );

  Widget _errorPlaceholder(String msg) => Container(
    height: 200,
    color: AppColors.surface,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          msg,
          style: const TextStyle(color: AppColors.inkMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (permanentlyDenied)
          OutlinedButton.icon(
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('설정에서 권한 열기'),
            onPressed: () => openAppSettings(),
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('다시 시도'),
            onPressed: onRetry,
          ),
      ],
    ),
  );
}

class _ShutterHint extends StatelessWidget {
  const _ShutterHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '탭하여 촬영',
            style: TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _LocationHint extends StatelessWidget {
  final LocationAccess access;
  final VoidCallback onTap;
  const _LocationHint({required this.access, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (access == LocationAccess.granted) return const SizedBox.shrink();
    final msg = switch (access) {
      LocationAccess.serviceDisabled => '위치 서비스 꺼짐 · 탭하여 설정 열기',
      LocationAccess.permanentlyDenied => '위치 권한 영구 거부 · 탭하여 설정 열기',
      LocationAccess.denied => 'GPS 미기록 · 탭하여 위치 권한 허용',
      LocationAccess.granted => '',
    };
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.surface,
        child: Row(
          children: [
            const Icon(
              Icons.location_off,
              size: 14,
              color: AppColors.inkMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends ConsumerWidget {
  final int nextFrame;
  final VoidCallback onConfirm;

  const _ConfirmBar({required this.nextFrame, required this.onConfirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newShotFormProvider(null));
    final canSave = form.isValid;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: canSave ? onConfirm : null,
          child: Text(
            '확인 · #$nextFrame 저장',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
