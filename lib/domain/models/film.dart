import 'package:uuid/uuid.dart';

class Film {
  final String id;
  final String name;
  final String? brand;
  final int? iso;
  final String? format;
  final String? note;
  final DateTime? lastUsedAt;
  final bool owned;

  Film({
    String? id,
    required this.name,
    this.format,
    this.brand,
    this.iso,
    this.note,
    this.lastUsedAt,
    this.owned = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'brand': brand,
    'iso': iso,
    'format': format,
    'note': note,
    'lastUsedAt': lastUsedAt?.toIso8601String(),
    'owned': owned,
  };

  factory Film.fromMap(Map<String, Object?> m) => Film(
    id: m['id'] as String,
    name: m['name'] as String,
    brand: m['brand'] as String?,
    iso: m['iso'] as int?,
    format: m['format'] as String?,
    note: m['note'] as String?,
    lastUsedAt: m['lastUsedAt'] == null
        ? null
        : DateTime.parse(m['lastUsedAt'] as String),
    owned: m['owned'] as bool? ?? false,
  );
}
