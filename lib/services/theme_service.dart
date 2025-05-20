import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:domini/constants/app_colors.dart';
import 'package:domini/services/database_service.dart';

class ThemeService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isDarkMode = false;
  bool _useSystemTheme = true;

  ThemeService() {
    _loadThemePreference();
  }

  bool get isDarkMode => _useSystemTheme 
      ? SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
      : _isDarkMode;

  bool get useSystemTheme => _useSystemTheme;

  Future<void> _loadThemePreference() async {
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      _isDarkMode = settings.darkMode;
      _useSystemTheme = settings.useSystemTheme;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      settings.darkMode = _isDarkMode;
      await _databaseService.updateSettings(settings);
      notifyListeners();
    }
  }

  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      settings.useSystemTheme = value;
      await _databaseService.updateSettings(settings);
      notifyListeners();
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.accentLight,
        surface: AppColors.surfaceLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textLight),
        bodyMedium: TextStyle(color: AppColors.textLight),
        titleLarge: TextStyle(color: AppColors.textLight),
      ),
      fontFamily: '.SF Pro Text', // System font similar to iOS
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryLight,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        barBackgroundColor: AppColors.surfaceLight,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primaryLight,
          textStyle: TextStyle(
            color: AppColors.textLight,
            fontFamily: '.SF Pro Text', // System font similar to iOS
          ),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.accentDark,
        surface: AppColors.surfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
        titleLarge: TextStyle(color: AppColors.textDark),
      ),
      fontFamily: '.SF Pro Text', // System font similar to iOS
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        barBackgroundColor: AppColors.surfaceDark,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primaryDark,
          textStyle: TextStyle(
            color: AppColors.textDark,
            fontFamily: '.SF Pro Text', // System font similar to iOS
          ),
        ),
      ),
    );
  }
}
