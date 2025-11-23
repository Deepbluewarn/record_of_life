enum Aperture {
  f1_4(1.4, 'f/1.4'),
  f2_0(2.0, 'f/2.0'),
  f2_8(2.8, 'f/2.8'),
  f4_0(4.0, 'f/4.0'),
  f5_6(5.6, 'f/5.6'),
  f8_0(8.0, 'f/8.0'),
  f11_0(11.0, 'f/11.0'),
  f16_0(16.0, 'f/16.0');

  final double value;
  final String label;

  const Aperture(this.value, this.label);

  @override
  String toString() => label;
}
