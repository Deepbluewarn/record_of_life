import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';

class Roll {
  final String id = DateTime.now().toString();
  final Camera? camera;
  final Film? film;

  final String? title;
  final int? totalShots;
  final int? shotsDone;
  final String? memo;

  DateTime? startedAt = DateTime.now();
  final DateTime? endedAt;

  Roll({
    this.camera,
    this.film,
    this.title,
    this.totalShots,
    this.shotsDone,
    this.memo,
    this.startedAt,
    this.endedAt,
  });

  @override
  String toString() {
    return 'Roll(id: $id, camera: ${camera?.title}, film: ${film?.name}, title: $title, totalShots: $totalShots, shotsDone: $shotsDone, memo: $memo, startedAt: $startedAt, endedAt: $endedAt)';
  }
}
