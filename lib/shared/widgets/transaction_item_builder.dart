import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/utils/category_helper.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/shared/widgets/transaction_list_item.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';

/// Helper to create a [TransactionListItem] from an [AppTransaction] entity.
/// Centralizes the logic for icon, color, title, subtitle, and amount formatting.
class TransactionItemBuilder {
  /// Format a date into a human-readable label: "Hôm nay", "Hôm qua", or "dd thg MM"
  static String formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hôm nay';
    } else if (dateToCheck == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd thg MM').format(date);
    }
  }

  /// Build a [TransactionListItem] from an [AppTransaction].
  static TransactionListItem buildItem({
    required BuildContext context,
    required AppTransaction tx,
    VoidCallback? onTap,
  }) {
    // Determine icon
    final icon = tx.type == TransactionType.transfer
        ? Icons.swap_horiz
        : (tx.categoryIcon != null
            ? CategoryHelper.getIcon(tx.categoryIcon!)
            : Icons.category);

    // Determine icon colors
    final iconColor = tx.categoryColor != null
        ? CategoryHelper.getColor(tx.categoryColor!)
        : (tx.type == TransactionType.income
            ? AppColors.green500
            : (tx.type == TransactionType.expense
                ? AppColors.red500
                : AppColors.blue500));

    final iconBgColor = tx.categoryColor != null
        ? CategoryHelper.getColor(tx.categoryColor!).withValues(alpha: 0.1)
        : (AppColors.isDark(context)
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.gray50);

    // Determine title & subtitle
    final title = tx.note != null && tx.note!.isNotEmpty
        ? tx.note!
        : (tx.categoryName ??
            (tx.type == TransactionType.transfer ? 'Chuyển khoản' : 'Khác'));

    final subtitle = tx.note != null && tx.note!.isNotEmpty
        ? (tx.categoryName ??
            (tx.type == TransactionType.transfer ? 'Chuyển khoản' : 'Khác'))
        : null;

    // Determine amount display
    final prefix = tx.type == TransactionType.income ? '+' : '-';
    final amountStr = '$prefix${CurrencyFormatter.format(context, tx.amount)}';

    final amountColor = tx.type == TransactionType.income
        ? AppColors.transactionIncome
        : (tx.type == TransactionType.expense
            ? AppColors.transactionExpense
            : AppColors.blue500);

    return TransactionListItem(
      icon: icon,
      iconBgColor: iconBgColor,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      amount: amountStr,
      amountColor: amountColor,
      time: formatDateLabel(tx.date),
      onTap: onTap,
    );
  }
}
