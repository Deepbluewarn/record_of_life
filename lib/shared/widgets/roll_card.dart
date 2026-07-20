import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class RollCard extends ConsumerWidget {
  final Roll roll;

  const RollCard({super.key, required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter(rollId: roll.id)));
    final currentRoll = rollState.when(
      data: (state) => state.rolls.isNotEmpty ? state.rolls.first : roll,
      loading: () => roll,
      error: (_, __) => roll,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        currentRoll.title ?? '제목 없음',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (currentRoll.hasFormatMismatch) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _MismatchBadge(
                        camera: currentRoll.camera?.format,
                        film: currentRoll.film?.format,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(currentRoll.startedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentRoll.camera?.title ?? '카메라 미선택',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                currentRoll.film?.name ?? '필름 미선택',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Pill(
                    label: '${currentRoll.shotsDone}/${currentRoll.totalShots}',
                    strong: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusDot(status: currentRoll.status),
                  const SizedBox(width: 4),
                  Text(
                    currentRoll.status.displayName(context),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
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

class _Pill extends StatelessWidget {
  final String label;
  final bool strong;
  const _Pill({required this.label, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: strong ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: strong ? Colors.white : AppColors.ink,
        ),
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

class _MismatchBadge extends StatelessWidget {
  final String? camera;
  final String? film;
  const _MismatchBadge({this.camera, this.film});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '카메라($camera) · 필름($film) 포맷 불일치',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderStrong),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '⚠',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
