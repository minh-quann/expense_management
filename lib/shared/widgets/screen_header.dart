import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:motor/motor.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/liquid_glass/app_liquid_glass_button.dart';
import 'package:expense_management/core/utils/app_settings_manager.dart';

/// Reusable screen header widget used across the entire app.
///
/// Supports two modes:
/// 1. **Tab screen header**: Pass [leading] and/or [trailing] widgets.
///    If [leading] is null, a placeholder is shown to keep the title centered.
/// 2. **Sub-screen header (with back button)**: Set [showBackButton] = true.
///    The back button uses [onBack] or defaults to Navigator.pop.
class ScreenHeader extends StatefulWidget {
  final String title;

  /// Custom leading widget (e.g. grid icon button).
  /// If null and [showBackButton] is false, an invisible placeholder is used.
  final Widget? leading;

  /// Custom trailing widget (e.g. notification icon, filter icon).
  /// If null, an invisible placeholder is used.
  final Widget? trailing;

  /// If true, shows a back arrow button as the leading widget.
  /// Overrides the [leading] widget.
  final bool showBackButton;

  /// Callback when the back button is tapped. Defaults to Navigator.pop.
  final VoidCallback? onBack;

  /// Custom padding. Defaults to horizontal: 24, vertical: 16.
  /// Set to EdgeInsets.zero when header is inside a padded parent.
  final EdgeInsetsGeometry? padding;

  final bool useLiquidGlassTitle;

  /// Callback when the title is tapped.
  final VoidCallback? onTitleTap;

  /// Callback when search query changes. If provided and [trailing] is null,
  /// an expandable search bar will be shown on the right side.
  final ValueChanged<String>? onSearchChanged;

  /// Placeholder text for the search input.
  final String? searchPlaceholder;

  const ScreenHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.showBackButton = false,
    this.onBack,
    this.padding,
    this.useLiquidGlassTitle = true,
    this.onTitleTap,
    this.onSearchChanged,
    this.searchPlaceholder,
  });

  /// Factory for building a circular icon button matching the app's nav bar style.
  /// Use this for consistent icon buttons in headers across all screens.
  static Widget circleButton({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool useOwnLayer = true,
  }) {
    return AppLiquidGlassButton(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius:
          22.0, // Match search bar border radius to prevent geometry shape changes in GPU shaders
      padding: EdgeInsets.zero,
      width: 44,
      height: 44,
      useOwnLayer: useOwnLayer,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: FittedBox(fit: BoxFit.contain, child: child),
          ),
        ),
      ),
    );
  }

  @override
  State<ScreenHeader> createState() => _ScreenHeaderState();
}

class _ScreenHeaderState extends State<ScreenHeader> {
  bool _isSearching = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSearchContent(BuildContext context, double progress) {
    return Stack(
      children: [
        // Smoothly transition search icon size, opacity, and position to prevent flickering
        Positioned(
          left: 10.0 + (4.0 * progress),
          top: (44.0 - (24.0 - 4.0 * progress)) / 2,
          child: Icon(
            Icons.search_rounded,
            color: AppColors.textPrimary(context).withValues(
              alpha: 1.0 - (0.4 * progress), // from 1.0 to 0.6
            ),
            size: 24.0 - (4.0 * progress), // from 24 to 20
          ),
        ),
        if (progress > 0.1)
          Positioned(
            left: 42.0,
            right: 16.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: ((progress - 0.1) / 0.9).clamp(0.0, 1.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchPlaceholder ?? 'Tìm kiếm...',
                    hintStyle: TextStyle(
                      color: AppColors.textPrimary(context).withValues(alpha: 0.4),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettingsManager.disableLiquidGlassNotifier,
      builder: (context, disableLiquidGlass, _) {
        final isDark = AppColors.isDark(context);

        // Default translucent glass colors matching system theme
        final defaultGlassColor = isDark
            ? const Color(0xFFD0D5DD).withValues(alpha: 0.10)
            : const Color(0xFFF8F8F8).withValues(alpha: 0.45);

        // Determine leading widget
        Widget leadingWidget;
        if (widget.showBackButton) {
          leadingWidget = ScreenHeader.circleButton(
            context: context,
            onTap: widget.onBack ?? () => Navigator.pop(context),
            useOwnLayer:
                true, // Use own glass layer to ensure background renders correctly under transition animations
            child: Icon(
              CupertinoIcons.chevron_back,
              color: AppColors.textPrimary(context),
              size: 22,
            ),
          );
        } else {
          // Use provided leading or a transparent placeholder to keep title centered
          leadingWidget = widget.leading ?? const SizedBox(width: 44);
        }

        Widget titleWidget = AppText(
          widget.title,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary(context),
        );

        if (widget.useLiquidGlassTitle) {
          titleWidget = AppLiquidGlassButton(
            onTap: widget.onTitleTap ?? () {},
            borderRadius: 100.0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            autoSize:
                true, // Enable IntrinsicWidth and IntrinsicHeight inside the button
            useOwnLayer: false, // Grouped mode to blend with search bar
            child: titleWidget,
          );
        }

        final width = MediaQuery.of(context).size.width;
        final paddingHorizontal =
            widget.padding?.horizontal ??
            48.0; // horizontal is 24 on each side by default, so 48 total
        final availableWidth = width - paddingHorizontal;

        // Determine trailing/search widget
        Widget searchOrTrailingWidget;
        if (widget.onSearchChanged != null && widget.trailing == null) {
          searchOrTrailingWidget = VelocityMotionBuilder(
            converter: SingleMotionConverter(),
            motion: const Motion.snappySpring(
              snapToEnd: true,
              duration: Duration(milliseconds: 350),
            ),
            value: _isSearching ? availableWidth : 44.0,
            builder: (context, animWidth, velocity, _) {
              // Calculate vertical squash and stretch deformation based on velocity
              final double velocityDouble = velocity;
              final distortion = (velocityDouble / 1500.0).clamp(-0.2, 0.2);
              final double scaleY = 1.0 - distortion;

              // Clamp width to prevent it from expanding beyond the available width
              final double clampedWidth = animWidth.clamp(44.0, availableWidth);

              // Check if we are currently searching or animating to avoid overlapping shader layers
              final isAnimatingOrSearching = _isSearching || clampedWidth > 44.5;
              final double range = availableWidth - 44.0;
              final double progress = range > 0
                  ? ((clampedWidth - 44.0) / range).clamp(0.0, 1.0)
                  : 0.0;

              return Transform(
                alignment: Alignment.centerRight,
                transform: Matrix4.diagonal3Values(1.0, scaleY, 1.0),
                child: SizedBox(
                  width: clampedWidth,
                  height: 44,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Expandable Search Bar content - active during search or transition animation
                      if (isAnimatingOrSearching)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          right: 54.0 * progress,
                          child: ClipRect(
                            child: disableLiquidGlass
                                ? Container(
                                    decoration: ShapeDecoration(
                                      color: isDark
                                          ? const Color(0xFF1C1C1E).withValues(alpha: 0.88)
                                          : const Color(0xFFF2F2F7).withValues(alpha: 0.92),
                                      shape: const RoundedSuperellipseBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                        side: BorderSide(color: Color(0x17FFFFFF), width: 1),
                                      ),
                                    ),
                                    child: ClipPath(
                                      clipper: const ShapeBorderClipper(
                                        shape: RoundedSuperellipseBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(22.0)),
                                        ),
                                      ),
                                      child: _buildSearchContent(context, progress),
                                    ),
                                  )
                                : LiquidGlassLayer(
                                    settings: LiquidGlassSettings(
                                      refractiveIndex: 1.15,
                                      thickness: 15.0,
                                      blur: 8.0,
                                      saturation: 1.5,
                                      lightIntensity: isDark ? 0.0 : 1.0,
                                      ambientStrength: isDark ? 0.0 : 0.5,
                                      lightAngle: math.pi / 4,
                                      glassColor: defaultGlassColor,
                                    ),
                                    child: LiquidGlass.grouped(
                                      shape: const LiquidRoundedSuperellipse(
                                        borderRadius: 22.0,
                                      ),
                                      child: _buildSearchContent(context, progress),
                                    ),
                                  ),
                          ),
                        ),

                      // 2. Separate Cancel Button on the right
                      if (progress > 0.2)
                        Positioned(
                          right: 0,
                          width: 44,
                          height: 44,
                          child: Opacity(
                            opacity: ((progress - 0.2) / 0.8).clamp(0.0, 1.0),
                            child: ScreenHeader.circleButton(
                              context: context,
                              onTap: () {
                                _searchFocusNode.unfocus();
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                  widget.onSearchChanged?.call('');
                                });
                              },
                              useOwnLayer: true,
                              child: Icon(
                                CupertinoIcons.xmark,
                                color: AppColors.textPrimary(context),
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                      // 3. Circular Search Button - only active when fully collapsed
                      if (!isAnimatingOrSearching)
                        Positioned(
                          right: 0,
                          width: 44,
                          height: 44,
                          child: ScreenHeader.circleButton(
                            context: context,
                            onTap: () {
                              setState(() {
                                _isSearching = true;
                              });
                              // Delayed keyboard focus prevents frame drops during expansion animation
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (_isSearching && mounted) {
                                  _searchFocusNode.requestFocus();
                                }
                              });
                            },
                            useOwnLayer:
                                true, // Use own glass layer to ensure background renders correctly outside layout builder context
                            child: Icon(
                              Icons.search_rounded,
                              color: AppColors.textPrimary(context),
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          searchOrTrailingWidget = widget.trailing ?? const SizedBox(width: 44);
        }

        // Create a shared settings for the entire header glass layer
        final sharedSettings = lgw.LiquidGlassSettings(
          refractiveIndex: 1.15,
          thickness: 15.0,
          blur: 8.0,
          saturation: 1.5,
          lightIntensity: isDark ? 0.0 : 1.0,
          ambientStrength: isDark ? 0.0 : 0.5,
          lightAngle: math.pi / 4,
          glassColor: defaultGlassColor,
        );

        Widget headerContent = Stack(
          alignment: Alignment.center,
          children: [
            // Leading widget (scales down and fades out during search)
            Positioned(
              left: 0,
              child: AnimatedScale(
                scale: _isSearching ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _isSearching ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isSearching,
                    child: leadingWidget,
                  ),
                ),
              ),
            ),

            // Title widget (scales down and fades out during search)
            AnimatedScale(
              scale: _isSearching ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isSearching ? 0.0 : 1.0,
                child: IgnorePointer(ignoring: _isSearching, child: titleWidget),
              ),
            ),

            // Trailing / Search widget (expanding from right to left)
            Positioned(right: 0, child: searchOrTrailingWidget),
          ],
        );

        // Wrap the entire header content with a shared AdaptiveLiquidGlassLayer and LiquidGlassBlendGroup
        return SizedBox(
          width: double.infinity,
          height: 64,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
            child: disableLiquidGlass
                ? headerContent
                : lgw.AdaptiveLiquidGlassLayer(
                    settings: sharedSettings,
                    blendAmount: 14.0, // High blend radius for organic liquid merging
                    child: lgw.LiquidGlassBlendGroup(blend: 14.0, child: headerContent),
                  ),
          ),
        );
      },
    );
  }
}
