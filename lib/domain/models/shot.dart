import 'dart:math';

class Shot {
  final String id = _generateId();
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
    required this.rollId,
    this.date,
    this.aperture,
    this.shutterSpeed,
    this.focusDistance,
    this.exposureComp,
    this.note,
    this.rating,
  });
}

String _generateId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = Random().nextInt(999999);
  return '$timestamp-$random';
}
