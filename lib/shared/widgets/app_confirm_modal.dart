import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';

/// A shared confirmation modal dialog used across the entire app.
/// Supports customizable icon, title, message, button labels, and destructive styling.
///
/// Usage:
/// ```dart
/// final confirmed = await AppConfirmModal.show(
///   context: context,
///   title: 'Đăng xuất',
///   message: 'Bạn có chắc chắn muốn đăng xuất?',
///   confirmLabel: 'Đăng xuất',
///   isDestructive: true,
/// );
/// if (confirmed) { /* do something */ }
/// ```
class AppConfirmModal extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final bool isDestructive;

  const AppConfirmModal({
    super.key,
    this.icon = Icons.help_outline_rounded,
    this.iconColor,
    required this.title,
    required this.message,
    this.cancelLabel = 'Hủy',
    this.confirmLabel = 'Xác nhận',
    this.isDestructive = false,
  });

  /// Show the confirmation modal and return true if user confirmed, false otherwise.
  static Future<bool> show({
    required BuildContext context,
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
    required String title,
    required String message,
    String cancelLabel = 'Hủy',
    String confirmLabel = 'Xác nhận',
    bool isDestructive = false,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppConfirmModal(
          icon: icon,
          iconColor: iconColor,
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          isDestructive: isDestructive,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.gray900;
    final subtextColor = isDark ? Colors.grey[400]! : AppColors.gray500;
    final confirmColor = isDestructive ? AppColors.error : AppColors.primary;
    final effectiveIconColor = iconColor ?? (isDestructive ? AppColors.error : AppColors.primary);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveIconColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                AppText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Message
                AppText(
                  message,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: subtextColor,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Action buttons using shared AppButton
                Row(
                  children: [
                    // Cancel button (outlined variant)
                    Expanded(
                      child: AppButton(
                        label: cancelLabel,
                        onPressed: () => Navigator.pop(context, false),
                        isOutlined: true,
                        height: 48,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm button (filled variant)
                    Expanded(
                      child: AppButton(
                        label: confirmLabel,
                        onPressed: () => Navigator.pop(context, true),
                        backgroundColor: confirmColor,
                        height: 48,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

