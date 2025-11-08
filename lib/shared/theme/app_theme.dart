import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 120, 159, 190);
  static const Color secondary = Color(0xFFFFC107);

  // Backgrounds
  static const Color background = Colors.white;
  static const Color surfaceLight = Color(0xFFFAFAFA);

  // Text
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;

  // Borders
  static const Color border = Color(0xFFE0E0E0);
}

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
    ),
  );
}
