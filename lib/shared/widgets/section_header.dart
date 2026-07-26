import 'package:flutter/material.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.onActionPressed,
    this.actionLabel = '전체보기',
  });

  final String title;
  final int count;
  final VoidCallback? onActionPressed;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$count',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}
