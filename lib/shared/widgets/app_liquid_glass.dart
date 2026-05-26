import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// A reusable glassmorphic container that applies the Liquid Glass effect.
/// It wraps a child widget with [LiquidGlassLayer] and [LiquidGlass.grouped]
/// to render high-end refraction, blur, and lighting highlights.
class AppLiquidGlass extends StatelessWidget {
  const AppLiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.refractiveIndex = 1.21,
    this.thickness = 30.0,
    this.blur = 10.0,
    this.saturation = 1.5,
    this.lightIntensity,
    this.ambientStrength,
    this.glassColor,
    this.shape,
  });

  /// The widget inside the glass container.
  final Widget child;

  /// Corner radius for the glass container, using superellipse shape by default.
  final double borderRadius;

  /// Height of the container.
  final double? height;

  /// Width of the container.
  final double? width;

  /// Internal padding of the container.
  final EdgeInsetsGeometry? padding;

  /// External margin of the container.
  final EdgeInsetsGeometry? margin;

  /// Refractive index representing the bending of background light.
  final double refractiveIndex;

  /// Edge thickness of the glass (refraction border depth).
  final double thickness;

  /// Background gaussian blur intensity.
  final double blur;

  /// Color saturation boost factor of background.
  final double saturation;

  /// Brightness of the highlight reflection. If null, automatically adjusted for Dark/Light mode.
  final double? lightIntensity;

  /// Ambient light intensity for glass visibility. If null, automatically adjusted for Dark/Light mode.
  final double? ambientStrength;

  /// Color tint of the glass itself. If null, automatically adapt to dark/light theme background.
  final Color? glassColor;

  /// Custom shape for the glass container. Defaults to [LiquidRoundedSuperellipse].
  final LiquidShape? shape;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Default translucent glass colors matching system theme
    final defaultGlassColor = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
        : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

    return Container(
      margin: margin,
      height: height,
      width: width,
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          refractiveIndex: refractiveIndex,
          thickness: thickness,
          blur: blur,
          saturation: saturation,
          lightIntensity: lightIntensity ?? (isDark ? 0.3 : 1.0), // Keep light intensity low in dark mode to not overpower the flat border
          ambientStrength: ambientStrength ?? (isDark ? 0.3 : 0.5),
          lightAngle: math.pi / 4,
          glassColor: glassColor ?? defaultGlassColor,
        ),
        child: LiquidGlass.grouped(
          clipBehavior: Clip.none,
          shape: shape ?? LiquidRoundedSuperellipse(borderRadius: borderRadius),
          child: Container(
            padding: padding,
            decoration: isDark ? ShapeDecoration(
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.09), // Even grey border like Telegram
                  width: 1, // Slightly thicker border
                ),
              ),
            ) : null,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A reusable glassmorphic sliding indicator (pill) with interactive drag gestures,
/// spring animations, organic jelly squash & stretch distortion, and integrated liquid glass background.
class AppLiquidGlassIndicator extends StatefulWidget {
  const AppLiquidGlassIndicator({
    super.key,
    required this.selectedIndex,
    required this.count,
    required this.onChanged,
    required this.child,
    this.isDark,
    this.borderRadius = 100.0,
    this.refractiveIndex = 1.4,
    this.thickness = 25.0,
    this.blur = 10.0,
    this.saturation = 1.5,
    this.blend = 10.0,
    this.lightIntensity,
    this.ambientStrength,
    this.glassColor,
    this.padding,
    this.margin,
  });

  /// The active selected tab index.
  final int selectedIndex;

  /// Total number of items/tabs.
  final int count;

  /// Callback when the selected index is updated via drag gesture.
  final ValueChanged<int> onChanged;

  /// The navigation/toggle bar items.
  final Widget child;

  /// Override theme dark mode check if provided.
  final bool? isDark;

  /// Corner radius for the glass container, using superellipse shape by default.
  final double borderRadius;

  /// Refractive index representing the bending of background light.
  final double refractiveIndex;

  /// Edge thickness of the glass (refraction border depth).
  final double thickness;

  /// Background gaussian blur intensity.
  final double blur;

  /// Color saturation boost factor of background.
  final double saturation;

  /// The blending radius in pixels between the container glass and indicator.
  final double blend;

  /// Brightness of the highlight reflection. If null, automatically adjusted for Dark/Light mode.
  final double? lightIntensity;

  /// Ambient light intensity for glass visibility. If null, automatically adjusted for Dark/Light mode.
  final double? ambientStrength;

  /// Color tint of the glass itself. If null, automatically adapt to dark/light theme background.
  final Color? glassColor;

  /// Internal padding of the container.
  final EdgeInsetsGeometry? padding;

  /// External margin of the container.
  final EdgeInsetsGeometry? margin;

  @override
  State<AppLiquidGlassIndicator> createState() =>
      _AppLiquidGlassIndicatorState();
}

class _AppLiquidGlassIndicatorState extends State<AppLiquidGlassIndicator> {
  // Use ValueNotifier to drive animation without triggering full widget rebuild
  late final ValueNotifier<double> _xAlignNotifier;
  late final ValueNotifier<bool> _isDownNotifier;
  late final ValueNotifier<bool> _isDraggingNotifier;

  /// Map index directly to alignment range -1..1
  double _computeXAlign(int index) {
    if (widget.count <= 1) return 0.0;
    final fraction = index / (widget.count - 1);
    return (fraction * 2) - 1;
  }

  @override
  void initState() {
    super.initState();
    _xAlignNotifier = ValueNotifier(_computeXAlign(widget.selectedIndex));
    _isDownNotifier = ValueNotifier(false);
    _isDraggingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _xAlignNotifier.dispose();
    _isDownNotifier.dispose();
    _isDraggingNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppLiquidGlassIndicator oldWidget) {
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _xAlignNotifier.value = _computeXAlign(widget.selectedIndex);
    }
    super.didUpdateWidget(oldWidget);
  }

  double _getAlignmentFromGlobalPosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);

    final indicatorWidth = 1.0 / widget.count;
    final draggableRange = 1.0 - indicatorWidth;
    final padding = indicatorWidth / 2;

    final rawRelativeX = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    final normalizedX = (rawRelativeX - padding) / draggableRange;

    final adjustedX = _applyRubberBandResistance(normalizedX);
    return (adjustedX * 2) - 1; // Convert to -1..1 range
  }

  double _applyRubberBandResistance(double value) {
    const double resistance = 0.4;
    const double maxOverdrag = 0.3;

    if (value < 0) {
      final overdrag = -value;
      return -(overdrag * resistance).clamp(0.0, maxOverdrag);
    } else if (value > 1) {
      final overdrag = value - 1;
      return 1 + (overdrag * resistance).clamp(0.0, maxOverdrag);
    }
    return value;
  }

  void _onDragDown(DragDownDetails details) {
    // Update ValueNotifiers instead of calling setState
    _isDownNotifier.value = true;
    _xAlignNotifier.value = _getAlignmentFromGlobalPosition(
      details.globalPosition,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Update ValueNotifiers instead of calling setState
    _isDraggingNotifier.value = true;
    _xAlignNotifier.value = _getAlignmentFromGlobalPosition(
      details.globalPosition,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    _isDraggingNotifier.value = false;
    _isDownNotifier.value = false;

    final box = context.findRenderObject() as RenderBox;
    final currentRelativeX =
        (_xAlignNotifier.value + 1) / 2; // Convert from -1..1 to 0..1
    final tabWidth = 1.0 / widget.count;

    final indicatorWidth = 1.0 / widget.count;
    final draggableRange = 1.0 - indicatorWidth;
    final velocityX =
        (details.velocity.pixelsPerSecond.dx / box.size.width) / draggableRange;

    int targetSlot;

    if (currentRelativeX < 0) {
      targetSlot = 0;
    } else if (currentRelativeX > 1) {
      targetSlot = widget.count - 1;
    } else {
      const velocityThreshold = 0.5;
      if (velocityX.abs() > velocityThreshold) {
        final projectedX = (currentRelativeX + velocityX * 0.3).clamp(0.0, 1.0);
        targetSlot = (projectedX / tabWidth).round().clamp(0, widget.count - 1);
      } else {
        targetSlot = (currentRelativeX / tabWidth).round().clamp(
          0,
          widget.count - 1,
        );
      }
    }

    final navIndex = targetSlot;
    _xAlignNotifier.value = _computeXAlign(navIndex);

    if (navIndex != widget.selectedIndex) {
      widget.onChanged(navIndex);
    }
  }

  void _onDragCancel() {
    _isDraggingNotifier.value = false;
    _isDownNotifier.value = false;
    _xAlignNotifier.value = _computeXAlign(widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark ?? AppColors.isDark(context);
    final indicatorColor = dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final targetAlignment = _computeXAlign(widget.selectedIndex);

    final defaultGlassColor = dark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
        : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

    // Use ListenableBuilder to only rebuild the motion subtree when notifiers change,
    // avoiding full widget tree rebuild from setState
    Widget mainStack = GestureDetector(
      onHorizontalDragDown: _onDragDown,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: _onDragCancel,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _xAlignNotifier,
          _isDownNotifier,
          _isDraggingNotifier,
        ]),
        builder: (context, child) {
          final isDragging = _isDraggingNotifier.value;
          final isDown = _isDownNotifier.value;

          return VelocityMotionBuilder(
            converter: SingleMotionConverter(),
            value: _xAlignNotifier.value,
            motion: isDragging
                ? const Motion.interactiveSpring(snapToEnd: true)
                : const Motion.snappySpring(snapToEnd: true),
            builder: (context, value, velocity, builderChild) {
              final alignment = Alignment(value, 0);

              return SingleMotionBuilder(
                motion: const Motion.snappySpring(
                  snapToEnd: true,
                  duration: Duration(milliseconds: 200),
                ),
                value:
                    isDown ||
                        isDragging ||
                        ((value - targetAlignment).abs() +
                                velocity.abs() * 0.15) >
                            0.05
                    ? 1.0
                    : 0.0,
                builder: (context, thickness, stackChild) {
                  // Compute normal pill color with alpha baked in
                  // to avoid expensive Opacity widget
                  final normalAlpha = thickness < 0.2
                      ? (1.0 - (thickness / 0.2)).clamp(0.0, 1.0)
                      : 0.0;
                  final fadedIndicatorColor = indicatorColor.withValues(
                    alpha: indicatorColor.a * normalAlpha,
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Normal state pill - always in tree, fade via color alpha
                      _IndicatorTransform(
                        velocity: velocity,
                        tabCount: widget.count,
                        alignment: alignment,
                        thickness: thickness,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: fadedIndicatorColor,
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      // Background/Child scales slightly when active
                      Transform.scale(
                        scale: 1.0 + (thickness * 0.04), // Grow by 4%
                        child: stackChild!,
                      ),
                      // Active glass pill - always in tree, visibility via LiquidGlassSettings.visibility
                      _IndicatorTransform(
                        velocity: velocity,
                        tabCount: widget.count,
                        alignment: alignment,
                        thickness: thickness,
                        child: LiquidGlass.withOwnLayer(
                          settings: LiquidGlassSettings(
                            visibility: thickness,
                            glassColor: const Color.fromARGB(0, 255, 255, 255),
                            saturation: 1.5,
                            refractiveIndex: 1.2,
                            thickness: 40,
                            lightIntensity: 2.5,
                            chromaticAberration: 0.5,
                            blur: 0,
                          ),
                          shape: LiquidRoundedSuperellipse(
                            borderRadius: widget.borderRadius,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                  );
                },
                child: LiquidGlass.grouped(
                  clipBehavior: Clip.none,
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: widget.borderRadius,
                  ),
                  child: Container(
                    padding: widget.padding,
                    margin: widget.margin,
                    decoration: dark ? ShapeDecoration(
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.09), // Even grey border like Telegram
                          width: 1.2, // Slightly thicker border
                        ),
                      ),
                    ) : null,
                    child: widget.child,
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    return RepaintBoundary(
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          refractiveIndex: widget.refractiveIndex,
          thickness: widget.thickness,
          blur: widget.blur,
          saturation: widget.saturation,
          lightIntensity: widget.lightIntensity ?? (dark ? 0.3 : 1.0), // Keep light intensity low in dark mode to not overpower the flat border
          ambientStrength: widget.ambientStrength ?? (dark ? 0.3 : 0.5),
          lightAngle: math.pi / 4,
          glassColor: widget.glassColor ?? defaultGlassColor,
        ),
        child: LiquidGlassBlendGroup(blend: widget.blend, child: mainStack),
      ),
    );
  }
}

class _IndicatorTransform extends StatelessWidget {
  const _IndicatorTransform({
    required this.velocity,
    required this.tabCount,
    required this.alignment,
    required this.thickness,
    required this.child,
  });

  final double velocity;
  final int tabCount;
  final Alignment alignment;
  final double thickness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final double marginValue = isDark ? 5.0 : 4.0;

    // --- Asymmetric leading/trailing edge stretch (iOS 26 liquid glass) ---
    // The leading edge (direction of movement) extends further,
    // the trailing edge lags behind, creating the signature liquid "blob" feel.
    const double maxStretchPx = 18.0;
    const double velocityNormalize = 8.0;

    // Smooth cubic ease-out mapping from velocity to stretch amount
    final rawFactor = (velocity.abs() / velocityNormalize).clamp(0.0, 1.0);
    final easedStretch = (1.0 - math.pow(1.0 - rawFactor, 3.0)) * maxStretchPx;

    // Leading edge stretches more, trailing edge stretches less
    final double leadingStretch = easedStretch * 1.0; // full stretch forward
    final double trailingStretch = easedStretch * 0.3; // subtle drag backward

    // Determine direction: positive velocity = moving right
    final double leftExtra;
    final double rightExtra;
    if (velocity > 0) {
      // Moving right: right edge leads, left edge trails
      rightExtra = leadingStretch;
      leftExtra = trailingStretch;
    } else if (velocity < 0) {
      // Moving left: left edge leads, right edge trails
      leftExtra = leadingStretch;
      rightExtra = trailingStretch;
    } else {
      leftExtra = 0;
      rightExtra = 0;
    }

    // Expand pill outward when active + asymmetric stretch
    final baseExpand = thickness * 16.0;
    final rect = RelativeRect.fromLTRB(
      -(baseExpand + leftExtra),
      -baseExpand,
      -(baseExpand + rightExtra),
      -baseExpand,
    );

    // Subtle vertical squeeze during fast horizontal movement (liquid blob feel)
    final double verticalSqueeze =
        1.0 - (rawFactor * 0.06); // max 6% squeeze at full speed

    return Positioned.fill(
      left: marginValue,
      right: marginValue,
      top: marginValue,
      bottom: marginValue,
      child: FractionallySizedBox(
        widthFactor: 1 / tabCount,
        alignment: alignment,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fromRelativeRect(
              rect: rect,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(1.0, verticalSqueeze, 1.0),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
