import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';

class Roll {
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
}
