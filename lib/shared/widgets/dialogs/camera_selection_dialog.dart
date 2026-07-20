import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
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
            final cameras = [...data.cameras];
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
                    leading: Icon(Icons.add, color: AppColors.primary),
                    title: Text(
                      '새 카메라 추가',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
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
                    style: TextStyle(color: mismatched ? Colors.grey : null),
                  ),
                  subtitle: Text(
                    '${camera.brand ?? 'Unknown'} · ${camera.format ?? ''}',
                    style: TextStyle(color: mismatched ? Colors.grey : null),
                  ),
                  trailing: mismatched
                      ? const Icon(
                          Icons.warning_amber,
                          color: Colors.amber,
                          size: 18,
                        )
                      : null,
                  onTap: () => onSelected(camera),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    );
  }
}
