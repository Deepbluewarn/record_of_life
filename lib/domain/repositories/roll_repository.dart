import 'package:record_of_life/domain/models/roll.dart';

abstract class RollRepository {
  Future<List<Roll>> getRolls(List<String> rollId);
  Future<void> addRolls(List<Roll> newRolls);
  Future<Roll> updateRoll(Roll roll);
  Future<bool> deleteRoll(String rollId);
}
