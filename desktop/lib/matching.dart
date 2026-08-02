// shot ↔ file 매칭 상태. shot idx → file idx Map.
// 안 들어간 shot·file 은 unmatched. gap 개념 없음.

class MatchState {
  final Map<int, int> shotToFile;
  final int shotCount;
  final int fileCount;

  const MatchState(this.shotToFile, this.shotCount, this.fileCount);

  // 로드 즉시 순서대로 min(N,M) 개 자동 매치.
  factory MatchState.autoMatch(int shots, int files) {
    final n = shots < files ? shots : files;
    return MatchState({for (var i = 0; i < n; i++) i: i}, shots, files);
  }

  int? fileForShot(int shot) => shotToFile[shot];

  int? shotForFile(int file) {
    for (final e in shotToFile.entries) {
      if (e.value == file) return e.key;
    }
    return null;
  }

  List<int> get unmatchedShots => [
        for (var i = 0; i < shotCount; i++)
          if (!shotToFile.containsKey(i)) i
      ];

  List<int> get unmatchedFiles {
    final used = shotToFile.values.toSet();
    return [
      for (var i = 0; i < fileCount; i++)
        if (!used.contains(i)) i
    ];
  }

  int get matchedCount => shotToFile.length;

  // shot 을 file 에 매핑. 해당 file 이 다른 shot 에 이미 잡혀 있으면 그 매핑은 해제.
  MatchState reassign(int shot, int file) {
    final map = Map<int, int>.from(shotToFile)
      ..removeWhere((_, f) => f == file);
    map[shot] = file;
    return MatchState(map, shotCount, fileCount);
  }

  MatchState unmatch(int shot) {
    final map = Map<int, int>.from(shotToFile)..remove(shot);
    return MatchState(map, shotCount, fileCount);
  }

  // 두 shot 의 file 매핑을 교환.
  MatchState swapShots(int a, int b) {
    final map = Map<int, int>.from(shotToFile);
    final fa = map[a];
    final fb = map[b];
    if (fa == null) {
      map.remove(b);
    } else {
      map[b] = fa;
    }
    if (fb == null) {
      map.remove(a);
    } else {
      map[a] = fb;
    }
    return MatchState(map, shotCount, fileCount);
  }
}
