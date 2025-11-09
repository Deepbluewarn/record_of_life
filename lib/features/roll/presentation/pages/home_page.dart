import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider);

    return Scaffold(
      appBar: CustomAppBar(title: '롤 | ROL', subtitle: 'Record Of Life'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: rollState.when(
                data: (rollData) {
                  if (rollData.rolls.isEmpty) {
                    return Center(child: Text('저장된 롤이 없습니다'));
                  } else {
                    print(rollData.rolls[0].toString());
                  }
                  return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return RollCard(roll: rollData.rolls[index]);
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
