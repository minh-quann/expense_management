import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// A premium interactive glassmorphic button that wobbles and distorts like a jelly drop of water when tapped.
/// Implemented using [GlassButton.custom] from `liquid_glass_widgets` package,
/// coupled with a custom physics-driven spring wrapper to support highly configurable elastic bounce.
class AppLiquidGlassButton extends StatefulWidget {
  const AppLiquidGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 100.0,
    this.padding = const EdgeInsets.all(10),
    this.margin,
    this.width,
    this.height,
    this.autoSize = false,
    this.interactionScale = 1.3,
    this.stretch = 1.4,
    this.resistance = 0.07,
    this.refractiveIndex = 1.2,
    this.thickness = 30.0,
    this.blur = 1.0,
    this.bounce =
        0.4, // Custom bounce factor (elasticity) when dragging is released
    this.useOwnLayer =
        true, // Whether to create its own glass rendering context layer
    this.glassColor, // Optional custom glass tint color
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool autoSize;

  // Custom spring motion properties
  final double interactionScale;
  final double stretch;
  final double resistance;
  final double bounce;

  // Custom glass rendering settings
  final double refractiveIndex;
  final double thickness;
  final double blur;

  final bool useOwnLayer;
  final Color? glassColor;

  @override
  State<AppLiquidGlassButton> createState() => _AppLiquidGlassButtonState();
}

class _AppLiquidGlassButtonState extends State<AppLiquidGlassButton>
    with TickerProviderStateMixin {
  bool _isTransitioning = false;
  Animation<double>? _animation;
  Animation<double>? _secondaryAnimation;

  // Custom spring animation variables
  Offset _stretchOffset = Offset.zero;
  Offset _rawDragOffset = Offset.zero;
  Offset _velocity = Offset.zero;
  int _lastTimestamp = 0;
  bool _isDragging = false;
  bool _hasDragged =
      false; // Flag to differentiate between normal Tap and actual Drag

  Ticker? _springTicker;
  SpringSimulation? _simX;
  SpringSimulation? _simY;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cleanupRouteListeners();

    final route = ModalRoute.of(context);
    if (route != null) {
      _animation = route.animation;
      _secondaryAnimation = route.secondaryAnimation;

      _animation?.addStatusListener(_handleRouteStatusChange);
      _secondaryAnimation?.addStatusListener(_handleRouteStatusChange);

      final isRouteTransitioning = _checkIfRouteTransitioning(route);
      if (_isTransitioning != isRouteTransitioning) {
        _isTransitioning = isRouteTransitioning;
      }
    }
  }

  bool _checkIfRouteTransitioning(ModalRoute<dynamic> route) {
    final animStatus = route.animation?.status;
    final secAnimStatus = route.secondaryAnimation?.status;

    final isPrimaryTransitioning =
        animStatus == AnimationStatus.forward ||
        animStatus == AnimationStatus.reverse;
    final isSecondaryTransitioning =
        secAnimStatus == AnimationStatus.forward ||
        secAnimStatus == AnimationStatus.reverse;

    return isPrimaryTransitioning || isSecondaryTransitioning;
  }

  void _handleRouteStatusChange(AnimationStatus status) {
    final route = ModalRoute.of(context);
    if (route == null) return;

    final isRouteTransitioning = _checkIfRouteTransitioning(route);
    if (_isTransitioning != isRouteTransitioning) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isTransitioning = isRouteTransitioning;
            });
          }
        });
      }
    }
  }

  void _cleanupRouteListeners() {
    _animation?.removeStatusListener(_handleRouteStatusChange);
    _secondaryAnimation?.removeStatusListener(_handleRouteStatusChange);
  }

  // Apply non-linear resistance to the drag offset
  Offset _applyResistance(Offset offset, double resistance) {
    if (resistance == 0) return offset;
    final magnitude = offset.distance;
    if (magnitude == 0) return Offset.zero;
    final resistedMagnitude = magnitude / (1 + magnitude * resistance);
    return offset * (resistedMagnitude / magnitude);
  }

  // Start bouncy spring animation to return the stretch back to zero
  void _startSpringAnimation(Offset startOffset, Offset startVelocity) {
    _springTicker?.stop();
    _springTicker?.dispose();

    final springDesc = SpringDescription.withDurationAndBounce(
      duration: const Duration(
        milliseconds: 600,
      ), // Natural elastic settle duration
      bounce: widget.bounce, // Custom spring bounce factor from property
    );

    _simX = SpringSimulation(springDesc, startOffset.dx, 0.0, startVelocity.dx);
    _simY = SpringSimulation(springDesc, startOffset.dy, 0.0, startVelocity.dy);

    _springTicker = createTicker((elapsed) {
      final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
      final x = _simX!.x(t);
      final y = _simY!.x(t);

      if (mounted) {
        setState(() {
          _stretchOffset = Offset(x, y);
        });
      }

      if (_simX!.isDone(t) && _simY!.isDone(t)) {
        _springTicker?.stop();
        if (mounted) {
          setState(() {
            _stretchOffset = Offset.zero;
          });
        }
      }
    });
    _springTicker!.start();
  }

  @override
  void dispose() {
    _cleanupRouteListeners();
    _springTicker?.stop();
    _springTicker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Default translucent glass colors matching system theme
    final defaultGlassColor = isDark
        ? const Color(0xFFD0D5DD).withValues(alpha: 0.10)
        : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

    final isCircle =
        widget.borderRadius >= 100.0 &&
        widget.width != null &&
        widget.height != null &&
        widget.width == widget.height &&
        !widget.autoSize;

    final effectiveShape = isCircle
        ? const lgw.LiquidOval()
        : lgw.LiquidRoundedSuperellipse(borderRadius: widget.borderRadius);

    // Set dimensions based on autoSize flag
    final double w = widget.autoSize ? double.infinity : (widget.width ?? 56.0);
    final double h = widget.autoSize
        ? double.infinity
        : (widget.height ?? 56.0);

    // Use exactly the same settings as AppLiquidGlass to ensure perfect visual match
    final settings = lgw.LiquidGlassSettings(
      refractiveIndex: widget.refractiveIndex,
      thickness: widget.thickness,
      blur: widget.blur,
      saturation: 1.5,
      lightIntensity: isDark ? 0.0 : 1.0,
      ambientStrength: isDark ? 0.0 : 0.5,
      lightAngle: math.pi / 4,
      glassColor: widget.glassColor ?? defaultGlassColor,
    );

    Widget button = lgw.GlassButton.custom(
      onTap: widget.onTap ?? () {},
      enabled: true,
      width: w,
      height: h,
      shape: effectiveShape,
      settings: settings,
      useOwnLayer: widget.useOwnLayer, // Use parameter
      quality: _isTransitioning
          ? lgw.GlassQuality.minimal
          : lgw.GlassQuality.premium,
      glowColor: Colors
          .transparent, // Disable radial interactive glow to avoid grey spot on dark background
      interactionScale: widget.interactionScale,
      stretch:
          0.0, // Disable internal library stretch to use our custom bounce spring
      resistance: widget.resistance,
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.autoSize) {
      button = IntrinsicWidth(child: IntrinsicHeight(child: button));
    }

    Widget interactiveButton = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _springTicker?.stop();
        if (mounted) {
          setState(() {
            _isDragging = true;
            _hasDragged = false;
            _rawDragOffset = Offset.zero;
            _stretchOffset = Offset.zero;
            _lastTimestamp = DateTime.now().microsecondsSinceEpoch;
            _velocity = Offset.zero;
          });
        }
      },
      onPointerMove: (event) {
        if (!_isDragging) return;
        final now = DateTime.now().microsecondsSinceEpoch;
        final dt = (now - _lastTimestamp) / Duration.microsecondsPerSecond;
        if (dt > 0) {
          // Calculate drag velocity in pixels/second
          _velocity = event.delta / dt;
        }
        _lastTimestamp = now;

        _rawDragOffset += event.delta;

        // Threshold of 4.0 pixels to determine if a real drag gesture is occurring
        if (!_hasDragged && _rawDragOffset.distance > 4.0) {
          _hasDragged = true;
        }

        if (_hasDragged) {
          if (mounted) {
            setState(() {
              // Apply resistance and custom stretch multiplier to determine stretch pixels
              _stretchOffset =
                  _applyResistance(_rawDragOffset, widget.resistance) *
                  widget.stretch;
            });
          }
        }
      },
      onPointerUp: (event) {
        if (!_isDragging) return;
        _isDragging = false;

        if (_hasDragged) {
          // Calculate resisted velocity for smoother transition into spring
          final startVelocity =
              _applyResistance(_velocity, widget.resistance) * widget.stretch;

          // Clamp extreme velocities to avoid visual glitching
          final double maxVelocity = 3000.0;
          final clampedVelocity = Offset(
            startVelocity.dx.clamp(-maxVelocity, maxVelocity),
            startVelocity.dy.clamp(-maxVelocity, maxVelocity),
          );

          _startSpringAnimation(_stretchOffset, clampedVelocity);
        } else {
          // If it was a clean tap without dragging, instantly return to zero with no bounce
          if (mounted) {
            setState(() {
              _stretchOffset = Offset.zero;
            });
          }
        }
      },
      onPointerCancel: (event) {
        if (!_isDragging) return;
        _isDragging = false;
        _startSpringAnimation(_stretchOffset, Offset.zero);
      },
      child: RawLiquidStretch(stretchPixels: _stretchOffset, child: button),
    );

    return Container(margin: widget.margin, child: interactiveButton);
  }
}
