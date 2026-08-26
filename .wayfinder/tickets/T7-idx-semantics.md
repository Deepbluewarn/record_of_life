# T7: idx 시맨틱 검증

Label: `wayfinder:task`
Status: open, unblocked
Blocks: (none, but critical for T2 correctness)

## Question

모바일 앱 `Shot.idx`는 **물리 프레임 번호**를 의미하나, **메모 입력 순서**를 의미하나?

T2 매칭 UX는 idx가 물리 프레임 번호에 근접하다는 가정 위에 서 있음. 만약 idx가 단순 입력 순서면 (사용자가 frame 5 먼저 메모 → idx=1) T2의 나란한 두 열 매칭이 뿌리부터 흔들림.

## Task

1. `lib/domain/models/shot.dart`와 shot 생성 코드(new_shot_form_provider, capture_form, add_roll 등)를 읽고 idx가 어떻게 결정되는지 확인.
2. 두 경우 중 어느 쪽인지 판정.
3. 만약 "입력 순서"면 → `physicalFrame` 필드 추가 검토, export 스키마 확장 필요. 별도 후속 티켓 생성.
4. "물리 프레임 근접"이면 → T2 가정 확정.

## Resolution

**idx = 촬영/입력 순서 = 물리 프레임 번호 (UX가 강제).**

**근거** ([capture_mode.dart:74, :96](../../lib/features/roll/presentation/pages/capture_mode.dart)):
```dart
final nextFrame = currentRoll.shotsDone + 1;
final shot = form.toShot(...).copyWith(idx: nextFrame, ...);
```
- idx는 항상 `shotsDone + 1`.
- 사용자가 idx를 직접 지정하는 UI 없음.
- Shot 재정렬 UI 없음.
- "건너뛰기" 기능 없음.

**정상 워크플로우** (매번 촬영 후 메모)에서 idx = 물리 프레임 완전 일치. T2 매칭 UX 그대로 성립.

**갈리는 엣지 케이스** (물리 프레임 스킵/앱 안 켠 촬영)는 **T2의 Gap-좌 삽입 도구가 흡수**. 사용자가 시각적으로 확인해서 조정 가능.

**결정:**
- `physicalFrame` 별도 필드 추가 안 함.
- Export 스키마(T1) 유지.
- T2 근본 가정 확정.

**Fog로 남김**: shot 편집 시 idx 변경 가능한지, shot 삭제 시 뒤 shot들 idx 재계산 여부. 모바일 앱 데이터 무결성 이슈로 desktop 앱 스코프 밖. 필요 시 별도 조사.
