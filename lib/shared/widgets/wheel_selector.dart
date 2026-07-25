import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

// Flutter 표준 ListWheelScrollView 기반의 가로 다이얼.
// 세로 wheel을 RotatedBox로 눕혀 가로로 사용. snap·onSelectedItemChanged가
// 프레임워크 native라 커스텀 스크롤 물리·리페인트 최적화 불필요.
class WheelSelector<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;
  // 라벨 → 대표 item. 지정 시 위쪽에 섹션 점프 칩 노출.
  final Map<String, T>? sections;

  const WheelSelector({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    this.sections,
  });

  @override
  State<WheelSelector<T>> createState() => _WheelSelectorState<T>();
}

class _WheelSelectorState<T> extends State<WheelSelector<T>> {
  static const double _itemExtent = 72;
  static const double _height = 76;

  late final FixedExtentScrollController _controller;
  int _lastIndex = 0;

  int _initialIndex() {
    if (widget.selectedItem == null) return 0;
    final idx = widget.items.indexOf(widget.selectedItem as T);
    return idx < 0 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    _lastIndex = _initialIndex();
    _controller = FixedExtentScrollController(initialItem: _lastIndex);
  }

  @override
  void didUpdateWidget(covariant WheelSelector<T> old) {
    super.didUpdateWidget(old);
    final now = _initialIndex();
    if (now != _lastIndex && _controller.hasClients) {
      _lastIndex = now;
      _controller.jumpToItem(now);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpTo(T item) {
    final idx = widget.items.indexOf(item);
    if (idx < 0 || !_controller.hasClients) return;
    _controller.animateToItem(
      idx,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        if (widget.sections != null) ...[
          _SectionChips<T>(sections: widget.sections!, onJump: _jumpTo),
          const SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(
          height: _height,
          child: Stack(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: _itemExtent,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  diameterRatio: 2.2,
                  onSelectedItemChanged: (i) {
                    if (i != _lastIndex) {
                      _lastIndex = i;
                      HapticFeedback.selectionClick();
                      widget.onSelected(widget.items[i]);
                    }
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: widget.items.length,
                    builder: (context, i) => RotatedBox(
                      quarterTurns: 1,
                      child: Center(
                        child: Text(
                          widget.labelBuilder(widget.items[i]),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const _CenterMarker(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionChips<T> extends StatelessWidget {
  final Map<String, T> sections;
  final ValueChanged<T> onJump;
  const _SectionChips({required this.sections, required this.onJump});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final entry = sections.entries.elementAt(i);
          return InkWell(
            onTap: () => onJump(entry.value),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CenterMarker extends StatelessWidget {
  const _CenterMarker();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 2, height: 6, color: AppColors.ink),
            const SizedBox(height: 48),
            Container(width: 2, height: 6, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
