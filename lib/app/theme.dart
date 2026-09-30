import 'package:flutter/material.dart';

class AppTheme {
  // مأخوذة من تصميم Figma الأصلي: أخضر مزرق (تيل) أساسي وبرتقالي كلون تمييز.
  static const primaryTeal = Color(0xFF246760);
  static const accentOrange = Color(0xFFF4A160);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    fontFamily: 'Arial',

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTeal,
    ).copyWith(tertiary: accentOrange),

    scaffoldBackgroundColor: const Color(0xFFF7F7F7),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
