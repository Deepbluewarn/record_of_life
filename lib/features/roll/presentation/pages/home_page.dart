import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/widgets/filmstrip_list_row.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/capture_mode.dart';
import 'package:record_of_life/features/roll/presentation/pages/roll_details.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
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
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    // 필터를 provider 키로 쓰면 스위치마다 family 인스턴스가 재빌드돼 loading이 깜빡임.
    // 전체를 한 번만 가져와서 위젯에서 필터.
    final rollState = ref.watch(rollProvider(RollFilter.all));
    final all = rollState.value?.rolls ?? const [];
    final rolls = _showAll
        ? all
        : all
              .where((r) =>
                  r.status == RollStatus.planning ||
                  r.status == RollStatus.inProgress)
              .toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'ROL',
        subtitle: _showAll ? '전체' : '진행 중',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('진행 중')),
                ButtonSegment(value: true, label: Text('전체')),
              ],
              selected: {_showAll},
              onSelectionChanged: (s) => setState(() => _showAll = s.first),
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.ink,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: rollState.when(
              data: (_) => rolls.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      itemCount: rolls.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.xl),
                      itemBuilder: (context, i) {
                        final roll = rolls[i];
                        return _FilmStrip(
                          roll: roll,
                          onOpen: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RollDetailsPage(roll: roll),
                            ),
                          ),
                          onQuickCapture: () =>
                              _startCapture(context, ref, roll),
                        );
                      },
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
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
    final link = ref.listenManual(newShotFormProvider(null), (_, _) {});
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
      await Navigator.push(
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
  const _EmptyState();

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
          ],
        ),
      ),
    );
  }
}
