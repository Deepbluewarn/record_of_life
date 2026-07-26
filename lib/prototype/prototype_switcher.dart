// PROTOTYPE — throwaway. 하단 pill로 변형 순회. kDebugMode에서만 표시.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrototypeScaffold extends StatefulWidget {
  final List<({String label, WidgetBuilder builder})> variants;

  const PrototypeScaffold({super.key, required this.variants});

  @override
  State<PrototypeScaffold> createState() => _PrototypeScaffoldState();
}

class _PrototypeScaffoldState extends State<PrototypeScaffold> {
  final FocusNode _focus = FocusNode();
  int _idx = 0;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _cycle(int delta) {
    final n = widget.variants.length;
    setState(() => _idx = (_idx + delta + n) % n);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _cycle(-1);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      _cycle(1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.variants[_idx];
    final page = Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: current.builder(context),
    );

    if (!kDebugMode) return page;

    return Stack(
      children: [
        page,
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: SafeArea(
            child: Center(
              child: Material(
                color: Colors.black,
                elevation: 6,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _cycle(-1),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${String.fromCharCode(65 + _idx)} · ${current.label}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _cycle(1),
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
