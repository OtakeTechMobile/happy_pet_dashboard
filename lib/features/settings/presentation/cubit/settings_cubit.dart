import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/persistence_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState(themeMode: ThemeMode.system, locale: Locale('pt')));

  Future<void> loadSettings() async {
    final isDark = PersistenceService.getThemeMode();
    final themeMode = isDark == true ? ThemeMode.dark : ThemeMode.light;

    // TODO: Load locale from persistence

    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> toggleTheme(bool isDark) async {
    await PersistenceService.saveThemeMode(isDark);
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  void setLocale(Locale locale) {
    // TODO: Save locale to persistence
    emit(state.copyWith(locale: locale));
  }
}
