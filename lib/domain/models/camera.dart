import 'package:record_of_life/domain/models/lens.dart';

class Camera {
  final String id;
  final String title;
  String? brand; // Canon
  String? format; // 35mm, 120, Half
  String? mount; // FD, M42, etc.
  String? notes; // 상태/메모

  final List<Lens> lenses;

  Camera({
    required this.id,
    required this.lenses,
    required this.title,
    this.brand,
    this.format,
    this.mount,
    this.notes,
  });
}
