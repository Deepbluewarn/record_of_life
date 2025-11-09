import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/infra/repositories_impl/roll_repository_impl.dart';

class RollState {
  final List<Roll> rolls;

  RollState({required this.rolls});
}

class RollNotifier extends AsyncNotifier<RollState> {
  final rollRepository = RollRepositoryImpl();

  @override
  Future<RollState> build() async {
    var allRolls = await rollRepository.getAllRolls();
    return RollState(rolls: allRolls);
  }

  void addRoll(Roll roll) async {
    await rollRepository.addRolls([roll]);
    final rolls = await rollRepository.getAllRolls();

    state = AsyncValue.data(RollState(rolls: rolls));
  }
}

final rollProvider = AsyncNotifierProvider.autoDispose<RollNotifier, RollState>(
  RollNotifier.new,
);
