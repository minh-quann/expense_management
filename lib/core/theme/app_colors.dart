import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // Primary colors
  static const Color primary = Color(0xFF5E35B1);
  static const Color primaryLight = Color(0xFF8E24AA);
  static const Color primaryDark = Color(0xFF311B92);

  // Background colors
  static Color background(BuildContext context) => isDark(context) ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  static Color surface(BuildContext context) => isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  // Text colors
  static Color textPrimary(BuildContext context) => isDark(context) ? Colors.white : const Color(0xFF212121);
  static Color textSecondary(BuildContext context) => isDark(context) ? const Color(0xFFAAAAAA) : const Color(0xFF757575);

  // Status colors
  static const Color success = Color(0xFF4CAF50); // For income
  static const Color error = Color(0xFFE53935); // For expense
  static const Color warning = Color(0xFFFFB300); // For pending or alerts
}
