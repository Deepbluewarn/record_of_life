# T6: Backup / destructive-write policy

Label: `wayfinder:grilling`
Status: open, blocked by T5
Blocks: (none)

## Question

주입은 in-place로 파일을 덮어쓰는가, 아니면 사본을 만드는가?

- exiftool 기본은 `_original` 백업 생성 (`-overwrite_original`로 끔).
- 사용자 원본을 절대 건드리지 않는 옵션이 기본이어야 하지 않나?
- 반대로 in-place면 Lightroom catalog가 깨지지 않고 잘 갱신됨.
- 실패 시 롤백 전략 (특정 파일 주입 실패 시 나머지는? 트랜잭션?)

T5에서 exiftool의 실제 동작이 확정된 후 정책 확정.

## Resolution

**1. Default 쓰기 모드**: exiftool `-overwrite_original_in_place`.
- 이유: `_original` 백업 파일이 사용자 스캔 폴더에 쌓이지 않음. Lightroom 등 후속 도구가 중복 파일로 인식하는 문제 방지. Inode·hard link·permissions·Windows 생성 시각 보존.

**2. UI 토글**: T4 status bar에 `backup ○` / `backup ●` 배지. 클릭 시 토글. 상태 앱 설정에 persist (매번 안 물어봄). 초기값: **꺼짐**. 켜지면 `_original` 백업 파일 남김.

**3. 부분 실패 처리**: 트랜잭션 아님. 각 파일 독립 처리.
- 이유: exiftool은 파일 단위 원자적. 여러 파일 트랜잭션은 FS 수준에서 불가능. 실패는 대부분 파일별 고유(권한/잠금/손상). 나머지 진행이 정답.
- UI: 실패 행에 ✗, exiftool stderr 확장 시 표시. 사용자가 원인 확인 후 그 파일만 재시도.

**4. 기존 EXIF 있는 파일**: 우리 매핑 태그만 덮어씀. Confirm 다이얼로그 없음 (모달 0개 원칙).
- 우리는 T5 매핑 목록에 있는 태그만 씀. 스캐너가 넣은 다른 태그(예: 스캐너 모델, 스캔 해상도)는 안 건드림. exiftool 기본 동작.

**5. 재적용 안전**: 같은 파일에 두 번 Apply해도 결과 동일. 매칭 잘못했으면 고쳐서 다시 Apply.

**커스텀 XMP-rol 네임스페이스 배포**: `.ExifTool_config` 파일을 앱 리소스로 번들, exiftool 프로세스 실행 시 `-config <path>` 플래그로 지정. 사용자가 신경 안 씀.
