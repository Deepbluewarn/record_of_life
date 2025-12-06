import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:uuid/uuid.dart';

class Shot {
  final String id;
  final String rollId;
  int idx = 1;
  DateTime? date;
  String? lensId; // 렌즈 ID 추가
  Aperture? aperture;
  ShutterSpeed? shutterSpeed;
  ExposureComp? exposureComp;
  String? note;
  int? rating;
  String? imagePath;

  Shot({
    String? id,
    required this.rollId,
    this.date,
    this.lensId,
    this.aperture,
    this.shutterSpeed,
    this.exposureComp,
    this.note,
    this.rating,
    this.imagePath,
  }) : id = id ?? const Uuid().v4();

  Shot copyWith({
    DateTime? date,
    String? lensId,
    Aperture? aperture,
    ShutterSpeed? shutterSpeed,
    ExposureComp? exposureComp,
    String? note,
    int? rating,
    String? imagePath,
  }) {
    return Shot(
      id: id,
      rollId: rollId,
      date: date ?? this.date,
      lensId: lensId ?? this.lensId,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      exposureComp: exposureComp ?? this.exposureComp,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
