import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/forms/shot_form.dart';
import 'package:record_of_life/shared/widgets/shot_card.dart';

class PictureDetailPage extends ConsumerWidget {
  final Shot shot;
  final String rollId;

  const PictureDetailPage({
    super.key,
    required this.shot,
    required this.rollId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(newShotFormProvider(shot));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ROL',
        subtitle: '#${shot.idx} 상세',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '샷 삭제',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: shot.id,
              child: Material(
                color: Colors.transparent,
                child: ShotCard(shot: shot, index: shot.idx - 1),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: ShotForm(shot: shot),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(shotProvider(rollId).notifier)
                      .updateShot(
                        formState.toShot(rollId: rollId, shotId: shot.id),
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('저장됨'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  '저장',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('샷 삭제'),
        content: Text('#${shot.idx} 샷 기록을 삭제합니다. 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref
                  .read(shotProvider(rollId).notifier)
                  .deleteShot(shot.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Color(0xFFC44234)),
            ),
          ),
        ],
      ),
    );
  }
}
