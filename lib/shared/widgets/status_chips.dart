// 롤 상태 세그먼트 chip. 헤더 아래 4개 chip 항상 노출.
// (프로토타입 B 확정 후 유지된 유일한 변형)
import 'package:flutter/material.dart';
import 'package:record_of_life/domain/enums/roll_status.dart';

typedef StatusPick = void Function(RollStatus s);

class StatusChips extends StatelessWidget {
  final RollStatus current;
  final StatusPick onPick;
  const StatusChips({super.key, required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final s in RollStatus.values)
            ChoiceChip(
              selected: s == current,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.displayColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(s.displayName(context)),
                ],
              ),
              onSelected: (_) => s == current ? null : onPick(s),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: s == current ? FontWeight.w800 : FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              selectedColor: theme.colorScheme.surface,
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: s == current
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  width: s == current ? 2 : 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
