import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(BuildContext context, double amount) {
    // Determine the locale from context
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'vi') {
      final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
      return formatter.format(amount);
    } else {
      final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
      return formatter.format(amount);
    }
  }

  // Format without symbol, useful for input fields
  static String formatNumber(BuildContext context, double amount) {
    final locale = Localizations.localeOf(context).languageCode;
    final formatter = NumberFormat.decimalPattern(locale == 'vi' ? 'vi_VN' : 'en_US');
    return formatter.format(amount);
  }
}
