// PROTOTYPE — throwaway. 갭 표현/정렬 3안.
// 질문: 사진 30 / 데이터 36 (혹은 반대) 일 때 어긋난 개수를 어떻게 표현?
//
// 3안:
// A. 스트라이프 스킵 행       — 갭도 온전한 행. 대각선 스트라이프 + 스킵 이유 라벨.
// B. 필름 스트립 오프셋 정렬   — 두 열을 위/아래로 밀어서 정렬. 갭 개념 없음.
// C. 압축 스킵 세그먼트        — 스킵 구간을 접힘 배지로 요약. diff 뷰 은유.
//
// 이 파일은 main.dart의 정상 로딩 상태를 대체하는 위젯 3개 + 스위처.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'rol_json.dart';

enum PrototypeVariant { a, b, c }

extension PrototypeVariantX on PrototypeVariant {
  String get label => switch (this) {
        PrototypeVariant.a => 'A · 스트라이프 스킵 행',
        PrototypeVariant.b => 'B · 필름 스트립 오프셋',
        PrototypeVariant.c => 'C · 압축 스킵 세그먼트',
      };
  PrototypeVariant get next => PrototypeVariant
      .values[(index + 1) % PrototypeVariant.values.length];
  PrototypeVariant get prev => PrototypeVariant.values[
      (index - 1 + PrototypeVariant.values.length) %
          PrototypeVariant.values.length];
}

// ============================================================
// 공용 컨텍스트: 3안 모두 이 상태만 있으면 렌더 가능.
// ============================================================
class GapUxContext {
  final RolExport rol;
  final List<File> scanFiles;
  final List<int?> leftIdx;
  final List<int?> rightIdx;

  const GapUxContext({
    required this.rol,
    required this.scanFiles,
    required this.leftIdx,
    required this.rightIdx,
  });

  int get rows => leftIdx.length;
  Shot? shotAt(int i) => leftIdx[i] == null ? null : rol.roll.shots[leftIdx[i]!];
  File? fileAt(int i) => rightIdx[i] == null ? null : scanFiles[rightIdx[i]!];
  bool isMatched(int i) => leftIdx[i] != null && rightIdx[i] != null;
  int get matched {
    var c = 0;
    for (var i = 0; i < rows; i++) {
      if (isMatched(i)) c++;
    }
    return c;
  }
}

// ============================================================
// 플로팅 스위처 — 3안 하단 오버레이. throwaway.
// ============================================================
class PrototypeSwitcher extends StatelessWidget {
  final PrototypeVariant current;
  final ValueChanged<PrototypeVariant> onChange;
  const PrototypeSwitcher({
    super.key,
    required this.current,
    required this.onChange,
  });

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
                    child: Text(
                      current.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
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
// Variant A — 스트라이프 스킵 행.
// 갭 셀 = 대각선 스트라이프 + 스킵 이유. 행 배경 dim + 좌측 노란 stripe로 skip 표시.
// 결측이 어디에 얼마나 있는지 스크롤하면서 바로 봄.
// ============================================================
class VariantA extends StatelessWidget {
  final GapUxContext ctx;
  const VariantA({super.key, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: ctx.rows,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final matched = ctx.isMatched(i);
        return Container(
          decoration: BoxDecoration(
            color: matched
                ? null
                : Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border(
              left: BorderSide(
                width: 4,
                color: matched ? Colors.transparent : Colors.amber.shade600,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(child: _shotCell(context, i)),
              const SizedBox(width: 16),
              Expanded(child: _fileCell(context, i)),
            ],
          ),
        );
      },
    );
  }

  Widget _shotCell(BuildContext context, int i) {
    final s = ctx.shotAt(i);
    if (s == null) return const _GapCell(reason: '메모 없음 · 이 파일엔 EXIF 안 씀');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('#${s.idx}', style: Theme.of(context).textTheme.labelLarge),
        Text(s.summary),
      ],
    );
  }

  Widget _fileCell(BuildContext context, int i) {
    final f = ctx.fileAt(i);
    if (f == null) return const _GapCell(reason: '파일 없음 · 이 shot은 이번 배치에서 스킵');
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Image.file(f,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.broken_image)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(p.basename(f.path),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _GapCell extends StatelessWidget {
  final String reason;
  const _GapCell({required this.reason});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _DiagonalStripes()),
          Center(
            child: Text(
              reason,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalStripes extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 8;
    const step = 16.0;
    for (var x = -size.height; x < size.width; x += step) {
      canvas.drawLine(Offset(x, size.height),
          Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _) => false;
}

// ============================================================
// Variant B — 필름 스트립 오프셋 정렬.
// 두 열을 완전 독립 세로 스크롤. 슬라이더로 각 열 오프셋 조정.
// 갭 개념 없음 — 밀려서 겹치지 않는 프레임은 그냥 표시만 되고 EXIF는 안 씀.
// 겹치는 (같은 세로 위치) 프레임 쌍만 매치.
// ============================================================
class VariantB extends StatefulWidget {
  final GapUxContext ctx;
  const VariantB({super.key, required this.ctx});

  @override
  State<VariantB> createState() => _VariantBState();
}

class _VariantBState extends State<VariantB> {
  // 각 열의 세로 오프셋 (프레임 단위, 음수 가능).
  // 두 열은 같은 세로 스케일에 놓이고 leftOffset~rightOffset 차이만큼 어긋남.
  int _leftOffset = 0;
  int _rightOffset = 0;

  static const _rowH = 72.0;

  @override
  Widget build(BuildContext context) {
    final shots = widget.ctx.rol.roll.shots;
    final files = widget.ctx.scanFiles;
    return Column(
      children: [
        _controls(context),
        const Divider(height: 1),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _stripe(
                context: context,
                offset: _leftOffset,
                otherOffset: _rightOffset,
                otherLen: files.length,
                count: shots.length,
                cellBuilder: (i) => _shotTile(context, shots[i]),
              )),
              const VerticalDivider(width: 1),
              Expanded(child: _stripe(
                context: context,
                offset: _rightOffset,
                otherOffset: _leftOffset,
                otherLen: shots.length,
                count: files.length,
                cellBuilder: (i) => _fileTile(context, files[i]),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _controls(BuildContext context) {
    final shots = widget.ctx.rol.roll.shots.length;
    final files = widget.ctx.scanFiles.length;
    final aligned = _alignedCount();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('shot: $shots · file: $files · 정렬됨: $aligned',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 24),
          IconButton(
            tooltip: '왼쪽 열 위로',
            icon: const Icon(Icons.arrow_upward, size: 16),
            onPressed: () => setState(() => _leftOffset--),
          ),
          IconButton(
            tooltip: '왼쪽 열 아래로',
            icon: const Icon(Icons.arrow_downward, size: 16),
            onPressed: () => setState(() => _leftOffset++),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: '오른쪽 열 위로',
            icon: const Icon(Icons.arrow_upward, size: 16),
            onPressed: () => setState(() => _rightOffset--),
          ),
          IconButton(
            tooltip: '오른쪽 열 아래로',
            icon: const Icon(Icons.arrow_downward, size: 16),
            onPressed: () => setState(() => _rightOffset++),
          ),
          const Spacer(),
          Text(
            'ponytail: 오프셋 정렬만. 중간 스킵은 못 처리 — 이 안의 한계.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  int _alignedCount() {
    final shots = widget.ctx.rol.roll.shots.length;
    final files = widget.ctx.scanFiles.length;
    var c = 0;
    for (var i = 0; i < shots; i++) {
      final rowInLeft = i + _leftOffset;
      final j = rowInLeft - _rightOffset;
      if (j >= 0 && j < files) c++;
    }
    return c;
  }

  Widget _stripe({
    required BuildContext context,
    required int offset,
    required int otherOffset,
    required int otherLen,
    required int count,
    required Widget Function(int) cellBuilder,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            _cellRow(
              context: context,
              positionRow: i + offset,
              otherOffset: otherOffset,
              otherLen: otherLen,
              child: cellBuilder(i),
            ),
        ],
      ),
    );
  }

  Widget _cellRow({
    required BuildContext context,
    required int positionRow,
    required int otherOffset,
    required int otherLen,
    required Widget child,
  }) {
    final otherIdx = positionRow - otherOffset;
    final aligned = otherIdx >= 0 && otherIdx < otherLen;
    return Container(
      height: _rowH,
      margin: EdgeInsets.only(top: positionRow == 0 ? positionRow * _rowH : 0),
      decoration: BoxDecoration(
        color: aligned
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
          left: BorderSide(
            width: 3,
            color: aligned ? Colors.green.shade400 : Colors.transparent,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: child,
    );
  }

  Widget _shotTile(BuildContext context, Shot s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('#${s.idx}', style: Theme.of(context).textTheme.labelLarge),
        Text(s.summary),
      ],
    );
  }

  Widget _fileTile(BuildContext context, File f) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Image.file(f,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.broken_image)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(p.basename(f.path),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ============================================================
// Variant C — 압축 스킵 세그먼트 (diff-style).
// 정상 매치 = 온전 행. 갭이 연속되면 한 줄 배지로 접힘.
// "shot #7~#9 스킵됨 (파일 없음)" 배지 클릭 시 펼침.
// 상단에 총 매칭 요약. 정보 밀도 최고.
// ============================================================
class VariantC extends StatefulWidget {
  final GapUxContext ctx;
  const VariantC({super.key, required this.ctx});

  @override
  State<VariantC> createState() => _VariantCState();
}

class _VariantCState extends State<VariantC> {
  final Set<int> _expandedSegments = {}; // 세그먼트 index (0부터)

  @override
  Widget build(BuildContext context) {
    final ctx = widget.ctx;
    // 연속 갭 구간 병합.
    final segments = <_Seg>[];
    var i = 0;
    var segIdx = 0;
    while (i < ctx.rows) {
      if (ctx.isMatched(i)) {
        segments.add(_Seg.match(i));
        i++;
      } else {
        final start = i;
        final leftGap = ctx.shotAt(i) == null;
        final rightGap = ctx.fileAt(i) == null;
        while (i < ctx.rows &&
            !ctx.isMatched(i) &&
            (ctx.shotAt(i) == null) == leftGap &&
            (ctx.fileAt(i) == null) == rightGap) {
          i++;
        }
        segments.add(_Seg.skip(
          start: start,
          end: i - 1,
          leftGap: leftGap,
          rightGap: rightGap,
          idx: segIdx++,
        ));
      }
    }

    return Column(
      children: [
        _summary(context, segments),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: segments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _renderSeg(context, segments[i]),
          ),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context, List<_Seg> segs) {
    final ctx = widget.ctx;
    final shots = ctx.rol.roll.shots.length;
    final files = ctx.scanFiles.length;
    final matched = ctx.matched;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('$shots shots · $files files · $matched 정렬됨',
              style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          Text(
            '${segs.where((s) => !s.isMatch).length}개 스킵 구간',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _renderSeg(BuildContext context, _Seg s) {
    if (s.isMatch) return _MatchTile(ctx: widget.ctx, row: s.start);
    final expanded = _expandedSegments.contains(s.idx);
    return _SkipBadge(
      seg: s,
      expanded: expanded,
      onToggle: () => setState(() {
        if (expanded) {
          _expandedSegments.remove(s.idx);
        } else {
          _expandedSegments.add(s.idx);
        }
      }),
      ctx: widget.ctx,
    );
  }
}

class _Seg {
  final int start;
  final int end;
  final bool isMatch;
  final bool leftGap;
  final bool rightGap;
  final int idx;

  _Seg.match(this.start)
      : end = start,
        isMatch = true,
        leftGap = false,
        rightGap = false,
        idx = -1;
  _Seg.skip({
    required this.start,
    required this.end,
    required this.leftGap,
    required this.rightGap,
    required this.idx,
  }) : isMatch = false;

  int get count => end - start + 1;
}

class _MatchTile extends StatelessWidget {
  final GapUxContext ctx;
  final int row;
  const _MatchTile({required this.ctx, required this.row});

  @override
  Widget build(BuildContext context) {
    final s = ctx.shotAt(row)!;
    final f = ctx.fileAt(row)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${s.idx}',
                    style: Theme.of(context).textTheme.labelLarge),
                Text(s.summary),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.file(f,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(p.basename(f.path),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkipBadge extends StatelessWidget {
  final _Seg seg;
  final bool expanded;
  final VoidCallback onToggle;
  final GapUxContext ctx;
  const _SkipBadge({
    required this.seg,
    required this.expanded,
    required this.onToggle,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    final where = seg.leftGap ? '메모 없음' : '파일 없음';
    final range = seg.count == 1 ? '#${seg.start + 1}' : '#${seg.start + 1}~#${seg.end + 1}';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                Icon(expanded ? Icons.expand_more : Icons.chevron_right,
                    size: 18, color: Colors.amber.shade900),
                const SizedBox(width: 4),
                Text(
                  '$where · $range · ${seg.count}개',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  seg.leftGap ? '(파일만 있음 — EXIF 안 씀)' : '(shot만 있음 — 이 배치에서 스킵)',
                  style: TextStyle(
                    color: Colors.amber.shade900.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            for (var i = seg.start; i <= seg.end; i++) _detailRow(context, i),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, int i) {
    final s = ctx.shotAt(i);
    final f = ctx.fileAt(i);
    final leftText = s == null ? '—' : '#${s.idx} · ${s.summary}';
    final rightText = f == null ? '—' : p.basename(f.path);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 26),
      child: Row(
        children: [
          Expanded(child: Text(leftText,
              style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(child: Text(rightText,
              style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
