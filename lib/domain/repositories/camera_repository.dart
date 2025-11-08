import 'package:record_of_life/domain/models/camera.dart';

abstract class CameraRepository {
  Future<List<Camera>> getCameras(List<String> ids);
  Future<List<Camera>> getAllCameras();
  Future<void> addCamera(Camera camera);
  Future<void> updateCamera(Camera camera);
  Future<bool> deleteCamera(String id);
}
