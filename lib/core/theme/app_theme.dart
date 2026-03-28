import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1D9E75);
  static const Color lightGreen = Color(0xFFE1F5EE);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color lightBlue = Color(0xFFE6F1FB);
  static const Color amber = Color(0xFFBA7517);
  static const Color lightAmber = Color(0xFFFAEEDA);
  static const Color lightGray = Color(0xFFF1EFE8);
  static const Color midGray = Color(0xFFD3D1C7);
  static const Color darkText = Color(0xFF2C2C2A);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: lightGray,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: primaryBlue,
        error: amber,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: darkText,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkText, fontSize: 16),
        bodyMedium: TextStyle(color: darkText, fontSize: 14),
        bodySmall: TextStyle(color: darkText, fontSize: 12),
        headlineLarge: TextStyle(color: darkText, fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: midGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: midGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: darkText, fontSize: 14),
        hintStyle: const TextStyle(color: midGray, fontSize: 14),
      ),
    );
  }
}
