import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/features/roll/presentation/widgets/capture_form.dart';
import 'package:record_of_life/features/roll/presentation/widgets/picture_detail_body.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';

class PictureDetailPage extends ConsumerStatefulWidget {
  final Shot shot;
  final Roll roll;

  const PictureDetailPage({
    super.key,
    required this.shot,
    required this.roll,
  });

  @override
  ConsumerState<PictureDetailPage> createState() => _PictureDetailPageState();
}

class _PictureDetailPageState extends ConsumerState<PictureDetailPage> {
  // 화면에 뿌리는 shot은 provider의 최신값. 초기값은 widget.shot으로 즉시 표시.
  Shot get shot {
    final list = ref.watch(shotProvider(rollId)).value?.shots;
    return list?.firstWhere(
          (s) => s.id == widget.shot.id,
          orElse: () => widget.shot,
        ) ??
        widget.shot;
  }

  String get rollId => widget.roll.id;

  Future<void> _openEditSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CaptureForm(shot: shot),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final form = ref.read(newShotFormProvider(shot));
                      await ref
                          .read(shotProvider(rollId).notifier)
                          .updateShot(
                            form.toShot(rollId: rollId, shotId: shot.id),
                          );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('저장됨'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ROL',
        subtitle: '#${shot.idx} 상세',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '사진 삭제',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Hero(
        tag: shot.id,
        child: Material(
          color: Colors.transparent,
          child: PictureDetailBody(
            shot: shot,
            roll: widget.roll,
            onOpenEdit: _openEditSheet,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('사진 삭제'),
        content: Text('#${shot.idx} 사진 기록을 삭제합니다. 되돌릴 수 없습니다.'),
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
