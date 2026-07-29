import 'package:sembast/sembast.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/repositories/roll_repository.dart';

class RollRepositoryImpl extends RollRepository {
  final AppStore _store;
  RollRepositoryImpl(this._store);

  @override
  Future<void> addRolls(List<Roll> newRolls) async {
    await _store.db.transaction((txn) async {
      for (final r in newRolls) {
        await AppStore.rolls.record(r.id).put(txn, r.toMap());
      }
    });
  }

  @override
  Future<bool> deleteRoll(String rollId) async {
    final removed = await AppStore.rolls.record(rollId).delete(_store.db);
    return removed != null;
  }

  @override
  Future<List<Roll>> getRolls(List<String> rollIds) async {
    if (rollIds.isEmpty) return getAllRolls();
    final snaps = await AppStore.rolls.records(rollIds).getSnapshots(_store.db);
    return [
      for (final s in snaps)
        if (s != null) Roll.fromMap(Map<String, Object?>.from(s.value)),
    ];
  }

  @override
  Future<List<Roll>> getAllRolls() async {
    final snaps = await AppStore.rolls.find(
      _store.db,
      finder: Finder(sortOrders: [SortOrder('startedAt', false)]),
    );
    return snaps
        .map((s) => Roll.fromMap(Map<String, Object?>.from(s.value)))
        .toList();
  }

  @override
  Future<void> updateRoll(
    String rollId, {
    String? title,
    String? memo,
    int? shotsDone,
    int? totalShots,
    RollStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    String? labId,
    DateTime? sentToLabAt,
    DateTime? expectedReturnAt,
  }) async {
    final snap = await AppStore.rolls.record(rollId).getSnapshot(_store.db);
    if (snap == null) return;
    final current = Roll.fromMap(Map<String, Object?>.from(snap.value));
    final updated = current.copyWith(
      title: title,
      memo: memo,
      shotsDone: shotsDone,
      totalShots: totalShots,
      status: status,
      startedAt: startedAt,
      endedAt: endedAt,
      labId: labId,
      sentToLabAt: sentToLabAt,
      expectedReturnAt: expectedReturnAt,
    );
    await AppStore.rolls.record(rollId).put(_store.db, updated.toMap());
  }

  @override
  Future<void> incrementShotsDone(String rollId) async {
    await _store.db.transaction((txn) async {
      final snap = await AppStore.rolls.record(rollId).getSnapshot(txn);
      if (snap == null) return;
      final current = Roll.fromMap(Map<String, Object?>.from(snap.value));
      final next = current.shotsDone + 1;
      // 첫 사진 추가 시 planning → inProgress. 그 외 자동 전이 없음
      // (현상중/보관 전이는 명시적 버튼으로만).
      final nextStatus = current.status == RollStatus.planning
          ? RollStatus.inProgress
          : null;
      await AppStore.rolls.record(rollId).put(
        txn,
        current.copyWith(shotsDone: next, status: nextStatus).toMap(),
      );
    });
  }
}
