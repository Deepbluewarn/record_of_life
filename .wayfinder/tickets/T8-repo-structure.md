# T8: 저장소·모듈 구조

Label: `wayfinder:grilling`
Status: open, unblocked
Blocks: (none — T4는 이거 없이도 진행 가능하지만 확정되면 파일 위치 명확해짐)

## Question

Desktop 앱과 모바일 앱이 모델 코드를 공유해야 하는데, 어떤 구조로 둘까?

- **옵션 A: 같은 저장소, 별도 entry point.** `lib/mobile/main.dart` + `lib/desktop/main.dart`, Flutter flavor 나 별도 build target으로 구분. 모델·도메인은 `lib/domain/` 공유.
- **옵션 B: 같은 저장소, monorepo 서브패키지.** `packages/rol_mobile/`, `packages/rol_desktop/`, `packages/rol_core/`. `rol_core`에 모델 넣고 나머지 둘이 depend. melos 등 tool로 관리.
- **옵션 C: 별도 저장소, pub 패키지 공유.** `rol_core`를 (사설) pub 패키지로 배포, 두 앱이 사용. 오버킬 가능성.

주요 판단축: 개발 편의(같은 저장소면 diff 하나로 mobile+desktop 동시 변경), 의존성 명료함(패키지 분리하면 순환 의존 방지), 빌드 복잡도.

## Resolution

**Monorepo 서브패키지 (옵션 B). Dart 3.5+ 네이티브 pub workspaces 사용, melos 없음.**

**구조:**
```
record_of_life/
├─ pubspec.yaml                    ← workspace 루트
├─ packages/
│  ├─ rol_core/                    ← 순수 Dart
│  │  └─ lib/{models,export,exif}/
│  ├─ rol_mobile/                  ← 현 앱, sembast 지속화 포함
│  └─ rol_desktop/                 ← 데스크탑 앱 scaffold
```

**패키지 책임:**
| 패키지 | 무엇 | Flutter |
|---|---|---|
| `rol_core` | 도메인 모델, `.rol.json`/argfile 직렬화, T5 태그 매핑 규칙 | ❌ |
| `rol_mobile` | 촬영 로거, sembast 지속화, 온보딩, 렌즈/필름 UI | ✅ |
| `rol_desktop` | 파일 매칭 UI, exiftool subprocess, `.ExifTool_config` 번들 | ✅ Desktop |

**지속화(sembast) 위치**: `rol_mobile`에만. 데스크탑은 export JSON 읽고 EXIF 쓰고 종료 — 지속화 불필요. 나중에 필요해지면 `rol_data` 분리.

**네이밍**: `rol_*` prefix (pub 배포 안 하니 충돌 무관).

**마이그레이션은 별도 실행 티켓으로**. Map의 destination은 spec 확정이라 실행은 map 밖.
