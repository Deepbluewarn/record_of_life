import 'package:sembast/sembast.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/domain/repositories/shot_repository.dart';

class ShotRepositoryImpl extends ShotRepository {
  final AppStore _store;
  ShotRepositoryImpl(this._store);

  @override
  Future<void> addShot(Shot shot) async {
    await AppStore.shots.record(shot.id).put(_store.db, shot.toMap());
  }

  @override
  Future<bool> deleteShot(String id) async {
    final removed = await AppStore.shots.record(id).delete(_store.db);
    return removed != null;
  }

  @override
  Future<bool> deleteShotsByRollId(String rollId) async {
    final removed = await AppStore.shots.delete(
      _store.db,
      finder: Finder(filter: Filter.equals('rollId', rollId)),
    );
    return removed > 0;
  }

  @override
  Future<List<Shot>> getShots(List<String> ids) async {
    final snaps = await AppStore.shots.records(ids).getSnapshots(_store.db);
    return [
      for (final s in snaps)
        if (s != null) Shot.fromMap(Map<String, Object?>.from(s.value)),
    ];
  }

  @override
  Future<List<Shot>> getShotsByRollId(String? id) async {
    if (id == null) return [];
    final snaps = await AppStore.shots.find(
      _store.db,
      finder: Finder(
        filter: Filter.equals('rollId', id),
        sortOrders: [SortOrder('idx')],
      ),
    );
    return snaps
        .map((s) => Shot.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
  }

  @override
  Future<List<Shot>> getAllShots() async {
    final snaps = await AppStore.shots.find(_store.db);
    return snaps
        .map((s) => Shot.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
  }

  @override
  Future<void> updateShot(Shot shot) async {
    await AppStore.shots.record(shot.id).put(_store.db, shot.toMap());
  }
}
