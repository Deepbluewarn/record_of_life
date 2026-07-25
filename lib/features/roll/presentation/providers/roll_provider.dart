import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/features/roll/presentation/providers/repository_provider.dart';
import 'package:record_of_life/features/roll/presentation/providers/shot_provider.dart';

class RollFilter {
  final String? rollId;
  final RollStatus? status;
  final bool? isActive; // true = archived 제외

  const RollFilter({this.rollId, this.status, this.isActive});

  static const all = RollFilter();
  static const active = RollFilter(isActive: true);
  static const inactive = RollFilter(isActive: false);
  static const inProgress = RollFilter(status: RollStatus.inProgress);
  static const completed = RollFilter(status: RollStatus.completed);
  static const archived = RollFilter(status: RollStatus.archived);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RollFilter &&
          runtimeType == other.runtimeType &&
          rollId == other.rollId &&
          status == other.status &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(rollId, status, isActive);
}

class RollState {
  final List<Roll> rolls;

  RollState({required this.rolls});
}

class RollNotifier extends AsyncNotifier<RollState> {
  RollNotifier(this.filter);
  RollFilter? filter;

  @override
  Future<RollState> build() async {
    final rollRepository = ref.watch(rollRepositoryProvider);
    var allRolls = await rollRepository.getAllRolls();

    final localFilter = filter; // 지역 변수로 복사

    if (localFilter == null) return RollState(rolls: allRolls);

    final filteredRolls = allRolls.where((roll) {
      if (localFilter.rollId != null && roll.id != localFilter.rollId) {
        return false;
      }
      if (localFilter.status != null && roll.status != localFilter.status) {
        return false;
      }
      if (localFilter.isActive != null) {
        final rollIsActive = roll.status != RollStatus.archived;
        if (rollIsActive != localFilter.isActive) {
          return false;
        }
      }
      return true;
    }).toList();

    return RollState(rolls: filteredRolls);
  }

  Future<void> addRoll(Roll roll) async {
    final rollRepository = ref.read(rollRepositoryProvider);
    await rollRepository.addRolls([roll]);
    // family 전체 무효화 — 다른 필터 인스턴스도 refetch.
    ref.invalidate(rollProvider);
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

    ref.invalidate(rollProvider);
    // final rolls = await rollRepository.getAllRolls();

    // state = AsyncValue.data(RollState(rolls: rolls));
  }

  Future<void> deleteRoll(String rollId) async {
    final rollRepository = ref.read(rollRepositoryProvider);
    final shotRepository = ref.read(shotRepositoryProvider);

    await shotRepository.deleteShotsByRollId(rollId);
    await rollRepository.deleteRoll(rollId);

    ref.invalidate(rollProvider);
    ref.invalidate(shotProvider(rollId));
  }
}

final rollProvider =
    AsyncNotifierProvider.family<RollNotifier, RollState, RollFilter?>(
      RollNotifier.new,
    );
