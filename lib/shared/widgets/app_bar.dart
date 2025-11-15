import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    List<Widget>? actions,
  }) : actions = actions ?? [];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: const Color.fromARGB(100, 216, 216, 216),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
          ],
        ),
      ),
      actions: [
        ...actions,
        IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}
