import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'exiftool.dart';
import 'matching.dart';
import 'rol_json.dart';
import 'sample.dart';

void main() {
  runApp(const RolDesktopApp());
}

class RolDesktopApp extends StatelessWidget {
  const RolDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROL Desktop',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

enum _MatchPhase { idle, running, ok, fail }

class _MatchStatus {
  final _MatchPhase phase;
  final String? stderr;
  const _MatchStatus(this.phase, {this.stderr});
  static const idle = _MatchStatus(_MatchPhase.idle);
}

enum MatchSide { shot, file }

class _MainPageState extends State<MainPage> {
  RolExport? _rol;
  String? _rolPath;
  Directory? _scanDir;
  List<File> _scanFiles = const [];
  String? _error;

  // T6: default false = -overwrite_original_in_place (백업 없음).
  bool _keepBackup = false;
  bool? _exiftoolOk;
  bool _running = false;
  // shot idx → 주입 상태
  final Map<int, _MatchStatus> _status = {};

  MatchState _match = const MatchState({}, 0, 0);

  // 두 그리드 UI의 클릭 선택. 반대편 클릭 = 매치, 같은편 = 스왑.
  MatchSide? _selSide;
  int? _selIdx;

  @override
  void initState() {
    super.initState();
    exiftoolAvailable().then((ok) {
      if (mounted) setState(() => _exiftoolOk = ok);
    });
  }

  void _rebuildMatch() {
    _match = MatchState.autoMatch(
        _rol?.roll.shots.length ?? 0, _scanFiles.length);
    _status.clear();
    _selSide = null;
    _selIdx = null;
  }

  Future<void> _openRolFile() async {
    final f = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: '.rol.json', extensions: ['json']),
      ],
    );
    if (f != null) _loadRol(File(f.path));
  }

  Future<void> _openScanDir() async {
    final dir = await getDirectoryPath();
    if (dir != null) _loadScanDir(Directory(dir));
  }

  void _loadRol(File f) {
    try {
      final rol = RolExport.fromFile(f);
      setState(() {
        _rol = rol;
        _rolPath = f.path;
        _error = null;
        _rebuildMatch();
      });
    } catch (e) {
      setState(() => _error = '${f.path} 로드 실패: $e');
    }
  }

  void _loadScanDir(Directory dir) {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => _isImageExt(p.extension(f.path)))
        .toList()
      ..sort(_natCompare);
    setState(() {
      _scanDir = dir;
      _scanFiles = files;
      _error = null;
      _rebuildMatch();
    });
  }

  void _onDrop(DropDoneDetails d) {
    for (final item in d.files) {
      final path = item.path;
      final stat = FileStat.statSync(path);
      if (stat.type == FileSystemEntityType.directory) {
        _loadScanDir(Directory(path));
      } else if (path.toLowerCase().endsWith('.json')) {
        _loadRol(File(path));
      }
    }
  }

  // UI 프리뷰용. 실제 스캔 파일은 없으므로 Image.file은 broken_image로 폴백.
  void _loadSample() {
    setState(() {
      _rol = sampleExport();
      _rolPath = 'sample.rol.json';
      _scanDir = Directory('(sample)');
      _scanFiles = sampleScanFiles();
      _error = null;
      _rebuildMatch();
    });
  }

  void _reset() {
    setState(() {
      _rol = null;
      _rolPath = null;
      _scanDir = null;
      _scanFiles = const [];
      _error = null;
      _match = const MatchState({}, 0, 0);
      _status.clear();
      _selSide = null;
      _selIdx = null;
    });
  }

  // 두 그리드 상호작용:
  // - 선택 없음 + 클릭 → 하이라이트만
  // - 선택 있음 + 반대편 클릭 → 그 shot ↔ file 매치
  // - 선택 있음 + 같은편 다른 아이템 클릭 → 두 아이템의 file 매핑 스왑 (shot 기준)
  void _onTapCell(MatchSide side, int idx) {
    if (_running) return;
    setState(() {
      if (_selSide == null) {
        _selSide = side;
        _selIdx = idx;
        return;
      }
      if (_selSide == side && _selIdx == idx) {
        // 자기 자신 재클릭 → 선택 해제
        _selSide = null;
        _selIdx = null;
        return;
      }
      if (_selSide == side) {
        if (side == MatchSide.shot) {
          _match = _match.swapShots(_selIdx!, idx);
        } else {
          // file 쌍 스왑 = 그 file들을 잡고 있는 shot들의 매핑 교환
          final sa = _match.shotForFile(_selIdx!);
          final sb = _match.shotForFile(idx);
          if (sa != null && sb != null) {
            _match = _match.reassign(sa, idx).reassign(sb, _selIdx!);
          } else if (sa != null) {
            _match = _match.reassign(sa, idx);
          } else if (sb != null) {
            _match = _match.reassign(sb, _selIdx!);
          }
        }
      } else {
        final shot = side == MatchSide.shot ? idx : _selIdx!;
        final file = side == MatchSide.file ? idx : _selIdx!;
        _match = _match.reassign(shot, file);
      }
      _selSide = null;
      _selIdx = null;
      _status.clear();
    });
  }

  void _unmatchShot(int shot) {
    if (_running) return;
    setState(() {
      _match = _match.unmatch(shot);
      _status.remove(shot);
      _selSide = null;
      _selIdx = null;
    });
  }

  Future<void> _apply() async {
    if (_running || _rol == null) return;
    setState(() {
      _running = true;
      _status.clear();
    });
    final entries = _match.shotToFile.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final e in entries) {
      final shotIdx = e.key;
      final fileIdx = e.value;
      setState(
          () => _status[shotIdx] = const _MatchStatus(_MatchPhase.running));
      final shot = _rol!.roll.shots[shotIdx];
      final args = shotToArgs(export: _rol!, shot: shot);
      final res = await injectFile(
        args: args,
        targetPath: _scanFiles[fileIdx].path,
        keepBackup: _keepBackup,
      );
      setState(() {
        _status[shotIdx] = res.ok
            ? const _MatchStatus(_MatchPhase.ok)
            : _MatchStatus(_MatchPhase.fail, stderr: res.stderr);
      });
    }
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final loaded = _rol != null && _scanDir != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROL Desktop'),
        actions: [
          if (_rol != null || _scanDir != null)
            IconButton(
              tooltip: '초기화',
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: DropTarget(
        onDragDone: _onDrop,
        child: loaded
            ? _MatchingLoaded(
                rol: _rol!,
                scanDir: _scanDir!,
                scanFiles: _scanFiles,
                match: _match,
                status: _status,
                selSide: _selSide,
                selIdx: _selIdx,
                running: _running,
                keepBackup: _keepBackup,
                exiftoolOk: _exiftoolOk,
                onReloadRol: _openRolFile,
                onReloadDir: _openScanDir,
                onTapCell: _onTapCell,
                onUnmatchShot: _unmatchShot,
                onKeepBackupChanged: (v) => setState(() => _keepBackup = v),
                onApply: _apply,
              )
            : _EmptyState(
                rol: _rol,
                rolPath: _rolPath,
                scanDir: _scanDir,
                error: _error,
                onOpenRol: _openRolFile,
                onOpenDir: _openScanDir,
                onLoadSample: _loadSample,
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final RolExport? rol;
  final String? rolPath;
  final Directory? scanDir;
  final String? error;
  final VoidCallback onOpenRol;
  final VoidCallback onOpenDir;
  final VoidCallback onLoadSample;

  const _EmptyState({
    required this.rol,
    required this.rolPath,
    required this.scanDir,
    required this.error,
    required this.onOpenRol,
    required this.onOpenDir,
    required this.onLoadSample,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_download_outlined,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              '.rol.json + 스캔 폴더를 여기로 드롭',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              rol == null
                  ? '.rol.json 아직 없음'
                  : '.rol.json 로드됨: ${p.basename(rolPath!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              scanDir == null
                  ? '스캔 폴더 아직 없음'
                  : '스캔 폴더 로드됨: ${p.basename(scanDir!.path)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenRol,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('.rol.json 열기'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenDir,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('스캔 폴더 열기'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onLoadSample,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('샘플 데이터로 UI 미리보기'),
            ),
            if (error != null) ...[
              const SizedBox(height: 24),
              Text(error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

// 두 그리드 + 스왑 매칭 UI. shot 열과 file 열, 자동 매치는 같은 번호 배지로 표시.
class _MatchingLoaded extends StatelessWidget {
  final RolExport rol;
  final Directory scanDir;
  final List<File> scanFiles;
  final MatchState match;
  final Map<int, _MatchStatus> status;
  final MatchSide? selSide;
  final int? selIdx;
  final bool running;
  final bool keepBackup;
  final bool? exiftoolOk;
  final VoidCallback onReloadRol;
  final VoidCallback onReloadDir;
  final void Function(MatchSide, int) onTapCell;
  final void Function(int) onUnmatchShot;
  final ValueChanged<bool> onKeepBackupChanged;
  final Future<void> Function() onApply;

  const _MatchingLoaded({
    required this.rol,
    required this.scanDir,
    required this.scanFiles,
    required this.match,
    required this.status,
    required this.selSide,
    required this.selIdx,
    required this.running,
    required this.keepBackup,
    required this.exiftoolOk,
    required this.onReloadRol,
    required this.onReloadDir,
    required this.onTapCell,
    required this.onUnmatchShot,
    required this.onKeepBackupChanged,
    required this.onApply,
  });

  Color _badgeColor(int matchIdx) {
    // 매치 인덱스 → 색상 hue. shot idx 기준으로 짝지어져 좌우 같은 색.
    final hue = (matchIdx * 47) % 360;
    return HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final done = status.values.where((s) => s.phase == _MatchPhase.ok).length;
    final failed =
        status.values.where((s) => s.phase == _MatchPhase.fail).length;

    return Column(
      children: [
        _metaBar(context),
        if (exiftoolOk == false)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'exiftool 이 PATH에 없음. 설치 후 앱을 재실행하세요.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        _selectionHint(context),
        const Divider(height: 1),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _shotColumn(context)),
              const VerticalDivider(width: 1),
              Expanded(child: _fileColumn(context)),
            ],
          ),
        ),
        const Divider(height: 1),
        _bottomBar(context, done, failed),
      ],
    );
  }

  Widget _metaBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rol.roll.summaryLine,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(scanDir.path,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: '.rol.json 재로드',
            icon: const Icon(Icons.description_outlined),
            onPressed: onReloadRol,
          ),
          IconButton(
            tooltip: '스캔 폴더 재로드',
            icon: const Icon(Icons.folder_open),
            onPressed: onReloadDir,
          ),
        ],
      ),
    );
  }

  Widget _selectionHint(BuildContext context) {
    final t = Theme.of(context).textTheme.bodySmall;
    final msg = selSide == null
        ? '아이템 클릭 → 반대편 클릭으로 매치 · 같은편 클릭으로 스왑'
        : '${selSide == MatchSide.shot ? "shot" : "file"} 선택됨 · 대상 클릭 (같은 아이템 재클릭 = 취소)';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(msg, style: t?.copyWith(color: Colors.grey)),
    );
  }

  Widget _shotColumn(BuildContext context) {
    final shots = rol.roll.shots;
    return ListView.separated(
      itemCount: shots.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _cell(
        context: context,
        side: MatchSide.shot,
        idx: i,
        matchIdx: match.fileForShot(i),
        content: _shotContent(context, shots[i], status[i] ?? _MatchStatus.idle),
        onLongPress:
            match.fileForShot(i) != null ? () => onUnmatchShot(i) : null,
      ),
    );
  }

  Widget _fileColumn(BuildContext context) {
    return ListView.separated(
      itemCount: scanFiles.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _cell(
        context: context,
        side: MatchSide.file,
        idx: i,
        matchIdx: match.shotForFile(i),
        content: _fileContent(context, scanFiles[i]),
      ),
    );
  }

  Widget _cell({
    required BuildContext context,
    required MatchSide side,
    required int idx,
    required int? matchIdx,
    required Widget content,
    VoidCallback? onLongPress,
  }) {
    final selected = selSide == side && selIdx == idx;
    // 색 hue 기준: shot idx. side=shot 이면 idx 자체, side=file 이면 잡고 있는 shot.
    final hueKey = side == MatchSide.shot ? idx : matchIdx;
    final badgeColor = matchIdx == null || hueKey == null
        ? Colors.grey.shade400
        : _badgeColor(hueKey);
    final badgeLabel = matchIdx == null ? '?' : '${matchIdx + 1}';

    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: () => onTapCell(side, idx),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: badgeColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shotContent(BuildContext context, Shot s, _MatchStatus st) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('#${s.idx}',
                  style: Theme.of(context).textTheme.labelLarge),
              Text(s.summary,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              if (s.note != null)
                Text(s.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
        _statusIcon(st),
      ],
    );
  }

  Widget _fileContent(BuildContext context, File f) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Image.file(
            f,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            p.basename(f.path),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statusIcon(_MatchStatus st) {
    switch (st.phase) {
      case _MatchPhase.idle:
        return const SizedBox(width: 20);
      case _MatchPhase.running:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case _MatchPhase.ok:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case _MatchPhase.fail:
        return Tooltip(
          message: st.stderr ?? 'exiftool 실패',
          child: const Icon(Icons.error, color: Colors.red, size: 20),
        );
    }
  }

  Widget _bottomBar(BuildContext context, int done, int failed) {
    final matched = match.matchedCount;
    final statusText = running
        ? '$done / $matched 진행중${failed > 0 ? " · $failed 실패" : ""}'
        : done + failed > 0
            ? '$done 성공${failed > 0 ? " · $failed 실패" : ""} · $matched 매치'
            : '$matched 매치 · shot ${match.shotCount} · file ${match.fileCount}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Tooltip(
            message: keepBackup
                ? '기존 파일을 <name>_original 로 백업'
                : '원본에 직접 쓰기 (백업 없음)',
            child: Row(
              children: [
                Switch(
                    value: keepBackup,
                    onChanged: running ? null : onKeepBackupChanged),
                const SizedBox(width: 4),
                const Text('백업 유지'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(statusText,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          FilledButton.icon(
            onPressed:
                (matched == 0 || running || exiftoolOk != true) ? null : onApply,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Apply EXIF'),
          ),
        ],
      ),
    );
  }
}

bool _isImageExt(String ext) {
  final e = ext.toLowerCase();
  return e == '.jpg' ||
      e == '.jpeg' ||
      e == '.png' ||
      e == '.tif' ||
      e == '.tiff' ||
      e == '.dng';
}

// 파일명 자연 정렬 (scan_2 < scan_10).
int _natCompare(File a, File b) {
  final an = p.basename(a.path);
  final bn = p.basename(b.path);
  final re = RegExp(r'(\d+)|(\D+)');
  final am = re.allMatches(an).toList();
  final bm = re.allMatches(bn).toList();
  final len = am.length < bm.length ? am.length : bm.length;
  for (var i = 0; i < len; i++) {
    final ap = am[i][0]!;
    final bp = bm[i][0]!;
    final aNum = int.tryParse(ap);
    final bNum = int.tryParse(bp);
    final c = (aNum != null && bNum != null)
        ? aNum.compareTo(bNum)
        : ap.compareTo(bp);
    if (c != 0) return c;
  }
  return am.length.compareTo(bm.length);
}
