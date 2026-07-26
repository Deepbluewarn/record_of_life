// PROTOTYPE — throwaway. 홈 화면 3가지 대안.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
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

Future<void> _openCapture(BuildContext context, WidgetRef ref, Roll roll) async {
  final n = ref.read(newShotFormProvider(null).notifier);
  n.reset();
  final shots = await ref.read(shotRepositoryProvider).getShotsByRollId(roll.id);
  if (shots.isNotEmpty) {
    shots.sort((a, b) => b.idx.compareTo(a.idx));
    final last = shots.first;
    n
      ..setLensId(last.lensId ?? roll.defaultLensId)
      ..setAperture(last.aperture)
      ..setShutterSpeed(last.shutterSpeed)
      ..setExposureComp(last.exposureComp)
      ..setIso(last.iso);
  } else if (roll.defaultLensId != null) {
    n.setLensId(roll.defaultLensId);
  }
  if (!context.mounted) return;
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CaptureModePage(roll: roll)),
  );
}

void _openDetails(BuildContext context, Roll roll) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => RollDetailsPage(roll: roll)),
  );
}

// =============================================================================
// Variant A — 필름 스트립 갤러리
// 각 롤 = 세로 필름 스트립. 프레임 셀에 샷 썸네일(있으면) / 프레임 번호.
// 스트립 상하 검정 sprocket 밴드.
// =============================================================================

class HomeVariantA extends ConsumerWidget {
  const HomeVariantA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter.working));
    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '필름 스트립'),
      body: rollState.when(
        data: (data) {
          if (data.rolls.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: data.rolls.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, i) => _FilmStrip(roll: data.rolls[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
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
}

class _FilmStrip extends ConsumerWidget {
  final Roll roll;
  const _FilmStrip({required this.roll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotState = ref.watch(shotProvider(roll.id));
    final shots = shotState.value?.shots ?? const [];
    // 표시할 프레임 슬롯 = totalShots. 완료된 것만 강조, 나머지는 빈.
    return GestureDetector(
      onTap: () => _openDetails(context, roll),
      onLongPress: () => _openCapture(context, ref, roll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    roll.title ?? '제목 없음',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${roll.shotsDone}/${roll.totalShots}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.black,
            child: SizedBox(
              height: 92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: roll.totalShots,
                itemBuilder: (context, i) {
                  final done = i < roll.shotsDone;
                  final shot = shots.where((s) => s.idx == i + 1).firstOrNull;
                  final img = shot?.imagePath;
                  return Container(
                    width: 76,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: done ? Colors.white : Colors.black,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: img != null
                        ? Image.file(File(img), fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: done ? Colors.black : Colors.white38,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${roll.camera?.title ?? ''} · ${roll.film?.name ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Variant B — 메모장 노트 스타일
// 각 롤 = 라이트한 종이 페이지. 손글씨 느낌 제목, 라인. 넘김 감성.
// =============================================================================

class HomeVariantB extends ConsumerWidget {
  const HomeVariantB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter.working));
    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '노트'),
      backgroundColor: const Color(0xFFF8F6EF),
      body: rollState.when(
        data: (data) => data.rolls.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.rolls.length,
                itemBuilder: (context, i) => _NotePage(roll: data.rolls[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddRollPage()),
        ),
        child: const Icon(Icons.edit_note),
      ),
    );
  }
}

class _NotePage extends StatelessWidget {
  final Roll roll;
  const _NotePage({required this.roll});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDDD6C4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(2, 2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
      child: GestureDetector(
        onTap: () => _openDetails(context, roll),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roll.title ?? '제목 없음',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateStr(roll.startedAt),
              style: const TextStyle(
                color: Color(0xFF8C8574),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFE8E0CC), height: 1),
            const SizedBox(height: 14),
            _line('카메라', roll.camera?.title),
            _line('필름', roll.film?.name),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatusChip(status: roll.status),
                const Spacer(),
                Text(
                  '${roll.shotsDone} / ${roll.totalShots}',
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8C8574),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _dateStr(DateTime? d) {
    if (d == null) return '';
    return '${d.year}. ${d.month.toString().padLeft(2, '0')}. '
        '${d.day.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final RollStatus status;
  const _StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.displayColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        status.displayName(context),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.displayColor,
        ),
      ),
    );
  }
}

// =============================================================================
// Variant C — 다음 액션 중심
// 최상단: 진행 중 롤 중 가장 최근 하나를 크게 hero + 큰 '다음 샷 촬영' 버튼.
// 하단: 나머지 진행 중 롤 mini list.
// =============================================================================

class HomeVariantC extends ConsumerWidget {
  const HomeVariantC({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollState = ref.watch(rollProvider(RollFilter.working));
    return Scaffold(
      appBar: CustomAppBar(title: 'ROL', subtitle: '다음 촬영'),
      body: rollState.when(
        data: (data) {
          final rolls = [...data.rolls];
          rolls.sort((a, b) {
            final aT = a.startedAt ?? DateTime(0);
            final bT = b.startedAt ?? DateTime(0);
            return bT.compareTo(aT);
          });
          if (rolls.isEmpty) return const _EmptyState();
          final hero = rolls.first;
          final rest = rolls.skip(1).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeroRoll(roll: hero),
              const SizedBox(height: 20),
              if (rest.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    '다른 진행 중 롤',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              for (final r in rest) _MiniRow(roll: r),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllRollsPage()),
                ),
                child: const Text('전체 롤 · 완료 · 보관 →'),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
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
}

class _HeroRoll extends ConsumerWidget {
  final Roll roll;
  const _HeroRoll({required this.roll});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roll.title ?? '제목 없음',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${roll.camera?.title ?? '카메라 미선택'} · ${roll.film?.name ?? '필름 미선택'}',
            style: const TextStyle(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${roll.shotsDone}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ ${roll.totalShots}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openCapture(context, ref, roll),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text(
                        '다음 샷 촬영',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _openDetails(context, roll),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      child: const Text('상세'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniRow extends ConsumerWidget {
  final Roll roll;
  const _MiniRow({required this.roll});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _openDetails(context, roll),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roll.title ?? '제목 없음',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${roll.camera?.title ?? ''} · ${roll.shotsDone}/${roll.totalShots}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () => _openCapture(context, ref, roll),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              '오른쪽 아래 버튼으로 첫 롤을 추가하세요.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
