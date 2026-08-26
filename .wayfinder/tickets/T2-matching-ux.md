# T2: Shot ↔ photo file matching UX

Label: `wayfinder:prototype`
Status: open, blocked by T1
Blocks: T4

## Question

한 롤 = N개 shot 메모 ↔ M개 스캔 파일을 어떻게 매칭시키나?

- 순서 자동 정렬 (촬영 idx ↔ 파일명 정렬 순서) + 수동 교정 이 기본안.
- 이지 케이스: N == M, 순서 일치. 하드 케이스: 일부 shot을 안 찍었거나, 스캔 실패 컷 있음.
- UI: 좌 shot 리스트 / 우 파일 리스트 나란히 + 드래그로 재매칭? 아니면 슬라이드 offset 조정?
- 미리보기 썸네일 필요 여부 (product-scope에 갤러리 안 붙인다는 것과 충돌하지 않는지 확인).

`/prototype UI.md` 로 몇 개 레이아웃 만들고 사용자와 결정.

## Resolution

**패러다임**: 나란한 두 열. 왼쪽 = shot 메모(idx 고정), 오른쪽 = 스캔 파일. 행 i가 행 i와 쌍. 매칭 편집은 오른쪽 열만 조작.

**썸네일**: 오른쪽 열에 작은 썸네일(≈64px) 렌더. **매칭 화면 안에서만**, 클릭 확대·풀뷰어·상세 UI 없음. 저장 안 함 — 렌더 시점에 파일 디코드. product-scope 지킴선: 이 화면 밖으로 이미지 개념 새어나가지 않음.

**초기 자동 배치**: 파일명 자연 정렬(`scan_001` < `scan_002` < ... < `scan_010`). mtime/EXIF 기반 정렬은 후일 옵션.

**조정 도구 (v0에 4개):**

| 도구 | 용도 |
|---|---|
| Shift right ← / → | 오른쪽 열 전체 오프셋. shot 1이 실제로 물리 frame 2였을 때. |
| Insert gap (좌) | 왼쪽 특정 위치에 빈 행 → 메모 안 한 프레임이 그 자리에 있음. |
| Insert gap (우) | 오른쪽 특정 위치에 빈 행 → 파일 없는 shot (스캔 실패). |
| Reverse right | 스캐너 역순 반환. 원클릭. |

**확정 규칙**: 
- 양쪽 다 채워진 행만 EXIF 주입.
- 오른쪽만 있고 왼쪽 갭 = 파일 EXIF 안 건드림.
- 왼쪽만 있고 오른쪽 갭 = 그 shot 메모는 이번에 주입 안 됨 (다음 배치에서 시도 가능).

**Deferred (YAGNI)**: 행 개별 드래그 스왑, 헝가리안 자동 매칭, mtime/EXIF 정렬. gap+shift 조합으로 커버 안 되는 케이스 확인되면 그때 추가.

**Assumption**: shot의 `idx`는 **물리 프레임 번호에 최대한 근접한** 값으로 가정. 만약 실제 모델의 `idx`가 "메모 입력 순서"에 불과하면 이 매칭 UX가 흔들림 — 그 경우 모바일 앱에서 `physicalFrame` 필드 추가하고 export 스키마도 갱신 필요. 이 검증은 별도 티켓으로 분리 대상. → [[T7-idx-semantics]]
