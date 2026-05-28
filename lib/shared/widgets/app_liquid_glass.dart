import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// Creates a jelly transform matrix based on velocity for organic squash and stretch effect.
/// Ported from the liquid_glass_renderer library example.
Matrix4 _buildJellyTransform({
  required Offset velocity,
  double maxDistortion = 0.7,
  double velocityScale = 1000.0,
}) {
  final speed = velocity.distance;
  final direction = speed > 0 ? velocity / speed : Offset.zero;
  final distortionFactor =
      (speed / velocityScale).clamp(0.0, 1.0) * maxDistortion;

  if (distortionFactor == 0) return Matrix4.identity();

  // Squash in direction of movement, stretch perpendicular
  final squashX = 1.0 - (direction.dx.abs() * distortionFactor * 0.5);
  final squashY = 1.0 - (direction.dy.abs() * distortionFactor * 0.5);
  final stretchX = 1.0 + (direction.dy.abs() * distortionFactor * 0.3);
  final stretchY = 1.0 + (direction.dx.abs() * distortionFactor * 0.3);

  final matrix = Matrix4.identity();
  // ignore: deprecated_member_use
  matrix.scale(squashX * stretchX, squashY * stretchY);
  return matrix;
}

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
    this.showGlow = false,
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

  /// Whether to show the interactive glow effect when tapped (requires [HitTestBehavior.opaque] or a gesture detector).
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Default translucent glass colors matching system theme
    final defaultGlassColor = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
        : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

    // Determine the border shape
    final effectiveShape = shape ?? LiquidRoundedSuperellipse(borderRadius: borderRadius);
    final borderShape = effectiveShape is LiquidOval
        ? const OvalBorder(
            side: BorderSide(
              color: Color(0x17FFFFFF), // White with 9% alpha
              width: 1,
            ),
          )
        : RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(
              color: Color(0x17FFFFFF),
              width: 1,
            ),
          );

    Widget innerChild = Container(
      padding: padding,
      decoration: isDark
          ? ShapeDecoration(shape: borderShape)
          : null,
      child: child,
    );

    if (showGlow) {
      innerChild = GlassGlow(
        glowColor: isDark ? Colors.white24 : Colors.black12,
        child: innerChild,
      );
    }

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
          lightIntensity:
              lightIntensity ??
              (isDark
                  ? 0.3
                  : 1.0), // Keep light intensity low in dark mode to not overpower the flat border
          ambientStrength: ambientStrength ?? (isDark ? 0.3 : 0.5),
          lightAngle: math.pi / 4,
          glassColor: glassColor ?? defaultGlassColor,
        ),
        child: LiquidGlass.grouped(
          shape: effectiveShape,
          child: innerChild,
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
    this.onHoverChanged,
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

  /// Real-time callback during dragging to track closest tab index.
  final ValueChanged<int?>? onHoverChanged;

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
  bool _isDown = false;
  bool _isDragging = false;

  late double xAlign = _computeXAlign(widget.selectedIndex);

  /// Map index directly to alignment range -1..1
  double _computeXAlign(int index) {
    if (widget.count <= 1) return 0.0;
    final fraction = index / (widget.count - 1);
    return (fraction * 2) - 1;
  }

  @override
  void didUpdateWidget(covariant AppLiquidGlassIndicator oldWidget) {
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.count != widget.count) {
      setState(() {
        xAlign = _computeXAlign(widget.selectedIndex);
      });
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
    setState(() {
      _isDown = true;
      xAlign = _getAlignmentFromGlobalPosition(details.globalPosition);
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      xAlign = _getAlignmentFromGlobalPosition(details.globalPosition);
    });

    // Notify hover change during drag
    final currentRelativeX = (xAlign + 1) / 2;
    final targetSlot = (currentRelativeX * (widget.count - 1)).round().clamp(
      0,
      widget.count - 1,
    );
    widget.onHoverChanged?.call(targetSlot);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _isDown = false;
    });

    final box = context.findRenderObject() as RenderBox;
    final currentRelativeX = (xAlign + 1) / 2;
    final tabWidth = 1.0 / widget.count;

    final indicatorWidth = 1.0 / widget.count;
    final draggableRange = 1.0 - indicatorWidth;
    final velocityX =
        (details.velocity.pixelsPerSecond.dx / box.size.width) / draggableRange;

    int targetTabIndex;

    if (currentRelativeX < 0) {
      targetTabIndex = 0;
    } else if (currentRelativeX > 1) {
      targetTabIndex = widget.count - 1;
    } else {
      const velocityThreshold = 0.5;
      if (velocityX.abs() > velocityThreshold) {
        final projectedX = (currentRelativeX + velocityX * 0.3).clamp(0.0, 1.0);
        targetTabIndex = (projectedX / tabWidth).round().clamp(
          0,
          widget.count - 1,
        );
      } else {
        targetTabIndex = (currentRelativeX / tabWidth).round().clamp(
          0,
          widget.count - 1,
        );
      }
    }

    xAlign = _computeXAlign(targetTabIndex);
    widget.onHoverChanged?.call(null);

    if (targetTabIndex != widget.selectedIndex) {
      widget.onChanged(targetTabIndex);
    }
  }

  void _onDragCancel() {
    setState(() {
      _isDragging = false;
      _isDown = false;
      xAlign = _computeXAlign(widget.selectedIndex);
    });
    widget.onHoverChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark ?? AppColors.isDark(context);
    final indicatorColor = dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final defaultGlassColor = dark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
        : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

    Widget mainStack = GestureDetector(
      onHorizontalDragDown: _onDragDown,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: _onDragCancel,
      child: VelocityMotionBuilder(
        converter: SingleMotionConverter(),
        value: xAlign,
        motion: _isDragging
            ? const Motion.interactiveSpring(snapToEnd: true)
            : const Motion.bouncySpring(snapToEnd: true),
        builder: (context, value, velocity, child) {
          final alignment = Alignment(value, 0);

          final targetAlignment = _computeXAlign(widget.selectedIndex);

          return SingleMotionBuilder(
            motion: const Motion.snappySpring(
              snapToEnd: true,
              duration: Duration(milliseconds: 300),
            ),
            value:
                _isDown || (alignment.x - targetAlignment).abs() > 0.30
                ? 1.0
                : 0.0,
            builder: (context, thickness, stackChild) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Normal state pill - fade out when glass pill is active
                  if (thickness < 1)
                    _IndicatorTransform(
                      velocity: velocity,
                      tabCount: widget.count,
                      alignment: alignment,
                      thickness: thickness,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: thickness <= 0.2 ? 1 : 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            borderRadius: BorderRadius.circular(64),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  // Background/Child - slight scale up on press like iOS native
                  Transform.scale(
                    scale: 1 + (thickness * 0.02),
                    child: IndicatorStateScope(
                      alignmentX: value,
                      thickness: thickness,
                      count: widget.count,
                      child: stackChild!,
                    ),
                  ),
                  // Active glass pill - visibility controlled by thickness
                  if (thickness > 0)
                    _IndicatorTransform(
                      velocity: velocity,
                      tabCount: widget.count,
                      alignment: alignment,
                      thickness: thickness,
                      child: LiquidGlass.withOwnLayer(
                        settings: LiquidGlassSettings(
                          visibility: thickness,
                          glassColor: Color.from(
                            alpha: 0.1,
                            red: 1,
                            green: 1,
                            blue: 1,
                          ),
                          saturation: 1.5,
                          refractiveIndex: 1.15,
                          thickness: 20,
                          lightIntensity: 2,
                          chromaticAberration: 0.5,
                          blur: 0,
                        ),
                        shape: LiquidRoundedSuperellipse(
                          borderRadius: widget.borderRadius,
                        ),
                        child: GlassGlow(child: const SizedBox.expand()),
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
                decoration: dark
                    ? ShapeDecoration(
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius,
                          ),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.09),
                            width: 1.2,
                          ),
                        ),
                      )
                    : null,
                child: widget.child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );

    return RepaintBoundary(
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          refractiveIndex: widget.refractiveIndex,
          thickness: widget.thickness,
          blur: widget.blur,
          saturation: widget.saturation,
          lightIntensity: widget.lightIntensity ?? (dark ? 0.3 : 1.0),
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
    // Fixed margin matching library example
    const double marginValue = 4.0;

    // Zoom expansion: lerp from no expansion to -14px outward based on thickness
    final rect = RelativeRect.lerp(
      RelativeRect.fill,
      const RelativeRect.fromLTRB(-14, -14, -14, -14),
      thickness,
    );

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
              rect: rect!,
              child: SingleMotionBuilder(
                motion: const Motion.bouncySpring(
                  duration: Duration(milliseconds: 600),
                ),
                value: velocity,
                builder: (context, velocity, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: _buildJellyTransform(
                      velocity: Offset(velocity, 0),
                      maxDistortion: 0.8,
                      velocityScale: 10,
                    ),
                    child: child,
                  );
                },
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// InheritedWidget to propagate the current alignment, thickness, and count of the indicator down the widget tree.
class IndicatorStateScope extends InheritedWidget {
  final double alignmentX;
  final double thickness;
  final int count;

  const IndicatorStateScope({
    super.key,
    required this.alignmentX,
    required this.thickness,
    required this.count,
    required super.child,
  });

  static IndicatorStateScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<IndicatorStateScope>();
  }

  @override
  bool updateShouldNotify(IndicatorStateScope oldWidget) {
    return oldWidget.alignmentX != alignmentX ||
        oldWidget.thickness != thickness ||
        oldWidget.count != count;
  }
}

/// A premium interactive glassmorphic button that wobbles and distorts like a jelly drop of water when tapped.
class AppLiquidGlassButton extends StatefulWidget {
  const AppLiquidGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 100.0,
    this.padding = const EdgeInsets.all(10),
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  State<AppLiquidGlassButton> createState() => _AppLiquidGlassButtonState();
}

class _AppLiquidGlassButtonState extends State<AppLiquidGlassButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: widget.margin,
        child: LiquidStretch(
          interactionScale: 1.06,
          stretch: 0.5,
          resistance: 0.08,
          child: AppLiquidGlass(
            shape: const LiquidOval(), // Use LiquidOval to guarantee a perfect circle/ellipse
            padding: widget.padding,
            showGlow: true, // Enable GlassGlow for buttons
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
