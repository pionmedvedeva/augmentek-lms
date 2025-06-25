import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _initialize();
  }

  Future<void> _initialize() async {
    // TODO: Load theme from settings
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // TODO: Save theme to settings
  }
}

class AppTheme {
  // Цвета из дизайна Augmentek
  static const Color primaryBlue = Color(0xFF4A90B8);      // Основной синий
  static const Color darkBlue = Color(0xFF2C5F7C);         // Темно-синий
  static const Color lightBlue = Color(0xFF87CEEB);        // Светло-голубой
  static const Color peachBackground = Color(0xFFF5E6D3);  // Персиковый фон
  static const Color warmWhite = Color(0xFFFFFFFE);        // Теплый белый
  static const Color accentOrange = Color(0xFFE8A87C);     // Акцентный оранжевый

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: lightBlue,
      surface: warmWhite,
      background: peachBackground,
      onPrimary: Colors.white,
      onSecondary: darkBlue,
    ),
    scaffoldBackgroundColor: peachBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: warmWhite,
      selectedItemColor: primaryBlue,
      unselectedItemColor: darkBlue.withOpacity(0.6),
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: warmWhite,
      elevation: 2,
      shadowColor: darkBlue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: BorderSide(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: warmWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBlue.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryBlue,
      unselectedLabelColor: darkBlue.withOpacity(0.6),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: lightBlue,
        secondary: primaryBlue,
        surface: const Color(0xFF1E2832),
        background: const Color(0xFF121820),
        onPrimary: darkBlue,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121820),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E2832),
        foregroundColor: lightBlue,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E2832),
        selectedItemColor: lightBlue,
        unselectedItemColor: Colors.grey.shade400,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2832),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
} 