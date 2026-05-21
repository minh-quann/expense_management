import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// A shared button widget used across the app for consistent styling.
///
/// Supports two variants:
/// - **Filled** (default): Solid background with white text
/// - **Outlined** (`isOutlined: true`): Transparent background with border
///
/// Key props:
/// - [expand]: If true (default), button stretches full width. Set false for inline buttons.
/// - [borderRadius]: Custom corner radius. Defaults to stadium shape (100).
/// - [isOutlined]: Renders as outlined button with border instead of filled.
/// - [borderColor]: Custom border color for outlined variant.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool isOutlined;
  final Color? borderColor;
  final double borderRadius;
  final bool expand;
  final FontWeight fontWeight;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.fontSize = 16,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.isOutlined = false,
    this.borderColor,
    this.borderRadius = 100,
    this.expand = true,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Resolve colors based on variant
    final bgColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ?? AppColors.primary);
    final fgColor = isOutlined
        ? (foregroundColor ?? (isDark ? Colors.grey[400]! : AppColors.gray500))
        : (foregroundColor ?? Colors.white);
    final effectiveBorderColor = borderColor ??
        (isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0));

    // Build label or loading indicator
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : AppText(
            label,
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: fgColor,
          );

    // Common shape
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    // Build the button widget
    Widget button;

    if (isOutlined) {
      button = icon != null && !isLoading
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(icon, size: 20, color: fgColor),
              label: child,
              style: OutlinedButton.styleFrom(
                foregroundColor: fgColor,
                side: BorderSide(color: effectiveBorderColor),
                shape: shape,
                elevation: 0,
              ),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: fgColor,
                side: BorderSide(color: effectiveBorderColor),
                shape: shape,
                elevation: 0,
              ),
              child: child,
            );
    } else {
      button = icon != null && !isLoading
          ? ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(icon, size: 20),
              label: child,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: shape,
              ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: shape,
              ),
              child: child,
            );
    }

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: button,
    );
  }
}

