import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:record_of_life/data/export.dart';
import 'package:record_of_life/domain/enums/aperture.dart';
import 'package:record_of_life/domain/enums/exposure_comp.dart';
import 'package:record_of_life/domain/enums/shutter_speed.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:record_of_life/domain/models/lens.dart';
import 'package:record_of_life/domain/models/roll.dart';
import 'package:record_of_life/domain/models/shot.dart';

void main() {
  group('buildRolJson (T1 schema v1)', () {
    test('schema=1, roll+shots+artist 왕복', () {
      final roll = Roll(
        id: 'r1',
        title: '가을 산책',
        camera: Camera(id: 'c1', title: 'FM2', brand: 'Nikon'),
        film: Film(id: 'f1', name: 'Portra 400', brand: 'Kodak', iso: 400),
        defaultLensId: 'l1',
        pushPull: 1,
      );
      final lens = Lens(id: 'l1', name: 'Nikkor 50mm', focalLength: 50, brand: 'Nikon');
      final shots = [
        Shot(
          id: 's1',
          rollId: 'r1',
          idx: 2,
          aperture: Aperture.f2_8,
          shutterSpeed: ShutterSpeed.s1_125,
          exposureComp: ExposureComp.plus0_7,
          iso: 800,
          rating: 4,
          note: 'overcast',
          date: DateTime(2026, 8, 2, 14, 30),
        ),
        Shot(id: 's2', rollId: 'r1', idx: 1),
      ];
      final data = jsonDecode(buildRolJson(
        roll: roll,
        shots: shots,
        lenses: [lens],
        artist: 'Jane',
        exportedAt: DateTime.utc(2026, 8, 2, 5, 30),
      )) as Map<String, Object?>;

      expect(data['schema'], 1);
      expect(data['artist'], 'Jane');
      final r = data['roll'] as Map<String, Object?>;
      expect(r['name'], '가을 산책');
      expect(r['pushPull'], 1);
      expect(((r['film'] as Map)['iso']), 400);
      expect(((r['camera'] as Map)['make']), 'Nikon');
      final lenses = r['lenses'] as List;
      expect(lenses, hasLength(1));
      expect((lenses.first as Map)['model'], 'Nikkor 50mm');
      final ss = r['shots'] as List;
      expect(ss.map((s) => (s as Map)['idx']), [1, 2]); // idx 순 정렬
      final s1 = ss[1] as Map;
      expect(s1['aperture'], 2.8);
      expect(s1['shutterSpeed'], '1/125');
      expect(s1['iso'], 800);
      expect(s1['rating'], 4);
      expect(s1['note'], 'overcast');
    });

    test('null 필드 생략', () {
      final roll = Roll(id: 'r1');
      final shot = Shot(id: 's1', rollId: 'r1', idx: 1);
      final data = jsonDecode(buildRolJson(
        roll: roll,
        shots: [shot],
        lenses: const [],
      )) as Map<String, Object?>;
      final s = (data['roll'] as Map)['shots'] as List;
      expect((s.first as Map).containsKey('aperture'), false);
      expect((s.first as Map).containsKey('iso'), false);
      expect(data.containsKey('artist'), false);
    });
  });

  group('buildArgfile (T9 + T5)', () {
    test('shot당 -execute 블록 + frame_NNN.<ext>', () {
      final roll = Roll(
        id: 'r1',
        title: 'roll',
        camera: Camera(id: 'c1', title: 'FM2', brand: 'Nikon'),
        film: Film(id: 'f1', name: 'Portra 400', iso: 400),
      );
      final shots = [
        Shot(
          id: 's1',
          rollId: 'r1',
          idx: 1,
          aperture: Aperture.f2_8,
          shutterSpeed: ShutterSpeed.s1_125,
        ),
        Shot(id: 's2', rollId: 'r1', idx: 2, aperture: Aperture.f4_0),
      ];
      final out = buildArgfile(
        roll: roll,
        shots: shots,
        lenses: const [],
        artist: 'Jane',
      );

      expect(out, contains('-FNumber=2.8'));
      expect(out, contains('-ExposureTime=1/125'));
      expect(out, contains('-ISO=400')); // film.iso 상속
      expect(out, contains('-Make=Nikon'));
      expect(out, contains('-Model=FM2'));
      expect(out, contains('-XMP-rol:FilmStock=Portra 400'));
      expect(out, contains('-Artist=Jane'));
      expect(out, contains('-XMP-dc:Creator=Jane'));
      expect(out, contains('frame_001.jpg'));
      expect(out, contains('frame_002.jpg'));
      expect('-execute'.allMatches(out).length, 2);
    });

    test('push/pull, 노트 개행 압축', () {
      final roll = Roll(id: 'r1', pushPull: -1);
      final shot = Shot(
        id: 's1',
        rollId: 'r1',
        idx: 1,
        note: 'line1\nline2',
        flash: true,
      );
      final out = buildArgfile(
        roll: roll,
        shots: [shot],
        lenses: const [],
      );
      expect(out, contains('-XMP-rol:PushPull=-1'));
      expect(out, contains('-Flash=1'));
      expect(out, contains('-ImageDescription=line1 line2'));
      expect(out, isNot(contains('line1\nline2')));
    });

    test('defaultExt 커스터마이즈', () {
      final roll = Roll(id: 'r1');
      final shot = Shot(id: 's1', rollId: 'r1', idx: 3);
      final out = buildArgfile(
        roll: roll,
        shots: [shot],
        lenses: const [],
        defaultExt: 'tif',
      );
      expect(out, contains('frame_003.tif'));
    });
  });

  test('slugForFilename: 특수문자 압축', () {
    expect(slugForFilename('가을 산책/일본 여행'), '가을_산책_일본_여행');
  });
}
