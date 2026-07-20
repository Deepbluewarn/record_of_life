import 'dart:convert';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';

// exiftool -json= 명령으로 스캔본에 EXIF 주입할 수 있는 포맷.
// 각 항목의 SourceFile 값이 실제 스캔 파일명과 매칭되어야 함.
//
// 사용 흐름:
//   1. 이 앱에서 롤 선택 → Export
//   2. 생성된 .json을 스캔본 폴더에 복사
//   3. 스캔본 파일을 {safeTitle}_{idx:03d}.* 형식으로 이름 맞추거나
//      JSON의 SourceFile 필드를 수정
//   4. `exiftool -json=roll_XXX.json *.jpg` 로 일괄 주입
class ExiftoolExporter {
  final List<Roll> rolls;
  final List<Shot> shots;
  final List<Lens> lenses;

  ExiftoolExporter({
    required this.rolls,
    required this.shots,
    required this.lenses,
  });

  String toJson() {
    final entries = <Map<String, Object?>>[];
    final lensById = {for (final l in lenses) l.id: l};
    final rollById = {for (final r in rolls) r.id: r};

    for (final shot in shots) {
      final roll = rollById[shot.rollId];
      if (roll == null) continue;
      entries.add(_shotToMap(shot, roll, lensById));
    }

    return const JsonEncoder.withIndent('  ').convert(entries);
  }

  Map<String, Object?> _shotToMap(
    Shot shot,
    Roll roll,
    Map<String, Lens> lensById,
  ) {
    final safeTitle = _slug(roll.title ?? roll.id);
    final lensId = shot.lensId ?? roll.defaultLensId;
    final lens = lensId == null ? null : lensById[lensId];

    // 상속 우선순위: Shot 값 > 롤의 필름·렌즈 값
    final iso = shot.iso ?? roll.film?.iso;
    final focal = shot.focalLength ?? lens?.focalLength;
    final lensName = lens?.name;

    // exiftool 표준 태그. 미지정 필드는 아예 생략(exiftool이 빈 값으로 덮어쓰지 않도록).
    final m = <String, Object?>{
      'SourceFile': '${safeTitle}_${shot.idx.toString().padLeft(3, '0')}.*',
    };
    if (shot.date != null) m['DateTimeOriginal'] = _formatExifDate(shot.date!);
    if (shot.aperture != null) m['FNumber'] = shot.aperture!.value;
    if (shot.shutterSpeed != null) {
      m['ExposureTime'] = _exposureTimeString(shot.shutterSpeed!.value);
    }
    if (iso != null) m['ISO'] = iso;
    if (shot.exposureComp != null) {
      m['ExposureBiasValue'] = shot.exposureComp!.value;
    }
    if (focal != null) m['FocalLength'] = focal;
    if (lensName != null) m['LensModel'] = lensName;
    if (shot.gpsLat != null) m['GPSLatitude'] = shot.gpsLat;
    if (shot.gpsLng != null) m['GPSLongitude'] = shot.gpsLng;
    if (roll.camera != null) {
      final cam = roll.camera!;
      m['Make'] = cam.brand;
      m['Model'] = cam.title;
    }
    if (roll.film != null) m['UserComment'] = 'Film: ${roll.film!.name}';
    if (shot.note != null && shot.note!.isNotEmpty) {
      m['ImageDescription'] = shot.note;
    }
    if (shot.rating != null) m['Rating'] = shot.rating;

    m.removeWhere((_, v) => v == null);
    return m;
  }

  String _formatExifDate(DateTime d) {
    // exiftool DateTimeOriginal 표준: "YYYY:MM:DD HH:MM:SS"
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}:${two(d.month)}:${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  // enum value 는 double. 1/125 같은 값은 "1/125" 문자열로 변환.
  String _exposureTimeString(double v) {
    if (v <= 0) return v.toString(); // bulb/auto 특수값
    if (v >= 1) return v.toString();
    final inv = (1 / v).round();
    return '1/$inv';
  }

  String _slug(String s) => s
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}
