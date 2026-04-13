import 'package:flutter/material.dart';

class AppTheme {
  // Colors mimicking the dark mode html Tailwind styles
  static const Color background = Color(0xFF111827); // gray-900
  static const Color surface = Color(0xFF1F2937); // gray-800
  static const Color border = Color(0xFF374151); // gray-700
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryLight = Color(0xFF60A5FA); // blue-400
  
  static const Color textMain = Color(0xFFF3F4F6); // gray-100/200
  static const Color textMuted = Color(0xFF9CA3AF); // gray-400

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      dividerColor: border,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textMain, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textMain, fontSize: 16),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: textMain,
        iconColor: primaryLight,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return surface;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: textMain,
        unselectedLabelColor: textMuted,
        indicatorColor: primaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}
