import 'package:sembast/sembast.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/models/lab.dart';
import 'package:record_of_life/domain/repositories/lab_repository.dart';

class LabRepositoryImpl extends LabRepository {
  final AppStore _store;
  LabRepositoryImpl(this._store);

  @override
  Future<void> addLab(Lab lab) async {
    await AppStore.labs.record(lab.id).put(_store.db, lab.toMap());
  }

  @override
  Future<bool> deleteLab(String id) async {
    final removed = await AppStore.labs.record(id).delete(_store.db);
    return removed != null;
  }

  @override
  Future<Lab?> getLab(String id) async {
    final snap = await AppStore.labs.record(id).getSnapshot(_store.db);
    if (snap == null) return null;
    return Lab.fromMap(Map<String, Object?>.from(snap.value));
  }

  @override
  Future<List<Lab>> getAllLabs() async {
    final snaps = await AppStore.labs.find(_store.db);
    final list = snaps
        .map((s) => Lab.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
    list.sort(_byRecency);
    return list;
  }

  @override
  Future<void> updateLab(Lab lab) async {
    await AppStore.labs.record(lab.id).put(_store.db, lab.toMap());
  }

  @override
  Future<void> touchLab(String id) async {
    await AppStore.labs.record(id).update(_store.db, {
      'lastUsedAt': DateTime.now().toIso8601String(),
    });
  }
}

int _byRecency(Lab a, Lab b) {
  final aT = a.lastUsedAt;
  final bT = b.lastUsedAt;
  if (aT == null && bT == null) return a.title.compareTo(b.title);
  if (aT == null) return 1;
  if (bT == null) return -1;
  return bT.compareTo(aT);
}
