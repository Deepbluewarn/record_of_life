import 'package:flutter/material.dart';
import 'package:record_of_life/features/settings/pages/settings_page.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  // 페이지가 액션 오버플로에 설정 항목을 직접 넣는 경우 false로 자동 아이콘을 끔.
  final bool showSettings;

  CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    List<Widget>? actions,
    this.showSettings = true,
  }) : actions = actions ?? [];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 68,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
      titleSpacing: AppSpacing.lg,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1.5,
              color: AppColors.ink,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                letterSpacing: 0.5,
                color: AppColors.inkMuted,
              ),
            ),
        ],
      ),
      actions: [
        ...actions,
        if (showSettings)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(68);
}
