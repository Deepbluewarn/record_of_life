import 'package:flutter_test/flutter_test.dart';
import 'package:rol_desktop/rol_json.dart';

void main() {
  test('schema v1 파싱: roll/lens/shot 왕복', () {
    final export = RolExport.fromMap({
      'schema': 1,
      'artist': 'Jane',
      'roll': {
        'id': 'r1',
        'name': '가을 산책',
        'film': {'name': 'Portra 400', 'iso': 400},
        'camera': {'make': 'Nikon', 'model': 'FM2', 'title': 'Nikon FM2'},
        'pushPull': 1,
        'lenses': [
          {'id': 'l1', 'make': 'Nikon', 'model': 'Nikkor 50mm', 'focalLength': 50},
        ],
        'shots': [
          {'idx': 2, 'aperture': 2.8, 'shutterSpeed': '1/125', 'iso': 400},
          {'idx': 1, 'aperture': 4.0, 'shutterSpeed': '1/60'},
        ],
      },
    });
    expect(export.artist, 'Jane');
    expect(export.roll.name, '가을 산책');
    expect(export.roll.pushPull, 1);
    expect(export.roll.filmIso, 400);
    expect(export.roll.cameraTitle, 'Nikon FM2');
    expect(export.roll.lenses, hasLength(1));
    expect(export.roll.lenses.first.model, 'Nikkor 50mm');
    // idx 순 정렬
    expect(export.roll.shots.map((s) => s.idx), [1, 2]);
  });

  test('schema 불일치는 FormatException', () {
    expect(() => RolExport.fromMap({'schema': 2, 'roll': {'id': 'r1'}}),
        throwsFormatException);
  });

  test('summaryLine: 메타 조합', () {
    final export = RolExport.fromMap({
      'schema': 1,
      'roll': {
        'id': 'r1',
        'name': 'roll12',
        'film': {'name': 'Portra 400'},
        'camera': {'title': 'FM2'},
        'lenses': [],
        'shots': [
          {'idx': 1},
          {'idx': 2},
        ],
      },
    });
    expect(export.roll.summaryLine, 'roll12 · Portra 400 · FM2 · 2 frames');
  });

  test('Shot.summary: 미지정은 (no meta)', () {
    final s = Shot.fromMap({'idx': 1});
    expect(s.summary, '(no meta)');
  });
}
