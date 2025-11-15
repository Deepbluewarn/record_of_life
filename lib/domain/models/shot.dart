import 'package:uuid/uuid.dart';

class Shot {
  final String id;
  final String rollId;
  int idx = 1;
  DateTime? date;
  double? aperture; // 2.8
  String? shutterSpeed; // 1/125
  String? focusDistance; // 3m
  double? exposureComp; // +0.3
  String? note; // 컷 메모
  int? rating; // 1~5

  Shot({
    String? id,
    required this.rollId,
    this.date,
    this.aperture,
    this.shutterSpeed,
    this.focusDistance,
    this.exposureComp,
    this.note,
    this.rating,
  }) : id = id ?? const Uuid().v4();

  Shot copyWith({
    DateTime? date,
    double? aperture,
    String? shutterSpeed,
    String? focusDistance,
    double? exposureComp,
    String? note,
    int? rating,
  }) {
    return Shot(
      id: id,
      rollId: rollId,
      date: date ?? this.date,
      aperture: aperture ?? this.aperture,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      focusDistance: focusDistance ?? this.focusDistance,
      exposureComp: exposureComp ?? this.exposureComp,
      note: note ?? this.note,
      rating: rating ?? this.rating,
    );
  }
}
