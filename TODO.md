# TODO

## 최근 세션 완료
- [x] 홈 필터 버그 (RollFilter.working — planning+inProgress)
- [x] LRU 정렬 (카메라·필름·렌즈 dialog 상단 최근 사용순)
- [x] 캡처 실시간 프리뷰 제거 (필름 카메라 사용자에게 방해)
- [x] E UI 톤 통일: ShotForm 컴포넌트 분해, 3개 bottom sheet를 BottomSheetShell로
      공용화, 인라인 스타일 제거
- [x] K 부분: 홈 롤 카드에서 '입력 모드 시작' 바로가기 아이콘

## 남음
- [ ] C. 스토어 준비물 (개인정보처리방침, 서명, 스크린샷)
- [ ] E 잔여. dialog 배경/타이틀 계열, shot_card, section_header 톤 재점검.
- [ ] H. 스캔 파일명 규칙 사용자 설정 (PRD 4.5)
- [ ] K 잔여. 사용자가 언급한 '전체 플로우 재정비' 추가 아이디어:
      - 캡처 진입 후 저장 완료 시 롤 상세로 되돌아가는 옵션
      - 온보딩 종료 후 첫 롤 CTA를 온보딩 자체에 통합할지
      - 롤 카드 롱프레스 = 즉시 캡처 (다중 선택 있는 all_rolls_page와 충돌 주의)
- [ ] icon PNG: assets/icon/icon.png (1024×1024) 준비 후
      `dart run flutter_launcher_icons` 실행.

## 나중
- [ ] J. 웹 정식 영속화 (Dart 3.10+ → sembast_web)
- [ ] L. 통계·이력 대시보드
- [ ] M. CI (GitHub Actions flutter analyze + test)
- [ ] N. README 갱신
