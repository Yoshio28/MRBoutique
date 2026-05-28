// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _kKey = 'is_dark_mode';

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _load();
  }

  // ─── Persistencia ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // Si no existe la key, se mantiene el default (true = dark)
    _isDarkMode = prefs.getBool(_kKey) ?? _isDarkMode;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, _isDarkMode);
  }

  // ─── Operaciones ────────────────────────────────────────────────────────────

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _save();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
    _save();
  }
}
