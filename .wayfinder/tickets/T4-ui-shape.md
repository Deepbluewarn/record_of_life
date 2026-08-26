# T4: Desktop app UI shape

Label: `wayfinder:prototype`
Status: open, blocked by T2, T3
Blocks: (none)

## Question

전체 데스크탑 앱의 화면 구조는 어떻게 되나?

- 단일 화면 (드롭존 하나 → 매칭 → 적용) vs 위저드 (import → match → review → apply).
- Roll 선택 방식 (드롭된 JSON에서 자동 인식 vs 리스트에서 선택).
- Preview 창 — 어떤 태그가 어떤 값으로 들어가는지 확인 가능해야.
- Progress / 완료 후 결과 화면.

T2 매칭 UX와 T3 스택 결정 후에 진행.

## Resolution

**단일 화면** (위저드 아님). 모달 0개.

**상태 두 개:**

**Empty state** (JSON·스캔 폴더 둘 다 미로드):
- 중앙 대형 drop zone (`.rol.json` + 스캔 폴더 둘 다 accept)
- 하단에 파일 선택 다이얼로그 진입점 (`[.rol.json 열기]`, `[스캔 폴더 열기]`)

**Loaded state** (둘 다 로드되면 자동 전이):
- 상단: 롤 메타 요약 한 줄 (`Roll 12 · Portra 400 · Nikon FM2 · 36 frames`) + 재로드 버튼 두 개
- 중앙: T2에서 결정한 두 열 매칭 UI (좌 shot / 우 파일 + 64px 썸네일)
- 하단: T2 조정 도구 4개 + status bar + `[▸ Apply EXIF]` 버튼

**Preview**: 전용 화면·모달 없음. 각 행 좌측 `▸` 클릭 시 인라인 확장, 그 shot이 이 파일에 어떤 태그를 어떤 값으로 쓸지 전체 나열. 사용자가 걱정될 때만 열어봄, 안 열면 방해 없음.

**Apply 진행/결과**: 인라인만.
- 각 행에 상태 아이콘: ⏳ pending → ✓ 성공 / ✗ 실패
- 하단 status bar 실시간 갱신: `12/36 written...` → `34/36 done · 2 failed`
- 실패 행 클릭 시 확장에 exiftool stderr 표시

**설계 원칙:**
- 모달 0개 (파일/폴더 선택 시 OS 네이티브 다이얼로그만).
- Preview·Result 다 인라인 확장으로 통합 — 별도 화면 없음.
- 앱을 열자마자 다음 액션이 명확 (drop zone 하나).
- Roll 선택 UI 없음 — `.rol.json` 하나 = 롤 하나 (T1 결정).
