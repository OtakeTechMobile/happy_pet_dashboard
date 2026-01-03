import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/persistence_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(_initialState);

  static SettingsState get _initialState {
    final isDark = PersistenceService.getThemeMode();
    final themeMode = isDark == null ? ThemeMode.system : (isDark ? ThemeMode.dark : ThemeMode.light);

    final localeCode = PersistenceService.getLocale();
    final locale = localeCode != null ? Locale(localeCode) : const Locale('pt');

    return SettingsState(themeMode: themeMode, locale: locale);
  }

  Future<void> loadSettings() async {
    // Already handled in constructor
  }

  Future<void> toggleTheme(bool isDark) async {
    await PersistenceService.saveThemeMode(isDark);
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  void setLocale(Locale locale) {
    PersistenceService.saveLocale(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
