import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// A glass toggle switch wrapper that resolves styling defaults and uses GlassSwitch from library.
class AppLiquidGlassSwitch extends StatelessWidget {
  /// Whether the switch is on or off.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  /// The color of the track when the switch is on.
  final Color? activeColor;

  /// The color of the track when the switch is off.
  final Color? inactiveColor;

  /// The color of the thumb (circular knob).
  final Color thumbColor;

  /// Width of the switch.
  final double width;

  /// Height of the switch.
  final double height;

  /// Glass effect settings.
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass.
  final bool useOwnLayer;

  /// Resolution quality for the glass rendering.
  final GlassQuality? quality;

  /// Whether to emit haptic feedback on toggle.
  final bool enableHaptics;

  const AppLiquidGlassSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor = Colors.white,
    this.width = 68.0,
    this.height = 30.0,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    
    // Resolve inactive track color: transparent white for dark mode, light grey for light mode
    final resolvedInactiveColor = inactiveColor ??
        (isDark ? const Color(0x33FFFFFF) : const Color(0xFFE5E5EA));
        
    // Resolve active track color: app primary color
    final resolvedActiveColor = activeColor ?? AppColors.primary;

    return GlassSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: resolvedActiveColor,
      inactiveColor: resolvedInactiveColor,
      thumbColor: thumbColor,
      width: width,
      height: height,
      settings: settings,
      useOwnLayer: useOwnLayer,
      quality: quality,
      enableHaptics: enableHaptics,
    );
  }
}
