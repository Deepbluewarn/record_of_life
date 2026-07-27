import 'package:flutter/material.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

// 홈의 Rail 스타일과 일치. 제목 + 상태 dot + 카메라/필름 + 얇은 진행 바.
class RollCard extends StatelessWidget {
  final Roll roll;
  const RollCard({super.key, required this.roll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = roll.totalShots == 0 ? 0.0 : roll.shotsDone / roll.totalShots;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  roll.title ?? '제목 없음',
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusDot(status: roll.status),
              const SizedBox(width: 4),
              Text(
                roll.status.displayName(context),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.camera_alt_outlined, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  roll.camera?.title ?? '-',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.camera_roll_outlined, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  roll.film?.name ?? '-',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: done,
                    minHeight: 4,
                    backgroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${roll.shotsDone}/${roll.totalShots}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final RollStatus status;
  const _StatusDot({required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status.displayColor,
      ),
    );
  }
}
