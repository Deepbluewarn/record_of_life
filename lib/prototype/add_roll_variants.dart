// PROTOTYPE — throwaway. AddRoll의 3가지 대안 레이아웃.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_roll_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/date_picker_field.dart';
import 'package:record_of_life/shared/widgets/dialogs/camera_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/dialogs/film_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/dialogs/lens_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/simple_text_field.dart';

// =============================================================================
// Variant A — 스텝 위저드
// 카메라 → 필름 → 렌즈 → 상세 4단계. 각 단계가 화면을 크게 차지.
// 하단 좌우 '이전/다음', 마지막에 '저장'.
// =============================================================================

class AddRollVariantA extends ConsumerStatefulWidget {
  final Roll? roll;
  const AddRollVariantA({super.key, this.roll});

  @override
  ConsumerState<AddRollVariantA> createState() => _AddRollVariantAState();
}

class _AddRollVariantAState extends ConsumerState<AddRollVariantA> {
  int _step = 0;
  static const _titles = ['카메라', '필름', '렌즈', '상세'];

  void _next() {
    if (_step < _titles.length - 1) setState(() => _step += 1);
  }

  void _prev() {
    if (_step > 0) setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(newRollFormProvider(widget.roll));
    final n = ref.read(newRollFormProvider(widget.roll).notifier);
    final isEdit = widget.roll != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ROL',
        subtitle: isEdit ? '롤 편집' : '새 롤 · ${_step + 1}/${_titles.length}',
      ),
      body: Column(
        children: [
          _Stepper(count: _titles.length, current: _step),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _stepBody(form, n),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _step == 0 ? null : _prev,
                    child: const Text('이전'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _step < _titles.length - 1
                        ? _next
                        : (form.isComplete
                              ? () {
                                  ref
                                      .read(rollProvider(null).notifier)
                                      .addRoll(form.toRoll());
                                  n.reset();
                                  Navigator.pop(context);
                                }
                              : null),
                    child: Text(
                      _step < _titles.length - 1 ? '다음' : '저장',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBody(NewRollFormState form, NewRollFormNotifier n) {
    switch (_step) {
      case 0:
        return _BigTapCard(
          label: '카메라',
          value: form.camera?.title,
          onTap: () => showDialog(
            context: context,
            builder: (_) => CameraSelectionDialog(
              matchFormat: form.film?.format,
              onSelected: (c) {
                n.setCamera(c);
                Navigator.pop(context);
              },
            ),
          ),
        );
      case 1:
        return _BigTapCard(
          label: '필름',
          value: form.film?.name,
          onTap: () => showDialog(
            context: context,
            builder: (_) => FilmSelectionDialog(
              matchFormat: form.camera?.format,
              onSelected: (f) {
                n.setFilm(f);
                Navigator.pop(context);
              },
            ),
          ),
        );
      case 2:
        return Consumer(
          builder: (context, ref, _) {
            final lensState = ref.watch(lensProvider);
            final name = lensState.when(
              data: (data) => form.defaultLensId == null
                  ? null
                  : data.lenses
                        .where((l) => l.id == form.defaultLensId)
                        .map((l) => l.name)
                        .firstOrNull,
              loading: () => null,
              error: (_, __) => null,
            );
            return _BigTapCard(
              label: '기본 렌즈 (선택)',
              value: name,
              onTap: () => showDialog(
                context: context,
                builder: (_) => LensSelectionDialog(
                  onSelected: (l) {
                    n.setDefaultLensId(l.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        );
      case 3:
      default:
        return ListView(
          children: [
            const Text('제목', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SimpleTextFormField(
              initialValue: form.title,
              onChanged: n.setTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '컷 수',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      SimpleTextFormField(
                        initialValue: form.totalShots.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final t = int.tryParse(v);
                          if (t != null) n.setTotalShots(t);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '시작일',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      DatePickerField(
                        initialDate: form.startedAt,
                        onDateChanged: n.setStartedAt,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('메모', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            SimpleTextFormField(
              initialValue: form.memo,
              onChanged: n.setMemo,
            ),
          ],
        );
    }
  }
}

class _Stepper extends StatelessWidget {
  final int count;
  final int current;
  const _Stepper({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(count, (i) {
          final done = i <= current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: done ? AppColors.ink : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BigTapCard extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _BigTapCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.isEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Text(
              empty ? '탭하여 선택' : value!,
              style: TextStyle(
                fontSize: empty ? 22 : 28,
                fontWeight: FontWeight.w800,
                color: empty ? AppColors.inkMuted : AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Icon(
              empty ? Icons.touch_app_outlined : Icons.check_circle_outline,
              color: empty ? AppColors.inkMuted : AppColors.ink,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Variant B — 상단 큰 pictogram + 하단 컴팩트 폼
// 카메라·필름을 큰 아이콘 카드로 상단에 나란히, 채워지면 하이라이트.
// 나머지는 하단 압축.
// =============================================================================

class AddRollVariantB extends ConsumerWidget {
  final Roll? roll;
  const AddRollVariantB({super.key, this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newRollFormProvider(roll));
    final n = ref.read(newRollFormProvider(roll).notifier);
    final isEdit = roll != null;

    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: isEdit ? '롤 편집' : '새 롤'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _IconCard(
                    icon: Icons.photo_camera_outlined,
                    label: '카메라',
                    value: form.camera?.title,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CameraSelectionDialog(
                        matchFormat: form.film?.format,
                        onSelected: (c) {
                          n.setCamera(c);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _IconCard(
                    icon: Icons.filter_center_focus,
                    label: '필름',
                    value: form.film?.name,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => FilmSelectionDialog(
                        matchFormat: form.camera?.format,
                        onSelected: (f) {
                          n.setFilm(f);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _CompactRow(
              label: '기본 렌즈',
              child: Consumer(
                builder: (context, ref, _) {
                  final lensState = ref.watch(lensProvider);
                  final name = lensState.when(
                    data: (data) => form.defaultLensId == null
                        ? '선택'
                        : data.lenses
                                  .where((l) => l.id == form.defaultLensId)
                                  .map((l) => l.name)
                                  .firstOrNull ??
                              '선택',
                    loading: () => '선택',
                    error: (_, __) => '선택',
                  );
                  return TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => LensSelectionDialog(
                        onSelected: (l) {
                          n.setDefaultLensId(l.id);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    child: Text(name),
                  );
                },
              ),
            ),
            const Divider(),
            _CompactRow(
              label: '제목',
              child: SimpleTextFormField(
                initialValue: form.title,
                onChanged: n.setTitle,
              ),
            ),
            _CompactRow(
              label: '컷 수',
              child: SimpleTextFormField(
                initialValue: form.totalShots.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final t = int.tryParse(v);
                  if (t != null) n.setTotalShots(t);
                },
              ),
            ),
            _CompactRow(
              label: '시작일',
              child: DatePickerField(
                initialDate: form.startedAt,
                onDateChanged: n.setStartedAt,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: form.isComplete
                    ? () {
                        ref
                            .read(rollProvider(null).notifier)
                            .addRoll(form.toRoll());
                        n.reset();
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('롤 저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _IconCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null && value!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: filled ? AppColors.ink : Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: filled ? Colors.white : AppColors.inkMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: filled ? Colors.white70 : AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              filled ? value! : '탭하여 선택',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _CompactRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// =============================================================================
// Variant C — 인라인 확장 accordion
// 한 번에 하나의 섹션만 확장. 다른 것들은 요약 한 줄.
// =============================================================================

class AddRollVariantC extends ConsumerStatefulWidget {
  final Roll? roll;
  const AddRollVariantC({super.key, this.roll});

  @override
  ConsumerState<AddRollVariantC> createState() => _AddRollVariantCState();
}

class _AddRollVariantCState extends ConsumerState<AddRollVariantC> {
  int _expanded = 0;

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(newRollFormProvider(widget.roll));
    final n = ref.read(newRollFormProvider(widget.roll).notifier);
    final isEdit = widget.roll != null;

    final sections = <_Section>[
      _Section(
        label: '카메라',
        summary: form.camera?.title ?? '미선택',
        body: OutlinedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => CameraSelectionDialog(
              matchFormat: form.film?.format,
              onSelected: (c) {
                n.setCamera(c);
                Navigator.pop(context);
                setState(() => _expanded = 1);
              },
            ),
          ),
          child: const Text('카메라 선택'),
        ),
      ),
      _Section(
        label: '필름',
        summary: form.film?.name ?? '미선택',
        body: OutlinedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => FilmSelectionDialog(
              matchFormat: form.camera?.format,
              onSelected: (f) {
                n.setFilm(f);
                Navigator.pop(context);
                setState(() => _expanded = 2);
              },
            ),
          ),
          child: const Text('필름 선택'),
        ),
      ),
      _Section(
        label: '제목',
        summary: (form.title == null || form.title!.isEmpty)
            ? '미입력'
            : form.title!,
        body: SimpleTextFormField(
          initialValue: form.title,
          onChanged: n.setTitle,
        ),
      ),
      _Section(
        label: '컷 수',
        summary: '${form.totalShots}',
        body: SimpleTextFormField(
          initialValue: form.totalShots.toString(),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final t = int.tryParse(v);
            if (t != null) n.setTotalShots(t);
          },
        ),
      ),
      _Section(
        label: '시작일',
        summary: form.startedAt == null
            ? '미정'
            : '${form.startedAt!.year}. '
                  '${form.startedAt!.month.toString().padLeft(2, '0')}. '
                  '${form.startedAt!.day.toString().padLeft(2, '0')}',
        body: DatePickerField(
          initialDate: form.startedAt,
          onDateChanged: n.setStartedAt,
        ),
      ),
      _Section(
        label: '메모',
        summary: (form.memo == null || form.memo!.isEmpty) ? '없음' : form.memo!,
        body: SimpleTextFormField(
          initialValue: form.memo,
          onChanged: n.setMemo,
        ),
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: isEdit ? '롤 편집' : '새 롤'),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = sections[i];
                final open = _expanded == i;
                return _AccordionTile(
                  label: s.label,
                  summary: s.summary,
                  open: open,
                  body: s.body,
                  onTap: () =>
                      setState(() => _expanded = open ? -1 : i),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: form.isComplete
                    ? () {
                        ref
                            .read(rollProvider(null).notifier)
                            .addRoll(form.toRoll());
                        n.reset();
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('롤 저장'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String label;
  final String summary;
  final Widget body;
  _Section({required this.label, required this.summary, required this.body});
}

class _AccordionTile extends StatelessWidget {
  final String label;
  final String summary;
  final bool open;
  final Widget body;
  final VoidCallback onTap;
  const _AccordionTile({
    required this.label,
    required this.summary,
    required this.open,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      summary,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: summary == '미선택' ||
                                summary == '미입력' ||
                                summary == '없음' ||
                                summary == '미정'
                            ? AppColors.inkMuted
                            : AppColors.ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    open ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.inkMuted,
                  ),
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

// 로컬 상태 필드가 없는 편집 시 status는 A에서만 필요. 프로토타입 스코프에선 생략.
extension _RollStatusUnused on RollStatus {}
