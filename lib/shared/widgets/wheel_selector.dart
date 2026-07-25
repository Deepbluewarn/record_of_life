import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

// Halide/iPhone 다이얼 스타일: 가로 스크롤, 중앙 스냅, 스텝마다 햅틱.
// ListView 기반 — fling 관성으로 여러 스텝 훑고 놓으면 근처 값에 스냅.
class WheelSelector<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const WheelSelector({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  State<WheelSelector<T>> createState() => _WheelSelectorState<T>();
}

class _WheelSelectorState<T> extends State<WheelSelector<T>> {
  static const double _itemExtent = 72;
  static const double _height = 76;

  late final ScrollController _controller;
  int _lastIndex = 0;
  bool _snapPending = false;

  int _initialIndex() {
    if (widget.selectedItem == null) return 0;
    final idx = widget.items.indexOf(widget.selectedItem as T);
    return idx < 0 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    _lastIndex = _initialIndex();
    _controller = ScrollController(
      initialScrollOffset: _lastIndex * _itemExtent,
    );
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant WheelSelector<T> old) {
    super.didUpdateWidget(old);
    final now = _initialIndex();
    if (now != _lastIndex && _controller.hasClients) {
      _lastIndex = now;
      _controller.jumpTo(now * _itemExtent);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final idx = (_controller.offset / _itemExtent)
        .round()
        .clamp(0, widget.items.length - 1);
    if (idx != _lastIndex) {
      _lastIndex = idx;
      HapticFeedback.selectionClick();
      widget.onSelected(widget.items[idx]);
    }
  }

  Future<void> _snapToNearest() async {
    if (_snapPending || !_controller.hasClients) return;
    _snapPending = true;
    final idx = (_controller.offset / _itemExtent)
        .round()
        .clamp(0, widget.items.length - 1);
    final target = idx * _itemExtent;
    if ((target - _controller.offset).abs() > 0.5) {
      await _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
    _snapPending = false;
  }

  bool _handleNotif(ScrollNotification n) {
    if (n is ScrollEndNotification) _snapToNearest();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sidePad = (constraints.maxWidth - _itemExtent) / 2;
              return NotificationListener<ScrollNotification>(
                onNotification: _handleNotif,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: sidePad),
                      itemExtent: _itemExtent,
                      itemCount: widget.items.length,
                      itemBuilder: (context, i) => _WheelItem(
                        label: widget.labelBuilder(widget.items[i]),
                        controller: _controller,
                        index: i,
                        itemExtent: _itemExtent,
                        onTap: () {
                          _controller.animateTo(
                            i * _itemExtent,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                    const _CenterMarker(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WheelItem extends StatelessWidget {
  final String label;
  final ScrollController controller;
  final int index;
  final double itemExtent;
  final VoidCallback onTap;

  const _WheelItem({
    required this.label,
    required this.controller,
    required this.index,
    required this.itemExtent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double offset = 0;
        if (controller.hasClients) offset = controller.offset;
        final page = offset / itemExtent;
        final distance = (page - index).abs().clamp(0.0, 1.5);
        final scale = 1.0 - (distance * 0.25);
        final opacity = (1.0 - (distance * 0.55)).clamp(0.2, 1.0);
        final selected = distance < 0.5;
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
