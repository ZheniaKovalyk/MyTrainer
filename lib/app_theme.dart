import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32), brightness: Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFF7F9FB),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32), brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF101418),
  );
}
