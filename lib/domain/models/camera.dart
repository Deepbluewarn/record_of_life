import 'package:uuid/uuid.dart';

class Camera {
  final String id;
  final String title;
  final String? brand;
  final String? format;
  final String? mount;
  final String? notes;
  final DateTime? lastUsedAt;

  Camera({
    String? id,
    required this.title,
    this.brand,
    this.format,
    this.mount,
    this.notes,
    this.lastUsedAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'brand': brand,
    'format': format,
    'mount': mount,
    'notes': notes,
    'lastUsedAt': lastUsedAt?.toIso8601String(),
  };

  factory Camera.fromMap(Map<String, Object?> m) => Camera(
    id: m['id'] as String,
    title: m['title'] as String,
    brand: m['brand'] as String?,
    format: m['format'] as String?,
    mount: m['mount'] as String?,
    notes: m['notes'] as String?,
    lastUsedAt: m['lastUsedAt'] == null
        ? null
        : DateTime.parse(m['lastUsedAt'] as String),
  );
}
