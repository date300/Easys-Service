import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    
    if (savedTheme != null) {
      _themeMode = _stringToThemeMode(savedTheme);
      notifyListeners();
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeModeToString(mode));
    
    _themeMode = mode;
    notifyListeners();
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      default: return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}
