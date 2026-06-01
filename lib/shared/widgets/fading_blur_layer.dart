import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:expense_management/core/utils/app_settings_manager.dart';

/// A reusable fading blur layer that handles backdrop filter optimization.
/// When Liquid Glass / animations are disabled, it returns an empty widget [SizedBox.shrink]
/// to save GPU usage (avoiding expensive real-time raster blurs during scrolling).
class FadingBlurLayer extends StatelessWidget {
  const FadingBlurLayer({
    super.key,
    this.stops = const [0.35, 1.0],
  });

  /// The stops for the linear gradient that controls the fading blur.
  /// Typically [0.35, 1.0] for standard screens, or [0.65, 1.0] for screens with search filters.
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettingsManager.disableLiquidGlassNotifier,
      builder: (context, disableLiquidGlass, _) {
        if (disableLiquidGlass) {
          // Completely omit BackdropFilter to optimize GPU rasterization to 0% during scroll
          return const SizedBox.shrink();
        }

        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Colors.black, Colors.transparent],
              stops: stops,
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
        );
      },
    );
  }
}
