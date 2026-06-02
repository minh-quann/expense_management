import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/core/routing/app_router.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// Centralized toast notification helper.
/// Shows beautiful top-sliding toast notifications with frosted glass effect.
///
/// Uses BackdropFilter for a standard frosted glass blur, matching Apple's
/// iOS notification banner style. LiquidGlass is reserved for persistent
/// interactive UI elements (buttons, nav bars, tab bars).
///
/// When [context] is null (e.g. during logout), falls back to
/// [rootNavigatorKey] to get a valid BuildContext.
class AppToast {
  AppToast._();

  /// Show a success toast with green accent
  static void success(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.success,
      icon: Icons.check_circle_rounded,
      primaryColor: AppColors.green600,
    );
  }

  /// Show an error toast with red accent
  static void error(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.error,
      icon: Icons.error_rounded,
      primaryColor: AppColors.error,
    );
  }

  /// Show a warning toast with orange accent
  static void warning(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.warning,
      icon: Icons.warning_rounded,
      primaryColor: AppColors.orange500,
    );
  }

  /// Show an info toast with blue accent
  static void info(BuildContext? context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.info,
      icon: Icons.info_rounded,
      primaryColor: AppColors.primary,
    );
  }

  /// Resolve a valid BuildContext: use provided context, or fall back
  /// to the root navigator's context.
  static BuildContext? _resolveContext(BuildContext? context) {
    if (context != null) return context;
    return rootNavigatorKey.currentContext;
  }

  /// Internal method to display the toast
  static void _show({
    BuildContext? context,
    required String message,
    required ToastificationType type,
    required IconData icon,
    required Color primaryColor,
  }) {
    final resolvedContext = _resolveContext(context);

    toastification.showCustom(
      context: resolvedContext,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      builder: (context, holder) {
        final isDark = AppColors.isDark(context);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () => toastification.dismiss(holder),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: ShapeDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.65),
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(26),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: primaryColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          message,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary(context),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
