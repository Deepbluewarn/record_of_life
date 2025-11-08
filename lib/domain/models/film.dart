class Film {
  final String id = DateTime.now().toString();
  final String name;
  String? brand;
  int? iso;
  String? format;
  String? note;

  Film({required this.name, this.format, this.brand, this.iso, this.note});
}
