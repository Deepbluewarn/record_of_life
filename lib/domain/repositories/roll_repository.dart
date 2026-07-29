import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';

abstract class RollRepository {
  Future<List<Roll>> getRolls(List<String> rollId);
  Future<List<Roll>> getAllRolls();
  Future<void> addRolls(List<Roll> newRolls);
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
  });
  Future<bool> deleteRoll(String rollId);
  Future<void> incrementShotsDone(String rollId);
}
