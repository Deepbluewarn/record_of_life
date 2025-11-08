import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_roll_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/camera_selection_dialog.dart';

class AddRollPage extends ConsumerWidget {
  const AddRollPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollFormState = ref.watch(newRollFormProvider);

    return Scaffold(
      appBar: CustomAppBar(title: '롤 | ROL', subtitle: '새 롤 추가'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Text(
                '새 롤을 추가합니다',
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
                            .read(newRollFormProvider.notifier)
                            .setCamera(camera);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),

              // 필름 선택
              _buildSelectionCard(
                label: '필름',
                value: rollFormState.film?.name,
                onTap: () {
                  // FilmSelectionDialog
                },
              ),
              SizedBox(height: 16),

              // 렌즈 선택
              // _buildSelectionCard(
              //   label: '렌즈',
              //   value: rollFormState.lens?.name,
              //   onTap: () {
              //     // LensSelectionDialog
              //   },
              // ),
              SizedBox(height: 32),

              // 제목 입력
              Text(
                '롤 제목 (선택)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) {
                  ref.read(newRollFormProvider.notifier).setTitle(value);
                },
                decoration: InputDecoration(
                  hintText: '예: 여름 휴가',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: rollFormState.isComplete
                      ? () {
                          ref
                              .read(rollProvider.notifier)
                              .addRoll(rollFormState.toRoll());
                          ref.read(newRollFormProvider.notifier).reset();
                          Navigator.pop(context);
                        }
                      : null,
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
