# Map: Desktop EXIF injection companion

Label: `wayfinder:map`

## Destination

record_of_life 모바일 앱의 촬영 메모를 스캔 필름 파일에 EXIF/XMP로 주입하는 데스크탑 companion 앱의 **spec 확정**. 시장 조사 결과 유사 앱(Frames/Lightme/FilmTracker)이 이미 존재하므로 destination은 **범용 툴이 아니라 이 세 gap을 겨냥한 앱**:

1. **Windows 지원** — 기존 companion 앱들이 macOS 편중.
2. **엉망 롤을 처리하는 시각적 매칭 UI** — 스킵/재순서/블랭크 대응.
3. **record_of_life 자체 스키마와 완전 fidelity** — WheelSelector 기반 값·별점·아티스트·메모 온전 왕복.

map이 끝나면 이 셋을 겨냥한 앱의 구현 티켓만 남는 상태.

## Notes

- Domain: 필름 사진 후처리 워크플로우. 사용자는 스캐너로 필름을 디지털화한 뒤, 이 앱에서 촬영 당시 메모를 EXIF로 주입.
- 상위 스코프 규칙 (memory: product-scope): 사진 저장/뷰어는 스코프 밖. 이 desktop 앱은 **주입 도구**지 갤러리 아님. 사진은 통과만 함.
- 필드 규칙: EXIF에 매핑 가능한 항목만. 이미 모바일 모델이 이 규칙을 따름.
- **Prior art 참조**: [`.wayfinder/research/market-scan.md`](research/market-scan.md). Frames가 우리와 가장 가까움 — 차별화 지점 판단 시 이 리포트 다시 볼 것.
- 사용 스킬: `/grilling`, `/domain-modeling`, `/prototype` (UI 결정용), `/research` (exiftool 태그/CLI 조사용).

## Decisions so far

- [T1: Data bridge format & transport](tickets/T1-data-bridge.md) — v0는 수동 파일 이동, 단일 JSON, roll 단위(`.rol.json`), schema 버전 필드. v1에서 WebRTC 페어링 여지 남김.
- [T2: Shot ↔ photo file matching UX](tickets/T2-matching-ux.md) — 나란한 두 열 + 작은 썸네일(64px) + Shift/Gap-좌/Gap-우/Reverse 4개 조정 도구. 파일명 자연 정렬 초기 배치. 양쪽 채워진 행만 주입.
- [T3: Tech stack](tickets/T3-tech-stack.md) — Flutter Desktop (Windows/macOS). 웹은 파일 접근·포맷·메모리 제약으로 기각. 로직/UI 분리로 향후 확장 여지만 남김.
- Market scan (research) — [`research/market-scan.md`](research/market-scan.md). Frames·Lightme·FilmTracker가 유사 companion 존재. 우리 정체성 = Windows 지원 + 엉망 롤 매칭 UI + 자체 스키마 fidelity로 재정렬.
- [T9: 모바일 argfile export](tickets/T9-argfile-export.md) — 둘 다 지원. 모바일에 즉시 붙임 (반나절). 데스크탑 GUI와 태그 매핑 동일. 파일명 규칙은 `frame_NNN.<ext>` 안내.
- [T4: Desktop app UI shape](tickets/T4-ui-shape.md) — 단일 화면. Empty ↔ Loaded 상태 전이. 모달 0개, preview·result는 인라인 row expand로 통합.
- [T5: EXIF injection tool & tag mapping](tickets/T5-exif-injection-tool.md) — exiftool CLI wrapping. 표준 태그 대부분 커버. film stock/push-pull은 커스텀 `XMP-rol:*` 네임스페이스(`.ExifTool_config` 앱 번들). JPEG/TIFF/DNG 동일 처리.
- [T6: Backup / destructive-write policy](tickets/T6-backup-policy.md) — Default `-overwrite_original_in_place` (백업 안 남김) + UI 토글. 개별 파일 원자적, 부분 실패 시 나머지 진행. 기존 태그는 우리 매핑만 덮음. 재적용 안전.
- [T7: idx 시맨틱 검증](tickets/T7-idx-semantics.md) — idx는 `shotsDone+1`로 결정, UX가 촬영/입력 순서 = 물리 프레임 강제. T2 가정 확정. 갈림 케이스는 T2의 gap 도구가 흡수. `physicalFrame` 필드 추가 안 함.
- [T8: 저장소·모듈 구조](tickets/T8-repo-structure.md) — Monorepo B. Pub workspaces + `rol_core`/`rol_mobile`/`rol_desktop` 3-패키지. sembast는 rol_mobile에만. 마이그레이션은 별도 실행 티켓.

## Not yet specified

- **모바일 side의 shot 편집·삭제 시 idx 처리** — 편집 시 idx 변경 가능한지, 삭제 시 뒤 shot들 재번호 되는지 검증 필요. 데이터 무결성 이슈, 모바일 앱 스코프.

## Out of scope

- 사진 뷰어/편집기 기능 (밝기·색보정 등). product-scope와 정면 충돌.
- 클라우드 계정·동기화 서버. 파일 브릿지로 충분한 이상 이번 map에서는 안 함.
- 스캐너 하드웨어 통합.

## Tickets

Frontier (open, unblocked):
- (none)

Blocked:
- (none)

Closed:
- T1, T2, T3, T4, T5, T6, T7, T8, T9 (see Decisions so far)

**🎯 Destination 도달.** 모든 spec 결정 확정. 실행은 이 map 밖 — 실행 티켓은 아직 만들어져 있지 않음. 새 세션은 이 map + 관련 spec 티켓을 참조해 바로 코드에 붙거나, 원하면 가벼운 `.wayfinder/impl/TODO.md`를 만들어 순서만 나열해도 됨. 추천 시작 순서: T9(모바일 argfile) → T8(monorepo 마이그레이션) → T1(rol_core 스키마) → T4(desktop scaffold) → T2(matching UI) → T5·T6(exiftool wrap).
