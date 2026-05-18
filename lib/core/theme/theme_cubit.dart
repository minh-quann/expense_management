import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

/// Manages the app theme mode (light, dark, system)
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
  void setSystem() => emit(ThemeMode.system);

  /// Cycle through: system -> light -> dark -> system
  void toggle() {
    switch (state) {
      case ThemeMode.system:
        emit(ThemeMode.light);
      case ThemeMode.light:
        emit(ThemeMode.dark);
      case ThemeMode.dark:
        emit(ThemeMode.system);
    }
  }
}
