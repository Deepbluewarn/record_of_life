import 'package:flutter_test/flutter_test.dart';
import 'package:rol_desktop/exiftool.dart';
import 'package:rol_desktop/rol_json.dart';

RolExport _sample() => RolExport.fromMap({
      'schema': 1,
      'artist': 'Jane',
      'roll': {
        'id': 'r1',
        'film': {'name': 'Portra 400', 'iso': 400},
        'camera': {'make': 'Nikon', 'model': 'FM2', 'title': 'Nikon FM2'},
        'pushPull': 1,
        'lenses': [
          {'id': 'l1', 'make': 'Nikon', 'model': 'Nikkor 50mm', 'focalLength': 50},
        ],
        'shots': [
          {
            'idx': 1,
            'aperture': 2.8,
            'shutterSpeed': '1/125',
            'iso': 800,
            'lensId': 'l1',
            'note': 'line1\nline2',
            'rating': 4,
            'flash': true,
          },
        ],
      },
    });

void main() {
  test('shotToArgs: T5 매핑 커버 + 노트 개행 압축', () {
    final e = _sample();
    final args = shotToArgs(export: e, shot: e.roll.shots.first);
    expect(args, contains('-FNumber=2.8'));
    expect(args, contains('-ExposureTime=1/125'));
    expect(args, contains('-ISO=800'));         // shot iso > film iso
    expect(args, contains('-FocalLength=50'));  // lens focalLength 상속
    expect(args, contains('-Make=Nikon'));
    expect(args, contains('-Model=Nikon FM2'));
    expect(args, contains('-LensModel=Nikkor 50mm'));
    expect(args, contains('-XMP-aux:Lens=Nikkor 50mm'));
    expect(args, contains('-LensMake=Nikon'));
    expect(args, contains('-XMP-rol:FilmStock=Portra 400'));
    expect(args, contains('-XMP-rol:PushPull=+1'));
    expect(args, contains('-Flash=1'));
    expect(args, contains('-Artist=Jane'));
    expect(args, contains('-Rating=4'));
    expect(args, contains('-ImageDescription=line1 line2'));
    // 개행 원본은 없어야
    expect(args.any((a) => a.contains('\n')), false);
  });

  test('shotToArgs: 필드 없으면 인자도 없음', () {
    final e = RolExport.fromMap({
      'schema': 1,
      'roll': {
        'id': 'r1',
        'lenses': [],
        'shots': [{'idx': 1}],
      },
    });
    final args = shotToArgs(export: e, shot: e.roll.shots.first);
    expect(args, isEmpty);
  });
}
