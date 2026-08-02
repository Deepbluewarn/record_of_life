// T5 태그 매핑 + T6 백업 정책. exiftool CLI wrapping.
// UI 밖 순수 로직 (T3 원칙: 로직/UI 분리).

import 'dart:io';

import 'rol_json.dart';

class InjectionResult {
  final bool ok;
  final String stderr;
  final int exitCode;
  InjectionResult({required this.ok, required this.stderr, required this.exitCode});
}

// T5 표 그대로. Shot 하나 → exiftool CLI 인자 리스트.
// 파일 경로/backup 플래그는 caller가 붙임.
List<String> shotToArgs({
  required RolExport export,
  required Shot shot,
}) {
  final roll = export.roll;
  final lensId = shot.lensId;
  final lens = lensId == null
      ? null
      : roll.lenses.where((l) => l.id == lensId).firstOrNull;
  final iso = shot.iso ?? roll.filmIso;
  final focal = shot.focalLength ?? lens?.focalLength;
  final artist = export.artist;

  final args = <String>[];
  if (shot.aperture != null) args.add('-FNumber=${shot.aperture}');
  if (shot.shutterSpeed != null) args.add('-ExposureTime=${shot.shutterSpeed}');
  if (iso != null) args.add('-ISO=$iso');
  if (focal != null) args.add('-FocalLength=$focal');
  if (shot.exposureComp != null) {
    args.add('-ExposureBiasValue=${shot.exposureComp}');
  }
  if (roll.cameraMake != null) args.add('-Make=${roll.cameraMake}');
  if (roll.cameraTitle != null) args.add('-Model=${roll.cameraTitle}');
  if (lens != null) {
    args
      ..add('-LensModel=${lens.model}')
      ..add('-XMP-aux:Lens=${lens.model}');
    if (lens.make != null) args.add('-LensMake=${lens.make}');
  }
  if (roll.filmName != null) args.add('-XMP-rol:FilmStock=${roll.filmName}');
  if (roll.pushPull != null && roll.pushPull != 0) {
    final v = roll.pushPull! > 0 ? '+${roll.pushPull}' : '${roll.pushPull}';
    args.add('-XMP-rol:PushPull=$v');
  }
  if (shot.flash != null) args.add('-Flash=${shot.flash! ? 1 : 0}');
  if (artist != null && artist.isNotEmpty) {
    args
      ..add('-Artist=$artist')
      ..add('-XMP-dc:Creator=$artist');
  }
  if (shot.date != null) {
    final d = _exifDate(DateTime.parse(shot.date!));
    args
      ..add('-DateTimeOriginal=$d')
      ..add('-CreateDate=$d')
      ..add('-ModifyDate=$d');
  }
  if (shot.rating != null) args.add('-Rating=${shot.rating}');
  if (shot.note != null && shot.note!.trim().isNotEmpty) {
    final n = shot.note!.replaceAll(RegExp(r'\r?\n'), ' ').trim();
    args
      ..add('-ImageDescription=$n')
      ..add('-XMP-dc:Description=$n');
  }
  return args;
}

Future<InjectionResult> injectFile({
  required List<String> args,
  required String targetPath,
  required bool keepBackup,
  String exiftool = 'exiftool',
}) async {
  // T6: default in-place overwrite (백업 없음). keepBackup=true면 flag 생략,
  // exiftool 기본 동작이 <file>_original 남김.
  final full = <String>[
    ...args,
    if (!keepBackup) '-overwrite_original_in_place',
    targetPath,
  ];
  try {
    final r = await Process.run(exiftool, full, stdoutEncoding: systemEncoding);
    return InjectionResult(
      ok: r.exitCode == 0,
      stderr: (r.stderr as String? ?? '').trim(),
      exitCode: r.exitCode,
    );
  } on ProcessException catch (e) {
    return InjectionResult(ok: false, stderr: e.message, exitCode: -1);
  }
}

// startup에서 확인. 미설치면 UI 배너.
Future<bool> exiftoolAvailable({String exiftool = 'exiftool'}) async {
  try {
    final r = await Process.run(exiftool, ['-ver']);
    return r.exitCode == 0;
  } on ProcessException {
    return false;
  }
}

String _exifDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}:${two(d.month)}:${two(d.day)} '
      '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
}
