import 'package:record_of_life/domain/enums/roll_status.dart';
import 'package:record_of_life/domain/models/camera.dart';
import 'package:record_of_life/domain/models/film.dart';
import 'package:uuid/uuid.dart';

class Roll {
  final String id;
  // ponytail: 카메라·필름을 nested map으로 저장. Camera/Film 마스터 수정 시
  // 기존 롤에는 반영 안 됨. 문제되면 id 참조로 정규화.
  final Camera? camera;
  final Film? film;
  final String? defaultLensId; // 롤의 기본 렌즈. 샷별 override 가능.

  final String? title;
  final int totalShots;
  final int shotsDone;
  final String? memo;
  final RollStatus status;

  final DateTime? startedAt;
  final DateTime? endedAt;

  Roll({
    String? id,
    this.camera,
    this.film,
    this.defaultLensId,
    this.title,
    this.totalShots = 36,
    this.shotsDone = 0,
    this.memo,
    RollStatus? status,
    DateTime? startedAt,
    this.endedAt,
  }) : id = id ?? const Uuid().v4(),
       status = status ?? RollStatus.inProgress,
       startedAt = startedAt ?? DateTime.now();

  // 카메라·필름 포맷 불일치 여부. UI에서 경고 배지용.
  // 어댑터·의도적 조합 가능성 있어 하드 블록은 하지 않음.
  bool get hasFormatMismatch =>
      camera?.format != null &&
      film?.format != null &&
      camera!.format != film!.format;

  Roll copyWith({
    Camera? camera,
    Film? film,
    String? defaultLensId,
    String? title,
    int? totalShots,
    int? shotsDone,
    String? memo,
    RollStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Roll(
      id: id,
      camera: camera ?? this.camera,
      film: film ?? this.film,
      defaultLensId: defaultLensId ?? this.defaultLensId,
      title: title ?? this.title,
      totalShots: totalShots ?? this.totalShots,
      shotsDone: shotsDone ?? this.shotsDone,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'camera': camera?.toMap(),
    'film': film?.toMap(),
    'defaultLensId': defaultLensId,
    'title': title,
    'totalShots': totalShots,
    'shotsDone': shotsDone,
    'memo': memo,
    'status': status.name,
    'startedAt': startedAt?.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
  };

  factory Roll.fromMap(Map<String, Object?> m) => Roll(
    id: m['id'] as String,
    camera: m['camera'] == null
        ? null
        : Camera.fromMap(Map<String, Object?>.from(m['camera'] as Map)),
    film: m['film'] == null
        ? null
        : Film.fromMap(Map<String, Object?>.from(m['film'] as Map)),
    defaultLensId: m['defaultLensId'] as String?,
    title: m['title'] as String?,
    totalShots: m['totalShots'] as int? ?? 36,
    shotsDone: m['shotsDone'] as int? ?? 0,
    memo: m['memo'] as String?,
    status: RollStatus.values.firstWhere(
      (s) => s.name == m['status'],
      orElse: () => RollStatus.inProgress,
    ),
    startedAt: m['startedAt'] == null
        ? null
        : DateTime.parse(m['startedAt'] as String),
    endedAt: m['endedAt'] == null
        ? null
        : DateTime.parse(m['endedAt'] as String),
  );

  @override
  String toString() {
    return 'Roll(id: $id, camera: ${camera?.title}, film: ${film?.name}, title: $title, totalShots: $totalShots, shotsDone: $shotsDone, memo: $memo, startedAt: $startedAt, endedAt: $endedAt)';
  }
}
