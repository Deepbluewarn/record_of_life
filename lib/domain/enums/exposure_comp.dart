enum ExposureComp {
  minus2_0(-2.0, '-2.0'),
  minus1_7(-1.7, '-1.7'),
  minus1_3(-1.3, '-1.3'),
  minus1_0(-1.0, '-1.0'),
  minus0_7(-0.7, '-0.7'),
  minus0_3(-0.3, '-0.3'),
  zero(0.0, '0.0'),
  plus0_3(0.3, '+0.3'),
  plus0_7(0.7, '+0.7'),
  plus1_0(1.0, '+1.0'),
  plus1_3(1.3, '+1.3'),
  plus1_7(1.7, '+1.7'),
  plus2_0(2.0, '+2.0');

  final double value;
  final String label;

  const ExposureComp(this.value, this.label);

  @override
  String toString() => label;
}
