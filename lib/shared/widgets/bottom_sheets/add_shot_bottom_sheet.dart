import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/widgets/horizontal_selector.dart';

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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '새 사진 추가',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.all(14),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
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
                // 조리개
                HorizontalSelector<Aperture>(
                  title: '조리개 (f/)',
                  items: Aperture.values,
                  selectedItem: shotFormProvider.aperture,
                  labelBuilder: (aperture) => 'f/${aperture.value}',
                  onSelected: (aperture) {
                    ref
                        .read(newShotFormProvider.notifier)
                        .setAperture(aperture);
                  },
                ),
                SizedBox(height: 16),

                // 셔터 스피드
                HorizontalSelector<ShutterSpeed>(
                  title: '셔터 스피드',
                  items: ShutterSpeed.values,
                  selectedItem: shotFormProvider.shutterSpeed,
                  labelBuilder: (shutterSpeed) => shutterSpeed.label,
                  onSelected: (shutterSpeed) {
                    ref
                        .read(newShotFormProvider.notifier)
                        .setShutterSpeed(shutterSpeed);
                  },
                ),
                SizedBox(height: 16),

                // 노출 보정
                HorizontalSelector<ExposureComp>(
                  title: '노출 보정 (E/V)',
                  items: ExposureComp.values,
                  selectedItem: shotFormProvider.exposureComp,
                  labelBuilder: (exposureComp) => exposureComp.label,
                  onSelected: (exposureComp) {
                    ref
                        .read(newShotFormProvider.notifier)
                        .setExposureComp(exposureComp);
                  },
                ),
                SizedBox(height: 16),

                // 평점
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('평점', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starRating = index + 1;
                        final isSelected =
                            shotFormProvider.rating != null &&
                            starRating <= shotFormProvider.rating!;
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(newShotFormProvider.notifier)
                                .setRating(starRating);
                            HapticFeedback.selectionClick();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
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
