import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class ShotCard extends StatelessWidget {
  final Shot shot;
  final int index;

  const ShotCard({super.key, required this.shot, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _Thumb(imagePath: shot.imagePath),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  '#${shot.idx}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _formatDate(shot.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (shot.aperture != null)
                    Text(
                      'f/${shot.aperture!.value}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (shot.shutterSpeed != null)
                    Text(
                      shot.shutterSpeed!.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              if (shot.rating != null && shot.rating! > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    shot.rating!,
                    (_) => const Icon(
                      Icons.star,
                      size: 12,
                      color: AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '날짜 미정';
    return '${d.year}. ${d.month.toString().padLeft(2, '0')}. '
        '${d.day.toString().padLeft(2, '0')}';
  }
}

class _Thumb extends StatelessWidget {
  final String? imagePath;
  const _Thumb({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
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
              color: AppColors.inkMuted,
              size: 26,
            ),
    );
  }
}
