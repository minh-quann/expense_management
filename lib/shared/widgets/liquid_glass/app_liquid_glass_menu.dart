import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_helpers.dart';
// ignore: implementation_imports
import 'package:liquid_glass_widgets/src/renderer/stretch.dart';
import 'package:expense_management/core/theme/app_colors.dart';

/// A premium glassmorphic context menu wrapper that resolves responsive typography and color schemes.
/// Automatically handles light and dark mode contrasts to ensure items are readable.
/// Uses custom-built morphing logic to support true premium liquid glass effects.
class AppLiquidGlassMenu extends StatelessWidget {
  const AppLiquidGlassMenu({
    super.key,
    this.trigger,
    this.triggerBuilder,
    required this.items,
    this.menuAlignment,
    this.autoAdjustToScreen = true, // Default to true to keep menu on screen
    this.menuWidth = 220, // Slightly wider default to prevent text truncation
    this.menuBorderRadius = 32.0,
    this.itemBorderRadius = 24.0,
    this.glassSettings,
    this.quality =
        GlassQuality.premium, // Default to premium for high-fidelity glass
    this.stretch = 0.5,
    this.interactionScale = 1.02,
    this.stretchResistance = 0.08,
    this.stretchAxis,
    this.allowPositiveX,
    this.allowNegativeX,
    this.allowPositiveY,
    this.allowNegativeY,
    this.menuHeight,
    this.menuPadding = EdgeInsets.zero,
    this.enableInteractionGlow = true,
    this.glowOnTapOnly = true,
    this.glowColor,
    this.glowRadius = 0.6,
    this.glowIntensity = 0.0,
    this.onClose,
    this.glassColor,
    this.thickness,
    this.refractiveIndex,
    this.blur,
  });

  final Widget? trigger;
  final Widget Function(BuildContext context, VoidCallback toggleMenu)?
  triggerBuilder;
  final List<Widget> items;
  final GlassMenuAlignment? menuAlignment;
  final bool autoAdjustToScreen;
  final double menuWidth;
  final double menuBorderRadius;
  final double itemBorderRadius;
  final LiquidGlassSettings? glassSettings;
  final GlassQuality? quality;
  final double stretch;
  final double interactionScale;
  final double stretchResistance;
  final Axis? stretchAxis;
  final bool? allowPositiveX;
  final bool? allowNegativeX;
  final bool? allowPositiveY;
  final bool? allowNegativeY;
  final double? menuHeight;
  final EdgeInsets menuPadding;
  final bool enableInteractionGlow;
  final bool glowOnTapOnly;
  final Color? glowColor;
  final double glowRadius;
  final double glowIntensity;
  final VoidCallback? onClose;
  final Color? glassColor;
  final double? thickness;
  final double? refractiveIndex;
  final double? blur;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Resolve selection background color for the sliding pill
    final resolvedSelectionColor = isDark
        ? const Color(0x3DFFFFFF) // 24% white for dark mode
        : const Color(0x1F000000); // 12% black for light mode contrast

    // Matches AppLiquidGlass default colors exactly
    final defaultGlassColor =
        glassColor ??
        (isDark
            ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
            : const Color(0xFFF8F8F8).withValues(alpha: 0.45));

    final resolvedGlassSettings =
        glassSettings ??
        LiquidGlassSettings(
          refractiveIndex: refractiveIndex ?? 1.21,
          thickness: thickness ?? 30.0,
          blur: blur ?? 3.0,
          saturation: 1.5,
          lightIntensity: isDark ? 0.0 : 1.0,
          ambientStrength: isDark ? 0.0 : 0.5,
          lightAngle: math.pi / 4,
          glassColor: defaultGlassColor,
        );

    return AppGlassMenu(
      trigger: trigger,
      triggerBuilder: triggerBuilder,
      items: items,
      menuAlignment: menuAlignment,
      autoAdjustToScreen: autoAdjustToScreen,
      menuWidth: menuWidth,
      menuBorderRadius: menuBorderRadius,
      itemBorderRadius: itemBorderRadius,
      glassSettings: resolvedGlassSettings,
      quality: quality,
      stretch: stretch,
      interactionScale: interactionScale,
      stretchResistance: stretchResistance,
      stretchAxis: stretchAxis,
      allowPositiveX: allowPositiveX,
      allowNegativeX: allowNegativeX,
      allowPositiveY: allowPositiveY,
      allowNegativeY: allowNegativeY,
      menuHeight: menuHeight,
      menuPadding: menuPadding,
      selectionColor: resolvedSelectionColor,
      enableInteractionGlow: enableInteractionGlow,
      glowOnTapOnly: glowOnTapOnly,
      glowColor: glowColor,
      glowRadius: glowRadius,
      glowIntensity: glowIntensity,
      onClose: onClose,
    );
  }
}

/// A wrapper for [GlassMenuItem] that resolves colors appropriately for light and dark modes.
class AppLiquidGlassMenuItem extends StatelessWidget {
  const AppLiquidGlassMenuItem({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
    this.trailing,
    this.height = 44.0,
    this.subtitle,
    this.isPressed,
    this.isSelected = false,
    this.enabled = true,
    this.titleStyle,
    this.subtitleStyle,
    this.iconColor,
    this.iconSize = 20.0,
  });

  final String title;
  final Widget? icon;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;
  final double height;
  final bool? isPressed;
  final bool isSelected;
  final bool enabled;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? iconColor;
  final double iconSize;

  AppLiquidGlassMenuItem copyWith({bool? isSelected, bool? isPressed}) {
    return AppLiquidGlassMenuItem(
      key: key,
      title: title,
      onTap: onTap,
      icon: icon,
      isDestructive: isDestructive,
      trailing: trailing,
      height: height,
      subtitle: subtitle,
      isPressed: isPressed ?? this.isPressed,
      isSelected: isSelected ?? this.isSelected,
      enabled: enabled,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeTextColor = AppColors.textPrimary(context);

    // Resolve color: default is text primary (black in light, white in dark), or error red for destructive
    final Color resolvedTextColor = isDestructive
        ? AppColors.error
        : (titleStyle?.color ?? themeTextColor);

    final Color resolvedIconColor = isDestructive
        ? AppColors.error
        : (iconColor ?? themeTextColor);

    final TextStyle resolvedTitleStyle = TextStyle(
      color: resolvedTextColor,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ).merge(titleStyle);

    final TextStyle? resolvedSubtitleStyle = subtitle != null
        ? TextStyle(
            color: resolvedTextColor.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ).merge(subtitleStyle)
        : null;

    return GlassMenuItem(
      title: title,
      onTap: onTap,
      icon: icon,
      isDestructive: isDestructive,
      trailing: trailing,
      height: height,
      subtitle: subtitle,
      isPressed: isPressed,
      isSelected: isSelected,
      enabled: enabled,
      titleStyle: resolvedTitleStyle,
      subtitleStyle: resolvedSubtitleStyle,
      iconColor: resolvedIconColor,
      iconSize: iconSize,
    );
  }
}

/// A wrapper for [GlassMenuDivider] that uses proper contrast color for lines.
class AppLiquidGlassMenuDivider extends StatelessWidget {
  const AppLiquidGlassMenuDivider({
    super.key,
    this.height = 12.0,
    this.color,
    this.indent = 8.0,
  });

  final double height;
  final Color? color;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Resolve line color: subtle white line in dark mode, subtle dark line in light mode
    final resolvedColor =
        color ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08));

    return GlassMenuDivider(
      height: height,
      color: resolvedColor,
      indent: indent,
    );
  }
}

/// Custom GlassMenu implementation to fix size and clipping bugs in standard/premium quality.
class AppGlassMenu extends StatefulWidget {
  final Widget? trigger;
  final Widget Function(BuildContext context, VoidCallback toggleMenu)?
  triggerBuilder;
  final List<Widget> items;
  final GlassMenuAlignment? menuAlignment;
  final bool autoAdjustToScreen;
  final double menuWidth;
  final double menuBorderRadius;
  final double itemBorderRadius;
  final LiquidGlassSettings? glassSettings;
  final GlassQuality? quality;
  final double stretch;
  final double interactionScale;
  final double stretchResistance;
  final Axis? stretchAxis;
  final bool? allowPositiveX;
  final bool? allowNegativeX;
  final bool? allowPositiveY;
  final bool? allowNegativeY;
  final bool enableInteractionGlow;
  final bool glowOnTapOnly;
  final Color? glowColor;
  final double glowRadius;
  final double glowIntensity;
  final Color selectionColor;
  final double? menuHeight;
  final EdgeInsets menuPadding;
  final VoidCallback? onClose;

  const AppGlassMenu({
    super.key,
    this.trigger,
    this.triggerBuilder,
    required this.items,
    this.menuAlignment,
    this.autoAdjustToScreen = false,
    this.menuWidth = 200,
    this.menuBorderRadius = 32.0,
    this.itemBorderRadius = 24.0,
    this.glassSettings,
    this.quality,
    this.stretch = 0.5,
    this.interactionScale = 1.02,
    this.stretchResistance = 0.08,
    this.stretchAxis,
    this.allowPositiveX,
    this.allowNegativeX,
    this.allowPositiveY,
    this.allowNegativeY,
    this.menuHeight,
    this.menuPadding = EdgeInsets.zero,
    this.selectionColor = const Color(0x3DFFFFFF),
    this.enableInteractionGlow = true,
    this.glowOnTapOnly = true,
    this.glowColor,
    this.glowRadius = 0.6,
    this.glowIntensity = 0.0,
    this.onClose,
  }) : assert(
         trigger != null || triggerBuilder != null,
         'Either trigger or triggerBuilder must be provided',
       );

  @override
  State<AppGlassMenu> createState() => _AppGlassMenuState();
}

class _AppGlassMenuState extends State<AppGlassMenu>
    with TickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final GlobalKey _menuBodyKey = GlobalKey();
  late final GlassMorphController _morphController;
  late final ScrollController _scrollController;
  Size? _triggerSize;
  double? _triggerBorderRadius;
  Offset _triggerGlobalPosition = Offset.zero;
  int? _hoveredIndex;
  bool _isDragging = false;
  bool _isGlobalDrag = false;
  bool _hasStretched = false;
  double _initialScrollOffset = 0.0;
  Offset _initialLocalPosition = Offset.zero;
  double _horizontalOffset = 0.0;
  double _verticalOffset = 0.0;

  // Custom spring animation variables
  Offset _stretchOffset = Offset.zero;
  Offset _rawDragOffset = Offset.zero;
  Offset _velocity = Offset.zero;
  int _lastTimestamp = 0;
  Ticker? _springTicker;
  SpringSimulation? _simX;
  SpringSimulation? _simY;

  late final ValueNotifier<int?> _hoveredIndexNotifier;
  late final ValueNotifier<bool> _isDraggingNotifier;
  List<Widget>? _cachedWrappedItems;

  @override
  void didUpdateWidget(AppGlassMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.items, oldWidget.items)) {
      _cachedWrappedItems = null;
      if (widget.items.length < oldWidget.items.length) {
        _hoveredIndex = null;
        _hoveredIndexNotifier.value = null;
      }
    }
  }

  Alignment _morphAlignment = Alignment.topLeft;

  Alignment? _getAlignment(GlassMenuAlignment align) {
    switch (align) {
      case GlassMenuAlignment.none:
        return null;
      case GlassMenuAlignment.topLeft:
        return Alignment.topLeft;
      case GlassMenuAlignment.topCenter:
        return Alignment.topCenter;
      case GlassMenuAlignment.topRight:
        return Alignment.topRight;
      case GlassMenuAlignment.centerLeft:
        return Alignment.centerLeft;
      case GlassMenuAlignment.center:
        return Alignment.center;
      case GlassMenuAlignment.centerRight:
        return Alignment.centerRight;
      case GlassMenuAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case GlassMenuAlignment.bottomCenter:
        return Alignment.bottomCenter;
      case GlassMenuAlignment.bottomRight:
        return Alignment.bottomRight;
    }
  }

  @override
  void initState() {
    super.initState();
    _morphController = GlassMorphController(vsync: this);
    _morphController.addListener(() {
      if (mounted) setState(() {});

      if (_overlayController.isShowing &&
          _morphController.value <= 0.001 &&
          _morphController.velocity.abs() < 0.5 &&
          _morphController.status != AnimationStatus.forward) {
        _overlayController.hide();
        _horizontalOffset = 0.0;
        _verticalOffset = 0.0;
      }
    });
    _scrollController = ScrollController();
    _hoveredIndexNotifier = ValueNotifier(null);
    _isDraggingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _springTicker?.dispose();
    _morphController.dispose();
    _scrollController.dispose();
    _hoveredIndexNotifier.dispose();
    _isDraggingNotifier.dispose();
    super.dispose();
  }

  Offset _applyResistance(Offset offset, double resistance) {
    if (resistance == 0) return offset;
    final magnitude = math.sqrt(offset.dx * offset.dx + offset.dy * offset.dy);
    if (magnitude == 0) return Offset.zero;
    final resistedMagnitude = magnitude / (1 + magnitude * resistance);
    final scale = resistedMagnitude / magnitude;
    return Offset(offset.dx * scale, offset.dy * scale);
  }

  void _startSpringAnimation(Offset startOffset, Offset startVelocity) {
    _springTicker?.stop();
    _springTicker?.dispose();

    final springDesc = SpringDescription.withDurationAndBounce(
      duration: const Duration(milliseconds: 600),
      bounce: 0.4,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _morphController.setDisableAnimations(
      MediaQuery.of(context).disableAnimations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphController.animation,
      builder: (context, child) {
        final rawValue = _morphController.value;
        final isMenuBlocking = _overlayController.isShowing && rawValue > 0.8;
        final isHandoff =
            _morphController.isClosing && _morphController.hasHandedOff;
        final triggerOpacity = (_overlayController.isShowing && !isHandoff)
            ? 0.0
            : 1.0;

        final tw = _triggerSize?.width ?? 44.0;
        final th = _triggerSize?.height ?? 44.0;
        final menuWidth = widget.menuWidth;
        final menuHeight = _calculateMenuHeight();
        final dxMag = (menuWidth - tw) / 2.0;
        final dyMag = (menuHeight - th) / 2.0;
        final finalDx = -_morphAlignment.x * dxMag;
        final finalDy = -_morphAlignment.y * dyMag;

        final double pushDx = isHandoff
            ? (finalDx + _horizontalOffset) * rawValue
            : 0.0;
        final double pushDy = isHandoff
            ? (finalDy + _verticalOffset) * rawValue
            : 0.0;

        return Listener(
          onPointerDown: (event) {
            _springTicker?.stop();
            _rawDragOffset = Offset.zero;
            _stretchOffset = Offset.zero;
            _velocity = Offset.zero;
            _lastTimestamp = DateTime.now().microsecondsSinceEpoch;

            if (!_overlayController.isShowing) {
              _isGlobalDrag = true;
            } else {
              final renderBox = _menuBodyKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPosition = renderBox.globalToLocal(event.position);
                final visibleHeight = _calculateMenuHeight();
                final isInsideMenu = localPosition.dx >= 0 && localPosition.dx <= widget.menuWidth &&
                                     localPosition.dy >= 0 && localPosition.dy <= visibleHeight;
                if (!isInsideMenu) {
                  _isGlobalDrag = true;
                } else {
                  _isGlobalDrag = false;
                }
              } else {
                _isGlobalDrag = false;
              }
            }
          },
          onPointerMove: (event) {
            if (_isGlobalDrag) {
              final now = DateTime.now().microsecondsSinceEpoch;
              final dt = (now - _lastTimestamp) / Duration.microsecondsPerSecond;
              if (dt > 0) {
                _velocity = event.delta / dt;
              }
              _lastTimestamp = now;
              _rawDragOffset += event.delta;

              if (_rawDragOffset.distance > 4.0) {
                setState(() {
                  final proposedStretch = _applyResistance(_rawDragOffset, widget.stretchResistance) * widget.stretch;
                  final allowPosX = widget.allowPositiveX ?? (_morphAlignment.x < 0);
                  final allowNegX = widget.allowNegativeX ?? (_morphAlignment.x > 0);
                  final allowPosY = widget.allowPositiveY ?? (_morphAlignment.y < 0);
                  final allowNegY = widget.allowNegativeY ?? (_morphAlignment.y > 0);
                  
                  _stretchOffset = Offset(
                    (!allowPosX && proposedStretch.dx > 0) ? 0 : (!allowNegX && proposedStretch.dx < 0) ? 0 : proposedStretch.dx,
                    (!allowPosY && proposedStretch.dy > 0) ? 0 : (!allowNegY && proposedStretch.dy < 0) ? 0 : proposedStretch.dy,
                  );
                });
              }

              if (_overlayController.isShowing && _morphController.value > 0.1) {
                if (!_isDragging) {
                  _isDragging = true;
                  _isDraggingNotifier.value = true;
                  _initialLocalPosition = Offset.zero; 
                  _initialScrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                }
                
                final renderBox = _menuBodyKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localPosition = renderBox.globalToLocal(event.position);
                  _updateHoveredIndex(localPosition);
                }
              }
            }
          },
          onPointerUp: (event) {
            if (_isGlobalDrag) {
               _startSpringAnimation(_stretchOffset, _velocity);
            }
            if (_overlayController.isShowing && _isDragging && _isGlobalDrag) {
              final indexToTap = _hoveredIndex;
              if (indexToTap != null) {
                final item = widget.items[indexToTap];
                if (item is AppLiquidGlassMenuItem && item.enabled) {
                  item.onTap();
                  _closeMenu();
                } else if (item is GlassMenuItem && item.enabled) {
                  item.onTap();
                  _closeMenu();
                }
              }
              _isDragging = false;
              _isDraggingNotifier.value = false;
              _isGlobalDrag = false;
            } else {
               _isGlobalDrag = false;
            }
          },
          onPointerCancel: (event) {
             if (_isGlobalDrag) {
               _startSpringAnimation(_stretchOffset, _velocity);
             }
             _isGlobalDrag = false;
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.translate(
                offset: Offset(pushDx, pushDy),
                child: Opacity(
                  opacity: triggerOpacity,
                  child: IgnorePointer(
                    ignoring: isMenuBlocking,
                    child: widget.triggerBuilder != null
                        ? widget.triggerBuilder!(context, _toggleMenu)
                        : GestureDetector(
                            onTap: _toggleMenu,
                            onLongPress: _toggleMenu,
                            child: widget.trigger ?? const SizedBox.shrink(),
                          ),
                  ),
                ),
              ),
              OverlayPortal(
                controller: _overlayController,
                overlayChildBuilder: _buildMorphingOverlay,
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleMenu() {
    if (_overlayController.isShowing && _morphController.value > 0.1) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    _triggerSize = renderBox.size;
    _triggerBorderRadius = _triggerSize!.height / 2;
    _triggerGlobalPosition = renderBox.localToGlobal(Offset.zero);
    final position = _triggerGlobalPosition;
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? double.infinity;
    final screenHeight = mediaQuery?.size.height ?? double.infinity;

    final menuHeight = _calculateMenuHeight();

    if (widget.menuAlignment == null ||
        widget.menuAlignment == GlassMenuAlignment.none) {
      final isRightHalf = screenWidth.isFinite && position.dx > screenWidth / 2;
      final spaceBelow = screenHeight.isFinite
          ? screenHeight - (position.dy + _triggerSize!.height)
          : double.infinity;
      final spaceAbove = screenHeight.isFinite ? position.dy : double.infinity;

      final shouldFlipVertical =
          spaceBelow < menuHeight && spaceAbove > menuHeight;

      if (shouldFlipVertical) {
        _morphAlignment = isRightHalf
            ? Alignment.bottomRight
            : Alignment.bottomLeft;
      } else {
        _morphAlignment = isRightHalf ? Alignment.topRight : Alignment.topLeft;
      }
    } else {
      _morphAlignment =
          _getAlignment(widget.menuAlignment!) ?? Alignment.center;
    }

    double hOffset = 0.0;
    double vOffset = 0.0;

    if (widget.autoAdjustToScreen) {
      final flutterView = View.of(context);
      final mqPadding = EdgeInsets.fromViewPadding(
        flutterView.padding,
        flutterView.devicePixelRatio,
      );

      final double safeTop = widget.menuPadding.top + mqPadding.top;
      final double safeBottom = widget.menuPadding.bottom + mqPadding.bottom;
      final double safeLeft = widget.menuPadding.left + mqPadding.left;
      final double safeRight = widget.menuPadding.right + mqPadding.right;

      final double targetX =
          position.dx + (1 + _morphAlignment.x) * _triggerSize!.width / 2;
      final double targetY =
          position.dy + (1 + _morphAlignment.y) * _triggerSize!.height / 2;
      final double menuLeft =
          targetX - (1 + _morphAlignment.x) * widget.menuWidth / 2;
      final double menuTop = targetY - (1 + _morphAlignment.y) * menuHeight / 2;

      if (menuLeft < safeLeft) {
        hOffset = safeLeft - menuLeft;
      } else if (screenWidth.isFinite &&
          menuLeft + widget.menuWidth > screenWidth - safeRight) {
        hOffset = (screenWidth - safeRight) - (menuLeft + widget.menuWidth);
      }

      if (menuTop < safeTop) {
        vOffset = safeTop - menuTop;
      } else if (screenHeight.isFinite &&
          menuTop + menuHeight > screenHeight - safeBottom) {
        vOffset = (screenHeight - safeBottom) - (menuTop + menuHeight);
      }
    }

    setState(() {
      _horizontalOffset = hOffset;
      _verticalOffset = vOffset;
    });

    _overlayController.show();
    _morphController.open();
  }

  void _closeMenu() {
    setState(() {
      _hoveredIndex = null;
      _isDragging = false;
    });
    _morphController.close();
    widget.onClose?.call();
  }

  Widget _buildMorphingOverlay(BuildContext context) {
    if (_triggerSize == null) return const SizedBox.shrink();

    final rawValue = _morphController.value;
    final clampedValue = rawValue.clamp(0.0, 1.0);

    final tw = _triggerSize!.width;
    final th = _triggerSize!.height;
    final menuWidth = widget.menuWidth.toDouble();
    final menuHeight = _calculateMenuHeight();

    final dxMag = (menuWidth - tw) / 2.0;
    final dyMag = (menuHeight - th) / 2.0;
    final finalDx = -_morphAlignment.x * dxMag;
    final finalDy = -_morphAlignment.y * dyMag;

    final state = _morphController.computeState(
      finalDx: finalDx,
      finalDy: finalDy,
      horizontalOffset: _horizontalOffset,
      verticalOffset: _verticalOffset,
    );

    final targetHeight = widget.menuHeight ?? menuHeight;
    final currentHeight = lerpDouble(th, targetHeight, state.sizeT)!;
    final currentWidth = lerpDouble(tw, widget.menuWidth, state.sizeT)!;

    final inheritedSettings = InheritedLiquidGlass.of(context);
    final effectiveSettings =
        widget.glassSettings ??
        inheritedSettings ??
        const LiquidGlassSettings(
          blur: 10,
          thickness: 10,
          glassColor: Color.fromRGBO(255, 255, 255, 0.12),
          lightAngle: GlassDefaults.lightAngle,
          lightIntensity: 0.7,
          ambientStrength: 0.4,
          saturation: 1.2,
          refractiveIndex: 0.7,
          chromaticAberration: 0.0,
        );

    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    // CRITICAL FIX: Wrapped the overlay root in SizedBox.expand to prevent
    // loose layout constraints from collapsing the Stack to 0x0 size.
    // This resolves the vertical clipping cut-off on the right edge.
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (clampedValue > 0.3)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
                child: Container(color: Colors.black.withValues(alpha: 0.0)),
              ),
            ),
          Positioned.fill(
            child: Opacity(
              opacity:
                  (_morphController.isClosing && _morphController.hasHandedOff)
                  ? 0.0
                  : 1.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blob A: Trigger Ghost
                  Positioned(
                    left: _triggerGlobalPosition.dx + state.pushDx,
                    top: _triggerGlobalPosition.dy + state.pushDy,
                    child: Transform.scale(
                      scale: state.anchorScale,
                      child: GlassContainer(
                        useOwnLayer: true,
                        settings: effectiveSettings,
                        quality: effectiveQuality,
                        width: tw,
                        height: th,
                        shape: LiquidRoundedSuperellipse(
                          borderRadius:
                              _triggerBorderRadius ??
                              _triggerSize!.shortestSide / 2.0,
                        ),
                      ),
                    ),
                  ),

                  // Blob B: Menu Body
                  Positioned(
                    left:
                        _triggerGlobalPosition.dx +
                        tw / 2.0 +
                        state.currentDx -
                        currentWidth / 2.0 +
                        (_horizontalOffset * clampedValue),
                    top:
                        _triggerGlobalPosition.dy +
                        th / 2.0 +
                        state.currentDy -
                        currentHeight / 2.0 +
                        (_verticalOffset * clampedValue),
                    child: IgnorePointer(
                      ignoring: clampedValue < 0.8,
                      child: _buildMorphingContainer(
                        state,
                        clampedValue,
                        currentWidth,
                        currentHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMenuHeight() {
    if (widget.menuHeight != null) {
      return widget.menuHeight!;
    }

    final itemHeights = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + _getItemHeight(item),
    );

    final gaps = (widget.items.length - 1) * 2.0;
    final naturalHeight = itemHeights + 24.0 + gaps;

    if (widget.autoAdjustToScreen) {
      final mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery != null) {
        final flutterView = View.of(context);
        final mqPadding = EdgeInsets.fromViewPadding(
          flutterView.padding,
          flutterView.devicePixelRatio,
        );

        final maxHeight =
            mediaQuery.size.height -
            mqPadding.vertical -
            widget.menuPadding.vertical -
            20.0;
        return math.min(naturalHeight, math.max(0.0, maxHeight));
      }
    }

    return naturalHeight;
  }

  Widget _buildMorphingContainer(
    LiquidMorphState state,
    double clampedValue,
    double currentWidth,
    double currentHeight,
  ) {
    final isDark = AppColors.isDark(context);
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    final maxRadius = math.min(currentWidth, currentHeight) / 2.0;
    final double radiusT = Curves.easeInExpo.transform(
      state.sizeT.clamp(0.0, 1.0),
    );
    final currentRadius = lerpDouble(
      maxRadius,
      widget.menuBorderRadius,
      radiusT,
    )!;

    final teardropShape = LiquidRoundedSuperellipse(
      borderRadius: currentRadius,
    );

    final containerScale = state.containerScale;
    final inheritedSettings = InheritedLiquidGlass.of(context);
    final effectiveSettings =
        widget.glassSettings ??
        inheritedSettings ??
        const LiquidGlassSettings(
          blur: 10,
          thickness: 10,
          glassColor: Color.fromRGBO(255, 255, 255, 0.12),
          lightAngle: GlassDefaults.lightAngle,
          lightIntensity: 0.7,
          ambientStrength: 0.4,
          saturation: 1.2,
          refractiveIndex: 0.7,
          chromaticAberration: 0.0,
        );

    final glassContent = RawLiquidStretch(
      stretchPixels: _stretchOffset,
      axis: widget.stretchAxis,
      child: GlassContainer(
        useOwnLayer: true,
        settings: effectiveSettings,
        quality: effectiveQuality,
        allowElevation: false,
        width: currentWidth,
        height: currentHeight,
        shape: teardropShape,
        clipBehavior: Clip.antiAlias,
        glowIntensity: widget.glowIntensity,
        child: Container(
          decoration: isDark
              ? ShapeDecoration(
                  shape: teardropShape.copyWith(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.09),
                      width: 1.2,
                    ),
                  ),
                )
              : null,
          child: GlassGlow(
            enabled: widget.enableInteractionGlow,
            glowOnTapOnly: widget.glowOnTapOnly,
            glowColor: widget.glowColor ?? Colors.white.withValues(alpha: 0.15),
            glowRadius: widget.glowRadius,
            glowBlurRadius: 40,
            clipper: ShapeBorderClipper(shape: teardropShape),
            child: Transform.scale(
              scale: containerScale,
              alignment: Alignment.center,
              child: Stack(
                key: _menuBodyKey,
                alignment: _morphAlignment,
                clipBehavior: Clip.none,
                children: [
                  if (clampedValue > 0.94)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ValueListenableBuilder<int?>(
                          valueListenable: _hoveredIndexNotifier,
                          builder: (context, hoveredIndex, _) {
                            if (hoveredIndex == null) {
                              return const SizedBox.shrink();
                            }
                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOutCubic,
                              left: 12,
                              right: 12,
                              top:
                                  _getItemOffset(hoveredIndex) -
                                  (_scrollController.hasClients
                                      ? _scrollController.offset
                                      : 0.0),
                              height: _getItemHeight(
                                widget.items[hoveredIndex],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.selectionColor,
                                  borderRadius: BorderRadius.circular(
                                    widget.itemBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: const Color(0x0DFFFFFF),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Listener(
                          onPointerDown: (event) {
                            _isDragging = true;
                            _isDraggingNotifier.value = true;
                            _hasStretched = false;
                            _initialLocalPosition = event.localPosition;
                            _initialScrollOffset = _scrollController.hasClients
                                ? _scrollController.offset
                                : 0.0;
                            _updateHoveredIndex(event.localPosition);
                          },
                          onPointerMove: (event) {
                            if (_isDragging) {
                              _updateHoveredIndex(event.localPosition);
                            }
                          },
                          onPointerUp: (event) {
                            if (_isDragging) {
                              final currentOffset = _scrollController.hasClients
                                  ? _scrollController.offset
                                  : 0.0;
                              final scrollDisplacement =
                                  (currentOffset - _initialScrollOffset).abs();
                              final dragDisplacement =
                                  (event.localPosition - _initialLocalPosition)
                                      .distance;

                              if (scrollDisplacement < 10 &&
                                  dragDisplacement < 10 &&
                                  !_isScrollable) {
                                final indexToTap =
                                    _hoveredIndex ??
                                    _calculateIndexFromPosition(
                                      event.localPosition,
                                    );
                                if (indexToTap != null) {
                                  final item = widget.items[indexToTap];
                                  if (item is AppLiquidGlassMenuItem &&
                                      item.enabled) {
                                    item.onTap();
                                    _closeMenu();
                                  } else if (item is GlassMenuItem &&
                                      item.enabled) {
                                    item.onTap();
                                    _closeMenu();
                                  }
                                }
                              }
                              _isDragging = false;
                              _isDraggingNotifier.value = false;
                              _hoveredIndex = null;
                              _hoveredIndexNotifier.value = null;
                              _hasStretched = false;
                            }
                          },
                          onPointerCancel: (_) {
                            _isDragging = false;
                            _isDraggingNotifier.value = false;
                            _hoveredIndex = null;
                            _hoveredIndexNotifier.value = null;
                          },
                          child: SizedBox(
                            width: currentWidth,
                            height: widget.menuHeight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 12),
                                    ..._buildWrappedItems()
                                        .asMap()
                                        .entries
                                        .expand((entry) {
                                          final itemOpacity =
                                              ((clampedValue - 0.5) / 0.5)
                                                  .clamp(0.0, 1.0);
                                          return [
                                            Opacity(
                                              opacity: itemOpacity,
                                              child: entry.value,
                                            ),
                                            if (entry.key <
                                                widget.items.length - 1)
                                              const SizedBox(height: 2),
                                          ];
                                        }),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return glassContent;
  }

  List<Widget> _buildWrappedItems() {
    return _cachedWrappedItems ??= widget.items.asMap().entries.map((entry) {
      final item = entry.value;

      if (item is AppLiquidGlassMenuItem) {
        return _SelectionItemWrapper(
          index: entry.key,
          hoverNotifier: _hoveredIndexNotifier,
          dragNotifier: _isDraggingNotifier,
          builder: (context, isSelected, isPressed) {
            return item.copyWith(isSelected: isSelected, isPressed: isPressed);
          },
        );
      }

      if (item is GlassMenuItem) {
        return _SelectionItemWrapper(
          index: entry.key,
          hoverNotifier: _hoveredIndexNotifier,
          dragNotifier: _isDraggingNotifier,
          builder: (context, isSelected, isPressed) {
            return GlassMenuItem(
              key: item.key ?? ValueKey(item.title),
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              isDestructive: item.isDestructive,
              enabled: item.enabled,
              trailing: item.trailing,
              height: item.height,
              titleStyle: item.titleStyle,
              subtitleStyle: item.subtitleStyle,
              iconColor: item.iconColor,
              iconSize: item.iconSize,
              isSelected: isSelected,
              isPressed: isPressed,
              onTap: () {
                if (_isScrollable && item.enabled) {
                  item.onTap();
                  _closeMenu();
                }
              },
            );
          },
        );
      }
      return item;
    }).toList();
  }

  bool get _isScrollable {
    final visibleHeight = _calculateMenuHeight();
    final itemHeights = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + _getItemHeight(item),
    );
    final gaps = (widget.items.length - 1) * 2.0;
    final naturalHeight = itemHeights + 24.0 + gaps;
    return widget.menuHeight != null || visibleHeight < naturalHeight - 1.0;
  }

  double _getItemHeight(Widget item) {
    if (item is AppLiquidGlassMenuItem) return item.height;
    if (item is GlassMenuItem) return item.height;
    if (item is AppLiquidGlassMenuDivider) return item.height;
    if (item is GlassMenuDivider) return item.height;
    if (item is GlassMenuLabel) return item.height;
    return 44.0;
  }

  double _getItemOffset(int index) {
    double offset = 12.0;
    for (int i = 0; i < index; i++) {
      offset += _getItemHeight(widget.items[i]) + 2.0;
    }
    return offset;
  }

  int? _calculateIndexFromPosition(Offset localPosition) {
    final visibleHeight = _calculateMenuHeight();
    final x = localPosition.dx;
    final dy = localPosition.dy;
    final y =
        dy + (_scrollController.hasClients ? _scrollController.offset : 0.0);

    final isWithinActiveZone =
        x > -20 &&
        x < widget.menuWidth + 20 &&
        dy > -20 &&
        dy < visibleHeight + 20;

    if (!isWithinActiveZone) return null;

    double currentOffset = 12.0;
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final itemHeight = _getItemHeight(item);

      if (y >= currentOffset && y <= currentOffset + itemHeight) {
        if (item is AppLiquidGlassMenuItem && item.enabled) {
          return i;
        }
        if (item is GlassMenuItem && item.enabled) {
          return i;
        }
        break;
      }
      currentOffset += itemHeight + 2.0;
    }
    return null;
  }

  void _updateHoveredIndex(Offset localPosition) {
    final visibleHeight = _calculateMenuHeight();
    final x = localPosition.dx;
    final dy = localPosition.dy;

    final outsideBounds =
        dy < -100 ||
        dy > visibleHeight + 100 ||
        x < -100 ||
        x > widget.menuWidth + 100;

    if (_hasStretched != outsideBounds) {
      setState(() => _hasStretched = outsideBounds);
    }

    int? detectedIndex;
    if (!_isScrollable) {
      detectedIndex = _calculateIndexFromPosition(localPosition);
    }

    _hoveredIndex = detectedIndex;
    _hoveredIndexNotifier.value = detectedIndex;
  }
}

class _SelectionItemWrapper extends StatelessWidget {
  final int index;
  final ValueNotifier<int?> hoverNotifier;
  final ValueNotifier<bool> dragNotifier;
  final Widget Function(BuildContext context, bool isSelected, bool isPressed)
  builder;

  const _SelectionItemWrapper({
    required this.index,
    required this.hoverNotifier,
    required this.dragNotifier,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: hoverNotifier,
      builder: (context, hoveredIndex, _) {
        final isSelected = hoveredIndex == index;
        return ValueListenableBuilder<bool>(
          valueListenable: dragNotifier,
          builder: (context, isDragging, _) {
            return builder(context, isSelected, isDragging && isSelected);
          },
        );
      },
    );
  }
}
