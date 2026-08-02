import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

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

class _MainPageState extends State<MainPage> {
  RolExport? _rol;
  String? _rolPath;
  Directory? _scanDir;
  List<File> _scanFiles = const [];
  String? _error;

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
                onReloadRol: _openRolFile,
                onReloadDir: _openScanDir,
                onApply: _applyStub,
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

  void _applyStub() {
    // ponytail: T5/T6 exiftool wrapping은 아직 없음. placeholder.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('exiftool 주입은 T5에서 붙일 예정')),
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
  final VoidCallback onReloadRol;
  final VoidCallback onReloadDir;
  final VoidCallback onApply;

  const _LoadedState({
    required this.rol,
    required this.scanDir,
    required this.scanFiles,
    required this.onReloadRol,
    required this.onReloadDir,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final shots = rol.roll.shots;
    final rows = <_MatchRow>[];
    final n = shots.length > scanFiles.length ? shots.length : scanFiles.length;
    for (var i = 0; i < n; i++) {
      rows.add(_MatchRow(
        shot: i < shots.length ? shots[i] : null,
        file: i < scanFiles.length ? scanFiles[i] : null,
      ));
    }
    final matched = rows.where((r) => r.shot != null && r.file != null).length;

    return Column(
      children: [
        _MetaBar(
          rol: rol,
          scanDir: scanDir,
          onReloadRol: onReloadRol,
          onReloadDir: onReloadDir,
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _MatchRowTile(row: rows[i]),
          ),
        ),
        const Divider(height: 1),
        _BottomBar(
          matched: matched,
          total: rows.length,
          onApply: onApply,
        ),
      ],
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

class _MatchRow {
  final Shot? shot;
  final File? file;
  _MatchRow({this.shot, this.file});
}

class _MatchRowTile extends StatelessWidget {
  final _MatchRow row;
  const _MatchRowTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _shotCell(context)),
          const SizedBox(width: 16),
          Expanded(child: _fileCell(context)),
        ],
      ),
    );
  }

  Widget _shotCell(BuildContext context) {
    final s = row.shot;
    if (s == null) {
      return const Text('— 갭 —', style: TextStyle(color: Colors.grey));
    }
    return Column(
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
    );
  }

  Widget _fileCell(BuildContext context) {
    final f = row.file;
    if (f == null) {
      return const Text('— 갭 —', style: TextStyle(color: Colors.grey));
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
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
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
}

class _BottomBar extends StatelessWidget {
  final int matched;
  final int total;
  final VoidCallback onApply;
  const _BottomBar({
    required this.matched,
    required this.total,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ponytail: T2 조정 도구 4개(Shift/Gap-L/Gap-R/Reverse)는 별도 티켓.
          Expanded(
            child: Text('$matched / $total 매칭됨',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          FilledButton.icon(
            onPressed: matched == 0 ? null : onApply,
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
