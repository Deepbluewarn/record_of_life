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
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/dialogs/lens_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/grid_selector.dart';
import 'package:record_of_life/shared/widgets/selection_card.dart';
import 'package:record_of_life/shared/widgets/wheel_selector.dart';

// 야외 촬영에서 흔히 조정하는 ISO 후보. 첫 항목 null = '필름 ISO 상속'.
const List<int?> _commonIsos = [
  null, 25, 50, 100, 125, 160, 200, 250, 320, 400, 500, 640,
  800, 1000, 1250, 1600, 2000, 2500, 3200, 6400,
];

class ShotForm extends ConsumerWidget {
  final Shot? shot;
  const ShotForm({super.key, this.shot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(newShotFormProvider(shot));
    final lensState = ref.watch(lensProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('촬영 날짜'),
        _DateField(
          date: form.date,
          onPick: (d) => ref.read(newShotFormProvider(shot).notifier).setDate(d),
        ),
        const SizedBox(height: AppSpacing.xl),

        _Label('렌즈'),
        SelectionCard(
          label: '렌즈',
          value: lensState.when(
            data: (data) {
              if (form.lensId == null || data.lenses.isEmpty) return null;
              final lens = data.lenses.firstWhere(
                (l) => l.id == form.lensId,
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
              builder: (_) => LensSelectionDialog(
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
        const SizedBox(height: AppSpacing.xl),

        WheelSelector<Aperture>(
          title: '조리개 (f/)',
          items: Aperture.values,
          selectedItem: form.aperture,
          labelBuilder: (a) => 'f/${a.value}',
          onSelected: (a) =>
              ref.read(newShotFormProvider(shot).notifier).setAperture(a),
        ),
        const SizedBox(height: AppSpacing.xl),

        WheelSelector<ShutterSpeed>(
          title: '셔터 스피드',
          items: ShutterSpeed.values,
          selectedItem: form.shutterSpeed,
          labelBuilder: (s) => s.label,
          onSelected: (s) =>
              ref.read(newShotFormProvider(shot).notifier).setShutterSpeed(s),
        ),
        const SizedBox(height: AppSpacing.xl),

        GridSelector<ExposureComp>(
          title: '노출 보정 (E/V)',
          items: ExposureComp.values,
          selectedItem: form.exposureComp,
          labelBuilder: (e) => e.label,
          columns: 4,
          cellHeight: 52,
          onSelected: (e) =>
              ref.read(newShotFormProvider(shot).notifier).setExposureComp(e),
        ),
        const SizedBox(height: AppSpacing.xl),

        WheelSelector<int?>(
          title: 'ISO (push/pull, 미지정 = 필름 값 상속)',
          items: _commonIsos,
          selectedItem: form.iso,
          labelBuilder: (v) => v == null ? '상속' : v.toString(),
          onSelected: (v) =>
              ref.read(newShotFormProvider(shot).notifier).setIso(v),
        ),
        const SizedBox(height: AppSpacing.xl),
        _MiniNumberField(
          label: '초점거리 (mm)',
          initial: form.focalLength?.toString(),
          hint: '렌즈 값 상속',
          onChanged: (v) => ref
              .read(newShotFormProvider(shot).notifier)
              .setFocalLength(int.tryParse(v)),
        ),
        const SizedBox(height: AppSpacing.xl),

        _Label('평점'),
        _RatingRow(
          rating: form.rating,
          onSelect: (r) =>
              ref.read(newShotFormProvider(shot).notifier).setRating(r),
        ),
        const SizedBox(height: AppSpacing.xl),

        _Label('참고 사진 (선택)'),
        _PhotoPicker(
          imagePath: form.imagePath,
          onPicked: (p) =>
              ref.read(newShotFormProvider(shot).notifier).setImagePath(p),
        ),
        const SizedBox(height: AppSpacing.xl),

        _Label('메모'),
        TextField(
          onChanged: (v) =>
              ref.read(newShotFormProvider(shot).notifier).setNote(v),
          decoration: const InputDecoration(hintText: '샷에 대한 메모'),
          maxLines: 3,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _DateField({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.inkMuted,
            ),
            const SizedBox(width: 10),
            Text(
              date != null
                  ? '${date!.year}. ${date!.month.toString().padLeft(2, '0')}. '
                      '${date!.day.toString().padLeft(2, '0')}'
                  : '날짜 선택',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniNumberField extends StatelessWidget {
  final String label;
  final String? initial;
  final String? hint;
  final ValueChanged<String> onChanged;
  const _MiniNumberField({
    required this.label,
    required this.initial,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        TextFormField(
          initialValue: initial,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: hint),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final int? rating;
  final ValueChanged<int> onSelect;
  const _RatingRow({required this.rating, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final star = i + 1;
          final selected = rating != null && star <= rating!;
          return GestureDetector(
            onTap: () {
              onSelect(star);
              HapticFeedback.selectionClick();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Icon(
                selected ? Icons.star : Icons.star_border,
                color: selected ? AppColors.ink : AppColors.border,
                size: 32,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String> onPicked;
  const _PhotoPicker({required this.imagePath, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.file(File(imagePath!), fit: BoxFit.cover),
                )
              : const Icon(
                  Icons.image_outlined,
                  size: 26,
                  color: AppColors.inkMuted,
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSourceDialog(context),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('사진 추가'),
          ),
        ),
      ],
    );
  }

  Future<void> _showSourceDialog(BuildContext context) async {
    final picker = ImagePicker();
    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('사진 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                Navigator.pop(dialogCtx);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  final saved = await _saveImage(image);
                  onPicked(saved);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                Navigator.pop(dialogCtx);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  final saved = await _saveImage(image);
                  onPicked(saved);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _saveImage(XFile image) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final path = '${dir.path}/images/$fileName';
    final file = File(path);
    await file.parent.create(recursive: true);
    await image.saveTo(path);
    return path;
  }
}
