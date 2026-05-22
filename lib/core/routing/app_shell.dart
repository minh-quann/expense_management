import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_cupertino_symbols/flutter_cupertino_symbols.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';

/// Creates a jelly transform matrix based on velocity for organic squash & stretch
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

  // Squash in movement direction, stretch perpendicular
  final squashX = 1.0 - (direction.dx.abs() * distortionFactor * 0.5);
  final squashY = 1.0 - (direction.dy.abs() * distortionFactor * 0.5);
  final stretchX = 1.0 + (direction.dy.abs() * distortionFactor * 0.3);
  final stretchY = 1.0 + (direction.dx.abs() * distortionFactor * 0.3);

  final matrix = Matrix4.identity();
  matrix.storage[0] = squashX * stretchX; // scaleX
  matrix.storage[5] = squashY * stretchY; // scaleY
  return matrix;
}

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final userId = AuthTokenManager.getUserId();
    if (userId.isNotEmpty) {
      context.read<WalletBloc>().add(LoadWalletsEvent(userId));
      context.read<TransactionBloc>().add(LoadTransactions(userId));
    }
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final userId = AuthTokenManager.getUserId();

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded && userId.isNotEmpty) {
          context.read<WalletBloc>().add(LoadWalletsEvent(userId));
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            widget.navigationShell,

            // Floating Navigation Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  refractiveIndex: 1.21,
                  thickness: 30,
                  blur: 10,
                  saturation: 1.5,
                  lightIntensity: isDark ? 0.7 : 1.0,
                  ambientStrength: isDark ? 0.2 : 0.5,
                  lightAngle: math.pi / 4,
                  glassColor: isDark
                      ? const Color(0xFF2C2C2E).withValues(alpha: 0.45)
                      : const Color(0xFFF8F8F8).withValues(alpha: 0.45),
                ),
                child: SizedBox(
                  height: 64,
                  child: LiquidGlassBlendGroup(
                    blend: 10,
                    child: _PillTabIndicator(
                      tabIndex: widget.navigationShell.currentIndex,
                      tabCount: 5, // 4 nav + 1 add button
                      addButtonIndex: 2,
                      isDark: isDark,
                      onTabChanged: (index) => _onTap(context, index),
                      child: LiquidGlass.grouped(
                        clipBehavior: Clip.none,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 100,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildNavItem(
                                context,
                                0,
                                SFSymbols.house,
                                SFSymbols.house_fill,
                                AppLocalizations.of(context)!.nav_home,
                              ),
                              _buildNavItem(
                                context,
                                1,
                                SFSymbols.list_clipboard,
                                SFSymbols.list_clipboard_fill,
                                AppLocalizations.of(
                                  context,
                                )!.nav_transactions,
                              ),
                              _buildAddItem(context, isDark),
                              _buildNavItem(
                                context,
                                2,
                                SFSymbols.chart_bar,
                                SFSymbols.chart_bar_fill,
                                AppLocalizations.of(context)!.nav_stats,
                              ),
                              _buildNavItem(
                                context,
                                3,
                                SFSymbols.person,
                                SFSymbols.person_fill,
                                AppLocalizations.of(context)!.nav_account,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Center "add" button
  Widget _buildAddItem(BuildContext context, bool isDark) {
    final color = isDark ? const Color(0xFF8E8E93) : const Color(0xFF3C3C43);

    return Expanded(
      child: GestureDetector(
        onTap: () => context.push('/add-transaction'),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(SFSymbols.plus_circle, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                'Thêm',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final isDark = AppColors.isDark(context);
    final color = isSelected
        ? AppColors.primary
        : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF3C3C43));

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill indicator widget — follows official example pattern
// ---------------------------------------------------------------------------

class _PillTabIndicator extends StatefulWidget {
  const _PillTabIndicator({
    required this.tabIndex,
    required this.tabCount,
    required this.addButtonIndex,
    required this.isDark,
    required this.child,
    required this.onTabChanged,
  });

  final int tabIndex;
  final int tabCount;
  final int addButtonIndex;
  final bool isDark;
  final Widget child;
  final ValueChanged<int> onTabChanged;

  @override
  State<_PillTabIndicator> createState() => _PillTabIndicatorState();
}

class _PillTabIndicatorState extends State<_PillTabIndicator> {
  late double xAlign;
  bool _isDown = false;
  bool _isDragging = false;

  /// Map navigation index (0-3) to slot position (0-4, skipping addButton)
  double _computeXAlign(int navIndex) {
    final slot = navIndex < widget.addButtonIndex ? navIndex : navIndex + 1;
    // Convert slot to alignment range -1..1
    final fraction = slot / (widget.tabCount - 1);
    return (fraction * 2) - 1;
  }

  /// Convert slot index (0-4) to nav index (0-3), skipping addButton slot
  int _slotToNavIndex(int slot) {
    if (slot < widget.addButtonIndex) return slot;
    if (slot > widget.addButtonIndex) return slot - 1;
    // If landing on addButton slot, snap to nearest valid nav
    return slot < widget.tabCount ~/ 2 ? slot : slot - 1;
  }

  @override
  void initState() {
    super.initState();
    xAlign = _computeXAlign(widget.tabIndex);
  }

  @override
  void didUpdateWidget(covariant _PillTabIndicator oldWidget) {
    if (oldWidget.tabIndex != widget.tabIndex) {
      setState(() {
        xAlign = _computeXAlign(widget.tabIndex);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  // --- Drag gesture handling (follows official example) ---

  double _getAlignmentFromGlobalPosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);

    // Calculate draggable range accounting for indicator width
    final indicatorWidth = 1.0 / widget.tabCount;
    final draggableRange = 1.0 - indicatorWidth;
    final padding = indicatorWidth / 2;

    final rawRelativeX = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    final normalizedX = (rawRelativeX - padding) / draggableRange;

    // Apply rubber band resistance for overdrag
    final adjustedX = _applyRubberBandResistance(normalizedX);
    return (adjustedX * 2) - 1; // Convert to -1..1 range
  }

  /// Apply rubber band resistance similar to iOS scroll views
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
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _isDown = false;
    });

    final box = context.findRenderObject() as RenderBox;
    final currentRelativeX = (xAlign + 1) / 2; // Convert from -1..1 to 0..1
    final tabWidth = 1.0 / widget.tabCount;

    // Calculate velocity in relative units
    final indicatorWidth = 1.0 / widget.tabCount;
    final draggableRange = 1.0 - indicatorWidth;
    final velocityX =
        (details.velocity.pixelsPerSecond.dx / box.size.width) / draggableRange;

    int targetSlot;

    // Handle overdrag scenarios
    if (currentRelativeX < 0) {
      targetSlot = 0;
    } else if (currentRelativeX > 1) {
      targetSlot = widget.tabCount - 1;
    } else {
      const velocityThreshold = 0.5;
      if (velocityX.abs() > velocityThreshold) {
        // High velocity — project position
        final projectedX =
            (currentRelativeX + velocityX * 0.3).clamp(0.0, 1.0);
        targetSlot = (projectedX / tabWidth)
            .round()
            .clamp(0, widget.tabCount - 1);
      } else {
        // Low velocity — snap to nearest slot
        targetSlot = (currentRelativeX / tabWidth)
            .round()
            .clamp(0, widget.tabCount - 1);
      }
    }

    // Skip the addButton slot
    if (targetSlot == widget.addButtonIndex) {
      // Snap to the nearest valid slot (left or right of addButton)
      final leftSlot = widget.addButtonIndex - 1;
      final rightSlot = widget.addButtonIndex + 1;
      final leftAlign = (leftSlot / (widget.tabCount - 1)) * 2 - 1;
      final rightAlign = (rightSlot / (widget.tabCount - 1)) * 2 - 1;
      targetSlot = (xAlign - leftAlign).abs() <= (xAlign - rightAlign).abs()
          ? leftSlot
          : rightSlot;
    }

    final navIndex = _slotToNavIndex(targetSlot);
    xAlign = _computeXAlign(navIndex);

    if (navIndex != widget.tabIndex) {
      widget.onTabChanged(navIndex);
    }
  }

  void _onDragCancel() {
    setState(() {
      _isDragging = false;
      _isDown = false;
      // Snap back to current tab
      xAlign = _computeXAlign(widget.tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final targetAlignment = _computeXAlign(widget.tabIndex);

    return GestureDetector(
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

          return SingleMotionBuilder(
            motion: const Motion.snappySpring(
              snapToEnd: true,
              duration: Duration(milliseconds: 300),
            ),
            // thickness = 1 when pill is actively pressed or moving
            value: _isDown || (alignment.x - targetAlignment).abs() > 0.05
                ? 1.0
                : 0.0,
            builder: (context, thickness, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Normal state pill (visible when thickness < 1)
                  if (thickness < 1)
                    _IndicatorTransform(
                      velocity: velocity,
                      tabCount: widget.tabCount,
                      alignment: alignment,
                      thickness: thickness,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: thickness <= 0.2 ? 1 : 0,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: indicatorColor,
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  // Child (the bar) in between
                  child!,
                  // Active glass pill (visible when thickness > 0)
                  if (thickness > 0)
                    _IndicatorTransform(
                      velocity: velocity,
                      tabCount: widget.tabCount,
                      alignment: alignment,
                      thickness: thickness,
                      child: LiquidGlass.withOwnLayer(
                        settings: LiquidGlassSettings(
                          visibility: thickness,
                          glassColor: const Color.fromARGB(25, 255, 255, 255),
                          saturation: 1.5,
                          refractiveIndex: 1.15,
                          thickness: 20,
                          lightIntensity: 2,
                          chromaticAberration: 0.5,
                          blur: 0,
                        ),
                        shape: const LiquidRoundedSuperellipse(borderRadius: 64),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              );
            },
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill transform — handles expand + jelly distortion
// ---------------------------------------------------------------------------

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
    // Expand pill outward when active (14px each side like official example)
    final rect = RelativeRect.lerp(
      RelativeRect.fill,
      const RelativeRect.fromLTRB(-14, -14, -14, -14),
      thickness,
    );

    return Positioned.fill(
      left: 4,
      right: 4,
      top: 4,
      bottom: 4,
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
                builder: (context, vel, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: _buildJellyTransform(
                      velocity: Offset(vel, 0),
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
