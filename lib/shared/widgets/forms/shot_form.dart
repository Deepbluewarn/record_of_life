import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/shared/widgets/dialogs/lens_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/horizontal_selector.dart';
import 'package:record_of_life/shared/widgets/selection_card.dart';

class ShotForm extends ConsumerWidget {
  final Shot? shot;
  const ShotForm({super.key, this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotFormProvider = ref.watch(newShotFormProvider(shot));
    final lensState = ref.watch(lensProvider);

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
        // 렌즈 선택
        SelectionCard(
          label: '렌즈',
          value: lensState.when(
            data: (data) {
              print('shotFormProvider.lensId: ${shotFormProvider.lensId}');
              print(data.lenses);
              if (shotFormProvider.lensId == null || data.lenses.isEmpty) {
                return null;
              }
              final lens = data.lenses.firstWhere(
                (l) => l.id == shotFormProvider.lensId,
                orElse: () => data.lenses.first,
              );
              return lens.name;
            },
            loading: () => null,
            error: (_, __) => null,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => LensSelectionDialog(
                onSelected: (lens) {
                  ref
                      .read(newShotFormProvider(shot).notifier)
                      .setLensId(lens.id);
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
        SizedBox(height: 24),
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

        // 사진
        Text('사진', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            // 썸네일 표시
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: shotFormProvider.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(shotFormProvider.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.image, size: 30, color: Colors.grey[400]),
            ),
            SizedBox(width: 12),
            // 사진 추가 버튼
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('사진 선택'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text('갤러리에서 선택'),
                            onTap: () async {
                              Navigator.pop(context);
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                // 앱 전용 디렉터리에 저장
                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                final fileName =
                                    '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
                                final savedPath =
                                    '${appDir.path}/images/$fileName';
                                final savedFile = File(savedPath);
                                await savedFile.parent.create(recursive: true);
                                await image.saveTo(savedPath);
                                ref
                                    .read(newShotFormProvider(shot).notifier)
                                    .setImagePath(savedPath);
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.camera_alt),
                            title: Text('카메라로 촬영'),
                            onTap: () async {
                              Navigator.pop(context);
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (image != null) {
                                // 앱 전용 디렉터리에 저장
                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                final fileName =
                                    '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
                                final savedPath =
                                    '${appDir.path}/images/$fileName';
                                final savedFile = File(savedPath);
                                await savedFile.parent.create(recursive: true);
                                await image.saveTo(savedPath);
                                ref
                                    .read(newShotFormProvider(shot).notifier)
                                    .setImagePath(savedPath);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add_photo_alternate),
                label: Text('사진 추가'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ],
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
