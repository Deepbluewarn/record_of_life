# TODO

## 이번 세션 완료
- [x] A. 앱 아이콘 · 스플래시 파이프라인 (icon PNG는 사용자 준비)
- [x] B. 홈 empty state
- [x] D. 총 매수 초과 촬영 옵션
- [x] F. 데드 코드 정리
- [x] G. ExiftoolExporter · 롤 라이프사이클 unit test
- [x] I. 위치 권한 거부 안내
- [x] 버그: 홈에서 방금 만든 롤이 안 보이는 문제 (RollFilter.inProgress → working)
- [x] LRU 정렬 (카메라·필름·렌즈 selection dialog 상단에 최근 사용)
- [x] E 부분: CustomAppBar 미니멀 톤 + shot_form 날짜 필드
- [x] K 부분: 프리뷰 탭 = 즉시 촬영

## 남음
- [ ] C. 스토어 준비물 (개인정보처리방침, 서명, 스크린샷)
- [ ] E 잔여. shot_form의 나머지 필드(TextField 인라인 스타일), 3개
      bottom sheet(add_camera/film/lens), 다이얼로그 배경·타이틀 스타일.
- [ ] H. 스캔 파일명 규칙 사용자 설정 (PRD 4.5)
- [ ] K 잔여. 사용자가 언급한 '전체적인 플로우 재정비':
      홈 → 롤 상세 → 입력 모드의 3단 탭 흐름 검토, 진행 중 롤 카드에서
      바로 입력 모드로 진입하는 shortcut, 온보딩 종료 후 첫 롤 CTA 배치 등.
      큰 스코프 — 별도 세션에서 재논의.
- [ ] icon PNG: assets/icon/icon.png (1024×1024) 준비 후
      `dart run flutter_launcher_icons` 실행.

## 나중
- [ ] J. 웹 정식 영속화 (Dart 3.10+ → sembast_web)
- [ ] L. 통계·이력 대시보드
- [ ] M. CI (GitHub Actions flutter analyze + test)
- [ ] N. README 갱신
