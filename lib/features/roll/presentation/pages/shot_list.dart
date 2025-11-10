import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';
import 'package:record_of_life/shared/widgets/shot_card.dart';

class ShotListPage extends ConsumerWidget {
  final Roll roll;

  const ShotListPage({super.key, required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotState = ref.watch(shotProvider(roll.id));

    return Scaffold(
      appBar: CustomAppBar(title: '롤 | ROL', subtitle: '사진 목록'),
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
                      return ShotCard(shot: shotData.shots[idx], index: idx);
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
                ref
                    .read(shotProvider(roll.id).notifier)
                    .addShot(
                      Shot(
                        roll: roll,
                        date: DateTime.now(),
                        aperture: 2.8,
                        shutterSpeed: '1/125',
                        focusDistance: '3m',
                        exposureComp: 0.3,
                        note: '테스트 샷',
                        rating: 4,
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
