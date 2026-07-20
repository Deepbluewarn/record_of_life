import 'package:sembast/sembast.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/domain/repositories/lens_repository.dart';

class LensRepositoryImpl extends LensRepository {
  final AppStore _store;
  LensRepositoryImpl(this._store);

  Future<List<Lens>> getAllLenses() async {
    final snaps = await AppStore.lenses.find(_store.db);
    return snaps
        .map((s) => Lens.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
  }

  @override
  Future<void> addLens(Lens lens) async {
    await AppStore.lenses.record(lens.id).put(_store.db, lens.toMap());
  }

  @override
  Future<bool> deleteLens(String id) async {
    final removed = await AppStore.lenses.record(id).delete(_store.db);
    return removed != null;
  }

  @override
  Future<List<Lens>> getLenses(List<String> ids) async {
    final snaps = await AppStore.lenses.records(ids).getSnapshots(_store.db);
    return [
      for (final s in snaps)
        if (s != null) Lens.fromMap(Map<String, Object?>.from(s.value)),
    ];
  }

  @override
  Future<void> updateLens(Lens lens) async {
    await AppStore.lenses.record(lens.id).put(_store.db, lens.toMap());
  }
}
