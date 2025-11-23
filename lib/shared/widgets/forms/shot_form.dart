import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/shared/widgets/horizontal_selector.dart';

class ShotForm extends ConsumerWidget {
  final Shot? shot;
  const ShotForm({super.key, this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotFormProvider = ref.watch(newShotFormProvider(shot));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 선택
        Text('촬영 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: shotFormProvider.date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              ref.read(newShotFormProvider(shot).notifier).setDate(picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                SizedBox(width: 10),
                Text(
                  shotFormProvider.date != null
                      ? '${shotFormProvider.date!.year}. ${shotFormProvider.date!.month.toString().padLeft(2, '0')}. ${shotFormProvider.date!.day.toString().padLeft(2, '0')}'
                      : '날짜 선택',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),

        // 조리개
        HorizontalSelector<Aperture>(
          title: '조리개 (f/)',
          items: Aperture.values,
          selectedItem: shotFormProvider.aperture,
          labelBuilder: (aperture) => 'f/${aperture.value}',
          onSelected: (aperture) {
            ref.read(newShotFormProvider(shot).notifier).setAperture(aperture);
          },
        ),
        SizedBox(height: 24),

        // 셔터 스피드
        HorizontalSelector<ShutterSpeed>(
          title: '셔터 스피드',
          items: ShutterSpeed.values,
          selectedItem: shotFormProvider.shutterSpeed,
          labelBuilder: (shutterSpeed) => shutterSpeed.label,
          onSelected: (shutterSpeed) {
            ref
                .read(newShotFormProvider(shot).notifier)
                .setShutterSpeed(shutterSpeed);
          },
        ),
        SizedBox(height: 24),

        // 노출 보정
        HorizontalSelector<ExposureComp>(
          title: '노출 보정 (E/V)',
          items: ExposureComp.values,
          selectedItem: shotFormProvider.exposureComp,
          labelBuilder: (exposureComp) => exposureComp.label,
          onSelected: (exposureComp) {
            ref
                .read(newShotFormProvider(shot).notifier)
                .setExposureComp(exposureComp);
          },
        ),
        SizedBox(height: 24),

        // 평점
        Text('평점', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starRating = index + 1;
              final isSelected =
                  shotFormProvider.rating != null &&
                  starRating <= shotFormProvider.rating!;
              return GestureDetector(
                onTap: () {
                  ref
                      .read(newShotFormProvider(shot).notifier)
                      .setRating(starRating);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? Colors.amber : Colors.grey[400],
                    size: 36,
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 24),

        // 메모
        Text('메모', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          onChanged: (value) {
            ref.read(newShotFormProvider(shot).notifier).setNote(value);
          },
          decoration: InputDecoration(
            hintText: '사진에 대한 메모를 남겨주세요',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          maxLines: 3,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
