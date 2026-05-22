import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// Centralized toast notification helper.
/// Shows beautiful top-sliding toast notifications instead of bottom SnackBars.
///
/// Context is optional because ToastificationWrapper wraps MaterialApp,
/// so toasts can be shown even during route transitions (e.g. logout).
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

  /// Internal method to display the toast
  static void _show({
    BuildContext? context,
    required String message,
    required ToastificationType type,
    required IconData icon,
    required Color primaryColor,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: AppText(message, fontSize: 14, fontWeight: FontWeight.w500),
      icon: Icon(icon, color: primaryColor, size: 22),
      primaryColor: primaryColor,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(26),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      showProgressBar: false,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }
}
