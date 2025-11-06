# record_of_life

```dart
// lib/models/film_camera_models.dart
import 'package:isar/isar.dart';

part 'film_camera_models.g.dart';

/// =======================
/// CAMERA
/// =======================
@collection
class Camera {
  Id id = Isar.autoIncrement;

  late String name;                  // Canon AE-1
  String? brand;                     // Canon
  String? format;                    // 35mm, 120, Half
  String? mount;                     // FD, M42, etc.
  bool hasMeter = true;              // 노출계 유무
  String? batteryType;               // 4LR44
  String? notes;                     // 상태/메모

  // 관계 (렌즈 다수)
  final lenses = IsarLinks<Lens>();

  @override
  String toString() => '$brand $name';
}

/// =======================
/// LENS
/// =======================
@collection
class Lens {
  Id id = Isar.autoIncrement;

  late String name;                  // FD 50mm f/1.8
  String? brand;                     // Canon
  int? focalLength;                  // 50
  double? maxAperture;               // 1.8
  String? mount;                     // FD, EF, M42
  String? coating;                   // S.S.C, T*
  String? type;                      // Prime, Zoom
  String? notes;                     // 코멘트

  // 관계 (카메라 1)
  final camera = IsarLink<Camera>();

  @override
  String toString() => '$brand $name (${focalLength}mm f/$maxAperture)';
}

/// =======================
/// FILM
/// =======================
@collection
class Film {
  Id id = Isar.autoIncrement;

  late String name;                  // Kodak Portra 400
  String? brand;                     // Kodak
  int iso = 400;
  String type = 'color';             // color, bw, cine
  String format = '35mm';            // 35mm, 120, etc.
  String? process;                   // C-41, E-6, B&W
  String? tone;                      // Warm, Neutral, Cool
  DateTime? expiration;              // 유통기한
  String? storage;                   // Fridge, Room
  String? notes;                     // 메모

  @override
  String toString() => '$brand $name ($iso ISO)';
}

/// =======================
/// ROLL (필름 한 통)
/// =======================
@collection
class Roll {
  Id id = Isar.autoIncrement;

  // 관계
  final camera = IsarLink<Camera>();
  final lens = IsarLink<Lens>();
  final film = IsarLink<Film>();

  // 스냅샷(요약정보)
  String? cameraNameSnapshot;
  String? lensNameSnapshot;
  String? filmNameSnapshot;
  int? filmIsoSnapshot;

  // 기본 정보
  String? title;                     // “봄 여행 롤”
  int totalShots = 36;
  int shotsDone = 0;

  @Index()
  String status = 'shooting';        // shooting, developing, scanned, archived, failed

  @Index()
  DateTime startedAt = DateTime.now();
  DateTime? endedAt;

  String? location;                  // 서울, 한강 등
  String? memo;                      // 전체 메모
  int? rating;                       // 1~5
  List<String>? tags;                // [“여행”, “인물”]

  @override
  String toString() =>
      '$title ($status) - ${shotsDone}/$totalShots';
}

/// =======================
/// SHOT (컷 단위 기록)
/// =======================
@collection
class Shot {
  Id id = Isar.autoIncrement;

  final roll = IsarLink<Roll>();

  int index = 1;                     // 1~36
  DateTime? date;
  double? aperture;                  // 2.8
  String? shutterSpeed;              // 1/125
  String? focusDistance;             // 3m
  double? exposureComp;              // +0.3
  String? note;                      // 컷 메모
  double? latitude;
  double? longitude;
  String? scanImageUrl;              // 스캔 이미지
  int? rating;                       // 1~5

  @override
  String toString() => 'Shot $index ($aperture, $shutterSpeed)';
}
```


```
lib/domain/usecases/
  ├─ create_roll_usecase.dart      ← Roll 생성 비즈니스 로직
  ├─ get_rolls_usecase.dart        ← Roll 목록 조회
  ├─ delete_roll_usecase.dart      ← Roll 삭제
  └─ add_shot_usecase.dart         ← 샷 추가

lib/domain/repositories/
  └─ roll_repository.dart          ← 추상 인터페이스

lib/infra/repositories_impl/
  └─ roll_repository_impl.dart     ← Isar 구현

lib/features/roll/presentation/providers/
  └─ roll_provider.dart            ← ChangeNotifier (상태관리)

lib/features/roll/presentation/pages/
  ├─ roll_list_page.dart           ← UI (provider 사용)
  └─ roll_detail_page.dart

models/film_camera_models.dart     ← @collection들 (타입으로 사용)
```