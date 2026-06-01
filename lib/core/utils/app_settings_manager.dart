import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager for app settings stored in SharedPreferences.
class AppSettingsManager {
  static const String _disableTabAnimationKey = 'disable_tab_animation';
  static const String _disableLiquidGlassKey = 'disable_liquid_glass';
  static SharedPreferences? _prefs;

  /// ValueNotifier to allow widgets to listen to tab animation setting changes.
  static final ValueNotifier<bool> disableTabAnimationNotifier = ValueNotifier<bool>(false);

  /// ValueNotifier to allow widgets to listen to liquid glass setting changes.
  static final ValueNotifier<bool> disableLiquidGlassNotifier = ValueNotifier<bool>(false);

  /// Initialize AppSettingsManager and load initial settings.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    disableTabAnimationNotifier.value = isTabAnimationDisabled();
    disableLiquidGlassNotifier.value = isLiquidGlassDisabled();
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
}
