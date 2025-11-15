// Roll Repository Implementation
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/repositories/roll_repository.dart';

class RollRepositoryImpl extends RollRepository {
  final List<Roll> _rolls = [
    Roll(
      camera: Camera(title: 'Canon AE-1', brand: 'Canon', format: '35mm'),
      film: Film(
        name: 'Kodak Portra 400',
        brand: 'Kodak',
        iso: 400,
        format: '35mm',
      ),
      title: '필름 이름 예제',
      totalShots: 36,
      shotsDone: 0,
      memo: '일본 여행에서 촬영',
      status: RollStatus.completed,
      startedAt: DateTime(2025, 10, 25),
      endedAt: DateTime(2025, 10, 28),
    ),
    Roll(
      camera: Camera(title: 'Pentax K1000', brand: 'Pentax', format: '35mm'),
      film: Film(
        name: 'Fujifilm Superia 200',
        brand: 'Fujifilm',
        iso: 200,
        format: '35mm',
      ),
      title: '가을 산책',
      totalShots: 36,
      shotsDone: 0,
      memo: '공원에서의 자연 풍경',
      status: RollStatus.inProgress,
      startedAt: DateTime(2025, 10, 20),
    ),
    Roll(
      camera: Camera(title: 'Rolleiflex', brand: 'Rollei', format: '120'),
      film: Film(name: 'Tri-X 400', brand: 'Kodak', iso: 400, format: '120'),
      title: '흑백 실험',
      totalShots: 36,
      shotsDone: 0,
      memo: '흑백 필름 테스트',
      status: RollStatus.inProgress,
      startedAt: DateTime(2025, 10, 10),
    ),
  ];
  @override
  Future<void> addRolls(List<Roll> newRolls) async {
    _rolls.addAll(newRolls);
  }

  @override
  Future<bool> deleteRoll(String rollId) async {
    final initialLength = _rolls.length;
    _rolls.removeWhere((r) => r.id == rollId);
    return _rolls.length < initialLength;
  }

  @override
  Future<List<Roll>> getRolls(List<String> rollIds) async {
    if (rollIds.isEmpty) return _rolls;
    return _rolls.where((r) => rollIds.contains(r.id)).toList();
  }

  @override
  Future<List<Roll>> getAllRolls() async {
    return [..._rolls];
  }

  @override
  Future<void> updateRoll(
    String rollId, {
    String? title,
    String? memo,
    int? shotsDone,
    int? totalShots,
    RollStatus? status,
    DateTime? endedAt,
  }) async {
    final index = _rolls.indexWhere((r) => r.id == rollId);
    if (index >= 0) {
      _rolls[index] = _rolls[index].copyWith(
        title: title,
        memo: memo,
        shotsDone: shotsDone,
        totalShots: totalShots,
        status: status,
        endedAt: endedAt,
      );
    }
  }

  @override
  Future<void> incrementShotsDone(String rollId) async {
    final index = _rolls.indexWhere((r) => r.id == rollId);

    if (index >= 0) {
      final newShotsDone = _rolls[index].shotsDone + 1;
      final totalShots = _rolls[index].totalShots;

      if (newShotsDone > totalShots) {
        return;
      }
      _rolls[index] = _rolls[index].copyWith(shotsDone: newShotsDone);
    }
  }
}
