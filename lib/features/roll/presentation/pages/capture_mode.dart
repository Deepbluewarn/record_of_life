import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/location.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/forms/shot_form.dart';

// Sticky Capture Mode: 확인 시 저장 + 카운트 +1 + 화면 유지.
// 뒤로가기만 탈출구. 참고 사진은 폼 내 첨부 필드에서 선택적으로 제공.
class CaptureModePage extends ConsumerStatefulWidget {
  final Roll roll;
  const CaptureModePage({super.key, required this.roll});

  @override
  ConsumerState<CaptureModePage> createState() => _CaptureModePageState();
}

class _CaptureModePageState extends ConsumerState<CaptureModePage> {
  LocationAccess _locationAccess = LocationAccess.granted;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    final a = await checkLocationAccess();
    if (mounted) setState(() => _locationAccess = a);
  }

  Future<void> _requestLocation() async {
    final a = await requestLocationAccess();
    if (mounted) setState(() => _locationAccess = a);
  }

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
    final shot = form.toShot(rollId: currentRoll.id).copyWith(
      idx: nextFrame,
      gpsLat: pos?.lat,
      gpsLng: pos?.lng,
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
            const Icon(Icons.location_off, size: 14, color: AppColors.inkMuted),
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
