import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';

class AddShotBottomSheet extends ConsumerWidget {
  final String rollId;

  const AddShotBottomSheet({super.key, required this.rollId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotFormProvider = ref.watch(newShotFormProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  '새 사진 추가',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 20),

                // 날짜 선택
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: shotFormProvider.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      ref.read(newShotFormProvider.notifier).setDate(picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '촬영 날짜',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      shotFormProvider.date != null
                          ? '${shotFormProvider.date!.year}-${shotFormProvider.date!.month.toString().padLeft(2, '0')}-${shotFormProvider.date!.day.toString().padLeft(2, '0')}'
                          : '날짜를 선택하세요',
                      style: TextStyle(
                        color: shotFormProvider.date != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // 조리개 값
                TextField(
                  onChanged: (value) {
                    final aperture = double.tryParse(value);
                    ref
                        .read(newShotFormProvider.notifier)
                        .setAperture(aperture);
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '조리개 (f/)',
                    hintText: '예: 2.8',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 셔터 스피드
                TextField(
                  onChanged: (value) {
                    ref
                        .read(newShotFormProvider.notifier)
                        .setShutterSpeed(value);
                  },
                  decoration: InputDecoration(
                    labelText: '셔터 스피드',
                    hintText: '예: 1/125',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 초점 거리
                TextField(
                  onChanged: (value) {
                    ref
                        .read(newShotFormProvider.notifier)
                        .setFocusDistance(value);
                  },
                  decoration: InputDecoration(
                    labelText: '초점 거리',
                    hintText: '예: 3m',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 노출 보정
                TextField(
                  onChanged: (value) {
                    final exposureComp = double.tryParse(value);
                    ref
                        .read(newShotFormProvider.notifier)
                        .setExposureComp(exposureComp);
                  },
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: '노출 보정',
                    hintText: '예: +0.3',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 평점
                TextField(
                  onChanged: (value) {
                    final rating = int.tryParse(value);
                    ref.read(newShotFormProvider.notifier).setRating(rating);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '평점 (1-5)',
                    hintText: '1~5',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 메모
                TextField(
                  onChanged: (value) {
                    ref.read(newShotFormProvider.notifier).setNote(value);
                  },
                  decoration: InputDecoration(
                    labelText: '메모',
                    hintText: '컷에 대한 메모',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final shot = shotFormProvider.toShot(rollId: rollId);
                      ref.read(shotProvider(rollId).notifier).addShot(shot);
                      ref.read(newShotFormProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                    child: Text('추가'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
