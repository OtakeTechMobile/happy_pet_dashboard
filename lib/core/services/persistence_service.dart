import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    log('Persistence initialized');
  }

  static Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool('is_dark_mode', isDark);
  }

  static bool? getThemeMode() {
    return _prefs.getBool('is_dark_mode');
  }
}
