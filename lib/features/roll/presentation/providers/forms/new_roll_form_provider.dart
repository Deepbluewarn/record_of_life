import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';

class NewRollFormState {
  final Camera? camera;
  final Film? film;
  final String? defaultLensId;
  final String? title;
  final int totalShots;
  final int? shotsDone;
  final String? memo;
  DateTime? startedAt = DateTime.now();
  final DateTime? endedAt;
  final RollStatus? status;
  final String? labId;
  final DateTime? sentToLabAt;
  final DateTime? expectedReturnAt;

  NewRollFormState({
    this.camera,
    this.film,
    this.defaultLensId,
    this.title,
    this.totalShots = 36,
    this.shotsDone,
    this.memo,
    this.startedAt,
    this.endedAt,
    this.status,
    this.labId,
    this.sentToLabAt,
    this.expectedReturnAt,
  });

  NewRollFormState copyWith({
    Camera? camera,
    Film? film,
    String? defaultLensId,
    String? title,
    int? totalShots,
    int? shotsDone,
    String? memo,
    DateTime? startedAt,
    DateTime? endedAt,
    RollStatus? status,
    String? labId,
    DateTime? sentToLabAt,
    DateTime? expectedReturnAt,
  }) {
    return NewRollFormState(
      camera: camera ?? this.camera,
      film: film ?? this.film,
      defaultLensId: defaultLensId ?? this.defaultLensId,
      title: title ?? this.title,
      totalShots: totalShots ?? this.totalShots,
      shotsDone: shotsDone ?? this.shotsDone,
      memo: memo ?? this.memo,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      labId: labId ?? this.labId,
      sentToLabAt: sentToLabAt ?? this.sentToLabAt,
      expectedReturnAt: expectedReturnAt ?? this.expectedReturnAt,
    );
  }

  bool get isComplete {
    return camera != null && film != null && title != null;
  }

  Roll toRoll({String? rollId}) {
    return Roll(
      id: rollId,
      camera: camera,
      film: film,
      defaultLensId: defaultLensId,
      title: title,
      totalShots: totalShots,
      shotsDone: shotsDone ?? 0,
      memo: memo,
      startedAt: startedAt,
      endedAt: endedAt,
      status: status,
      labId: labId,
      sentToLabAt: sentToLabAt,
      expectedReturnAt: expectedReturnAt,
    );
  }
}

class NewRollFormNotifier extends Notifier<NewRollFormState> {
  final Roll? _roll;

  NewRollFormNotifier(this._roll);

  @override
  NewRollFormState build() {
    if (_roll != null) {
      return NewRollFormState(
        camera: _roll.camera,
        film: _roll.film,
        defaultLensId: _roll.defaultLensId,
        title: _roll.title,
        totalShots: _roll.totalShots,
        shotsDone: _roll.shotsDone,
        memo: _roll.memo,
        startedAt: _roll.startedAt,
        endedAt: _roll.endedAt,
        status: _roll.status,
        labId: _roll.labId,
        sentToLabAt: _roll.sentToLabAt,
        expectedReturnAt: _roll.expectedReturnAt,
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

  void setDefaultLensId(String? lensId) {
    state = state.copyWith(defaultLensId: lensId);
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

  void setLabId(String? labId) {
    state = state.copyWith(labId: labId);
  }

  void setSentToLabAt(DateTime? d) {
    state = state.copyWith(sentToLabAt: d);
  }

  void setExpectedReturnAt(DateTime? d) {
    state = state.copyWith(expectedReturnAt: d);
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
