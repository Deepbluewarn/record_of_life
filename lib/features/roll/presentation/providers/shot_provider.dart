import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/infra/repositories_impl/shot_repository_impl.dart';

class ShotState {
  final List<Shot> shots;

  ShotState({required this.shots});
}

class ShotNotifier extends AsyncNotifier<ShotState> {
  final shotsRepository = ShotRepositoryImpl();

  ShotNotifier(this.rollId);
  final String? rollId;

  @override
  Future<ShotState> build() async {
    final list = await shotsRepository.getShotsByRollId(rollId);
    return ShotState(shots: list);
  }

  Future<void> addShot(Shot shot) async {
    await shotsRepository.addShot(shot);
    state.whenData((currentState) {
      final updatedShots = [...currentState.shots, shot];
      state = AsyncValue.data(ShotState(shots: updatedShots));
    });
  }

  Future<void> deleteShot(String shotId) async {
    await shotsRepository.deleteShot(shotId);
  }

  Future<void> updateShot(Shot shot) async {
    await shotsRepository.updateShot(shot);
  }
}

final shotProvider =
    AsyncNotifierProvider.family<ShotNotifier, ShotState, String?>(
      ShotNotifier.new,
    );
