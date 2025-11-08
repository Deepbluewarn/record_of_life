import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';

class Roll {
  final Camera camera;
  final Film film;

  final String title;
  int? totalShots;
  int? shotsDone;
  String? memo;

  DateTime startedAt = DateTime.now();
  DateTime? endedAt;

  Roll({
    required this.camera,
    required this.film,
    required this.title,
    this.totalShots,
    this.shotsDone,
    this.memo,
    this.endedAt,
  });
}
