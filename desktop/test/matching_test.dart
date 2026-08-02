import 'package:flutter_test/flutter_test.dart';
import 'package:rol_desktop/matching.dart';

void main() {
  test('autoMatch: min(N,M) 개 순서 매치', () {
    final m = MatchState.autoMatch(4, 6);
    expect(m.shotToFile, {0: 0, 1: 1, 2: 2, 3: 3});
    expect(m.unmatchedShots, isEmpty);
    expect(m.unmatchedFiles, [4, 5]);
  });

  test('reassign: file 이 이미 잡혀 있으면 기존 매핑 해제', () {
    var m = MatchState.autoMatch(3, 3); // {0:0, 1:1, 2:2}
    m = m.reassign(0, 2); // shot0 -> file2 (이전에 shot2가 잡던 file)
    expect(m.shotToFile, {0: 2, 1: 1});
    expect(m.unmatchedShots, [2]);
  });

  test('unmatch: shot 만 리스트에서 제거, file 도 미매치가 됨', () {
    final m = MatchState.autoMatch(3, 3).unmatch(1);
    expect(m.shotToFile, {0: 0, 2: 2});
    expect(m.unmatchedShots, [1]);
    expect(m.unmatchedFiles, [1]);
  });

  test('swapShots: 두 shot 의 file 교환', () {
    final m = MatchState.autoMatch(3, 3).swapShots(0, 2);
    expect(m.shotToFile, {0: 2, 1: 1, 2: 0});
  });

  test('swapShots: 한 쪽이 unmatched 면 file 이 그 shot 으로 넘어감', () {
    var m = MatchState.autoMatch(3, 3).unmatch(0); // {1:1, 2:2}
    m = m.swapShots(0, 1); // shot0(빔) <-> shot1(file1) → shot0=file1, shot1 없음
    expect(m.shotToFile, {0: 1, 2: 2});
    expect(m.unmatchedShots, [1]);
  });
}
