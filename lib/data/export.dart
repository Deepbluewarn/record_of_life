import 'dart:convert';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';

// T1 스키마 v1. 데스크탑 companion 앱이 소비하는 롤 단위 export.
String buildRolJson({
  required Roll roll,
  required List<Shot> shots,
  required List<Lens> lenses,
  String? artist,
  DateTime? exportedAt,
}) {
  final lensById = {for (final l in lenses) l.id: l};
  final sorted = [...shots]..sort((a, b) => a.idx.compareTo(b.idx));

  final usedLensIds = <String>{
    if (roll.defaultLensId != null) roll.defaultLensId!,
    for (final s in sorted)
      if (s.lensId != null) s.lensId!,
  };

  final lensList = <Map<String, Object?>>[];
  for (final id in usedLensIds) {
    final l = lensById[id];
    if (l == null) continue;
    lensList.add({
      'id': l.id,
      if (l.brand != null) 'make': l.brand,
      'model': l.name,
      if (l.focalLength != null) 'focalLength': l.focalLength,
    });
  }

  final shotMaps = <Map<String, Object?>>[];
  for (final s in sorted) {
    shotMaps.add({
      'idx': s.idx,
      if (s.aperture != null) 'aperture': s.aperture!.value,
      if (s.shutterSpeed != null)
        'shutterSpeed': _shutter(s.shutterSpeed!.value),
      if (s.iso != null) 'iso': s.iso,
      if (s.focalLength != null) 'focalLength': s.focalLength,
      if (s.exposureComp != null) 'exposureComp': s.exposureComp!.value,
      if (s.lensId != null) 'lensId': s.lensId,
      if (s.flash != null) 'flash': s.flash,
      if (s.date != null) 'date': s.date!.toIso8601String(),
      if (s.rating != null) 'rating': s.rating,
      if (s.note != null && s.note!.isNotEmpty) 'note': s.note,
      if (s.gpsLat != null) 'gpsLat': s.gpsLat,
      if (s.gpsLng != null) 'gpsLng': s.gpsLng,
    });
  }

  final data = <String, Object?>{
    'schema': 1,
    'exportedAt': (exportedAt ?? DateTime.now()).toIso8601String(),
    if (artist != null && artist.isNotEmpty) 'artist': artist,
    'roll': {
      'id': roll.id,
      if (roll.title != null) 'name': roll.title,
      if (roll.film != null)
        'film': {
          'name': roll.film!.name,
          if (roll.film!.iso != null) 'iso': roll.film!.iso,
        },
      if (roll.camera != null)
        'camera': {
          if (roll.camera!.brand != null) 'make': roll.camera!.brand,
          'model': roll.camera!.title,
          'title': roll.camera!.title,
        },
      if (roll.pushPull != null && roll.pushPull != 0) 'pushPull': roll.pushPull,
      'lenses': lensList,
      'shots': shotMaps,
    },
  };

  return const JsonEncoder.withIndent('  ').convert(data);
}

// T9 + T5. 터미널 사용자용 exiftool argfile. 각 shot을 -execute 블록으로 배치.
// 사용자는 스캔 파일을 frame_NNN.<ext>로 리네임 후 `exiftool -@ this.args` 실행.
String buildArgfile({
  required Roll roll,
  required List<Shot> shots,
  required List<Lens> lenses,
  String? artist,
  String defaultExt = 'jpg',
}) {
  final lensById = {for (final l in lenses) l.id: l};
  final sorted = [...shots]..sort((a, b) => a.idx.compareTo(b.idx));
  final buf = StringBuffer();

  buf
    ..writeln('# ROL exiftool argfile')
    ..writeln('# Roll: ${roll.title ?? roll.id}')
    ..writeln('# Usage: exiftool -@ this.args -overwrite_original_in_place')
    ..writeln('# 스캔 파일명 규칙: frame_001.$defaultExt (zero-padded).')
    ..writeln('#   확장자가 다르면 아래 파일명 라인의 확장자를 바꿔 실행.')
    ..writeln('# XMP-rol:* 커스텀 태그는 .ExifTool_config 필요.')
    ..writeln('#   설정 없으면 XMP-rol 줄 삭제 후 실행.')
    ..writeln('# 스킵/역순/블랭크 프레임 있는 롤은 데스크탑 GUI 사용 권장.')
    ..writeln();

  for (final s in sorted) {
    final lensId = s.lensId ?? roll.defaultLensId;
    final lens = lensId == null ? null : lensById[lensId];
    final iso = s.iso ?? roll.film?.iso;
    final focal = s.focalLength ?? lens?.focalLength;

    buf.writeln('# Frame ${s.idx}');
    if (s.aperture != null) buf.writeln('-FNumber=${s.aperture!.value}');
    if (s.shutterSpeed != null) {
      buf.writeln('-ExposureTime=${_shutter(s.shutterSpeed!.value)}');
    }
    if (iso != null) buf.writeln('-ISO=$iso');
    if (focal != null) buf.writeln('-FocalLength=$focal');
    if (s.exposureComp != null) {
      buf.writeln('-ExposureBiasValue=${s.exposureComp!.value}');
    }
    if (roll.camera != null) {
      final c = roll.camera!;
      if (c.brand != null) buf.writeln('-Make=${c.brand}');
      buf.writeln('-Model=${c.title}');
    }
    if (lens != null) {
      buf.writeln('-LensModel=${lens.name}');
      buf.writeln('-XMP-aux:Lens=${lens.name}');
      if (lens.brand != null) buf.writeln('-LensMake=${lens.brand}');
    }
    if (roll.film != null) {
      buf.writeln('-XMP-rol:FilmStock=${roll.film!.name}');
    }
    if (roll.pushPull != null && roll.pushPull != 0) {
      final v = roll.pushPull! > 0 ? '+${roll.pushPull}' : '${roll.pushPull}';
      buf.writeln('-XMP-rol:PushPull=$v');
    }
    if (s.flash != null) buf.writeln('-Flash=${s.flash! ? 1 : 0}');
    if (artist != null && artist.isNotEmpty) {
      buf.writeln('-Artist=$artist');
      buf.writeln('-XMP-dc:Creator=$artist');
    }
    if (s.date != null) {
      final d = _exifDate(s.date!);
      buf.writeln('-DateTimeOriginal=$d');
      buf.writeln('-CreateDate=$d');
      buf.writeln('-ModifyDate=$d');
    }
    if (s.rating != null) buf.writeln('-Rating=${s.rating}');
    if (s.note != null && s.note!.trim().isNotEmpty) {
      // argfile은 한 줄 = 한 인자. 개행은 공백으로 압축.
      final note = s.note!.replaceAll(RegExp(r'\r?\n'), ' ').trim();
      buf.writeln('-ImageDescription=$note');
      buf.writeln('-XMP-dc:Description=$note');
    }
    if (s.gpsLat != null) buf.writeln('-GPSLatitude=${s.gpsLat}');
    if (s.gpsLng != null) buf.writeln('-GPSLongitude=${s.gpsLng}');

    buf
      ..writeln('frame_${s.idx.toString().padLeft(3, '0')}.$defaultExt')
      ..writeln('-execute')
      ..writeln();
  }

  return buf.toString();
}

String _shutter(double v) {
  if (v <= 0) return v.toString();
  if (v >= 1) return v.toString();
  final inv = (1 / v).round();
  return '1/$inv';
}

String _exifDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}:${two(d.month)}:${two(d.day)} '
      '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
}

String slugForFilename(String s) => s
    .trim()
    .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_')
    .replaceAll(RegExp(r'_+'), '_');
