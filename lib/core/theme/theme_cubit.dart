import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/core/utils/app_settings_manager.dart';

/// Manages the app theme mode (light, dark, system)
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(AppSettingsManager.getThemeMode());

  void setLight() {
    AppSettingsManager.setThemeMode(ThemeMode.light);
    emit(ThemeMode.light);
  }

  void setDark() {
    AppSettingsManager.setThemeMode(ThemeMode.dark);
    emit(ThemeMode.dark);
  }

  void setSystem() {
    AppSettingsManager.setThemeMode(ThemeMode.system);
    emit(ThemeMode.system);
  }

  /// Cycle through: system -> light -> dark -> system
  void toggle() {
    switch (state) {
      case ThemeMode.system:
        setLight();
        break;
      case ThemeMode.light:
        setDark();
        break;
      case ThemeMode.dark:
        setSystem();
        break;
    }
  }
}
