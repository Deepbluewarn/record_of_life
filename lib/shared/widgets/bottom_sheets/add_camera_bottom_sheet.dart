import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/forms/new_camera_form_provider.dart';

class AddCameraBottomSheet extends ConsumerWidget {
  const AddCameraBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraFormProvider = ref.watch(newCameraFormProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  '새 카메라 추가',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 20),

                TextField(
                  onChanged: (value) {
                    ref.read(newCameraFormProvider.notifier).setTitle(value);
                  },
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '예: XD-5',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newCameraFormProvider.notifier).setBrand(value);
                  },
                  decoration: InputDecoration(
                    labelText: '브랜드',
                    hintText: '예: Canon',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newCameraFormProvider.notifier).setFormat(value);
                  },
                  decoration: InputDecoration(
                    labelText: '포맷',
                    hintText: '예: 35mm',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newCameraFormProvider.notifier).setMount(value);
                  },
                  decoration: InputDecoration(
                    labelText: '마운트',
                    hintText: '예: FD',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    ref.read(newCameraFormProvider.notifier).setNotes(value);
                  },
                  decoration: InputDecoration(
                    labelText: '메모',
                    hintText: '예: 좋은 상태',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: cameraFormProvider.when(
                    data: (formState) => ElevatedButton(
                      onPressed: () {
                        ref
                            .read(cameraProvider.notifier)
                            .addCamera(formState.toCamera());
                        Navigator.pop(context);
                      },
                      child: Text('추가'),
                    ),
                    loading: () =>
                        ElevatedButton(onPressed: null, child: Text('추가 중...')),
                    error: (error, stackTrace) =>
                        ElevatedButton(onPressed: null, child: Text('오류 발생')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Camera getRandomCamera() {
  final brands = ['Canon', 'Nikon', 'Pentax', 'Minolta', 'Olympus'];
  final titles = ['AE-1', 'FM2', 'K1000', 'XD5', 'OM-1'];
  final formats = ['35mm', '120', 'Half'];
  final mounts = ['FD', 'F', 'K', 'MD', 'OM'];

  final random = Random();

  return Camera(
    title: titles[random.nextInt(titles.length)],
    brand: brands[random.nextInt(brands.length)],
    format: formats[random.nextInt(formats.length)],
    mount: mounts[random.nextInt(mounts.length)],
  );
}
