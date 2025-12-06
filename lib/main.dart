import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record_of_life/features/roll/presentation/pages/home_page.dart';
import 'package:record_of_life/shared/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 480 : double.infinity,
            ),
            child: child,
          ),
        );
      },
      home: HomePage(),
    );
  }
}
