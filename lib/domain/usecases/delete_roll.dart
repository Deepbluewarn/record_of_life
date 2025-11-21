import 'package:record_of_life/infra/repositories_impl/roll_repository_impl.dart';
import 'package:record_of_life/infra/repositories_impl/shot_repository_impl.dart';

class DeleteRoll {
  final RollRepositoryImpl rollRepository;
  final ShotRepositoryImpl shotRepository;
  final String targetRollId;

  DeleteRoll({
    required this.rollRepository,
    required this.shotRepository,
    required this.targetRollId,
  });

  Future<void> delete() async {
    await shotRepository.deleteShotsByRollId(targetRollId);
    await rollRepository.deleteRoll(targetRollId);
  }
}
