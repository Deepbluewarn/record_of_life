import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/usecases/delete_roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';

class RollState {
  final List<Roll> rolls;

  RollState({required this.rolls});
}

class RollNotifier extends AsyncNotifier<RollState> {
  @override
  Future<RollState> build() async {
    final rollRepository = ref.watch(rollRepositoryProvider);
    var allRolls = await rollRepository.getAllRolls();
    return RollState(rolls: allRolls);
  }

  Future<void> addRoll(Roll roll) async {
    final rollRepository = ref.read(rollRepositoryProvider);
    await rollRepository.addRolls([roll]);
    final rolls = await rollRepository.getAllRolls();

    state = AsyncValue.data(RollState(rolls: rolls));
  }

  Future<void> updateRoll(Roll roll) async {
    final rollRepository = ref.read(rollRepositoryProvider);

    await rollRepository.updateRoll(
      roll.id,
      title: roll.title,
      memo: roll.memo,
      shotsDone: roll.shotsDone,
      totalShots: roll.totalShots,
      status: roll.status,
      startedAt: roll.startedAt,
      endedAt: roll.endedAt,
    );

    final rolls = await rollRepository.getAllRolls();

    state = AsyncValue.data(RollState(rolls: rolls));
  }

  Future<void> deleteRoll(String rollId) async {
    final rollRepository = ref.read(rollRepositoryProvider);
    final shotRepository = ref.read(shotRepositoryProvider);

    await DeleteRoll(
      rollRepository: rollRepository,
      shotRepository: shotRepository,
      targetRollId: rollId,
    ).delete();

    final rolls = await rollRepository.getAllRolls();

    state = AsyncValue.data(RollState(rolls: rolls));

    ref.invalidate(shotProvider(rollId));
  }
}

final rollProvider = AsyncNotifierProvider<RollNotifier, RollState>(
  RollNotifier.new,
);
