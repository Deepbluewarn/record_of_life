// PROTOTYPE — throwaway. 오토매치 + 예외 조정 3안.
// 질문: gap/오프셋 개념 버림. shot ↔ file 짝짓기 = 그냥 재지정 가능한 매핑.
// 로드 즉시 순서대로 자동 매치. 사용자는 예외만 손봄.
//
// 3안:
// A. 인라인 재지정        — 매치된 행 리스트, 행별 "..." 메뉴로 재지정/해제.
// B. 두 그리드 + 스왑     — 좌 shot 그리드 / 우 file 그리드. 클릭 두 번으로 매치 재설정.
// C. Confirm + 예외 리포트 — 정상 매치는 접힘. 미매치 있을 때만 리스트 노출.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'rol_json.dart';

enum MatchVariant { a, b, c }

extension MatchVariantX on MatchVariant {
  String get label => switch (this) {
        MatchVariant.a => 'A · 인라인 재지정',
        MatchVariant.b => 'B · 두 그리드 + 스왑',
        MatchVariant.c => 'C · Confirm + 예외 리포트',
      };
  MatchVariant get next =>
      MatchVariant.values[(index + 1) % MatchVariant.values.length];
  MatchVariant get prev => MatchVariant.values[
      (index - 1 + MatchVariant.values.length) % MatchVariant.values.length];
}

// ============================================================
// 매칭 상태: shot idx → file idx. 안 들어간 shot·file 은 unmatched.
// ============================================================
class MatchState {
  final Map<int, int> shotToFile;
  final int shotCount;
  final int fileCount;

  const MatchState(this.shotToFile, this.shotCount, this.fileCount);

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

  List<int> get unmatchedShots {
    final out = <int>[];
    for (var i = 0; i < shotCount; i++) {
      if (!shotToFile.containsKey(i)) out.add(i);
    }
    return out;
  }

  List<int> get unmatchedFiles {
    final used = shotToFile.values.toSet();
    final out = <int>[];
    for (var i = 0; i < fileCount; i++) {
      if (!used.contains(i)) out.add(i);
    }
    return out;
  }

  int get matchedCount => shotToFile.length;

  MatchState reassign(int shot, int file) {
    // shot이 다른 file 에 매핑돼 있으면 그것부터 제거. file 이 다른 shot 에
    // 잡혀 있으면 그것도 해제.
    final map = Map<int, int>.from(shotToFile);
    map.removeWhere((_, f) => f == file);
    map[shot] = file;
    return MatchState(map, shotCount, fileCount);
  }

  MatchState unmatch(int shot) {
    final map = Map<int, int>.from(shotToFile)..remove(shot);
    return MatchState(map, shotCount, fileCount);
  }

  MatchState swap(int shotA, int shotB) {
    final map = Map<int, int>.from(shotToFile);
    final fa = map[shotA];
    final fb = map[shotB];
    if (fa == null) {
      map.remove(shotB);
    } else {
      map[shotB] = fa;
    }
    if (fb == null) {
      map.remove(shotA);
    } else {
      map[shotA] = fb;
    }
    return MatchState(map, shotCount, fileCount);
  }
}

class MatchingContext {
  final RolExport rol;
  final List<File> scanFiles;
  MatchingContext({required this.rol, required this.scanFiles});
  Shot shot(int i) => rol.roll.shots[i];
  File file(int i) => scanFiles[i];
}

// ============================================================
// 스위처 (플로팅 하단 pill)
// ============================================================
class MatchPrototypeSwitcher extends StatelessWidget {
  final MatchVariant current;
  final ValueChanged<MatchVariant> onChange;
  const MatchPrototypeSwitcher(
      {super.key, required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 76,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: Material(
            elevation: 6,
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () => onChange(current.prev),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(current.label,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () => onChange(current.next),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Variant A — 인라인 재지정
// 매치된 페어 리스트. 각 행 오른쪽 팝업 메뉴로 재지정/해제.
// 하단에 미매치 shot/file 섹션.
// ============================================================
class VariantA extends StatefulWidget {
  final MatchingContext ctx;
  final MatchState initial;
  const VariantA({super.key, required this.ctx, required this.initial});
  @override
  State<VariantA> createState() => _VariantAState();
}

class _VariantAState extends State<VariantA> {
  late MatchState _state = widget.initial;

  Future<void> _pickFileFor(int shot) async {
    final f = await _pickFromList(
      title: 'shot #${widget.ctx.shot(shot).idx} → 어느 파일?',
      items: [
        for (var i = 0; i < widget.ctx.scanFiles.length; i++)
          _PickItem(i, p.basename(widget.ctx.file(i).path),
              usedByShot: _state.shotForFile(i)),
      ],
    );
    if (f != null) setState(() => _state = _state.reassign(shot, f));
  }

  Future<void> _pickShotFor(int file) async {
    final s = await _pickFromList(
      title: '${p.basename(widget.ctx.file(file).path)} → 어느 shot?',
      items: [
        for (var i = 0; i < widget.ctx.rol.roll.shots.length; i++)
          _PickItem(
              i,
              '#${widget.ctx.shot(i).idx} · ${widget.ctx.shot(i).summary}',
              usedByShot: _state.fileForShot(i) == null ? null : i),
      ],
    );
    if (s != null) setState(() => _state = _state.reassign(s, file));
  }

  Future<int?> _pickFromList({
    required String title,
    required List<_PickItem> items,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 400,
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(title,
                            style: Theme.of(context).textTheme.titleMedium)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return ListTile(
                      title: Text(it.label),
                      trailing: it.usedByShot != null
                          ? const Chip(
                              label: Text('이미 매치됨',
                                  style: TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, it.idx),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matched = _state.shotToFile.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final unShots = _state.unmatchedShots;
    final unFiles = _state.unmatchedFiles;

    return ListView(
      children: [
        _SectionHeader('매치됨 (${matched.length})'),
        for (final e in matched) _matchedRow(e.key, e.value),
        if (unShots.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader('미매치 shot (${unShots.length}) — 파일 없이 남음'),
          for (final s in unShots) _unmatchedShotRow(s),
        ],
        if (unFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader('미매치 파일 (${unFiles.length}) — EXIF 안 씀'),
          for (final f in unFiles) _unmatchedFileRow(f),
        ],
      ],
    );
  }

  Widget _matchedRow(int shot, int file) {
    final s = widget.ctx.shot(shot);
    final f = widget.ctx.file(file);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _shotCell(s)),
          const Icon(Icons.arrow_right_alt, color: Colors.grey, size: 20),
          Expanded(child: _fileCell(f)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (v) {
              switch (v) {
                case 'reassign_shot':
                  _pickFileFor(shot);
                case 'reassign_file':
                  _pickShotFor(file);
                case 'unmatch':
                  setState(() => _state = _state.unmatch(shot));
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reassign_shot',
                child: Text('이 shot 다른 파일로'),
              ),
              PopupMenuItem(
                value: 'reassign_file',
                child: Text('이 파일 다른 shot으로'),
              ),
              PopupMenuItem(
                value: 'unmatch',
                child: Text('매치 해제'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _unmatchedShotRow(int shot) {
    final s = widget.ctx.shot(shot);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _shotCell(s)),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _pickFileFor(shot),
            icon: const Icon(Icons.link, size: 16),
            label: const Text('파일 지정'),
          ),
        ],
      ),
    );
  }

  Widget _unmatchedFileRow(int file) {
    final f = widget.ctx.file(file);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _fileCell(f)),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _pickShotFor(file),
            icon: const Icon(Icons.link, size: 16),
            label: const Text('shot 지정'),
          ),
        ],
      ),
    );
  }

  Widget _shotCell(Shot s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('#${s.idx}',
              style: Theme.of(context).textTheme.labelLarge),
          Text(s.summary,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      );

  Widget _fileCell(File f) => Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.file(f,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 20)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(p.basename(f.path),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

class _PickItem {
  final int idx;
  final String label;
  final int? usedByShot;
  _PickItem(this.idx, this.label, {this.usedByShot});
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

// ============================================================
// Variant B — 두 그리드 + 스왑
// 좌·우 그리드. 자동 매치는 좌우 같은 번호 배지. 한 아이템 클릭 → 하이라이트.
// 반대편 아이템 클릭 → 그 두 개로 매치 재설정. 같은편 클릭 → 스왑.
// ============================================================
class VariantB extends StatefulWidget {
  final MatchingContext ctx;
  final MatchState initial;
  const VariantB({super.key, required this.ctx, required this.initial});
  @override
  State<VariantB> createState() => _VariantBState();
}

enum _Side { shot, file }

class _VariantBState extends State<VariantB> {
  late MatchState _state = widget.initial;
  _Side? _selSide;
  int? _selIdx;

  void _onTap(_Side side, int idx) {
    setState(() {
      if (_selSide == null) {
        _selSide = side;
        _selIdx = idx;
        return;
      }
      if (_selSide == side) {
        // 같은 편 → 스왑 (shot 기준)
        if (side == _Side.shot) {
          _state = _state.swap(_selIdx!, idx);
        } else {
          // 파일 스왑 = 그 파일들을 잡고 있는 shot들 스왑
          final sa = _state.shotForFile(_selIdx!);
          final sb = _state.shotForFile(idx);
          if (sa != null && sb != null) {
            _state = _state.reassign(sa, idx).reassign(sb, _selIdx!);
          } else if (sa != null) {
            _state = _state.reassign(sa, idx);
          } else if (sb != null) {
            _state = _state.reassign(sb, _selIdx!);
          }
        }
        _selSide = null;
        _selIdx = null;
      } else {
        // 반대편 → 매치
        final shot = side == _Side.shot ? idx : _selIdx!;
        final file = side == _Side.file ? idx : _selIdx!;
        _state = _state.reassign(shot, file);
        _selSide = null;
        _selIdx = null;
      }
    });
  }

  Color _badgeColor(int matchIdx) {
    // 매치 인덱스 → 색상 hue
    final hue = (matchIdx * 47) % 360;
    return HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final shotOrder = List.generate(widget.ctx.rol.roll.shots.length, (i) => i);
    final fileOrder = List.generate(widget.ctx.scanFiles.length, (i) => i);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _selSide == null
                ? '아이템 클릭 → 반대편 클릭으로 매치 / 같은편으로 스왑'
                : '${_selSide == _Side.shot ? "shot" : "file"} 선택됨 · 대상 클릭',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _column(_Side.shot, shotOrder)),
              const VerticalDivider(width: 1),
              Expanded(child: _column(_Side.file, fileOrder)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _column(_Side side, List<int> order) {
    return ListView.separated(
      itemCount: order.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final idx = order[i];
        final matchIdx = side == _Side.shot
            ? _state.fileForShot(idx)
            : _state.shotForFile(idx);
        final selected = _selSide == side && _selIdx == idx;
        final badgeColor = matchIdx == null
            ? Colors.grey.shade400
            : _badgeColor(
                side == _Side.shot ? idx : matchIdx,
              );

        return Material(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          child: InkWell(
            onTap: () => _onTap(side, idx),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      matchIdx == null ? '?' : '${matchIdx + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: side == _Side.shot
                        ? _shotContent(idx)
                        : _fileContent(idx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shotContent(int i) {
    final s = widget.ctx.shot(i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('#${s.idx}', style: Theme.of(context).textTheme.labelLarge),
        Text(s.summary, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _fileContent(int i) {
    final f = widget.ctx.file(i);
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Image.file(f,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 20)),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Text(p.basename(f.path),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

// ============================================================
// Variant C — Confirm + 예외 리포트
// 정상 매치는 안 보임. 미매치 있을 때만 리스트.
// ============================================================
class VariantC extends StatefulWidget {
  final MatchingContext ctx;
  final MatchState initial;
  const VariantC({super.key, required this.ctx, required this.initial});
  @override
  State<VariantC> createState() => _VariantCState();
}

class _VariantCState extends State<VariantC> {
  late MatchState _state = widget.initial;
  bool _showMatched = false;

  @override
  Widget build(BuildContext context) {
    final unShots = _state.unmatchedShots;
    final unFiles = _state.unmatchedFiles;
    final hasExceptions = unShots.isNotEmpty || unFiles.isNotEmpty;
    final matched = _state.shotToFile.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statusCard(hasExceptions, matched.length),
        const SizedBox(height: 16),
        if (hasExceptions) ...[
          _exceptionsSection(unShots, unFiles),
          const SizedBox(height: 16),
        ],
        _matchedFold(matched),
      ],
    );
  }

  Widget _statusCard(bool hasExceptions, int matchedCount) {
    final color = hasExceptions ? Colors.amber : Colors.green;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(hasExceptions ? Icons.warning_amber : Icons.check_circle,
              color: color.shade800, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasExceptions ? '검토 필요' : '자동 매치 완료',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color.shade900, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$matchedCount / ${_state.shotCount} shot ↔ ${_state.fileCount} file',
                  style: TextStyle(color: color.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exceptionsSection(List<int> unShots, List<int> unFiles) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('미매치',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final s in unShots) _unmatchedShotRow(s),
          for (final f in unFiles) _unmatchedFileRow(f),
        ],
      ),
    );
  }

  Widget _unmatchedShotRow(int shot) {
    final s = widget.ctx.shot(shot);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text('shot #${s.idx} · ${s.summary}',
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 12),
          _fileDropdown(
              value: null,
              options: _state.unmatchedFiles,
              onChange: (f) {
                if (f != null) {
                  setState(() => _state = _state.reassign(shot, f));
                }
              }),
        ],
      ),
    );
  }

  Widget _unmatchedFileRow(int file) {
    final f = widget.ctx.file(file);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(p.basename(f.path),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 12),
          _shotDropdown(
              options: _state.unmatchedShots,
              onChange: (s) {
                if (s != null) {
                  setState(() => _state = _state.reassign(s, file));
                }
              }),
        ],
      ),
    );
  }

  Widget _fileDropdown({
    required int? value,
    required List<int> options,
    required ValueChanged<int?> onChange,
  }) {
    return DropdownButton<int?>(
      value: value,
      hint: const Text('파일 선택', style: TextStyle(fontSize: 13)),
      items: [
        for (final f in options)
          DropdownMenuItem(
            value: f,
            child: Text(p.basename(widget.ctx.file(f).path),
                style: const TextStyle(fontSize: 13)),
          ),
      ],
      onChanged: onChange,
    );
  }

  Widget _shotDropdown({
    required List<int> options,
    required ValueChanged<int?> onChange,
  }) {
    return DropdownButton<int?>(
      value: null,
      hint: const Text('shot 선택', style: TextStyle(fontSize: 13)),
      items: [
        for (final s in options)
          DropdownMenuItem(
            value: s,
            child: Text('#${widget.ctx.shot(s).idx}',
                style: const TextStyle(fontSize: 13)),
          ),
      ],
      onChanged: onChange,
    );
  }

  Widget _matchedFold(List<MapEntry<int, int>> matched) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showMatched = !_showMatched),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(_showMatched
                      ? Icons.expand_more
                      : Icons.chevron_right),
                  const SizedBox(width: 8),
                  Text('매치된 ${matched.length}개 페어',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          if (_showMatched)
            for (final e in matched)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                          'shot #${widget.ctx.shot(e.key).idx}',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    const Icon(Icons.arrow_right_alt,
                        size: 16, color: Colors.grey),
                    Expanded(
                      child: Text(p.basename(widget.ctx.file(e.value).path),
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
