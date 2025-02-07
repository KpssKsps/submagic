import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference(mode);
    notifyListeners();
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedThemeMode = prefs.getInt('themeMode');
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values[savedThemeMode];
    }
    notifyListeners(); // Notify listeners after loading theme
  }
}
