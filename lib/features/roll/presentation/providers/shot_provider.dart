import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/shot.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/roll_provider.dart';

class ShotState {
  final List<Shot> shots;

  ShotState({required this.shots});
}

class ShotNotifier extends AsyncNotifier<ShotState> {
  ShotNotifier(this.rollId);
  final String? rollId;

  @override
  Future<ShotState> build() async {
    final shotsRepository = ref.watch(shotRepositoryProvider);
    final list = await shotsRepository.getShotsByRollId(rollId);
    return ShotState(shots: list);
  }

  Future<void> addShot(Shot shot) async {
    final shotsRepository = ref.read(shotRepositoryProvider);
    final rollRepository = ref.read(rollRepositoryProvider);

    if (rollId == null) {
      return;
    }

    await shotsRepository.addShot(shot);
    await rollRepository.incrementShotsDone(rollId!);
    state.whenData((currentState) {
      final updatedShots = [...currentState.shots, shot];
      state = AsyncValue.data(ShotState(shots: updatedShots));
    });
    ref.invalidate(rollProvider);
  }

  Future<void> deleteShot(String shotId) async {
    final shotsRepository = ref.read(shotRepositoryProvider);
    await shotsRepository.deleteShot(shotId);
  }

  Future<void> updateShot(Shot shot) async {
    final shotsRepository = ref.read(shotRepositoryProvider);
    await shotsRepository.updateShot(shot);

    state.whenData((currentState) {
      final shots = currentState.shots.where((s) => s.id != shot.id);
      final updatedShots = [...shots, shot];
      state = AsyncValue.data(ShotState(shots: updatedShots));
    });
  }
}

final shotProvider =
    AsyncNotifierProvider.family<ShotNotifier, ShotState, String?>(
      ShotNotifier.new,
    );
