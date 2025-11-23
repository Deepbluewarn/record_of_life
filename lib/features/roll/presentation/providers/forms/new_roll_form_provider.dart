import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';

class NewRollFormState {
  final Camera? camera;
  final Film? film;
  final String? title;
  final int totalShots;
  final int? shotsDone;
  final String? memo;
  DateTime? startedAt = DateTime.now();
  final DateTime? endedAt;
  final RollStatus? status;

  NewRollFormState({
    this.camera,
    this.film,
    this.title,
    this.totalShots = 36,
    this.shotsDone,
    this.memo,
    this.startedAt,
    this.endedAt,
    this.status,
  });

  NewRollFormState copyWith({
    Camera? camera,
    Film? film,
    String? title,
    int? totalShots,
    int? shotsDone,
    String? memo,
    DateTime? startedAt,
    DateTime? endedAt,
    RollStatus? status,
  }) {
    return NewRollFormState(
      camera: camera ?? this.camera,
      film: film ?? this.film,
      title: title ?? this.title,
      totalShots: totalShots ?? this.totalShots,
      shotsDone: shotsDone ?? this.shotsDone,
      memo: memo ?? this.memo,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
    );
  }

  // 폼 완성도 체크 (저장 가능 여부)
  bool get isComplete {
    return camera != null && film != null && title != null;
  }

  // Roll 객체로 변환 (저장할 때)
  Roll toRoll({String? rollId}) {
    return Roll(
      id: rollId,
      camera: camera,
      film: film,
      title: title,
      totalShots: totalShots,
      shotsDone: shotsDone ?? 0,
      memo: memo,
      endedAt: endedAt,
      status: status,
    );
  }
}

class NewRollFormNotifier extends Notifier<NewRollFormState> {
  final Roll? _roll;

  NewRollFormNotifier(this._roll);

  @override
  NewRollFormState build() {
    // ✅ roll이 있으면 해당 데이터로 초기화
    if (_roll != null) {
      return NewRollFormState(
        camera: _roll.camera,
        film: _roll.film,
        title: _roll.title,
        totalShots: _roll.totalShots,
        shotsDone: _roll.shotsDone,
        memo: _roll.memo,
        startedAt: _roll.startedAt,
        endedAt: _roll.endedAt,
        status: _roll.status,
      );
    }

    // ✅ roll이 없으면 빈 상태로 초기화
    return NewRollFormState();
  }

  void setCamera(Camera camera) {
    state = state.copyWith(camera: camera);
  }

  void setFilm(Film film) {
    state = state.copyWith(film: film);
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setTotalShots(int totalShots) {
    state = state.copyWith(totalShots: totalShots);
  }

  void setShotsDone(int shotsDone) {
    state = state.copyWith(shotsDone: shotsDone);
  }

  void setMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  void setStartedAt(DateTime startedAt) {
    state = state.copyWith(startedAt: startedAt);
  }

  void setEndedAt(DateTime endedAt) {
    state = state.copyWith(endedAt: endedAt);
  }

  void setStatus(RollStatus status) {
    state = state.copyWith(status: status);
  }

  void reset() {
    state = NewRollFormState();
  }

  void save() {}
}

final newRollFormProvider = NotifierProvider.family
    .autoDispose<NewRollFormNotifier, NewRollFormState, Roll?>(
      NewRollFormNotifier.new,
    );
