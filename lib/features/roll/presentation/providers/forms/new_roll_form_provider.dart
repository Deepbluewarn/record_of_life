import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/infra/repositories_impl/roll_repository_impl.dart';

class NewRollFormState {
  final Camera? camera;
  final Film? film;
  final String? title;
  final int? totalShots;
  final int? shotsDone;
  final String? memo;
  DateTime? startedAt = DateTime.now();
  final DateTime? endedAt;

  NewRollFormState({
    this.camera,
    this.film,
    this.title,
    this.totalShots,
    this.shotsDone,
    this.memo,
    this.startedAt,
    this.endedAt,
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
    );
  }

  // 폼 완성도 체크 (저장 가능 여부)
  bool get isComplete {
    return camera != null &&
        film != null &&
        title != null &&
        totalShots != null;
  }

  // Roll 객체로 변환 (저장할 때)
  Roll toRoll() {
    return Roll(
      camera: camera,
      film: film,
      title: title,
      totalShots: totalShots,
      shotsDone: shotsDone ?? 0,
      memo: memo,
      endedAt: endedAt,
    );
  }
}

class NewRollFormNotifier extends Notifier<NewRollFormState> {
  final repository = RollRepositoryImpl();

  @override
  NewRollFormState build() {
    return NewRollFormState();
  }

  void setCamera(Camera camera) {
    state = state.copyWith(camera: camera);
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void reset() {}

  void save() {}
}

final newRollFormProvider =
    NotifierProvider.autoDispose<NewRollFormNotifier, NewRollFormState>(
      NewRollFormNotifier.new,
    );
