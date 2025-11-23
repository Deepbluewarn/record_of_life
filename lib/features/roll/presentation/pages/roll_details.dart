import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/picture_detail.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_shot_bottom_sheet.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';
import 'package:record_of_life/shared/widgets/shot_card.dart';

class RollDetailsPage extends ConsumerWidget {
  final Roll roll;

  const RollDetailsPage({super.key, required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotState = ref.watch(shotProvider(roll.id));
    final rollState = ref.watch(rollProvider);

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

    return Scaffold(
      appBar: CustomAppBar(
        title: '롤 | ROL',
        subtitle: '롤 상세',
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddRollPage(roll: currentRoll),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: const Color.fromARGB(255, 228, 110, 101),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('롤 삭제'),
                  content: const Text(
                    '이 롤과 관련된 모든 샷이 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // 다이얼로그 닫기
                        await ref
                            .read(rollProvider.notifier)
                            .deleteRoll(currentRoll.id);
                        if (context.mounted) {
                          Navigator.pop(context); // RollDetailsPage 닫기
                        }
                      },
                      child: const Text(
                        '삭제',
                        style: TextStyle(
                          color: Color.fromARGB(255, 228, 110, 101),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Hero(
              tag: roll.id,
              child: Material(
                color: Colors.transparent,
                child: RollCard(roll: roll),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Expanded(
              child: shotState.when(
                data: (shotData) {
                  return ListView.separated(
                    itemCount: shotData.shots.length,
                    itemBuilder: (context, idx) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PictureDetailPage(
                                shot: shotData.shots[idx],
                                rollId: roll.id,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: shotData.shots[idx].id,
                          child: Material(
                            color: Colors.transparent,
                            child: ShotCard(
                              shot: shotData.shots[idx],
                              index: idx,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, idx) =>
                        const SizedBox(height: 8),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: AddShotBottomSheet(rollId: roll.id),
                  ),
                );
              },
              child: Text('새 샷 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
