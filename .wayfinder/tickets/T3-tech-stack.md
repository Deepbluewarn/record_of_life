# T3: Tech stack

Label: `wayfinder:grilling`
Status: open, unblocked, unclaimed
Blocks: T4

## Question

데스크탑 앱을 어떤 스택으로 만들까?

- **Flutter Desktop** — 모바일과 모델/스키마/JSON 파서 코드 공유 가능. Dart 하나로 통일. Windows/macOS 지원 성숙도 확인 필요.
- **Tauri (Rust + 웹)** — 번들 작고 빠름. 하지만 모델을 두 번 쓰게 됨.
- **Electron** — 흔함. 무거움.
- **CLI 우선 + 나중에 GUI** — MVP를 exiftool wrapper CLI로 시작하고 GUI 나중.

주요 판단축: (a) 모바일과 코드 공유 이득, (b) 사용자 (본인) 개발 편의, (c) exiftool 프로세스 실행 편의성.

## Resolution

**Flutter Desktop.** Windows/macOS 타겟.

**결정 근거:**
- 코드 공유 이득이 압도적 — 모바일 앱의 `Roll/Shot/fromMap/toMap`을 desktop 앱에서 그대로 재사용.
- 사용자가 이미 Flutter 익숙.
- exiftool subprocess 실행은 `dart:io Process.run`으로 trivial.
- 배포 스코프가 개인·서비스 내부 도구라 네이티브 룩·번들 크기 최적화 부담 없음.

**웹 검토 후 기각.** 파일 시스템 접근이 Chromium 계열에만 있음(`showDirectoryPicker`), TIFF/DNG는 exiftool WASM 필요, 100MB+ TIFF 다수 처리 시 메모리 위험. 웹만으로 하기엔 제약 너무 큼.

**아키텍처 원칙 (CLI-first 재해석)**:
- 별도 CLI 배포 산출물은 안 만듦.
- 하지만 **로직/UI 분리** 원칙은 살림 — `lib/injector/` 같은 모듈로 매칭 알고리즘·태그 매핑·XMP 조각 생성을 순수 함수로 분리. Widget이 얇게 감싸고 subprocess 실행만 얇은 어댑터로.
- 나중에 CLI/웹 요구가 생기면 같은 core 위에 얇게 얹을 수 있는 구조. 지금은 스캐폴딩 안 함(YAGNI).

**리포지토리 구조**: 지금 `record_of_life`가 mobile 앱인데, desktop 앱을 어디에 둘지는 별도 판단 필요:
- 같은 저장소, 별도 entry point (예: `lib/desktop/main.dart` + flavor)
- 같은 저장소, 서브 패키지 (`packages/rol_desktop/`)
- 별도 저장소, mobile 모델을 pub package로 게시

이 세부는 **T8: 저장소·모듈 구조**로 분리 → 후속.
