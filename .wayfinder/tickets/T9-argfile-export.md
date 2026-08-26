# T9: 모바일 argfile export (parity 백업 경로)

Label: `wayfinder:grilling`
Status: open, unblocked
Blocks: (none)

## Question

모바일 앱에서 `.rol.json`과 별도로 **exiftool argfile**도 export할지?

시장 조사에서 Crown+Flint가 이 경로만으로 사용자 만족시킴 — 데스크탑 companion 없이도 터미널 한 줄로 EXIF 주입 가능. 우리 데스크탑 앱이 존재해도, 이 옵션이 있으면:
- 터미널 사용자 즉시 만족
- 데스크탑 앱 개발 지연되어도 도구가 이미 유용
- Windows 안 쓰는 macOS/Linux 사용자에게도 가치

비용:
- 스키마 하나 더 유지 (JSON + argfile 두 포맷)
- argfile은 스캔 파일명 규칙을 사용자가 지켜야 성립 — 안내 문서 필요

**핵심 판단**: 데스크탑 앱이 destination이라 두고 argfile export를 곁들일지, argfile을 v0로 삼고 데스크탑을 v1로 미룰지, argfile은 무시할지.

## Resolution

**둘 다 지원.** Argfile export는 모바일 앱에 즉시 붙이고, 데스크탑 GUI는 destination 그대로 유지. 상호 배타 아님 — 사용자 타입/롤 상태에 따라 다른 경로 씀:
- Argfile → 터미널 사용자, macOS/Linux, 깔끔한 롤
- Desktop GUI → Windows, 터미널 싫은 사용자, 엉망 롤

**세부:**
- **릴리스 타이밍**: 데스크탑 개발 안 기다림. 다음 모바일 릴리스 포함. 스키마·태그 매핑 이미 T1·T5에서 결정.
- **파일명 규칙**: Default `frame_001.<ext>` (zero-padded, 확장자 자유). 사용자가 스캔 소프트웨어에서 이렇게 넘버링하도록 안내. 강제는 아님 — argfile은 그대로 뱉음, 사용자가 실행 전 자기 파일명 조정.
- **포함할 태그**: 데스크탑 GUI 주입 셋과 **완전 동일**. T5 매핑 그대로. 두 경로 결과 달라지면 안 됨.
- **UI 위치**: Roll 상세 페이지 `Export` 메뉴에 `.rol.json` / `exiftool argfile` 두 옵션. 별도 화면 안 만듦.
- **문서**: 앱 내 짧은 안내 (`exiftool -@ my_roll.args` 예제 + 파일명 규칙). 외부 사이트 대신 인앱으로 충분.
- **불완전 케이스**: 스킵/역순/블랭크는 argfile로 커버 안 됨 — 사용자가 argfile 열어 직접 수정하거나, 데스크탑 GUI로 넘어와야 함. 이 한계 안내 문구에 명시.

**비용**: 반나절. 스키마·태그 매핑 다 있음, 문자열 조립만.

**전략적 효과**: 데스크탑 앱 지연되어도 도구가 이미 유용. Crown+Flint parity 즉시 확보. macOS/Linux 사용자도 즉시 가치.
