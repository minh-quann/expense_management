import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// Reusable screen header widget used across the entire app.
///
/// Supports two modes:
/// 1. **Tab screen header**: Pass [leading] and/or [trailing] widgets.
///    If [leading] is null, a placeholder is shown to keep the title centered.
/// 2. **Sub-screen header (with back button)**: Set [showBackButton] = true.
///    The back button uses [onBack] or defaults to Navigator.pop.
class ScreenHeader extends StatelessWidget {
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

  const ScreenHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.showBackButton = false,
    this.onBack,
    this.padding,
  });

  /// Factory for building a circular icon button matching the app's nav bar style.
  /// Use this for consistent icon buttons in headers across all screens.
  static Widget circleButton({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.isDark(context)
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8F8F8),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine leading widget
    Widget leadingWidget;
    if (showBackButton) {
      leadingWidget = circleButton(
        context: context,
        onTap: onBack ?? () => Navigator.pop(context),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary(context),
          size: 20,
        ),
      );
    } else {
      // Use provided leading or a transparent placeholder to keep title centered
      leadingWidget = leading ?? const SizedBox(width: 44);
    }

    return SizedBox(
      height: 64,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leadingWidget,
            AppText(
              title,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
            trailing ?? const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}
