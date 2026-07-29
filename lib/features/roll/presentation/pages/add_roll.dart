import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_roll_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/date_picker_field.dart';
import 'package:record_of_life/shared/widgets/dialogs/camera_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/dialogs/film_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/dialogs/lens_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/simple_text_field.dart';

class AddRollPage extends ConsumerStatefulWidget {
  final Roll? roll;
  const AddRollPage({super.key, this.roll});

  @override
  ConsumerState<AddRollPage> createState() => _AddRollPageState();
}

class _AddRollPageState extends ConsumerState<AddRollPage> {
  @override
  void initState() {
    super.initState();
    if (widget.roll == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromLast());
    }
  }

  Future<void> _prefillFromLast() async {
    final rolls = await ref.read(rollRepositoryProvider).getAllRolls();
    if (rolls.isEmpty || !mounted) return;
    rolls.sort((a, b) {
      final aT = a.startedAt ?? DateTime(0);
      final bT = b.startedAt ?? DateTime(0);
      return bT.compareTo(aT);
    });
    final last = rolls.first;
    final n = ref.read(newRollFormProvider(widget.roll).notifier);
    if (last.camera != null) n.setCamera(last.camera!);
    if (last.film != null) n.setFilm(last.film!);
    if (last.defaultLensId != null) n.setDefaultLensId(last.defaultLensId);
  }

  @override
  Widget build(BuildContext context) {
    final roll = widget.roll;
    final form = ref.watch(newRollFormProvider(roll));
    final n = ref.read(newRollFormProvider(roll).notifier);
    final isEditMode = roll != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ROL',
        subtitle: isEditMode ? '롤 편집' : '새 롤 추가',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 카메라·필름 큰 아이콘 카드
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
                        onSelected: (film) {
                          n.setFilm(film);
                          // 필름의 기본 컷 수가 있으면 롤 컷 수도 자동 세팅.
                          if (film.defaultShots != null) {
                            n.setTotalShots(film.defaultShots!);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 기본 렌즈 (선택)
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
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
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
                key: ValueKey('totalShots-${form.totalShots}'),
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
            _CompactRow(
              label: '메모',
              child: SimpleTextFormField(
                initialValue: form.memo,
                onChanged: n.setMemo,
              ),
            ),

            // 상태·현상소는 편집 폼에서 조작하지 않음.
            // 상태 전이는 롤 상세의 정방향 액션으로만.

            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: form.isComplete
                    ? () {
                        if (isEditMode) {
                          ref
                              .read(rollProvider(null).notifier)
                              .updateRoll(form.toRoll(rollId: roll.id));
                        } else {
                          ref
                              .read(rollProvider(null).notifier)
                              .addRoll(form.toRoll());
                        }
                        n.reset();
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text(
                  '롤 저장',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 카메라·필름 큰 아이콘 카드. 채워지면 검정 하이라이트.
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
