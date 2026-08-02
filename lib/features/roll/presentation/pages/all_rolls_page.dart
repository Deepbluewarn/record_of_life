import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/export/export_service.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/pages/roll_details.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';
import 'package:record_of_life/shared/widgets/roll_card.dart';

class AllRollsPage extends ConsumerStatefulWidget {
  const AllRollsPage({super.key});

  @override
  ConsumerState<AllRollsPage> createState() => _AllRollsPageState();
}

class _AllRollsPageState extends ConsumerState<AllRollsPage> {
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelection(String initialId) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(initialId);
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _exportSelected(List<Roll> allRolls) async {
    final selected =
        allRolls.where((r) => _selectedIds.contains(r.id)).toList();
    if (selected.isEmpty) return;
    try {
      // 다중 선택 export: 롤마다 .rol.json 하나씩. argfile은 롤 상세에서 개별로.
      for (final r in selected) {
        await ref.read(exportServiceProvider).exportRoll(r, RollExportFormat.rolJson);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export 실패: $e')),
      );
    }
    if (mounted) _cancelSelection();
  }

  @override
  Widget build(BuildContext context) {
    final rollState = ref.watch(rollProvider(RollFilter.all));

    return Scaffold(
      appBar: _selectionMode
          ? _SelectionAppBar(
              count: _selectedIds.length,
              onCancel: _cancelSelection,
              onExport: () => rollState.whenData(
                (data) => _exportSelected(data.rolls),
              ),
            )
          : CustomAppBar(title: 'ROL', subtitle: '전체 롤'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: rollState.when(
                data: (rollData) {
                  if (rollData.rolls.isEmpty) {
                    return const Center(child: Text('저장된 롤이 없습니다'));
                  }
                  return ListView.separated(
                    itemCount: rollData.rolls.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final roll = rollData.rolls[i];
                      final selected = _selectedIds.contains(roll.id);
                      return GestureDetector(
                        onLongPress: () {
                          if (!_selectionMode) _enterSelection(roll.id);
                        },
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelection(roll.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RollDetailsPage(roll: roll),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Hero(
                              tag: roll.id,
                              child: Material(
                                color: Colors.transparent,
                                child: RollCard(roll: roll),
                              ),
                            ),
                            if (_selectionMode)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: selected
                                      ? AppColors.ink
                                      : AppColors.inkMuted,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('오류: $error')),
              ),
            ),
            if (!_selectionMode)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddRollPage()),
                ),
                child: const Text('새 롤 추가'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int count;
  final VoidCallback onCancel;
  final VoidCallback onExport;

  const _SelectionAppBar({
    required this.count,
    required this.onCancel,
    required this.onExport,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
      title: Text('$count개 선택됨'),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share),
          tooltip: 'exiftool JSON export',
          onPressed: count == 0 ? null : onExport,
        ),
      ],
    );
  }
}
