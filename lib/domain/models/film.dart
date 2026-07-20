import 'package:uuid/uuid.dart';

class Film {
  final String id;
  final String name;
  final String? brand;
  final int? iso;
  final String? format;
  final String? note;

  Film({
    String? id,
    required this.name,
    this.format,
    this.brand,
    this.iso,
    this.note,
  }) : id = id ?? const Uuid().v4();

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'brand': brand,
    'iso': iso,
    'format': format,
    'note': note,
  };

  factory Film.fromMap(Map<String, Object?> m) => Film(
    id: m['id'] as String,
    name: m['name'] as String,
    brand: m['brand'] as String?,
    iso: m['iso'] as int?,
    format: m['format'] as String?,
    note: m['note'] as String?,
  );
}
