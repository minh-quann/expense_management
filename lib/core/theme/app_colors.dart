import 'package:flutter/material.dart';

class AppColors {
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // Primary colors - Modern Electric Blue
  static const Color primary = Color(0xFF2970FF);
  static const Color primaryLight = Color(0xFF6B9AFF);
  static const Color primaryDark = Color(0xFF004EE6);

  // Background colors - Pure Black/Clean White for OLED/Minimalist feel
  static const Color appBackgroundLight = Color(0xFFEAECEF);
  static Color background(BuildContext context) => isDark(context) ? const Color(0xFF000000) : appBackgroundLight;
  static Color surface(BuildContext context) => isDark(context) ? const Color(0xFF1C1C1E) : Colors.white;

  // Text colors
  static Color textPrimary(BuildContext context) => isDark(context) ? Colors.white : const Color(0xFF111111);
  static Color textSecondary(BuildContext context) => isDark(context) ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);

  // Status colors - Vivid for clear storytelling
  static const Color success = Color(0xFF32D74B); // Vibrant Green
  static const Color error = Color(0xFFFF453A); // Vibrant Red
  static const Color warning = Color(0xFFFFD60A); // Vibrant Yellow 
  
  // Custom Card/Bento borders
  static Color border(BuildContext context) => isDark(context) ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  // --- Color Palette from Design System ---
  // --- Gray ---
  static const Color gray25 = Color(0xFFFDFDFD);
  static const Color gray50 = Color(0xFFFAFAF9);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE6E8EC);
  static const Color gray240 = Color(0xFFF0F0F0);
  static const Color gray300 = Color(0xFFD0D5DD);
  static const Color gray400 = Color(0xFF9AA0AA);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF525866);
  static const Color gray700 = Color(0xFF3F4652);
  static const Color gray800 = Color(0xFF252B37);
  static const Color gray900 = Color(0xFF161C24);
  static const Color gray950 = Color(0xFF0B1117);

  // --- Volcano ---
  static const Color volcano100 = Color(0xFFFFF1F0);
  static const Color volcano200 = Color(0xFFFFFCF5);
  static const Color volcano300 = Color(0xFFFEDF89);
  static const Color volcano400 = Color(0xFFFFA39E);
  static const Color volcano600 = Color(0xFFE7412B);
  static const Color volcano900 = Color(0xFFDC6803);

  // --- Magenta ---
  static const Color magenta100 = Color(0xFFFEF6FB);
  static const Color magenta300 = Color(0xFFFCCEEE);
  static const Color magenta900 = Color(0xFFDD2590);

  // --- Teal ---
  static const Color teal50 = Color(0xFFE6FFFB);
  static const Color teal200 = Color(0xFF99F6E0);
  static const Color teal600 = Color(0xFF0E9384);

  // --- Cyan ---
  static const Color cyan50 = Color(0xFFE6FFFB);
  static const Color cyan600 = Color(0xFF87E8DE);
  static const Color cyan800 = Color(0xFF08979C);

  // --- Blue ---
  static const Color blue25 = Color(0xFFF5FAFF);
  static const Color blue50 = Color(0xFFEFF8FF);
  static const Color blue100 = Color(0xFFD1E9FF);
  static const Color blue200 = Color(0xFFB2DDFF);
  static const Color blue300 = Color(0xFF84CAFF);
  static const Color blue400 = Color(0xFF53B1FD);
  static const Color blue500 = Color(0xFF2E90FA);
  static const Color blue600 = Color(0xFF1570EF);
  static const Color blue700 = Color(0xFF175CD3);
  static const Color blue800 = Color(0xFF1849A9);
  static const Color blue900 = Color(0xFF194185);
  static const Color blue950 = Color(0xFF102A56);

  // --- Geekblue ---
  static const Color geekblue100 = Color(0xFFF5FAFF);
  static const Color geekblue300 = Color(0xFFB2DDFF);
  static const Color geekblue900 = Color(0xFF1570EF);

  // --- Orange ---
  static const Color orange50 = Color(0xFFFFF2E8);
  static const Color orange100 = Color(0xFFFFE7BA);
  static const Color orange200 = Color(0xFFFFBB96);
  static const Color orange300 = Color(0xFFFFD9BE);
  static const Color orange500 = Color(0xFFD48806);
  static const Color orange600 = Color(0xFFFA541C);
  static const Color orange700 = Color(0xFFFF7A45);
  static const Color orange800 = Color(0xFFFD6900);
  static const Color orange900 = Color(0xFFFD6900);

  // --- Green ---
  static const Color green25 = Color(0xFFF6FEF9);
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);
  static const Color green950 = Color(0xFF052E16);

  // --- Purple ---
  static const Color purple25 = Color(0xFFFCFAFF);
  static const Color purple50 = Color(0xFFF9F5FF);
  static const Color purple100 = Color(0xFFF4E8FF);
  static const Color purple200 = Color(0xFFE9D7FE);
  static const Color purple300 = Color(0xFFD6BBFB);
  static const Color purple400 = Color(0xFFB692F6);
  static const Color purple500 = Color(0xFF9E77ED);
  static const Color purple600 = Color(0xFF7F56D9);
  static const Color purple700 = Color(0xFF6941C6);
  static const Color purple800 = Color(0xFF53389E);
  static const Color purple900 = Color(0xFF42307D);
  static const Color purple950 = Color(0xFF2C1C5F);

  // --- Pink ---
  static const Color pink25 = Color(0xFFFEF6FB);
  static const Color pink50 = Color(0xFFFDF2FA);
  static const Color pink100 = Color(0xFFFCE7F6);
  static const Color pink200 = Color(0xFFFCCEEE);
  static const Color pink300 = Color(0xFFFBA4D7);
  static const Color pink400 = Color(0xFFF670C0);
  static const Color pink500 = Color(0xFFEE46AB);
  static const Color pink600 = Color(0xFFDD2590);
  static const Color pink700 = Color(0xFFC11574);
  static const Color pink800 = Color(0xFF9E165F);
  static const Color pink900 = Color(0xFF851651);
  static const Color pink950 = Color(0xFF4E0D3D);

  // --- Red ---
  static const Color red25 = Color(0xFFFFF7F7);
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color red950 = Color(0xFF450A0A);

  // --- Yellow ---
  static const Color yellow25 = Color(0xFFFFFCF5);
  static const Color yellow50 = Color(0xFFFFFAEB);
  static const Color yellow100 = Color(0xFFFEF0C7);
  static const Color yellow200 = Color(0xFFFEDF89);
  static const Color yellow300 = Color(0xFFFEC84B);
  static const Color yellow400 = Color(0xFFFDB022);
  static const Color yellow500 = Color(0xFFF79009);
  static const Color yellow600 = Color(0xFFDC6803);
  static const Color yellow700 = Color(0xFFB54708);
  static const Color yellow800 = Color(0xFF93370D);
  static const Color yellow900 = Color(0xFF7A2E0E);
  static const Color yellow950 = Color(0xFF4E1D09);

  // --- Brown ---
  static const Color brown900 = Color(0xFF610B00);



  // --- Home Screen Semantic Colors ---
  
  // Balance Card Gradient
  static const Color balanceGradientStart = blue500;
  static const Color balanceGradientMiddle = purple500;
  static const Color balanceGradientEnd = pink500;

  // Transaction Icons
  static const Color iconBgPerson = purple50;
  static const Color iconColorPerson = purple600;
  static const Color iconBgPaypal = blue50;
  static const Color iconColorPaypal = blue600;
  static const Color iconBgStore = red50;
  static const Color iconColorStore = red600;
  
  // Specific Utility Colors
  static const Color notificationDot = red500;
  static const Color transactionExpense = red600;
  static const Color transactionIncome = green600;
  static const Color iconBgLight = gray100;
}
