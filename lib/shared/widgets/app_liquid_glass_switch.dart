import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// A premium glassmorphic switch toggle designed with native-like liquid glass refraction,
/// organic jelly spring motion, and blending effects.
class AppLiquidGlassSwitch extends StatelessWidget {
  const AppLiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDark,
    this.width = 56.0,
    this.height = 32.0,
    this.activeColor,
    this.inactiveColor,
  });

  /// Whether the switch is toggled ON.
  final bool value;

  /// Callback when the toggle state is updated.
  final ValueChanged<bool> onChanged;

  /// Override system theme mode check if provided.
  final bool? isDark;

  /// Width of the switch track. Defaults to 56.0.
  final double width;

  /// Height of the switch track. Defaults to 32.0.
  final double height;

  /// Color of the glass track when toggled ON. Defaults to [AppColors.primary].
  final Color? activeColor;

  /// Color of the glass track when toggled OFF. Defaults to semi-transparent grey/black.
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? AppColors.isDark(context);

    // Compute base track colors
    final baseActiveColor = activeColor ?? AppColors.primary;
    final defaultGlassColor = dark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
        : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

    // The active pill inside (thumb) is a shiny glass block
    final thumbColor = dark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white;

    // Use SingleMotionBuilder for spring motion
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: height,
        child: SingleMotionBuilder(
          motion: const Motion.snappySpring(snapToEnd: true),
          value: value ? 1.0 : 0.0,
          builder: (context, animValue, _) {
            // Blend track color between active and inactive states
            final trackColor = Color.lerp(
              inactiveColor ?? defaultGlassColor,
              baseActiveColor.withValues(alpha: 0.4),
              animValue,
            )!;

            // Interpolate thumb position (from Left: -1 to Right: 1)
            final alignment = Alignment(animValue * 2.0 - 1.0, 0.0);

            // Compute border decoration matching the bottom navigation style (Telegram style)
            final borderDecoration = dark
                ? ShapeDecoration(
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(height / 2),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.09),
                        width: 1.0,
                      ),
                    ),
                  )
                : null;

            return RepaintBoundary(
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  refractiveIndex: 1.21,
                  thickness: 20.0,
                  blur: 10.0,
                  saturation: 1.5,
                  lightIntensity: dark ? 0.3 : 1.0, // Match AppLiquidGlass lighting adjustments
                  ambientStrength: dark ? 0.3 : 0.5,
                  lightAngle: math.pi / 4,
                  glassColor: trackColor,
                ),
                child: LiquidGlassBlendGroup(
                  blend: 8.0, // Liquid blending distance in pixels
                  child: LiquidGlass.grouped(
                    clipBehavior: Clip.none,
                    shape: LiquidRoundedSuperellipse(borderRadius: height / 2),
                    child: Container(
                      padding: const EdgeInsets.all(3.0), // Padding around the thumb
                      decoration: borderDecoration,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Align(
                            alignment: alignment,
                            child: SizedBox(
                              width: height - 6.0, // Thumb is circular inside padding
                              height: height - 6.0,
                              child: LiquidGlass.withOwnLayer(
                                settings: LiquidGlassSettings(
                                  visibility: 1.0,
                                  glassColor: thumbColor,
                                  saturation: 1.5,
                                  refractiveIndex: 1.3,
                                  thickness: 25,
                                  lightIntensity: 2.0,
                                  ambientStrength: 0.4,
                                  chromaticAberration: 0.4, // Spectral dispersion like Telegram's active pill
                                  blur: 0,
                                ),
                                shape: LiquidRoundedSuperellipse(borderRadius: (height - 6.0) / 2),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
