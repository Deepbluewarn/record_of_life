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
import 'package:record_of_life/features/roll/presentation/providers/lab_provider.dart';
import 'package:record_of_life/features/roll/presentation/widgets/roll_shots_timeline.dart';
import 'package:record_of_life/features/settings/pages/settings_page.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/dialogs/lab_selection_dialog.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';

class RollDetailsPage extends ConsumerStatefulWidget {
  final Roll roll;

  const RollDetailsPage({super.key, required this.roll});

  @override
  ConsumerState<RollDetailsPage> createState() => _RollDetailsPageState();
}

class _RollDetailsPageState extends ConsumerState<RollDetailsPage> {
  Roll get roll => widget.roll;

  // inProgress → completed: 현상소 선택 필수, sentToLabAt=now, endedAt=now.
  Future<void> _startDeveloping(Roll current) async {
    final labId = await showDialog<String>(
      context: context,
      builder: (_) => LabSelectionDialog(
        onSelected: (lab) => Navigator.pop(context, lab?.id),
      ),
    );
    if (labId == null) return; // 현상소 미선택 → 취소
    final now = DateTime.now();
    await ref.read(rollProvider(null).notifier).updateRoll(current.copyWith(
      status: RollStatus.completed,
      labId: labId,
      sentToLabAt: now,
      endedAt: now,
    ));
  }

  // completed → archived: 회수 완료 처리.
  Future<void> _archive(Roll current) async {
    await ref.read(rollProvider(null).notifier).updateRoll(current.copyWith(
      status: RollStatus.archived,
    ));
  }

  Future<void> _showDevelopingSheet(Roll current) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => _DevelopingSheet(
        roll: current,
        onComplete: () async {
          Navigator.pop(sheetCtx);
          await _archive(current);
        },
      ),
    );
  }

  Future<void> _exportRoll(Roll current, RollExportFormat format) async {
    try {
      await ref.read(exportServiceProvider).exportRoll(current, format);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export 실패: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(Roll current) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('롤 삭제'),
        content: const Text(
          '이 롤과 관련된 모든 사진이 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Color.fromARGB(255, 228, 110, 101)),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(rollProvider(null).notifier).deleteRoll(current.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openCapture(Roll current) async {
    // autoDispose provider를 await 사이 살려두기.
    final link = ref.listenManual(newShotFormProvider(null), (_, __) {});
    try {
      final formNotifier = ref.read(newShotFormProvider(null).notifier);
      formNotifier.reset();
      final shots = await ref
          .read(shotRepositoryProvider)
          .getShotsByRollId(current.id);
      if (shots.isNotEmpty) {
        shots.sort((a, b) => b.idx.compareTo(a.idx));
        final last = shots.first;
        formNotifier
          ..setLensId(last.lensId ?? current.defaultLensId)
          ..setAperture(last.aperture)
          ..setShutterSpeed(last.shutterSpeed)
          ..setExposureComp(last.exposureComp)
          ..setIso(last.iso);
      } else if (current.defaultLensId != null) {
        formNotifier.setLensId(current.defaultLensId);
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CaptureModePage(roll: current)),
      );
    } finally {
      link.close();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        showSettings: false,
        actions: [
          PopupMenuButton<String>(
            tooltip: '더 보기',
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddRollPage(roll: currentRoll),
                    ),
                  );
                case 'export_rol':
                  _exportRoll(currentRoll, RollExportFormat.rolJson);
                case 'export_args':
                  _exportRoll(currentRoll, RollExportFormat.argfile);
                case 'delete':
                  _confirmDelete(currentRoll);
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: _MenuRow(icon: Icons.edit, label: '편집'),
              ),
              PopupMenuItem(
                value: 'export_rol',
                child: _MenuRow(
                  icon: Icons.ios_share,
                  label: '내보내기 (.rol.json)',
                ),
              ),
              PopupMenuItem(
                value: 'export_args',
                child: _MenuRow(
                  icon: Icons.terminal,
                  label: 'exiftool argfile (.args)',
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: _MenuRow(
                  icon: Icons.delete_outline,
                  label: '삭제',
                  danger: true,
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: _MenuRow(icon: Icons.settings_outlined, label: '설정'),
              ),
            ],
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
                child: RollCard(roll: currentRoll),
              ),
            ),
            _ActionsRow(
              roll: currentRoll,
              onAddPhoto: () => _openCapture(currentRoll),
              onStartDevelop: () => _startDeveloping(currentRoll),
              onOpenDevelopingSheet: () => _showDevelopingSheet(currentRoll),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1),
            ),
            Expanded(
              child: shotState.when(
                data: (shotData) => RollShotsTimeline(
                  shots: shotData.shots,
                  onTap: (shot, idx) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PictureDetailPage(shot: shot, roll: currentRoll),
                    ),
                  ),
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  const _MenuRow({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color.fromARGB(255, 228, 110, 101) : null;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

// 현상중 상태에서 열리는 시트. 현상소·일정을 보여주고 '현상 완료' 버튼으로 archived 전이.
class _DevelopingSheet extends ConsumerWidget {
  final Roll roll;
  final VoidCallback onComplete;
  const _DevelopingSheet({required this.roll, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labs = ref.watch(labProvider).value?.labs ?? const [];
    final lab = labs.where((l) => l.id == roll.labId).firstOrNull;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('현상 진행 상황', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            if (lab != null) _row(context, '현상소', lab.title),
            if (roll.sentToLabAt != null)
              _row(context, '맡긴날', _fmtDate(roll.sentToLabAt!)),
            if (roll.expectedReturnAt != null)
              _row(context, '회수예정', _fmtDate(roll.expectedReturnAt!)),
            if (roll.pushPull != null && roll.pushPull != 0)
              _row(
                context,
                '현상 보정',
                roll.pushPull! > 0
                    ? '+${roll.pushPull} stop (push)'
                    : '${roll.pushPull} stop (pull)',
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  '현상 완료',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}

// 사진 추가(primary, filled)와 상태 전이(secondary, outlined)를 카드 밑에 나란히.
// archived면 전체 숨김. completed면 사진 추가는 disable + 보관 처리.
class _ActionsRow extends StatelessWidget {
  final Roll roll;
  final VoidCallback onAddPhoto;
  final VoidCallback onStartDevelop;
  final VoidCallback onOpenDevelopingSheet;
  const _ActionsRow({
    required this.roll,
    required this.onAddPhoto,
    required this.onStartDevelop,
    required this.onOpenDevelopingSheet,
  });

  @override
  Widget build(BuildContext context) {
    if (roll.status == RollStatus.archived) return const SizedBox.shrink();

    final canAdd = roll.status != RollStatus.completed;
    Widget? secondary;
    switch (roll.status) {
      case RollStatus.inProgress:
        secondary = OutlinedButton.icon(
          onPressed: onStartDevelop,
          icon: const Icon(Icons.local_shipping_outlined, size: 16),
          label: const Text('현상 시작'),
        );
      case RollStatus.completed:
        secondary = OutlinedButton.icon(
          onPressed: onOpenDevelopingSheet,
          icon: const Icon(Icons.hourglass_bottom, size: 16),
          label: const Text('현상중'),
        );
      case RollStatus.planning:
      case RollStatus.archived:
        secondary = null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: canAdd ? onAddPhoto : null,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text(
                  '사진 추가',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (secondary != null) ...[
            const SizedBox(width: 8),
            SizedBox(height: 48, child: secondary),
          ],
        ],
      ),
    );
  }
}
