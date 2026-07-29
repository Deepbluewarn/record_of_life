import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:uuid/uuid.dart';

class Shot {
  final String id;
  final String rollId;
  final int idx;
  final DateTime? date;
  final String? lensId;
  final Aperture? aperture;
  final ShutterSpeed? shutterSpeed;
  final ExposureComp? exposureComp;
  final int? iso; // 실제 노출 ISO (push/pull 대응). 미지정 시 Film.iso 상속.
  final int? focalLength; // mm. 줌 렌즈 대응. 미지정 시 Lens.focalLength 상속.
  final double? gpsLat;
  final double? gpsLng;
  final String? note;
  final int? rating;

  Shot({
    String? id,
    required this.rollId,
    this.idx = 1,
    this.date,
    this.lensId,
    this.aperture,
    this.shutterSpeed,
    this.exposureComp,
    this.iso,
    this.focalLength,
    this.gpsLat,
    this.gpsLng,
    this.note,
    this.rating,
  }) : id = id ?? const Uuid().v4();

  Shot copyWith({
    int? idx,
    DateTime? date,
    String? lensId,
    Aperture? aperture,
    ShutterSpeed? shutterSpeed,
    ExposureComp? exposureComp,
    int? iso,
    int? focalLength,
    double? gpsLat,
    double? gpsLng,
    String? note,
    int? rating,
  }) {
    return Shot(
      id: id,
      rollId: rollId,
      idx: idx ?? this.idx,
      date: date ?? this.date,
      lensId: lensId ?? this.lensId,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      exposureComp: exposureComp ?? this.exposureComp,
      iso: iso ?? this.iso,
      focalLength: focalLength ?? this.focalLength,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      note: note ?? this.note,
      rating: rating ?? this.rating,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'rollId': rollId,
    'idx': idx,
    'date': date?.toIso8601String(),
    'lensId': lensId,
    'aperture': aperture?.name,
    'shutterSpeed': shutterSpeed?.name,
    'exposureComp': exposureComp?.name,
    'iso': iso,
    'focalLength': focalLength,
    'gpsLat': gpsLat,
    'gpsLng': gpsLng,
    'note': note,
    'rating': rating,
  };

  factory Shot.fromMap(Map<String, Object?> m) => Shot(
    id: m['id'] as String,
    rollId: m['rollId'] as String,
    idx: m['idx'] as int? ?? 1,
    date: m['date'] == null ? null : DateTime.parse(m['date'] as String),
    lensId: m['lensId'] as String?,
    aperture: _enumByName(Aperture.values, m['aperture']),
    shutterSpeed: _enumByName(ShutterSpeed.values, m['shutterSpeed']),
    exposureComp: _enumByName(ExposureComp.values, m['exposureComp']),
    iso: m['iso'] as int?,
    focalLength: m['focalLength'] as int?,
    gpsLat: (m['gpsLat'] as num?)?.toDouble(),
    gpsLng: (m['gpsLng'] as num?)?.toDouble(),
    note: m['note'] as String?,
    rating: m['rating'] as int?,
  );
}

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
