import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// A shared primary button widget with full rounded border (stadium shape).
/// Use this across the app for consistent button styling.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

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
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = foregroundColor ?? Colors.white;

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
            fontWeight: FontWeight.bold,
            color: fgColor,
          );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: icon != null && !isLoading
          ? ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(icon, size: 20),
              label: child,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: fgColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: child,
            ),
    );
  }
}
