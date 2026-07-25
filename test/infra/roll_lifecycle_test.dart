import 'package:flutter_test/flutter_test.dart';
import 'package:record_of_life/data/store.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/infra/repositories_impl/roll_repository_impl.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late AppStore store;
  late RollRepositoryImpl repo;

  setUp(() async {
    final db = await databaseFactoryMemory.openDatabase('test.db');
    store = AppStore(db);
    repo = RollRepositoryImpl(store);
  });

  test('planning → 첫 샷 저장 시 inProgress로 자동 승격', () async {
    final r = Roll(
      id: 'r1',
      title: 't',
      totalShots: 36,
      status: RollStatus.planning,
    );
    await repo.addRolls([r]);
    await repo.incrementShotsDone('r1');

    final loaded = (await repo.getRolls(['r1'])).first;
    expect(loaded.status, RollStatus.inProgress);
    expect(loaded.shotsDone, 1);
  });

  test('inProgress + shotsDone이 totalShots 도달 → completed + endedAt', () async {
    final r = Roll(
      id: 'r1',
      title: 't',
      totalShots: 3,
      shotsDone: 2,
      status: RollStatus.inProgress,
    );
    await repo.addRolls([r]);
    await repo.incrementShotsDone('r1');

    final loaded = (await repo.getRolls(['r1'])).first;
    expect(loaded.status, RollStatus.completed);
    expect(loaded.shotsDone, 3);
    expect(loaded.endedAt, isNotNull);
  });

  test('총 매수 초과: shotsDone > totalShots 저장은 가능, 상태 변경 없음', () async {
    final r = Roll(
      id: 'r1',
      title: 't',
      totalShots: 3,
      shotsDone: 3,
      status: RollStatus.completed,
    );
    await repo.addRolls([r]);
    await repo.incrementShotsDone('r1');

    final loaded = (await repo.getRolls(['r1'])).first;
    expect(loaded.shotsDone, 4);
    expect(loaded.status, RollStatus.completed); // 그대로
  });
}
