import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

// Halide/iPhone 다이얼 스타일: 가로 스크롤, 중앙 고정 지시선, 스텝마다 햅틱.
// snap = PageView 기반. viewportFraction으로 좌우 이웃 값도 보임.
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
  late final PageController _controller;
  int _lastIndex = 0;

  static const double _viewportFraction = 0.24;
  static const double _height = 76;

  int _initialIndex() {
    if (widget.selectedItem == null) return 0;
    final idx = widget.items.indexOf(widget.selectedItem as T);
    return idx < 0 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    _lastIndex = _initialIndex();
    _controller = PageController(
      initialPage: _lastIndex,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void didUpdateWidget(covariant WheelSelector<T> old) {
    super.didUpdateWidget(old);
    // 외부에서 선택값이 바뀌면(리셋 등) 휠도 맞춰줌.
    final now = _initialIndex();
    if (now != _lastIndex && _controller.hasClients) {
      _lastIndex = now;
      _controller.jumpToPage(now);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: _height,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.items.length,
                onPageChanged: (i) {
                  if (i != _lastIndex) {
                    _lastIndex = i;
                    HapticFeedback.selectionClick();
                    widget.onSelected(widget.items[i]);
                  }
                },
                itemBuilder: (context, i) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      double page = i.toDouble();
                      if (_controller.position.haveDimensions) {
                        page = _controller.page ?? i.toDouble();
                      }
                      final distance = (page - i).abs().clamp(0.0, 1.2);
                      final scale = 1.0 - (distance * 0.25);
                      final opacity = (1.0 - (distance * 0.55)).clamp(0.2, 1.0);
                      final selected = distance < 0.5;
                      return Center(
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Text(
                              widget.labelBuilder(widget.items[i]),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // 중앙 지시선 (위·아래 짧은 tick)
              const _CenterMarker(),
            ],
          ),
        ),
      ],
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
          mainAxisAlignment: MainAxisAlignment.center,
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
