// Shot Repository Implementation
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/domain/repositories/shot_repository.dart';

class ShotRepositoryImpl extends ShotRepository {
  final List<Shot> _shots = [];

  @override
  Future<void> addShot(Shot shot) async {
    _shots.add(shot);
  }

  @override
  Future<bool> deleteShot(String id) async {
    _shots.removeWhere((shot) => shot.id == id);

    return true;
  }

  @override
  Future<bool> deleteShotsByRollId(String rollId) async {
    _shots.removeWhere((s) => s.rollId == rollId);

    return true;
  }

  @override
  Future<List<Shot>> getShots(List<String> ids) async {
    return (_shots.where((s) => ids.contains(s.id))).toList();
  }

  @override
  Future<List<Shot>> getShotsByRollId(String? id) async {
    if (id == null) {
      return [];
    }
    return (_shots.where((s) => s.rollId == id)).toList();
  }

  @override
  Future<List<Shot>> getAllShots() async {
    return [..._shots];
  }

  @override
  Future<void> updateShot(Shot shot) async {
    final idx = _shots.indexWhere((s) => s.id == shot.id);
    if (idx > 0) {
      _shots[idx] = shot;
    }
  }
}
