import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's theme preference (light / dark / follow system) and
/// persists it across launches. Provided app-wide; the app shell watches it to
/// rebuild when the choice changes.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
      : _mode = initialMode;

  static const String _prefsKey = 'gd_theme_mode';

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  /// Load the saved preference. Safe to call once at startup; falls back to
  /// follow-system if nothing is stored or storage is unavailable.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _mode = _decode(prefs.getString(_prefsKey));
      notifyListeners();
    } catch (_) {
      // Keep the default (system) if preferences can't be read.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // A failed write only means the choice won't persist; ignore.
    }
  }

  static ThemeMode _decode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}
