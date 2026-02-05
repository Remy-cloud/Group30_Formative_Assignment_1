import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFF15A22); // Orange
  static const Color primaryBlue = Color(0xFF1E3A5F); // Dark Blue

  // Secondary Colors
  static const Color lightBlue = Color(0xFF4A90A4);
  static const Color lightOrange = Color(0xFFFF8C42);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
}

/// App Theme
ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryOrange,
    primary: AppColors.primaryOrange,
    secondary: AppColors.primaryBlue,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    elevation: 2,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.white,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
    ),
  ),
);
