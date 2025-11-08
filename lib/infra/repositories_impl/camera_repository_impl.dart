// Camera Repository Implementation

import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/repositories/camera_repository.dart';

class CameraRepositoryImpl extends CameraRepository {
  static final List<Camera> _cameras = [
    Camera(id: '1', title: 'Canon AE-1', brand: 'Canon', format: '35mm'),
    Camera(id: '2', title: 'Pentax K1000', brand: 'Pentax', format: '35mm'),
    Camera(id: '3', title: 'Rolleiflex', brand: 'Rollei', format: '120'),
  ];

  @override
  Future<void> addCamera(Camera camera) async {
    if (_cameras.any((c) => c.id == camera.id)) {
      return;
    }
    _cameras.add(camera);
  }

  @override
  Future<bool> deleteCamera(String id) async {
    _cameras.removeWhere((c) => c.id == id);

    return true;
  }

  @override
  Future<List<Camera>> getCameras(List<String> ids) async {
    return (_cameras.where((c) => ids.contains(c.id))).toList();
  }

  @override
  Future<List<Camera>> getAllCameras() async {
    return _cameras;
  }

  @override
  Future<void> updateCamera(Camera camera) async {
    final idx = _cameras.indexWhere((c) => c.id == camera.id);
    if (idx >= 0) {
      _cameras[idx] = camera;
    }
  }
}
