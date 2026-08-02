// T1 스키마 v1 파서. 모바일 앱의 buildRolJson과 왕복 대응.
// 데스크탑은 UI 표시·매칭·주입만 하므로 필드는 최소 subset.

import 'dart:convert';
import 'dart:io';

class RolExport {
  final int schema;
  final String? artist;
  final Roll roll;

  RolExport({required this.schema, this.artist, required this.roll});

  static RolExport fromFile(File f) {
    final raw = jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
    return RolExport.fromMap(raw);
  }

  static RolExport fromMap(Map<String, Object?> m) {
    final schema = m['schema'] as int? ?? 0;
    if (schema != 1) {
      throw FormatException('unsupported .rol.json schema: $schema (expected 1)');
    }
    return RolExport(
      schema: schema,
      artist: m['artist'] as String?,
      roll: Roll.fromMap(Map<String, Object?>.from(m['roll'] as Map)),
    );
  }
}

class Roll {
  final String id;
  final String? name;
  final String? filmName;
  final int? filmIso;
  final String? cameraTitle;
  final String? cameraMake;
  final int? pushPull;
  final List<Lens> lenses;
  final List<Shot> shots;

  Roll({
    required this.id,
    this.name,
    this.filmName,
    this.filmIso,
    this.cameraTitle,
    this.cameraMake,
    this.pushPull,
    required this.lenses,
    required this.shots,
  });

  factory Roll.fromMap(Map<String, Object?> m) {
    final film = m['film'] as Map?;
    final cam = m['camera'] as Map?;
    return Roll(
      id: m['id'] as String,
      name: m['name'] as String?,
      filmName: film?['name'] as String?,
      filmIso: film?['iso'] as int?,
      cameraTitle: (cam?['title'] ?? cam?['model']) as String?,
      cameraMake: cam?['make'] as String?,
      pushPull: m['pushPull'] as int?,
      lenses: [
        for (final l in (m['lenses'] as List? ?? const []))
          Lens.fromMap(Map<String, Object?>.from(l as Map)),
      ],
      shots: [
        for (final s in (m['shots'] as List? ?? const []))
          Shot.fromMap(Map<String, Object?>.from(s as Map)),
      ]..sort((a, b) => a.idx.compareTo(b.idx)),
    );
  }

  String get summaryLine {
    final parts = <String>[
      ?name,
      ?filmName,
      ?cameraTitle,
      '${shots.length} frames',
    ];
    return parts.join(' · ');
  }
}

class Lens {
  final String id;
  final String model;
  final String? make;
  final int? focalLength;
  Lens({required this.id, required this.model, this.make, this.focalLength});
  factory Lens.fromMap(Map<String, Object?> m) => Lens(
        id: m['id'] as String,
        model: m['model'] as String,
        make: m['make'] as String?,
        focalLength: m['focalLength'] as int?,
      );
}

class Shot {
  final int idx;
  final double? aperture;
  final String? shutterSpeed;
  final int? iso;
  final int? focalLength;
  final double? exposureComp;
  final String? lensId;
  final bool? flash;
  final String? date;
  final int? rating;
  final String? note;

  Shot({
    required this.idx,
    this.aperture,
    this.shutterSpeed,
    this.iso,
    this.focalLength,
    this.exposureComp,
    this.lensId,
    this.flash,
    this.date,
    this.rating,
    this.note,
  });

  factory Shot.fromMap(Map<String, Object?> m) => Shot(
        idx: m['idx'] as int,
        aperture: (m['aperture'] as num?)?.toDouble(),
        shutterSpeed: m['shutterSpeed'] as String?,
        iso: m['iso'] as int?,
        focalLength: m['focalLength'] as int?,
        exposureComp: (m['exposureComp'] as num?)?.toDouble(),
        lensId: m['lensId'] as String?,
        flash: m['flash'] as bool?,
        date: m['date'] as String?,
        rating: m['rating'] as int?,
        note: m['note'] as String?,
      );

  // T2 매칭 UI에 한 줄로 표시할 요약.
  String get summary {
    final parts = <String>[];
    if (aperture != null) parts.add('f/$aperture');
    if (shutterSpeed != null) parts.add(shutterSpeed!);
    if (iso != null) parts.add('ISO $iso');
    if (focalLength != null) parts.add('${focalLength}mm');
    return parts.isEmpty ? '(no meta)' : parts.join(' · ');
  }
}
