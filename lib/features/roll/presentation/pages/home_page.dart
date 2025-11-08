import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/pages/add_roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/camera_provider.dart';
import 'package:record_of_life/shared/widgets/app_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: '롤 | ROL', subtitle: 'Record Of Life'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddRollPage()),
                    );
                  },
                  child: Text('새 롤 추가'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraInfo extends StatelessWidget {
  final CameraState cameraState;
  const CameraInfo({super.key, required this.cameraState});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, idx) {
          final camera = cameraState.cameras[idx];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(
                camera.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('${camera.brand ?? 'Unknown'} · ${camera.format ?? ''}'),
                  if (camera.mount != null) Text('Mount: ${camera.mount}'),
                ],
              ),
              trailing: Icon(Icons.camera_alt),
            ),
          );
        },
        itemCount: cameraState.cameras.length,
      ),
    );
  }
}
