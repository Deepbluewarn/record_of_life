import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/all_rolls_page.dart';
import 'package:record_of_life/features/roll/presentation/pages/roll_details.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';
import 'package:record_of_life/shared/widgets/section_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter.inProgress));

    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '롤 목록'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SectionHeader(
              title: '진행 중인 롤',
              count: rollState.maybeWhen(
                data: (data) => data.rolls.length,
                orElse: () => 0,
              ),
              onActionPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllRollsPage()),
                );
              },
            ),
            Expanded(
              child: rollState.when(
                data: (rollData) {
                  if (rollData.rolls.isEmpty) {
                    return _EmptyState(
                      onCreate: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddRollPage(),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Hero(
                        tag: rollData.rolls[index].id,
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RollDetailsPage(
                                    roll: rollData.rolls[index],
                                  ),
                                ),
                              );
                            },
                            child: RollCard(roll: rollData.rolls[index]),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8),
                    itemCount: rollData.rolls.length,
                  );
                },
                loading: () {
                  return Center(child: CircularProgressIndicator());
                },
                error: (error, stack) {
                  return Center(child: Text('오류: $error'));
                },
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddRollPage()),
                );
              },
              child: Text('새 롤 추가'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_roll_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              '진행 중인 롤이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '카메라·필름을 골라 첫 롤을 만들어 보세요.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('첫 롤 만들기'),
            ),
          ],
        ),
      ),
    );
  }
}
