import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

/// Reusable transaction list item widget.
/// Used in HomeScreen, WalletsScreen, and TransactionsScreen.
class TransactionListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String amount;
  final Color amountColor;
  final String time;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Icon container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  AppText(
                    subtitle!,
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                amount,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
              const SizedBox(height: 4),
              AppText(
                time,
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
