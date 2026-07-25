import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ShotForm(),
              ),
            ),
            _ConfirmBar(
              roll: currentRoll,
              nextFrame: nextFrame,
              controller: _controller,
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

  const _PreviewArea({
    required this.controller,
    required this.initFuture,
    required this.initError,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _placeholder('웹에서는 실시간 카메라 미지원');
    }
    if (initError != null) return _placeholder(initError!);
    return FutureBuilder<void>(
      future: initFuture,
      builder: (context, snap) {
        final c = controller;
        if (snap.connectionState != ConnectionState.done || c == null) {
          return _placeholder('카메라 준비 중...');
        }
        return AspectRatio(
          aspectRatio: c.value.aspectRatio,
          child: CameraPreview(c),
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
}

class _ConfirmBar extends ConsumerWidget {
  final Roll roll;
  final int nextFrame;
  final CameraController? controller;

  const _ConfirmBar({
    required this.roll,
    required this.nextFrame,
    required this.controller,
  });

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
          onPressed: canSave ? () => _save(context, ref) : null,
          child: Text(
            '확인 · #$nextFrame 저장',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final form = ref.read(newShotFormProvider(null));
    final pos = await tryGetPosition();
    final imagePath = await _capture();

    final shot = form
        .toShot(rollId: roll.id)
        .copyWith(
          idx: nextFrame,
          gpsLat: pos?.lat,
          gpsLng: pos?.lng,
          imagePath: imagePath ?? form.imagePath,
        );

    await ref.read(shotProvider(roll.id).notifier).addShot(shot);
    ref.read(newShotFormProvider(null).notifier).resetForNextShot();
    HapticFeedback.mediumImpact();

    if (!context.mounted) return;
    final handedness = ref.read(settingsProvider).value?.handedness;
    final width = MediaQuery.of(context).size.width;
    final EdgeInsets margin = handedness == Handedness.left
        ? EdgeInsets.only(left: 16, right: width * 0.35, bottom: 16)
        : EdgeInsets.only(left: width * 0.35, right: 16, bottom: 16);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('#$nextFrame 저장됨'),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          margin: margin,
        ),
      );
  }

  Future<String?> _capture() async {
    final c = controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) {
      return null;
    }
    try {
      final xfile = await c.takePicture();
      // 앱 문서 디렉터리로 이동 저장(임시 캐시는 시스템이 지울 수 있음).
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
}
