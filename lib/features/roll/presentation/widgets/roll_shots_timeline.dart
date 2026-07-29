import 'package:flutter/material.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

typedef ShotTap = void Function(Shot shot, int index);

// 날짜별 그룹 헤더 + 각 그룹 가로 썸네일 스크롤.
class RollShotsTimeline extends StatelessWidget {
  final List<Shot> shots;
  final ShotTap onTap;
  const RollShotsTimeline({
    super.key,
    required this.shots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final taken = shots.where((s) => s.date != null).toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));
    final groups = <String, List<Shot>>{};
    for (final s in taken) {
      groups.putIfAbsent(_dateKey(s.date!), () => []).add(s);
    }
    final keys = groups.keys.toList();

    if (keys.isEmpty) {
      return const Center(
        child: Text(
          '아직 촬영한 사진이 없습니다',
          style: TextStyle(color: AppColors.inkMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: keys.length,
      itemBuilder: (context, gi) {
        final key = keys[gi];
        final list = groups[key]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      key,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${list.length}장',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) {
                    final s = list[i];
                    return GestureDetector(
                      onTap: () => onTap(s, s.idx - 1),
                      child: SizedBox(
                        width: 88,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 88,
                              height: 66,
                              color: const Color(0xFF1A0F08),
                            ),
                            Text(
                              '#${s.idx}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _dateKey(DateTime d) =>
    '${d.year}. ${d.month.toString().padLeft(2, '0')}. '
    '${d.day.toString().padLeft(2, '0')}';
