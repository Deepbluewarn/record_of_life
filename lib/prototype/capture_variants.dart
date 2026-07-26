// PROTOTYPE — throwaway. CaptureMode의 3가지 대안 레이아웃.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/data/location.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/wheel_selector.dart';

const List<int?> _commonIsos = [
  null, 25, 50, 100, 125, 160, 200, 250, 320, 400, 500, 640,
  800, 1000, 1250, 1600, 2000, 2500, 3200, 6400,
];

// 프로토타입 저장 로직 (실 페이지와 동일 흐름, 최소).
Future<void> _saveShot(BuildContext context, WidgetRef ref, Roll roll,
    int nextFrame) async {
  final form = ref.read(newShotFormProvider(null));
  if (!form.isValid) return;
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
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('#$nextFrame 저장됨')));
}

Roll _currentRoll(WidgetRef ref, Roll base) {
  final s = ref.watch(rollProvider(RollFilter(rollId: base.id)));
  return s.when(
    data: (v) => v.rolls.isNotEmpty ? v.rolls.first : base,
    loading: () => base,
    error: (_, __) => base,
  );
}

// =============================================================================
// Variant A — 필수 3개(조리개/셔터/노출) 상단 크게 + 나머지 accordion
// =============================================================================

class CaptureVariantA extends ConsumerStatefulWidget {
  final Roll roll;
  const CaptureVariantA({super.key, required this.roll});

  @override
  ConsumerState<CaptureVariantA> createState() => _CaptureVariantAState();
}

class _CaptureVariantAState extends ConsumerState<CaptureVariantA> {
  bool _extraOpen = false;

  @override
  Widget build(BuildContext context) {
    final roll = _currentRoll(ref, widget.roll);
    final next = roll.shotsDone + 1;
    final form = ref.watch(newShotFormProvider(null));
    final n = ref.read(newShotFormProvider(null).notifier);

    return Scaffold(
      appBar: AppBar(title: Text('입력 · $next/${roll.totalShots}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    WheelSelector<Aperture>(
                      title: '조리개',
                      items: Aperture.values,
                      selectedItem: form.aperture,
                      labelBuilder: (a) => 'f/${a.value}',
                      onSelected: n.setAperture,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    WheelSelector<ShutterSpeed>(
                      title: '셔터',
                      items: ShutterSpeed.values,
                      selectedItem: form.shutterSpeed,
                      labelBuilder: (s) => s.label,
                      onSelected: n.setShutterSpeed,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    WheelSelector<ExposureComp>(
                      title: '노출',
                      items: ExposureComp.values,
                      selectedItem: form.exposureComp,
                      labelBuilder: (e) => e.label,
                      onSelected: n.setExposureComp,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Fold(
                      open: _extraOpen,
                      onToggle: () =>
                          setState(() => _extraOpen = !_extraOpen),
                      title: '추가 세팅 (ISO · 렌즈 · 평점 · 메모)',
                      body: Column(
                        children: [
                          WheelSelector<int?>(
                            title: 'ISO',
                            items: _commonIsos,
                            selectedItem: form.iso,
                            labelBuilder: (v) =>
                                v == null ? '상속' : v.toString(),
                            onSelected: n.setIso,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            decoration: const InputDecoration(
                              hintText: '메모',
                            ),
                            onChanged: n.setNote,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(
              label: '확인 · #$next 저장',
              enabled: form.isValid,
              onTap: () => _saveShot(context, ref, roll, next),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fold extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final String title;
  final Widget body;
  const _Fold({
    required this.open,
    required this.onToggle,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Icon(open ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: body,
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Variant B — 상단 큰 프레임 카운터(원형) + 그 아래 wheel 4개 세로 스택
// =============================================================================

class CaptureVariantB extends ConsumerWidget {
  final Roll roll;
  const CaptureVariantB({super.key, required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = _currentRoll(ref, roll);
    final next = r.shotsDone + 1;
    final form = ref.watch(newShotFormProvider(null));
    final n = ref.read(newShotFormProvider(null).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('입력 모드')),
      body: SafeArea(
        child: Column(
          children: [
            _FrameHeader(current: next, total: r.totalShots),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    WheelSelector<Aperture>(
                      title: '조리개',
                      items: Aperture.values,
                      selectedItem: form.aperture,
                      labelBuilder: (a) => 'f/${a.value}',
                      onSelected: n.setAperture,
                    ),
                    WheelSelector<ShutterSpeed>(
                      title: '셔터',
                      items: ShutterSpeed.values,
                      selectedItem: form.shutterSpeed,
                      labelBuilder: (s) => s.label,
                      onSelected: n.setShutterSpeed,
                    ),
                    WheelSelector<ExposureComp>(
                      title: '노출',
                      items: ExposureComp.values,
                      selectedItem: form.exposureComp,
                      labelBuilder: (e) => e.label,
                      onSelected: n.setExposureComp,
                    ),
                    WheelSelector<int?>(
                      title: 'ISO',
                      items: _commonIsos,
                      selectedItem: form.iso,
                      labelBuilder: (v) =>
                          v == null ? '상속' : v.toString(),
                      onSelected: n.setIso,
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(
              label: '#$next 저장',
              enabled: form.isValid,
              onTap: () => _saveShot(context, ref, r, next),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameHeader extends StatelessWidget {
  final int current;
  final int total;
  const _FrameHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.ink, width: 3),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$current',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '/ $total',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Variant C — 2x2 그리드 대시보드 (조리개·셔터·노출·ISO 각 셀 wheel)
// 각 셀 탭 = 그 wheel만 확장, 나머지 축소 요약. 렌즈·메모 하단.
// =============================================================================

class CaptureVariantC extends ConsumerStatefulWidget {
  final Roll roll;
  const CaptureVariantC({super.key, required this.roll});

  @override
  ConsumerState<CaptureVariantC> createState() => _CaptureVariantCState();
}

class _CaptureVariantCState extends ConsumerState<CaptureVariantC> {
  int _focused = -1; // -1 = 모두 요약, 0..3 = 확장

  @override
  Widget build(BuildContext context) {
    final r = _currentRoll(ref, widget.roll);
    final next = r.shotsDone + 1;
    final form = ref.watch(newShotFormProvider(null));
    final n = ref.read(newShotFormProvider(null).notifier);

    Widget cell(int idx, String title, String summary, Widget wheel) {
      final open = _focused == idx;
      return GestureDetector(
        onTap: () => setState(() => _focused = open ? -1 : idx),
        child: Container(
          decoration: BoxDecoration(
            color: open ? AppColors.surface : AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: open
              ? wheel
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    final cells = [
      cell(
        0,
        '조리개',
        form.aperture == null ? '-' : 'f/${form.aperture!.value}',
        WheelSelector<Aperture>(
          title: '조리개',
          items: Aperture.values,
          selectedItem: form.aperture,
          labelBuilder: (a) => 'f/${a.value}',
          onSelected: n.setAperture,
        ),
      ),
      cell(
        1,
        '셔터',
        form.shutterSpeed?.label ?? '-',
        WheelSelector<ShutterSpeed>(
          title: '셔터',
          items: ShutterSpeed.values,
          selectedItem: form.shutterSpeed,
          labelBuilder: (s) => s.label,
          onSelected: n.setShutterSpeed,
        ),
      ),
      cell(
        2,
        '노출',
        form.exposureComp?.label ?? '0',
        WheelSelector<ExposureComp>(
          title: '노출',
          items: ExposureComp.values,
          selectedItem: form.exposureComp,
          labelBuilder: (e) => e.label,
          onSelected: n.setExposureComp,
        ),
      ),
      cell(
        3,
        'ISO',
        form.iso?.toString() ?? '상속',
        WheelSelector<int?>(
          title: 'ISO',
          items: _commonIsos,
          selectedItem: form.iso,
          labelBuilder: (v) => v == null ? '상속' : v.toString(),
          onSelected: n.setIso,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('입력 모드 · $next/${r.totalShots}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.4,
                  children: cells,
                ),
              ),
            ),
            _SaveBar(
              label: '#$next 저장',
              enabled: form.isValid,
              onTap: () => _saveShot(context, ref, r, next),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _SaveBar({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          child: Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
