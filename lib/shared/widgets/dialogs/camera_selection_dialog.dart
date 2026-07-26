import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:record_of_life/shared/widgets/bottom_sheets/add_camera_bottom_sheet.dart';

class CameraSelectionDialog extends ConsumerWidget {
  final Function(Camera) onSelected;
  final String? matchFormat;

  const CameraSelectionDialog({
    super.key,
    required this.onSelected,
    this.matchFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    return AlertDialog(
      title: const Text('카메라 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: cameraState.when(
          data: (data) {
            // 내가 소유한 카메라만 노출.
            final cameras = data.cameras.where((c) => c.owned).toList();
            if (matchFormat != null) {
              cameras.sort((a, b) {
                final aMatch = a.format == matchFormat ? 0 : 1;
                final bMatch = b.format == matchFormat ? 0 : 1;
                return aMatch - bMatch;
              });
            }
            return ListView.builder(
              itemCount: cameras.length + 1,
              itemBuilder: (context, index) {
                if (index == cameras.length) {
                  return ListTile(
                    leading: const Icon(Icons.add, color: AppColors.ink),
                    title: const Text(
                      '새 카메라 추가',
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
                          child: AddCameraBottomSheet(),
                        ),
                      );
                    },
                  );
                }
                final camera = cameras[index];
                final mismatched =
                    matchFormat != null && camera.format != matchFormat;
                return ListTile(
                  title: Text(
                    camera.title,
                    style: TextStyle(
                      color: mismatched ? AppColors.inkMuted : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${camera.brand ?? 'Unknown'} · ${camera.format ?? ''}',
                    style: const TextStyle(color: AppColors.inkMuted),
                  ),
                  trailing: mismatched
                      ? const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.inkMuted,
                          size: 18,
                        )
                      : null,
                  onTap: () async {
                    await ref
                        .read(cameraRepositoryProvider)
                        .touchCamera(camera.id);
                    ref.invalidate(cameraProvider);
                    onSelected(camera);
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
