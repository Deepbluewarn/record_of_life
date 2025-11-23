import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:uuid/uuid.dart';

class Shot {
  final String id;
  final String rollId;
  int idx = 1;
  DateTime? date;
  Aperture? aperture;
  ShutterSpeed? shutterSpeed;
  ExposureComp? exposureComp;
  String? note;
  int? rating;

  Shot({
    String? id,
    required this.rollId,
    this.date,
    this.aperture,
    this.shutterSpeed,
    this.exposureComp,
    this.note,
    this.rating,
  }) : id = id ?? const Uuid().v4();

  Shot copyWith({
    DateTime? date,
    Aperture? aperture,
    ShutterSpeed? shutterSpeed,
    ExposureComp? exposureComp,
    String? note,
    int? rating,
  }) {
    return Shot(
      id: id,
      rollId: rollId,
      date: date ?? this.date,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      exposureComp: exposureComp ?? this.exposureComp,
      note: note ?? this.note,
      rating: rating ?? this.rating,
    );
  }
}
