import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_roll_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/dialogs/camera_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/dialogs/film_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/selectable_button.dart';
import 'package:record_of_life/shared/widgets/simple_text_field.dart';
import 'package:record_of_life/shared/widgets/date_picker_field.dart';

class AddRollPage extends ConsumerWidget {
  final Roll? roll;

  const AddRollPage({super.key, this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollFormState = ref.watch(newRollFormProvider(roll));
    final isEditMode = roll != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: '롤 | ROL',
        subtitle: isEditMode ? '롤 편집' : '새 롤 추가',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditMode ? roll!.id : ''),
              // 헤더
              Text(
                isEditMode ? '롤 내용을 수정합니다.' : '새 롤을 추가합니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '카메라, 필름, 렌즈를 선택하고 롤을 저장하세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),

              // 필름 선택
              _buildSelectionCard(
                label: '필름',
                value: rollFormState.film?.name,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => FilmSelectionDialog(
                      onSelected: (film) {
                        ref
                            .read(newRollFormProvider(roll).notifier)
                            .setFilm(film);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              // 카메라 선택
              _buildSelectionCard(
                label: '카메라',
                value: rollFormState.camera?.title,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CameraSelectionDialog(
                      onSelected: (camera) {
                        ref
                            .read(newRollFormProvider(roll).notifier)
                            .setCamera(camera);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '제목',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SimpleTextFormField(
                          initialValue: rollFormState.title,
                          onChanged: (value) {
                            ref
                                .read(newRollFormProvider(roll).notifier)
                                .setTitle(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '컷 수',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SimpleTextFormField(
                          initialValue: rollFormState.totalShots.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final totalShots = int.tryParse(value);
                            if (totalShots != null) {
                              ref
                                  .read(newRollFormProvider(roll).notifier)
                                  .setTotalShots(totalShots);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시작일',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DatePickerField(
                          initialDate: rollFormState.startedAt,
                          onDateChanged: (date) {
                            ref
                                .read(newRollFormProvider(roll).notifier)
                                .setStartedAt(date);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '메모',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SimpleTextFormField(
                          initialValue: rollFormState.memo,
                          onChanged: (value) {
                            ref
                                .read(newRollFormProvider(roll).notifier)
                                .setMemo(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 제목 입력
              SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SelectableButton(
                    label: RollStatus.planning.displayName(context),
                    selected: rollFormState.status == RollStatus.planning,
                    onTap: () {
                      ref
                          .read(newRollFormProvider(roll).notifier)
                          .setStatus(RollStatus.planning);
                    },
                  ),
                  SelectableButton(
                    label: RollStatus.inProgress.displayName(context),
                    selected: rollFormState.status == RollStatus.inProgress,
                    onTap: () {
                      ref
                          .read(newRollFormProvider(roll).notifier)
                          .setStatus(RollStatus.inProgress);
                    },
                  ),
                  SelectableButton(
                    label: RollStatus.completed.displayName(context),
                    selected: rollFormState.status == RollStatus.completed,
                    onTap: () {
                      ref
                          .read(newRollFormProvider(roll).notifier)
                          .setStatus(RollStatus.completed);
                    },
                  ),
                  SelectableButton(
                    label: RollStatus.archived.displayName(context),
                    selected: rollFormState.status == RollStatus.archived,
                    onTap: () {
                      ref
                          .read(newRollFormProvider(roll).notifier)
                          .setStatus(RollStatus.archived);
                    },
                  ),
                ],
              ),
              SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: rollFormState.isComplete
                      ? () {
                          isEditMode
                              ? ref
                                    .read(rollProvider.notifier)
                                    .updateRoll(
                                      rollFormState.toRoll(rollId: roll!.id),
                                    )
                              : ref
                                    .read(rollProvider.notifier)
                                    .addRoll(rollFormState.toRoll());

                          ref.read(newRollFormProvider(roll).notifier).reset();
                          Navigator.pop(context);
                        }
                      : () {
                          // print(rollFormState.title);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: rollFormState.isComplete
                        ? Colors.black
                        : Colors.grey[300],
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    '롤 저장',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value ?? '선택하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value != null ? Colors.black : Colors.grey[400],
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
