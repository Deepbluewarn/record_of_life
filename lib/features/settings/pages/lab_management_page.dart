import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/lab.dart';
import 'package:record_of_life/features/roll/presentation/providers/lab_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class LabManagementPage extends ConsumerWidget {
  const LabManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('현상소 관리')),
      body: state.when(
        data: (d) {
          if (d.labs.isEmpty) {
            return const _Empty();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: d.labs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _LabTile(lab: d.labs[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('현상소 추가'),
      ),
    );
  }
}

class _LabTile extends ConsumerWidget {
  final Lab lab;
  const _LabTile({required this.lab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meta = [
      if (lab.phone != null && lab.phone!.isNotEmpty) lab.phone!,
      if (lab.address != null && lab.address!.isNotEmpty) lab.address!,
    ].join(', ');
    return InkWell(
      onTap: () => _showEditor(context, ref, lab),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lab.title, style: theme.textTheme.bodyLarge),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(meta, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref, lab),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              '등록된 현상소가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '자주 이용하는 현상소를 추가해두면 롤에 연결할 수 있어요.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showEditor(BuildContext context, WidgetRef ref, Lab? existing) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _LabEditor(existing: existing),
    ),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Lab lab,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('현상소 삭제'),
      content: Text('${lab.title}를 삭제합니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('삭제', style: TextStyle(color: Color(0xFFC44234))),
        ),
      ],
    ),
  );
  if (ok == true) await ref.read(labProvider.notifier).delete(lab.id);
}

class _LabEditor extends ConsumerStatefulWidget {
  final Lab? existing;
  const _LabEditor({required this.existing});

  @override
  ConsumerState<_LabEditor> createState() => _LabEditorState();
}

class _LabEditorState extends ConsumerState<_LabEditor> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _address = TextEditingController(
    text: widget.existing?.address ?? '',
  );
  late final _website = TextEditingController(
    text: widget.existing?.website ?? '',
  );
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');

  @override
  void dispose() {
    _title.dispose();
    _phone.dispose();
    _address.dispose();
    _website.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _n(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final n = ref.read(labProvider.notifier);
    if (widget.existing == null) {
      await n.add(Lab(
        title: title,
        phone: _n(_phone),
        address: _n(_address),
        website: _n(_website),
        notes: _n(_notes),
      ));
    } else {
      await n.save(widget.existing!.copyWith(
        title: title,
        phone: _n(_phone),
        address: _n(_address),
        website: _n(_website),
        notes: _n(_notes),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editing ? '현상소 편집' : '새 현상소 추가',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: '이름 *',
                hintText: '예: 충무로 현상소',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: '전화'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: '주소'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _website,
              decoration: const InputDecoration(labelText: '웹사이트'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: '메모'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(editing ? '저장' : '추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
