import 'package:uuid/uuid.dart';

class Lens {
  final String id;
  final String name;
  final String? brand;
  final int? focalLength;
  final double? maxAperture;
  final String? mount;
  final String? coating;
  final String? type;
  final String? notes;
  final DateTime? lastUsedAt;

  Lens({
    String? id,
    required this.name,
    this.brand,
    this.focalLength,
    this.maxAperture,
    this.mount,
    this.coating,
    this.notes,
    this.type,
    this.lastUsedAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'brand': brand,
    'focalLength': focalLength,
    'maxAperture': maxAperture,
    'mount': mount,
    'coating': coating,
    'type': type,
    'notes': notes,
    'lastUsedAt': lastUsedAt?.toIso8601String(),
  };

  factory Lens.fromMap(Map<String, Object?> m) => Lens(
    id: m['id'] as String,
    name: m['name'] as String,
    brand: m['brand'] as String?,
    focalLength: m['focalLength'] as int?,
    maxAperture: (m['maxAperture'] as num?)?.toDouble(),
    mount: m['mount'] as String?,
    coating: m['coating'] as String?,
    type: m['type'] as String?,
    notes: m['notes'] as String?,
    lastUsedAt: m['lastUsedAt'] == null
        ? null
        : DateTime.parse(m['lastUsedAt'] as String),
  );
}
