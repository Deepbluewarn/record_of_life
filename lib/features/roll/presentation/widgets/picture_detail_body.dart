// 사진 상세 body — Read-first 확정.
// 사진 크게, 값 chip, 별점, 메모, 편집 버튼.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class PictureDetailBody extends StatelessWidget {
  final Shot shot;
  final VoidCallback onOpenEdit;
  const PictureDetailBody({
    super.key,
    required this.shot,
    required this.onOpenEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BigPhoto(imagePath: shot.imagePath),
        const SizedBox(height: 16),
        _ChipRow(
          entries: [
            if (shot.aperture != null) ('조리개', 'f/${shot.aperture!.value}'),
            if (shot.shutterSpeed != null) ('셔터', shot.shutterSpeed!.label),
            if (shot.exposureComp != null) ('노출 보정', shot.exposureComp!.label),
            if (shot.iso != null) ('ISO', shot.iso.toString()),
            if (shot.focalLength != null) ('초점거리', '${shot.focalLength}mm'),
          ],
        ),
        const SizedBox(height: 16),
        if (shot.rating != null && shot.rating! > 0)
          _Stars(rating: shot.rating!),
        const SizedBox(height: 12),
        if (shot.note != null && shot.note!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(shot.note!),
          ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onOpenEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('편집'),
        ),
      ],
    );
  }
}

class _BigPhoto extends StatelessWidget {
  final String? imagePath;
  const _BigPhoto({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final child = imagePath != null
        ? Image.file(File(imagePath!), fit: BoxFit.cover)
        : Container(
            color: const Color(0xFFDB9A5C),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              size: 48,
              color: Color(0x33351404),
            ),
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(aspectRatio: 3 / 2, child: child),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<(String, String)> entries;
  const _ChipRow({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in entries)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${e.$1}  ',
                    style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: e.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;
  const _Stars({required this.rating});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star : Icons.star_border,
            size: 16,
            color: i <= rating ? AppColors.ink : AppColors.border,
          ),
      ],
    );
  }
}
