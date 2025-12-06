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
    final rollState = ref.watch(rollProvider(null));
    final currentRoll = rollState.when(
      data: (state) {
        try {
          return state.rolls.firstWhere((r) => r.id == roll.id);
        } catch (e) {
          return roll;
        }
      },
      loading: () => roll,
      error: (_, __) => roll,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 좌측: 썸네일
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일 (더미)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // 중간: 제목 + 날짜
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentRoll.title ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(currentRoll.id, style: TextStyle(fontSize: 8)),
                    Text(
                      _formatDate(currentRoll.startedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 우측: 카메라, 필름, 상태 (세로)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 카메라
                Text(
                  currentRoll.camera?.title ?? '카메라 선택 안함',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                // 필름
                Text(
                  currentRoll.film?.name ?? '필름 선택 안함',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                // 우측 하단: 진행도 + 상태 (Row)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 진행도
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${currentRoll.shotsDone}/${currentRoll.totalShots}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 상태
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Text(
                        currentRoll.status.displayName(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '날짜 미정';
    return '${dateTime.year}. ${dateTime.month}. ${dateTime.day}';
  }
}
