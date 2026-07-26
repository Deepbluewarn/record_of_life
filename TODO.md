# TODO

## 최근 완료
- [x] E 잔여: section_header/shot_card/3개 dialog 톤 통일
- [x] K: 저장 후 스낵바에 '확인' 액션 → 롤 상세로 pop

## 남음 (릴리스 축)
- [ ] C. 스토어 준비물 (개인정보처리방침, 서명 키, 스크린샷·설명)
- [ ] icon PNG: assets/icon/icon.png (1024×1024) 준비 후
      `dart run flutter_launcher_icons`
- [ ] H. 스캔 파일명 규칙 사용자 설정 (PRD 4.5) — 지금 하드코딩
      `{safeTitle}_{idx:03d}.*`

## 나중
- [ ] J. 웹 정식 영속화 (Dart 3.10+ → sembast_web)
- [ ] L. 통계·이력 대시보드
- [ ] M. CI (GitHub Actions flutter analyze + test)
- [ ] N. README 갱신

## 논의 후 skip
- 롤 카드 롱프레스 = 즉시 캡처: 홈 카드 우상단에 카메라 IconButton이 이미
  있어 shortcut 중복. 필요성 재확인되면 재검토.
- 온보딩 마지막에 첫 롤 CTA 통합: 홈 empty state의 '첫 롤 만들기'로 이미 유도.
  강제 push는 사용자가 앱을 캐주얼하게 탐색하지 못하게 함.
