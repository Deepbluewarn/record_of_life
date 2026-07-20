import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/location.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/features/settings/providers/settings_provider.dart';
import 'package:record_of_life/shared/widgets/forms/shot_form.dart';

// Sticky Capture Mode: 확인 누르면 저장 + 카운트 +1 + 화면 유지.
// 뒤로가기만 탈출구.
class CaptureModePage extends ConsumerWidget {
  final Roll roll;
  const CaptureModePage({super.key, required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter(rollId: roll.id)));
    final currentRoll = rollState.when(
      data: (s) => s.rolls.isNotEmpty ? s.rolls.first : roll,
      loading: () => roll,
      error: (_, __) => roll,
    );

    final nextFrame = currentRoll.shotsDone + 1;
    final total = currentRoll.totalShots;

    return Scaffold(
      appBar: AppBar(
        title: Text('입력 모드 · $nextFrame / $total'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ShotForm(),
              ),
            ),
            _ConfirmBar(roll: currentRoll, nextFrame: nextFrame),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends ConsumerWidget {
  final Roll roll;
  final int nextFrame;
  const _ConfirmBar({required this.roll, required this.nextFrame});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newShotFormProvider(null));
    final canSave = form.isValid;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: canSave ? () => _save(context, ref) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            '확인 · #$nextFrame 저장',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final form = ref.read(newShotFormProvider(null));
    final pos = await tryGetPosition();
    final shot = form.toShot(rollId: roll.id).copyWith(
      idx: nextFrame,
      gpsLat: pos?.lat,
      gpsLng: pos?.lng,
    );

    await ref.read(shotProvider(roll.id).notifier).addShot(shot);
    ref.read(newShotFormProvider(null).notifier).resetForNextShot();
    HapticFeedback.mediumImpact();

    if (!context.mounted) return;
    // 손잡이에 따라 스낵바를 엄지 사거리(화면 하단 코너)로 몰아줌.
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
}
