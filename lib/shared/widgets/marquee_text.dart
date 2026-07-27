import 'package:flutter/material.dart';

// 텍스트가 부모 폭보다 길면 좌→우 반복 스크롤. 짧으면 정적.
// AnimationController + AnimatedBuilder — Ticker+setState의 layout-중-빌드
// 어설션 회피.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const MarqueeText({super.key, required this.text, required this.style});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  static const double _gap = 24;

  late final AnimationController _ctrl;
  late double _textWidth;
  late double _textHeight;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measure();
  }

  @override
  void didUpdateWidget(covariant MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text || old.style != widget.style) {
      _measured = false;
      _measure();
    }
  }

  void _measure() {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _textWidth = tp.width;
    _textHeight = tp.height;
    _measured = true;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_measured) return Text(widget.text, style: widget.style, maxLines: 1);
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        if (!maxW.isFinite || _textWidth <= maxW) {
          _ctrl.stop();
          return Text(widget.text, style: widget.style, maxLines: 1);
        }
        if (!_ctrl.isAnimating) _ctrl.repeat();
        final loop = _textWidth + _gap;
        return SizedBox(
          height: _textHeight,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: _textHeight,
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) {
                  final dx = -_ctrl.value * loop;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.text, style: widget.style, maxLines: 1),
                        SizedBox(width: _gap),
                        Text(widget.text, style: widget.style, maxLines: 1),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
