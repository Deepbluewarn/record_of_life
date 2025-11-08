class Lens {
  final String id;
  final String name;
  String? brand; // Canon
  int? focalLength; // 50
  double? maxAperture; // 1.8
  String? mount; // FD, EF, M42
  String? coating; // S.S.C, T*
  String? type; // Prime, Zoom
  String? notes; // 코멘트

  Lens({
    required this.id,
    required this.name,
    this.brand,
    this.focalLength,
    this.maxAperture,
    this.mount,
    this.coating,
    this.notes,
    this.type,
  });
}
