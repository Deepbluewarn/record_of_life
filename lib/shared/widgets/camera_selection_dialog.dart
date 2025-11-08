import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/shared/widgets/add_camera_bottom_sheet.dart';

class CameraSelectionDialog extends ConsumerWidget {
  final Function(Camera) onSelected;

  const CameraSelectionDialog({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    return AlertDialog(
      title: Text('카메라 선택'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.4,
        child: cameraState.when(
          data: (data) => ListView.builder(
            itemCount: data.cameras.length + 1,
            itemBuilder: (context, index) {
              // 마지막 항목: 새 카메라 추가 버튼
              if (index == data.cameras.length) {
                return ListTile(
                  leading: Icon(Icons.add, color: Colors.blue),
                  title: Text(
                    '새 카메라 추가',
                    style: TextStyle(
                      color: Colors.blue,
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
              final camera = data.cameras[index];
              return ListTile(
                title: Text(camera.title),
                subtitle: Text(
                  '${camera.brand ?? 'Unknown'} · ${camera.format ?? ''}',
                ),
                onTap: () {
                  onSelected(camera);
                },
              );
            },
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
      ],
    );
  }
}
