import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    log('PersistenceService: Initialized');
  }

  static Future<void> saveThemeMode(bool isDark) async {
    log('PersistenceService: Saving theme mode: ${isDark ? 'dark' : 'light'}');
    await _prefs.setBool('is_dark_mode', isDark);
  }

  static bool? getThemeMode() {
    final mode = _prefs.getBool('is_dark_mode');
    log('PersistenceService: Loading theme mode: $mode');
    return mode;
  }

  static Future<void> saveLocale(String languageCode) async {
    log('PersistenceService: Saving locale: $languageCode');
    await _prefs.setString('locale', languageCode);
  }

  static String? getLocale() {
    final locale = _prefs.getString('locale');
    log('PersistenceService: Loading locale: $locale');
    return locale;
  }
}
