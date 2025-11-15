import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:uuid/uuid.dart';

class Roll {
  final String id;
  final Camera? camera;
  final Film? film;

  final String? title;
  final int totalShots;
  final int shotsDone;
  final String? memo;
  final RollStatus status;

  final DateTime? startedAt;
  final DateTime? endedAt;

  Roll({
    String? id,
    this.camera,
    this.film,
    this.title,
    this.totalShots = 36,
    this.shotsDone = 0,
    this.memo,
    RollStatus? status,
    DateTime? startedAt,
    this.endedAt,
  }) : id = id ?? const Uuid().v4(),
       status = status ?? RollStatus.inProgress,
       startedAt = startedAt ?? DateTime.now();

  Roll copyWith({
    Camera? camera,
    Film? film,
    String? title,
    int? totalShots,
    int? shotsDone,
    String? memo,
    RollStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Roll(
      id: id,
      camera: camera ?? this.camera,
      film: film ?? this.film,
      title: title ?? this.title,
      totalShots: totalShots ?? this.totalShots,
      shotsDone: shotsDone ?? this.shotsDone,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  String toString() {
    return 'Roll(id: $id, camera: ${camera?.title}, film: ${film?.name}, title: $title, totalShots: $totalShots, shotsDone: $shotsDone, memo: $memo, startedAt: $startedAt, endedAt: $endedAt)';
  }
}
