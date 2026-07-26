import 'package:sembast/sembast.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/repositories/camera_repository.dart';

class CameraRepositoryImpl extends CameraRepository {
  final AppStore _store;
  CameraRepositoryImpl(this._store);

  @override
  Future<void> addCamera(Camera camera) async {
    // put = upsert. add()는 중복 id에 예외 발생.
    await AppStore.cameras.record(camera.id).put(_store.db, camera.toMap());
  }

  @override
  Future<bool> deleteCamera(String id) async {
    final removed = await AppStore.cameras.record(id).delete(_store.db);
    return removed != null;
  }

  @override
  Future<List<Camera>> getCameras(List<String> ids) async {
    final snaps = await AppStore.cameras.records(ids).getSnapshots(_store.db);
    return [
      for (final s in snaps)
        if (s != null) Camera.fromMap(Map<String, Object?>.from(s.value)),
    ];
  }

  @override
  Future<List<Camera>> getAllCameras() async {
    final snaps = await AppStore.cameras.find(_store.db);
    final list = snaps
        .map((s) => Camera.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
    list.sort(_byRecency);
    return list;
  }

  @override
  Future<void> updateCamera(Camera camera) async {
    await AppStore.cameras.record(camera.id).put(_store.db, camera.toMap());
  }

  @override
  Future<void> touchCamera(String id) async {
    await AppStore.cameras.record(id).update(_store.db, {
      'lastUsedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> setCameraOwned(String id, bool owned) async {
    await AppStore.cameras.record(id).update(_store.db, {'owned': owned});
  }
}

// lastUsedAt desc(최근이 위), null은 뒤로, tie는 title 오름차순.
int _byRecency(Camera a, Camera b) {
  final aT = a.lastUsedAt;
  final bT = b.lastUsedAt;
  if (aT == null && bT == null) return a.title.compareTo(b.title);
  if (aT == null) return 1;
  if (bT == null) return -1;
  return bT.compareTo(aT);
}
