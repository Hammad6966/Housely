import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryTeal = Color(0xFF20B2AA);
  static const Color lightTeal = Color(0xFF4FD1C7);
  static const Color darkTeal = Color(0xFF0F766E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFF6C757D);
  static const Color darkGray = Color(0xFF343A40);
  static const Color black = Color(0xFF000000);
  static const Color accent = Color(0xFFFF6B6B);

  // Text styles
  static TextStyle get heading1 => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkGray,
        fontFamily: 'system-ui',
      );

  static TextStyle get heading2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkGray,
        fontFamily: 'system-ui',
      );

  static TextStyle get heading3 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkGray,
        fontFamily: 'system-ui',
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkGray,
        fontFamily: 'system-ui',
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: mediumGray,
        fontFamily: 'system-ui',
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: mediumGray,
        fontFamily: 'system-ui',
      );

  static TextStyle get button => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
        fontFamily: 'system-ui',
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mediumGray,
        fontFamily: 'system-ui',
      );

  // Theme data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'system-ui',
        colorScheme: const ColorScheme.light(
          primary: primaryTeal,
          secondary: lightTeal,
          surface: white,
          background: lightGray,
          onPrimary: white,
          onSecondary: white,
          onSurface: darkGray,
          onBackground: darkGray,
        ),
        textTheme: TextTheme(
          headlineLarge: heading1,
          headlineMedium: heading2,
          headlineSmall: heading3,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: button,
          labelMedium: caption,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: white,
          foregroundColor: darkGray,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: heading3,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: white,
            elevation: 2,
            shadowColor: primaryTeal.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          color: white,
          elevation: 4,
          shadowColor: darkGray.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: mediumGray.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: mediumGray.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryTeal, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
}
