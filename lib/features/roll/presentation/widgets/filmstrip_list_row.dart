import 'package:flutter/material.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/film_strip.dart';
import 'package:record_of_life/shared/widgets/marquee_text.dart';

// 홈 리스트의 롤 행: 제목 + 카메라/필름 marquee + 진행 바 + 필름 스트립.
class FilmstripListRow extends StatelessWidget {
  final Roll roll;
  final List<Shot> shots;
  const FilmstripListRow({
    super.key,
    required this.roll,
    required this.shots,
  });

  static const double _cameraColW = 96;
  static const double _filmColW = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = roll.totalShots == 0 ? 0.0 : roll.shotsDone / roll.totalShots;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  roll.title ?? '제목 없음',
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.camera_alt_outlined, size: 14),
              const SizedBox(width: 4),
              SizedBox(
                width: _cameraColW,
                child: MarqueeText(
                  text: roll.camera?.title ?? '-',
                  style: theme.textTheme.bodySmall!,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.camera_roll_outlined, size: 14),
              const SizedBox(width: 4),
              SizedBox(
                width: _filmColW,
                child: MarqueeText(
                  text: roll.film?.name ?? '-',
                  style: theme.textTheme.bodySmall!,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: done,
              minHeight: 2,
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.08,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilmStrip(roll: roll, shots: shots),
      ],
    );
  }
}
