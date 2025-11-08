import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/infra/repositories_impl/camera_repository_impl.dart';

class CameraState {
  final List<Camera> cameras;

  CameraState({required this.cameras});
}

class CameraNotifier extends AsyncNotifier<CameraState> {
  final cameraRepository = CameraRepositoryImpl();

  @override
  Future<CameraState> build() async {
    final cameras = await cameraRepository.getAllCameras();
    return CameraState(cameras: cameras);
  }

  Future<Camera?> getCamera(String id) async {
    return state.whenData((data) {
      return data.cameras[0];
    }).value;
  }

  Future<List<Camera>> getAllCameras() async {
    final cameras = await cameraRepository.getAllCameras();

    return cameras;
  }

  void addCamera(Camera camera) async {
    await cameraRepository.addCamera(camera);
    final updatedCameras = await cameraRepository.getAllCameras();

    state = AsyncValue.data(CameraState(cameras: updatedCameras));
  }
}

final cameraProvider =
    AsyncNotifierProvider.autoDispose<CameraNotifier, CameraState>(
      CameraNotifier.new,
    );
