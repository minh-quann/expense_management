import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager for app settings stored in SharedPreferences.
class AppSettingsManager {
  static const String _disableTabAnimationKey = 'disable_tab_animation';
  static const String _disableLiquidGlassKey = 'disable_liquid_glass';
  static const String _themeModeKey = 'theme_mode';
  static SharedPreferences? _prefs;

  /// ValueNotifier to allow widgets to listen to tab animation setting changes.
  static final ValueNotifier<bool> disableTabAnimationNotifier = ValueNotifier<bool>(false);

  /// ValueNotifier to allow widgets to listen to liquid glass setting changes.
  static final ValueNotifier<bool> disableLiquidGlassNotifier = ValueNotifier<bool>(false);

  /// ValueNotifier to allow widgets to listen to theme mode changes.
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Initialize AppSettingsManager and load initial settings.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    disableTabAnimationNotifier.value = isTabAnimationDisabled();
    disableLiquidGlassNotifier.value = isLiquidGlassDisabled();
    themeModeNotifier.value = getThemeMode();
  }

  /// Set whether tab animation is disabled.
  static Future<void> setDisableTabAnimation(bool disable) async {
    await init();
    await _prefs!.setBool(_disableTabAnimationKey, disable);
    disableTabAnimationNotifier.value = disable;
  }

  /// Check if tab animation is disabled.
  static bool isTabAnimationDisabled() {
    return _prefs?.getBool(_disableTabAnimationKey) ?? false;
  }

  /// Set whether liquid glass effect is disabled.
  static Future<void> setDisableLiquidGlass(bool disable) async {
    await init();
    await _prefs!.setBool(_disableLiquidGlassKey, disable);
    disableLiquidGlassNotifier.value = disable;
  }

  /// Check if liquid glass effect is disabled.
  static bool isLiquidGlassDisabled() {
    return _prefs?.getBool(_disableLiquidGlassKey) ?? false;
  }

  /// Set the app theme mode.
  static Future<void> setThemeMode(ThemeMode mode) async {
    await init();
    await _prefs!.setString(_themeModeKey, mode.name);
    themeModeNotifier.value = mode;
  }

  /// Get the app theme mode.
  static ThemeMode getThemeMode() {
    final themeStr = _prefs?.getString(_themeModeKey) ?? 'system';
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
