import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/widgets/forms/shot_form.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
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
    final shotFormProvider = ref.watch(newShotFormProvider(shot));

    return Scaffold(
      appBar: CustomAppBar(
        title: '사진 상세',
        subtitle: 'Shot Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('사진 삭제'),
                  content: Text('이 사진을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // 다이얼로그 닫기
                        await ref
                            .read(shotProvider(rollId).notifier)
                            .deleteShot(shot.id);
                        if (context.mounted) {
                          Navigator.pop(context); // 상세 페이지 닫기
                        }
                      },
                      child: Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shot ID: ${shot.id}'),
                      Text('Roll ID: $rollId'),
                      SizedBox(height: 20),
                      Text('Date: ${shot.date}'),
                      Text('Aperture: ${shot.aperture}'),
                      Text('Shutter Speed: ${shot.shutterSpeed}'),
                      Text('Exposure Comp: ${shot.exposureComp}'),
                      Text('Rating: ${shot.rating}'),
                      Text('Note: ${shot.note}'),
                    ],
                  ),
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
              tag: shot.id,
              child: Material(
                color: Colors.transparent,
                child: ShotCard(shot: shot, index: 0),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ShotForm(shot: shot),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(shotProvider(rollId).notifier)
                            .updateShot(
                              shotFormProvider.toShot(
                                rollId: rollId,
                                shotId: shot.id,
                              ),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('저장되었습니다'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
