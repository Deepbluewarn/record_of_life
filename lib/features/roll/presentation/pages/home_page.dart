import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/all_rolls_page.dart';
import 'package:record_of_life/features/roll/presentation/pages/capture_mode.dart';
import 'package:record_of_life/features/roll/presentation/pages/roll_details.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_shot_form_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/prototype/home_variants.dart';
import 'package:record_of_life/prototype/prototype_switcher.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';
import 'package:record_of_life/shared/widgets/section_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PROTOTYPE swap — 홈 3안. main으로 fold하면 삭제.
    return PrototypeScaffold(
      variants: [
        (label: '필름 스트립', builder: (_) => const HomeVariantA()),
        (label: '노트', builder: (_) => const HomeVariantB()),
        (label: '다음 액션', builder: (_) => const HomeVariantC()),
      ],
    );
  }

  // ignore: unused_element
  Widget _originalBuild(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter.working));

    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '롤 목록'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            SectionHeader(
              title: '진행 중인 롤',
              count: rollState.maybeWhen(
                data: (data) => data.rolls.length,
                orElse: () => 0,
              ),
              onActionPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllRollsPage()),
              ),
            ),
            Expanded(
              child: rollState.when(
                data: (rollData) {
                  if (rollData.rolls.isEmpty) {
                    return _EmptyState(
                      onCreate: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddRollPage()),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: rollData.rolls.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final roll = rollData.rolls[i];
                      return _HomeRollTile(
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('오류: $e')),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddRollPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('새 롤 추가'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCapture(
    BuildContext context,
    WidgetRef ref,
    Roll roll,
  ) async {
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
  }
}

// 홈 전용 롤 카드 래퍼: 카드 탭 = 상세, 우측 '지금 촬영' 액션 = 캡처 진입.
class _HomeRollTile extends StatelessWidget {
  final Roll roll;
  final VoidCallback onOpen;
  final VoidCallback onQuickCapture;

  const _HomeRollTile({
    required this.roll,
    required this.onOpen,
    required this.onQuickCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: roll.id,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: RollCard(roll: roll),
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: IconButton(
            tooltip: '입력 모드 시작',
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: onQuickCapture,
          ),
        ),
      ],
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
              '카메라·필름을 골라 첫 롤을 만들어 보세요.',
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
