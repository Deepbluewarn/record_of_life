import 'package:record_of_life/domain/models/roll.dart';

class Shot {
  final Roll roll;
  int idx = 1;
  DateTime? date;
  double? aperture; // 2.8
  String? shutterSpeed; // 1/125
  String? focusDistance; // 3m
  double? exposureComp; // +0.3
  String? note; // 컷 메모
  int? rating; // 1~5

  Shot({
    required this.roll,
    this.date,
    this.aperture,
    this.shutterSpeed,
    this.focusDistance,
    this.exposureComp,
    this.note,
    this.rating,
  });
}
