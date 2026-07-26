import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/export/export_service.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/capture_mode.dart';
import 'package:record_of_life/features/roll/presentation/pages/picture_detail.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';
import 'package:record_of_life/shared/widgets/shot_card.dart';

class RollDetailsPage extends ConsumerWidget {
  final Roll roll;

  const RollDetailsPage({super.key, required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotState = ref.watch(shotProvider(roll.id));
    final rollState = ref.watch(rollProvider(RollFilter(rollId: roll.id)));

    final currentRoll = rollState.when(
      data: (state) => state.rolls.isNotEmpty ? state.rolls.first : roll,
      loading: () => roll,
      error: (_, __) => roll,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ROL',
        subtitle: '롤 상세',
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'exiftool JSON export',
            onPressed: () async {
              try {
                await ref
                    .read(exportServiceProvider)
                    .exportRolls([currentRoll]);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export 실패: $e')),
                  );
                }
              }
            },
          ),
          PopupMenuButton<RollStatus>(
            tooltip: '상태 변경',
            icon: const Icon(Icons.flag_outlined),
            onSelected: (status) async {
              await ref
                  .read(rollProvider(null).notifier)
                  .updateRoll(currentRoll.copyWith(
                    status: status,
                    endedAt: status == RollStatus.completed
                        ? (currentRoll.endedAt ?? DateTime.now())
                        : currentRoll.endedAt,
                  ));
            },
            itemBuilder: (context) => [
              for (final s in RollStatus.values)
                PopupMenuItem(
                  value: s,
                  enabled: s != currentRoll.status,
                  child: Row(
                    children: [
                      Icon(
                        s == currentRoll.status
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: s.displayColor,
                      ),
                      const SizedBox(width: 8),
                      Text(s.displayName(context)),
                    ],
                  ),
                ),
            ],
          ),
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
                            .read(rollProvider(null).notifier)
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
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: currentRoll.status == RollStatus.archived
                    ? null
                    : () async {
                        final formNotifier = ref.read(
                          newShotFormProvider(null).notifier,
                        );
                        formNotifier.reset();
                        // 마지막 샷 값을 default로 (idx 최대). 없으면 롤 defaultLensId만.
                        final shots = await ref
                            .read(shotRepositoryProvider)
                            .getShotsByRollId(currentRoll.id);
                        if (shots.isNotEmpty) {
                          shots.sort((a, b) => b.idx.compareTo(a.idx));
                          final last = shots.first;
                          formNotifier
                            ..setLensId(last.lensId ?? currentRoll.defaultLensId)
                            ..setAperture(last.aperture)
                            ..setShutterSpeed(last.shutterSpeed)
                            ..setExposureComp(last.exposureComp)
                            ..setIso(last.iso);
                        } else if (currentRoll.defaultLensId != null) {
                          formNotifier.setLensId(currentRoll.defaultLensId);
                        }
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CaptureModePage(roll: currentRoll),
                          ),
                        );
                      },
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  currentRoll.status == RollStatus.completed
                      ? '입력 모드 (촬영 완료됨)'
                      : '입력 모드 시작',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
