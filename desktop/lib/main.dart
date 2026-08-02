import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'exiftool.dart';
import 'rol_json.dart';

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

enum _RowPhase { idle, running, ok, fail }

class _RowStatus {
  final _RowPhase phase;
  final String? stderr;
  const _RowStatus(this.phase, {this.stderr});
  static const idle = _RowStatus(_RowPhase.idle);
}

class _MainPageState extends State<MainPage> {
  RolExport? _rol;
  String? _rolPath;
  Directory? _scanDir;
  List<File> _scanFiles = const [];
  String? _error;

  // T6: default false = -overwrite_original_in_place (백업 없음).
  bool _keepBackup = false;
  bool? _exiftoolOk;
  final Map<int, _RowStatus> _status = {};
  final Set<int> _expanded = {};
  bool _running = false;

  // T2 매칭 상태. 각 리스트 원소는 인덱스(shots/scanFiles) 또는 null(갭).
  // 리스트 길이 = 행 개수. 두 리스트는 항상 같은 길이.
  List<int?> _leftIdx = [];
  List<int?> _rightIdx = [];

  void _rebuildRows() {
    final shots = _rol?.roll.shots.length ?? 0;
    final files = _scanFiles.length;
    _leftIdx = [for (var i = 0; i < shots; i++) i];
    _rightIdx = [for (var i = 0; i < files; i++) i];
    _padRows();
    _status.clear();
    _expanded.clear();
  }

  void _padRows() {
    final len = _leftIdx.length > _rightIdx.length
        ? _leftIdx.length
        : _rightIdx.length;
    while (_leftIdx.length < len) {
      _leftIdx.add(null);
    }
    while (_rightIdx.length < len) {
      _rightIdx.add(null);
    }
  }

  void _shiftRight(int by) {
    setState(() {
      if (by > 0) {
        _rightIdx.insertAll(0, List.filled(by, null));
      } else {
        for (var i = 0; i < -by; i++) {
          if (_rightIdx.isNotEmpty && _rightIdx.first == null) {
            _rightIdx.removeAt(0);
          }
        }
      }
      _padRows();
      _status.clear();
    });
  }

  void _insertGap(int at, {required bool left}) {
    setState(() {
      (left ? _leftIdx : _rightIdx).insert(at, null);
      _padRows();
      _status.clear();
    });
  }

  void _reverseRight() {
    setState(() {
      _rightIdx = _rightIdx.reversed.toList();
      _status.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    exiftoolAvailable().then((ok) {
      if (mounted) setState(() => _exiftoolOk = ok);
    });
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
        _rebuildRows();
      });
    } catch (e) {
      setState(() => _error = '${f.path} 로드 실패: $e');
    }
  }

  void _loadScanDir(Directory dir) {
    // T2 초기 배치: 파일명 자연 정렬. 이미지 확장자만.
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
      _rebuildRows();
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

  void _reset() {
    setState(() {
      _rol = null;
      _rolPath = null;
      _scanDir = null;
      _scanFiles = const [];
      _error = null;
    });
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
            ? _LoadedState(
                rol: _rol!,
                scanDir: _scanDir!,
                scanFiles: _scanFiles,
                leftIdx: _leftIdx,
                rightIdx: _rightIdx,
                status: _status,
                expanded: _expanded,
                keepBackup: _keepBackup,
                running: _running,
                exiftoolOk: _exiftoolOk,
                onReloadRol: _openRolFile,
                onReloadDir: _openScanDir,
                onApply: _apply,
                onToggleExpanded: _toggleExpanded,
                onKeepBackupChanged: (v) => setState(() => _keepBackup = v),
                onShiftRight: _shiftRight,
                onReverseRight: _reverseRight,
                onInsertGap: _insertGap,
              )
            : _EmptyState(
                rol: _rol,
                rolPath: _rolPath,
                scanDir: _scanDir,
                error: _error,
                onOpenRol: _openRolFile,
                onOpenDir: _openScanDir,
              ),
      ),
    );
  }

  // T5/T6. 매칭된 행 순차 주입. 실패해도 나머지 계속.
  Future<void> _apply() async {
    if (_running || _rol == null) return;
    setState(() {
      _running = true;
      _status.clear();
    });
    for (var i = 0; i < _leftIdx.length; i++) {
      final l = _leftIdx[i];
      final r = _rightIdx[i];
      if (l == null || r == null) continue;
      setState(() => _status[i] = const _RowStatus(_RowPhase.running));
      final shot = _rol!.roll.shots[l];
      final args = shotToArgs(export: _rol!, shot: shot);
      final res = await injectFile(
        args: args,
        targetPath: _scanFiles[r].path,
        keepBackup: _keepBackup,
      );
      setState(() {
        _status[i] = res.ok
            ? const _RowStatus(_RowPhase.ok)
            : _RowStatus(_RowPhase.fail, stderr: res.stderr);
      });
    }
    setState(() => _running = false);
  }

  void _toggleExpanded(int i) {
    setState(() {
      if (_expanded.contains(i)) {
        _expanded.remove(i);
      } else {
        _expanded.add(i);
      }
    });
  }
}

class _EmptyState extends StatelessWidget {
  final RolExport? rol;
  final String? rolPath;
  final Directory? scanDir;
  final String? error;
  final VoidCallback onOpenRol;
  final VoidCallback onOpenDir;

  const _EmptyState({
    required this.rol,
    required this.rolPath,
    required this.scanDir,
    required this.error,
    required this.onOpenRol,
    required this.onOpenDir,
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
                size: 64,
                color: Theme.of(context).colorScheme.outline),
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

class _LoadedState extends StatelessWidget {
  final RolExport rol;
  final Directory scanDir;
  final List<File> scanFiles;
  final List<int?> leftIdx;
  final List<int?> rightIdx;
  final Map<int, _RowStatus> status;
  final Set<int> expanded;
  final bool keepBackup;
  final bool running;
  final bool? exiftoolOk;
  final VoidCallback onReloadRol;
  final VoidCallback onReloadDir;
  final Future<void> Function() onApply;
  final void Function(int) onToggleExpanded;
  final ValueChanged<bool> onKeepBackupChanged;
  final void Function(int) onShiftRight;
  final VoidCallback onReverseRight;
  final void Function(int at, {required bool left}) onInsertGap;

  const _LoadedState({
    required this.rol,
    required this.scanDir,
    required this.scanFiles,
    required this.leftIdx,
    required this.rightIdx,
    required this.status,
    required this.expanded,
    required this.keepBackup,
    required this.running,
    required this.exiftoolOk,
    required this.onReloadRol,
    required this.onReloadDir,
    required this.onApply,
    required this.onToggleExpanded,
    required this.onKeepBackupChanged,
    required this.onShiftRight,
    required this.onReverseRight,
    required this.onInsertGap,
  });

  @override
  Widget build(BuildContext context) {
    final len = leftIdx.length;
    var matched = 0;
    for (var i = 0; i < len; i++) {
      if (leftIdx[i] != null && rightIdx[i] != null) matched++;
    }
    final done = status.values.where((s) => s.phase == _RowPhase.ok).length;
    final failed = status.values.where((s) => s.phase == _RowPhase.fail).length;

    return Column(
      children: [
        _MetaBar(
          rol: rol,
          scanDir: scanDir,
          onReloadRol: onReloadRol,
          onReloadDir: onReloadDir,
        ),
        if (exiftoolOk == false)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'exiftool 이 PATH에 없음. 설치 후 앱을 재실행하세요.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        _AdjustBar(
          running: running,
          onShiftLeft: () => onShiftRight(-1),
          onShiftRight: () => onShiftRight(1),
          onReverseRight: onReverseRight,
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: len,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final li = leftIdx[i];
              final ri = rightIdx[i];
              return _MatchRowTile(
                index: i,
                shot: li == null ? null : rol.roll.shots[li],
                file: ri == null ? null : scanFiles[ri],
                rol: rol,
                status: status[i] ?? _RowStatus.idle,
                expanded: expanded.contains(i),
                canAdjust: !running,
                onToggle: () => onToggleExpanded(i),
                onInsertGapLeft: () => onInsertGap(i, left: true),
                onInsertGapRight: () => onInsertGap(i, left: false),
              );
            },
          ),
        ),
        const Divider(height: 1),
        _BottomBar(
          matched: matched,
          total: len,
          done: done,
          failed: failed,
          running: running,
          keepBackup: keepBackup,
          canApply: exiftoolOk == true,
          onApply: onApply,
          onKeepBackupChanged: onKeepBackupChanged,
        ),
      ],
    );
  }
}

class _AdjustBar extends StatelessWidget {
  final bool running;
  final VoidCallback onShiftLeft;
  final VoidCallback onShiftRight;
  final VoidCallback onReverseRight;
  const _AdjustBar({
    required this.running,
    required this.onShiftLeft,
    required this.onShiftRight,
    required this.onReverseRight,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text('오른쪽 열:',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '왼쪽으로 shift (앞 갭 제거)',
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: running ? null : onShiftLeft,
          ),
          IconButton(
            tooltip: '오른쪽으로 shift (앞에 갭 삽입)',
            icon: const Icon(Icons.arrow_forward, size: 18),
            onPressed: running ? null : onShiftRight,
          ),
          IconButton(
            tooltip: '역순 (스캐너 역순 반환)',
            icon: const Icon(Icons.swap_vert, size: 18),
            onPressed: running ? null : onReverseRight,
          ),
        ],
      ),
    );
  }
}

class _MetaBar extends StatelessWidget {
  final RolExport rol;
  final Directory scanDir;
  final VoidCallback onReloadRol;
  final VoidCallback onReloadDir;

  const _MetaBar({
    required this.rol,
    required this.scanDir,
    required this.onReloadRol,
    required this.onReloadDir,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _MatchRowTile extends StatelessWidget {
  final int index;
  final Shot? shot;
  final File? file;
  final RolExport rol;
  final _RowStatus status;
  final bool expanded;
  final bool canAdjust;
  final VoidCallback onToggle;
  final VoidCallback onInsertGapLeft;
  final VoidCallback onInsertGapRight;

  const _MatchRowTile({
    required this.index,
    required this.shot,
    required this.file,
    required this.rol,
    required this.status,
    required this.expanded,
    required this.canAdjust,
    required this.onToggle,
    required this.onInsertGapLeft,
    required this.onInsertGapRight,
  });

  @override
  Widget build(BuildContext context) {
    final canExpand = shot != null;
    return Column(
      children: [
        InkWell(
          onTap: canExpand ? onToggle : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  canExpand
                      ? (expanded ? Icons.expand_more : Icons.chevron_right)
                      : Icons.remove,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(child: _shotCell(context)),
                const SizedBox(width: 16),
                Expanded(child: _fileCell(context)),
                const SizedBox(width: 8),
                _statusIcon(),
              ],
            ),
          ),
        ),
        if (expanded && shot != null) _expansion(context),
      ],
    );
  }

  Widget _statusIcon() {
    switch (status.phase) {
      case _RowPhase.idle:
        return const SizedBox(width: 20);
      case _RowPhase.running:
        return const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case _RowPhase.ok:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case _RowPhase.fail:
        return const Icon(Icons.error, color: Colors.red, size: 20);
    }
  }

  Widget _expansion(BuildContext context) {
    // T4: 인라인 확장 — 이 shot이 파일에 쓸 태그 전체 나열. 실패 시 stderr도.
    final args = shotToArgs(export: rol, shot: shot!);
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(52, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (args.isEmpty)
            const Text('(주입할 태그 없음)',
                style: TextStyle(fontStyle: FontStyle.italic))
          else
            SelectableText(
              args.join('\n'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          if (status.phase == _RowPhase.fail && status.stderr != null) ...[
            const SizedBox(height: 8),
            Text('exiftool 오류:',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold)),
            SelectableText(
              status.stderr!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _shotCell(BuildContext context) {
    final s = shot;
    if (s == null) {
      return Row(
        children: [
          const Expanded(
              child: Text('— 갭 —', style: TextStyle(color: Colors.grey))),
          if (canAdjust)
            IconButton(
              tooltip: '왼쪽에 갭 삽입',
              iconSize: 16,
              icon: const Icon(Icons.add_box_outlined),
              onPressed: onInsertGapLeft,
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('#${s.idx}',
                  style: Theme.of(context).textTheme.labelLarge),
              Text(s.summary),
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
        if (canAdjust)
          IconButton(
            tooltip: '왼쪽에 갭 삽입 (이 shot 이후로 밀림)',
            iconSize: 16,
            icon: const Icon(Icons.add_box_outlined),
            onPressed: onInsertGapLeft,
          ),
      ],
    );
  }

  Widget _fileCell(BuildContext context) {
    final f = file;
    if (f == null) {
      return Row(
        children: [
          const Expanded(
              child: Text('— 갭 —', style: TextStyle(color: Colors.grey))),
          if (canAdjust)
            IconButton(
              tooltip: '오른쪽에 갭 삽입',
              iconSize: 16,
              icon: const Icon(Icons.add_box_outlined),
              onPressed: onInsertGapRight,
            ),
        ],
      );
    }
    return Row(
      children: [
        // T2: 매칭 화면 안에서만 렌더. 저장·풀뷰어 없음.
        SizedBox(
          width: 64,
          height: 64,
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
        if (canAdjust)
          IconButton(
            tooltip: '오른쪽에 갭 삽입 (이 파일 이후로 밀림)',
            iconSize: 16,
            icon: const Icon(Icons.add_box_outlined),
            onPressed: onInsertGapRight,
          ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int matched;
  final int total;
  final int done;
  final int failed;
  final bool running;
  final bool keepBackup;
  final bool canApply;
  final VoidCallback onApply;
  final ValueChanged<bool> onKeepBackupChanged;

  const _BottomBar({
    required this.matched,
    required this.total,
    required this.done,
    required this.failed,
    required this.running,
    required this.keepBackup,
    required this.canApply,
    required this.onApply,
    required this.onKeepBackupChanged,
  });

  @override
  Widget build(BuildContext context) {
    // T6: keepBackup off = -overwrite_original_in_place. On = <file>_original 남김.
    final status = running
        ? '$done / $matched 진행중${failed > 0 ? " · $failed 실패" : ""}'
        : done + failed > 0
            ? '$done 성공${failed > 0 ? " · $failed 실패" : ""} · $matched 매칭 / $total 행'
            : '$matched / $total 매칭됨';

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
                Switch(value: keepBackup, onChanged: running ? null : onKeepBackupChanged),
                const SizedBox(width: 4),
                const Text('백업 유지'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(status,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          FilledButton.icon(
            onPressed: (matched == 0 || running || !canApply) ? null : onApply,
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
