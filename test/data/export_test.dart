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
  Map<String, Object?> firstEntry(String json) {
    final list = jsonDecode(json) as List;
    return Map<String, Object?>.from(list.first as Map);
  }

  test('SourceFile: {safeTitle}_{idx:03d}.*, 특수문자 slug', () {
    final roll = Roll(
      id: 'r1',
      title: '가을 산책/일본 여행',
      camera: Camera(id: 'c1', title: 'Nikon FM2', brand: 'Nikon'),
      film: Film(id: 'f1', name: 'Portra 400', brand: 'Kodak', iso: 400),
    );
    final shot = Shot(id: 's1', rollId: 'r1', idx: 5);
    final json = ExiftoolExporter(rolls: [roll], shots: [shot], lenses: [])
        .toJson();
    final entry = firstEntry(json);
    expect(entry['SourceFile'], '가을_산책_일본_여행_005.*');
  });

  test('ExposureTime: 1/125 형태로 변환', () {
    final roll = Roll(id: 'r1');
    final shot = Shot(
      id: 's1',
      rollId: 'r1',
      idx: 1,
      shutterSpeed: ShutterSpeed.s1_125, // 1/125
    );
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['ExposureTime'], '1/125');
  });

  test('ExposureTime: 1초 이상은 소수로', () {
    final roll = Roll(id: 'r1');
    final shot = Shot(
      id: 's1',
      rollId: 'r1',
      idx: 1,
      shutterSpeed: ShutterSpeed.s2_0, // 2 seconds
    );
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['ExposureTime'], '2.0');
  });

  test('ISO 상속: Shot.iso null이면 Film.iso 사용', () {
    final film = Film(id: 'f1', name: 'HP5', brand: 'Ilford', iso: 400);
    final roll = Roll(id: 'r1', film: film);
    final shot = Shot(id: 's1', rollId: 'r1', idx: 1);
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['ISO'], 400);
  });

  test('ISO override: Shot.iso 지정 시 우선 (push/pull)', () {
    final film = Film(id: 'f1', name: 'Portra', brand: 'Kodak', iso: 400);
    final roll = Roll(id: 'r1', film: film);
    final shot = Shot(id: 's1', rollId: 'r1', idx: 1, iso: 800);
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['ISO'], 800);
  });

  test('FocalLength: Shot 없으면 Lens 값 상속, LensModel 세팅', () {
    final lens =
        Lens(id: 'l1', name: 'Nikkor 50mm', focalLength: 50, mount: 'F');
    final roll = Roll(id: 'r1', defaultLensId: 'l1');
    final shot = Shot(id: 's1', rollId: 'r1', idx: 1);
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: [lens]).toJson(),
    );
    expect(entry['FocalLength'], 50);
    expect(entry['LensModel'], 'Nikkor 50mm');
  });

  test('null 필드는 JSON에서 생략', () {
    final roll = Roll(id: 'r1');
    final shot = Shot(id: 's1', rollId: 'r1', idx: 1);
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry.containsKey('FNumber'), false);
    expect(entry.containsKey('ISO'), false);
    expect(entry.containsKey('LensModel'), false);
  });

  test('DateTimeOriginal 포맷: YYYY:MM:DD HH:MM:SS', () {
    final roll = Roll(id: 'r1');
    final shot = Shot(
      id: 's1',
      rollId: 'r1',
      idx: 1,
      date: DateTime(2026, 3, 5, 14, 7, 42),
    );
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['DateTimeOriginal'], '2026:03:05 14:07:42');
  });

  test('Camera Make/Model, Film UserComment 매핑', () {
    final roll = Roll(
      id: 'r1',
      camera: Camera(id: 'c1', title: 'FM2', brand: 'Nikon'),
      film: Film(id: 'f1', name: 'HP5 Plus', brand: 'Ilford', iso: 400),
    );
    final shot = Shot(id: 's1', rollId: 'r1', idx: 1);
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['Make'], 'Nikon');
    expect(entry['Model'], 'FM2');
    expect(entry['UserComment'], 'Film: HP5 Plus');
  });

  test('FNumber / ExposureBiasValue 매핑', () {
    final roll = Roll(id: 'r1');
    final shot = Shot(
      id: 's1',
      rollId: 'r1',
      idx: 1,
      aperture: Aperture.f2_8,
      exposureComp: ExposureComp.plus1_0,
    );
    final entry = firstEntry(
      ExiftoolExporter(rolls: [roll], shots: [shot], lenses: []).toJson(),
    );
    expect(entry['FNumber'], 2.8);
    expect(entry['ExposureBiasValue'], 1.0);
  });
}
