import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _systemIsDark = true;

  AppThemeMode get themeMode => _themeMode;
  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return _systemIsDark;
    }
  }

  String get themeModeText {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light Mode';
      case AppThemeMode.dark:
        return 'Dark Mode';
      case AppThemeMode.system:
        return 'Follow System';
    }
  }

  IconData get themeModeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Initialize theme from stored preferences
  Future<void> initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTheme = prefs.getString('theme_mode') ?? 'system';
      
      print('🎨 ThemeProvider: Loading stored theme: $storedTheme');
      
      switch (storedTheme) {
        case 'light':
          _themeMode = AppThemeMode.light;
          break;
        case 'dark':
          _themeMode = AppThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = AppThemeMode.system;
          break;
      }
      
      // Get system theme
      _updateSystemTheme();
      print('🎨 ThemeProvider: Theme initialized to ${_themeMode.name}, isDark: $isDarkMode');
      notifyListeners();
    } catch (e) {
      print('🎨 ThemeProvider: Error initializing theme: $e');
      // Fallback to system theme
      _themeMode = AppThemeMode.system;
      _updateSystemTheme();
      notifyListeners();
    }
  }

  // Update system theme based on device settings
  void _updateSystemTheme() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _systemIsDark = brightness == Brightness.dark;
  }

  // Set theme mode and persist to storage
  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      _themeMode = mode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.name);
      
      print('🎨 ThemeProvider: Theme saved to storage: ${mode.name}');
      
      if (mode == AppThemeMode.system) {
        _updateSystemTheme();
      }
      
      // Verify the save worked
      final savedTheme = prefs.getString('theme_mode');
      print('🎨 ThemeProvider: Verification - stored theme is: $savedTheme');
      
      notifyListeners();
    } catch (e) {
      print('🎨 ThemeProvider: Error saving theme: $e');
    }
  }

  // Cycle through theme modes (for toggle functionality)
  Future<void> cycleThemeMode() async {
    switch (_themeMode) {
      case AppThemeMode.light:
        await setThemeMode(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setThemeMode(AppThemeMode.system);
        break;
      case AppThemeMode.system:
        await setThemeMode(AppThemeMode.light);
        break;
    }
  }

  // Legacy method for backward compatibility
  void toggleTheme() {
    cycleThemeMode();
  }

  void setTheme(bool isDark) {
    setThemeMode(isDark ? AppThemeMode.dark : AppThemeMode.light);
  }

  // Dark Theme Colors
  Color get darkBackground => const Color(0xFF1A202C);
  Color get darkSecondaryBackground => const Color(0xFF2D3748);
  Color get darkCardBackground => Colors.white.withValues(alpha: 0.1);
  Color get darkBorder => Colors.white.withValues(alpha: 0.2);
  Color get darkText => Colors.white;
  Color get darkSecondaryText => const Color(0xFFA0AEC0);

  // Light Theme Colors
  Color get lightBackground => const Color(0xFFF7FAFC);
  Color get lightSecondaryBackground => Colors.white;
  Color get lightCardBackground => Colors.white;
  Color get lightBorder => Colors.black.withValues(alpha: 0.1);
  Color get lightText => const Color(0xFF2D3748);
  Color get lightSecondaryText => const Color(0xFF718096);

  // Current Theme Colors
  Color get backgroundColor => isDarkMode ? darkBackground : lightBackground;
  Color get secondaryBackgroundColor => isDarkMode ? darkSecondaryBackground : lightSecondaryBackground;
  Color get cardBackgroundColor => isDarkMode ? darkCardBackground : lightCardBackground;
  Color get borderColor => isDarkMode ? darkBorder : lightBorder;
  Color get textColor => isDarkMode ? darkText : lightText;
  Color get secondaryTextColor => isDarkMode ? darkSecondaryText : lightSecondaryText;

  // Gradient Colors
  List<Color> get backgroundGradient => isDarkMode 
      ? [const Color(0xFF1A202C), const Color(0xFF2D3748)]
      : [const Color(0xFFF7FAFC), const Color(0xFFEDF2F7)];

  // Navigation Bar Color
  Color get navigationBarColor => isDarkMode 
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.white;

  Color get navigationBorderColor => isDarkMode 
      ? Colors.white.withValues(alpha: 0.2)
      : Colors.black.withValues(alpha: 0.1);
}