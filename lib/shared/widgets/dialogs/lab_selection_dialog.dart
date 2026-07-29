import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/lab.dart';
import 'package:record_of_life/features/roll/presentation/providers/lab_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/settings/pages/lab_management_page.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class LabSelectionDialog extends ConsumerWidget {
  final void Function(Lab? lab) onSelected; // null = 선택 해제
  const LabSelectionDialog({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labProvider);
    return AlertDialog(
      title: const Text('현상소 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: state.when(
          data: (d) {
            if (d.labs.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '등록된 현상소가 없습니다',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('현상소 관리로 이동'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LabManagementPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: d.labs.length + 1,
              itemBuilder: (context, i) {
                if (i == d.labs.length) {
                  return ListTile(
                    leading: const Icon(Icons.clear),
                    title: const Text('선택 해제'),
                    onTap: () {
                      onSelected(null);
                      Navigator.pop(context);
                    },
                  );
                }
                final lab = d.labs[i];
                return ListTile(
                  title: Text(
                    lab.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: lab.address == null
                      ? null
                      : Text(
                          lab.address!,
                          style: const TextStyle(color: AppColors.inkMuted),
                        ),
                  onTap: () async {
                    await ref.read(labRepositoryProvider).touchLab(lab.id);
                    onSelected(lab);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('오류: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }
}
