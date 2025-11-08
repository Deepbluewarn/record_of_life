class Camera {
  final String id = DateTime.now().toString();
  final String title;
  String? brand; // Canon
  String? format; // 35mm, 120, Half
  String? mount; // FD, M42, etc.
  String? notes; // 상태/메모

  Camera({
    required this.title,
    this.brand,
    this.format,
    this.mount,
    this.notes,
  });
}
