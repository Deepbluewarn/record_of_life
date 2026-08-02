// UI 프리뷰용 하드코딩 샘플. 실제 exiftool 실행은 안 됨(파일 실체 없음).

import 'dart:io';
import 'rol_json.dart';

RolExport sampleExport() => RolExport.fromMap({
      'schema': 1,
      'artist': 'Jane Doe',
      'roll': {
        'id': 'sample-roll-01',
        'name': '가을 산책 (샘플)',
        'film': {'name': 'Kodak Portra 400', 'iso': 400},
        'camera': {'make': 'Nikon', 'model': 'FM2', 'title': 'Nikon FM2'},
        'pushPull': 1,
        'lenses': [
          {'id': 'l1', 'make': 'Nikon', 'model': 'Nikkor 50mm f/1.4 AI-S', 'focalLength': 50},
          {'id': 'l2', 'make': 'Nikon', 'model': 'Nikkor 28mm f/2.8', 'focalLength': 28},
        ],
        'shots': [
          {
            'idx': 1,
            'aperture': 2.8,
            'shutterSpeed': '1/125',
            'iso': 400,
            'lensId': 'l1',
            'note': '창가 인물, 자연광 측면',
            'rating': 4,
          },
          {
            'idx': 2,
            'aperture': 4.0,
            'shutterSpeed': '1/60',
            'iso': 400,
            'lensId': 'l1',
            'flash': false,
          },
          {
            'idx': 3,
            'aperture': 5.6,
            'shutterSpeed': '1/250',
            'iso': 800,
            'lensId': 'l2',
            'exposureComp': 0.3,
            'note': '역광, +1/3 보정',
          },
          {
            'idx': 4,
            'aperture': 8.0,
            'shutterSpeed': '1/500',
            'iso': 400,
            'lensId': 'l2',
            'rating': 5,
          },
          {
            'idx': 5,
            'aperture': 2.0,
            'shutterSpeed': '1/30',
            'iso': 1600,
            'lensId': 'l1',
            'flash': true,
            'note': '실내, 플래시 사용',
          },
          {
            'idx': 6,
            'aperture': 11.0,
            'shutterSpeed': '1/1000',
            'iso': 400,
            'lensId': 'l2',
            'rating': 3,
          },
        ],
      },
    });

// UI 렌더는 File.path 있으면 됨 (Image.file은 errorBuilder로 fallback).
List<File> sampleScanFiles() => List.generate(
      6,
      (i) => File('sample_frame_${(i + 1).toString().padLeft(3, '0')}.jpg'),
    );
