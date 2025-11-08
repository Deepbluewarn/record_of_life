// Roll Repository Implementation
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/repositories/roll_repository.dart';

class RollRepositoryImpl extends RollRepository {
  final List<Roll> _rolls = [];
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
    return _rolls;
  }

  @override
  Future<void> updateRoll(Roll roll) async {
    final index = _rolls.indexWhere((r) => r.id == roll.id);
    if (index >= 0) {
      _rolls[index] = roll;
    }
  }
}
