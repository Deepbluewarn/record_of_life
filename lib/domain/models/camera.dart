import 'package:uuid/uuid.dart';

class Camera {
  final String id;
  final String title;
  final String? brand; // Canon
  final String? format; // 35mm, 120, Half
  final String? mount; // FD, M42, etc.
  final String? notes;

  Camera({
    String? id,
    required this.title,
    this.brand,
    this.format,
    this.mount,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'brand': brand,
    'format': format,
    'mount': mount,
    'notes': notes,
  };

  factory Camera.fromMap(Map<String, Object?> m) => Camera(
    id: m['id'] as String,
    title: m['title'] as String,
    brand: m['brand'] as String?,
    format: m['format'] as String?,
    mount: m['mount'] as String?,
    notes: m['notes'] as String?,
  );
}
