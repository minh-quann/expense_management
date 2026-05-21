import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// A Bento-style card widget with an icon, title, and value.
/// Used in forms and detail grids throughout the app.
class BentoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const BentoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: AppColors.isDark(context)
              ? AppColors.surface(context)
              : Colors.white,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: iconBgColor,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            AppText(
              title,
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 4),
            AppText(
              value,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ],
        ),
      ),
    );
  }
}
