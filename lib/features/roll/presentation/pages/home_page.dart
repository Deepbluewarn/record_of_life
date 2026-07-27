import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/widgets/filmstrip_list_row.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/all_rolls_page.dart';
import 'package:record_of_life/features/roll/presentation/pages/capture_mode.dart';
import 'package:record_of_life/features/roll/presentation/pages/roll_details.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final rollState = ref.watch(rollProvider(RollFilter.working));

    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '진행 중'),
      body: rollState.when(
        data: (data) => data.rolls.isEmpty
            ? _EmptyState(
                onCreate: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddRollPage()),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                itemCount: data.rolls.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xl),
                itemBuilder: (context, i) {
                  if (i == data.rolls.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllRollsPage(),
                          ),
                        ),
                        child: const Text('전체 롤 보기'),
                      ),
                    );
                  }
                  final roll = data.rolls[i];
                  return _FilmStrip(
                    roll: roll,
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RollDetailsPage(roll: roll),
                      ),
                    ),
                    onQuickCapture: () => _startCapture(context, ref, roll),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddRollPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('새 롤'),
      ),
    );
  }

  Future<void> _startCapture(
    BuildContext context,
    WidgetRef ref,
    Roll roll,
  ) async {
    // autoDispose provider를 await 사이 살려두기.
    final link = ref.listenManual(newShotFormProvider(null), (_, __) {});
    try {
      final notifier = ref.read(newShotFormProvider(null).notifier);
      notifier.reset();
      final shots = await ref
          .read(shotRepositoryProvider)
          .getShotsByRollId(roll.id);
      if (shots.isNotEmpty) {
        shots.sort((a, b) => b.idx.compareTo(a.idx));
        final last = shots.first;
        notifier
          ..setLensId(last.lensId ?? roll.defaultLensId)
          ..setAperture(last.aperture)
          ..setShutterSpeed(last.shutterSpeed)
          ..setExposureComp(last.exposureComp)
          ..setIso(last.iso);
      } else if (roll.defaultLensId != null) {
        notifier.setLensId(roll.defaultLensId);
      }
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CaptureModePage(roll: roll)),
      );
    } finally {
      link.close();
    }
  }
}

class _FilmStrip extends ConsumerWidget {
  final Roll roll;
  final VoidCallback onOpen;
  final VoidCallback onQuickCapture;

  const _FilmStrip({
    required this.roll,
    required this.onOpen,
    required this.onQuickCapture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotState = ref.watch(shotProvider(roll.id));
    final shots = shotState.value?.shots ?? const [];

    return GestureDetector(
      onTap: onOpen,
      onLongPress: onQuickCapture,
      behavior: HitTestBehavior.opaque,
      child: FilmstripListRow(roll: roll, shots: shots),
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
            const SizedBox(height: AppSpacing.lg),
            Text(
              '진행 중인 롤이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '카메라, 필름을 골라 첫 롤을 만들어 보세요.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
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
