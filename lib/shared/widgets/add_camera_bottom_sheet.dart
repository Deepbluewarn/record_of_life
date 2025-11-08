import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';

class AddCameraBottomSheet extends ConsumerWidget {
  const AddCameraBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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

            // 내용은 나중에 채우기
            Center(
              child: TextButton(
                onPressed: () {
                  ref
                      .read(cameraProvider.notifier)
                      .addCamera(getRandomCamera());
                  Navigator.pop(context);
                },
                child: Text('랜덤 카메라 추가'),
              ),
            ),
          ],
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
    id: DateTime.now().toString(),
    title: titles[random.nextInt(titles.length)],
    brand: brands[random.nextInt(brands.length)],
    format: formats[random.nextInt(formats.length)],
    mount: mounts[random.nextInt(mounts.length)],
  );
}
