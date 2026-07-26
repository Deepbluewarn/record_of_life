import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_lens_bottom_sheet.dart';

class LensSelectionDialog extends ConsumerWidget {
  final Function(Lens) onSelected;

  const LensSelectionDialog({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lensState = ref.watch(lensProvider);

    return AlertDialog(
      title: Text('렌즈 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: lensState.when(
          data: (data) {
            final lenses = data.lenses.where((l) => l.owned).toList();
            return ListView.builder(
              itemCount: lenses.length + 1,
              itemBuilder: (context, index) {
                if (index == lenses.length) {
                  return ListTile(
                    leading: const Icon(Icons.add, color: AppColors.ink),
                    title: const Text(
                      '새 렌즈 추가',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: AddLensBottomSheet(),
                        ),
                      );
                    },
                  );
                }
                final lens = lenses[index];
                return ListTile(
                  title: Text(
                    lens.name,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (lens.focalLength != null) '${lens.focalLength}mm',
                      if (lens.maxAperture != null) 'f/${lens.maxAperture}',
                      if (lens.mount != null) lens.mount,
                    ].join(' · '),
                    style: const TextStyle(color: AppColors.inkMuted),
                  ),
                  onTap: () async {
                    await ref
                        .read(lensRepositoryProvider)
                        .touchLens(lens.id);
                    ref.invalidate(lensProvider);
                    onSelected(lens);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Error: $error'),
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
