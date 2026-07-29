import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/film_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/lens_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_camera_bottom_sheet.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_film_bottom_sheet.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_lens_bottom_sheet.dart';

// 온보딩·설정 공용. owned=true인 항목만 카드로 노출 + 항목별 X 제거 + '+ 추가'.
void openEquipmentSheet(BuildContext context, Widget sheet) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: sheet,
    ),
  );
}

Widget _sectionShell({
  required BuildContext context,
  required IconData icon,
  required String label,
  required int count,
  required List<Widget> items,
  required VoidCallback onAdd,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 6),
              Text('$count',
                  style: const TextStyle(color: AppColors.inkMuted)),
            ],
          ),
        ),
        ...items,
        ListTile(
          leading: const Icon(Icons.add),
          title: Text('$label 추가'),
          onTap: onAdd,
        ),
      ],
    ),
  );
}

class CamerasSection extends ConsumerWidget {
  const CamerasSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cameraProvider);
    final owned = state.value?.cameras.where((c) => c.owned).toList() ?? [];
    return _sectionShell(
      context: context,
      icon: Icons.photo_camera_outlined,
      label: '카메라',
      count: owned.length,
      items: [
        for (final c in owned)
          ListTile(
            dense: true,
            title: Text(c.title),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () async {
                await ref
                    .read(cameraRepositoryProvider)
                    .setCameraOwned(c.id, false);
                ref.invalidate(cameraProvider);
              },
            ),
          ),
      ],
      onAdd: () => openEquipmentSheet(context, const AddCameraBottomSheet()),
    );
  }
}

class FilmsSection extends ConsumerWidget {
  const FilmsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filmProvider);
    final owned = state.value?.films.where((f) => f.owned).toList() ?? [];
    return _sectionShell(
      context: context,
      icon: Icons.filter_center_focus,
      label: '필름',
      count: owned.length,
      items: [
        for (final f in owned)
          ListTile(
            dense: true,
            title: Text(f.name),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () async {
                await ref
                    .read(filmRepositoryProvider)
                    .setFilmOwned(f.id, false);
                ref.invalidate(filmProvider);
              },
            ),
          ),
      ],
      onAdd: () => openEquipmentSheet(context, const AddFilmBottomSheet()),
    );
  }
}

class LensesSection extends ConsumerWidget {
  const LensesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lensProvider);
    final owned = state.value?.lenses.where((l) => l.owned).toList() ?? [];
    return _sectionShell(
      context: context,
      icon: Icons.lens_outlined,
      label: '렌즈',
      count: owned.length,
      items: [
        for (final l in owned)
          ListTile(
            dense: true,
            title: Text(l.name),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () async {
                await ref
                    .read(lensRepositoryProvider)
                    .setLensOwned(l.id, false);
                ref.invalidate(lensProvider);
              },
            ),
          ),
      ],
      onAdd: () => openEquipmentSheet(context, const AddLensBottomSheet()),
    );
  }
}
