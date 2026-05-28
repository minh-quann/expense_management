import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:motor/motor.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_liquid_glass.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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
  }) {
    return AppLiquidGlassButton(
      onTap: onTap,
      borderRadius: 100, // High border radius to achieve a circle shape using superellipse
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: FittedBox(
              fit: BoxFit.contain,
              child: child,
            ),
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine leading widget
    Widget leadingWidget;
    if (widget.showBackButton) {
      leadingWidget = ScreenHeader.circleButton(
        context: context,
        onTap: widget.onBack ?? () => Navigator.pop(context),
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
      titleWidget = AppLiquidGlass(
        borderRadius: 100.0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        refractiveIndex: 1.15,
        thickness: 20,
        blur: 8,
        showGlow: true,
        child: titleWidget,
      );

      // Always wrap with GestureDetector and LiquidStretch for interactivity feedback (spring stretch effect)
      titleWidget = GestureDetector(
        onTap: widget.onTitleTap ?? () {},
        behavior: HitTestBehavior.opaque,
        child: LiquidStretch(
          interactionScale: 1.2,
          stretch: 0.3,
          resistance: 0.08,
          child: titleWidget,
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final paddingHorizontal = widget.padding?.horizontal ?? 48.0; // horizontal is 24 on each side by default, so 48 total
    final availableWidth = width - paddingHorizontal;

    // Determine trailing/search widget
    Widget searchOrTrailingWidget;
    if (widget.onSearchChanged != null && widget.trailing == null) {
      searchOrTrailingWidget = VelocityMotionBuilder(
        converter: SingleMotionConverter(),
        motion: const Motion.bouncySpring(
          snapToEnd: true,
        ),
        value: _isSearching ? availableWidth : 44.0,
        builder: (context, animWidth, velocity, childWidget) {
          // Calculate vertical squash and stretch deformation based on velocity
          final double velocityDouble = velocity;
          final distortion = (velocityDouble / 1500.0).clamp(-0.2, 0.2);
          final double scaleY = 1.0 - distortion;

          // Clamp width to prevent it from expanding beyond the 24px screen margin and losing border radius
          final double clampedWidth = animWidth.clamp(0.0, availableWidth);

          return Transform(
            alignment: Alignment.centerRight,
            transform: Matrix4.diagonal3Values(1.0, scaleY, 1.0),
            child: SizedBox(
              width: clampedWidth,
              height: 44,
              child: childWidget,
            ),
          );
        },
        child: _isSearching
            ? ClipRect(
                child: AppLiquidGlass(
                  borderRadius: 22.0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  refractiveIndex: 1.15,
                  thickness: 15,
                  blur: 8,
                  showGlow: false,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: availableWidth - 28, // Subtract padding (14 on each side)
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: AppColors.textPrimary(context).withValues(alpha: 0.6),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
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
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                  widget.onSearchChanged?.call('');
                                });
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textPrimary(context),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : ScreenHeader.circleButton(
                context: context,
                onTap: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.textPrimary(context),
                  size: 24,
                ),
              ),
      );
    } else {
      searchOrTrailingWidget = widget.trailing ?? const SizedBox(width: 44);
    }

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Leading widget (fades out during search)
            Positioned(
              left: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isSearching ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: _isSearching,
                  child: leadingWidget,
                ),
              ),
            ),

            // Title widget (fades out during search)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _isSearching ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _isSearching,
                child: titleWidget,
              ),
            ),

            // Trailing / Search widget (expanding from right to left)
            Positioned(
              right: 0,
              child: searchOrTrailingWidget,
            ),
          ],
        ),
      ),
    );
  }
}
