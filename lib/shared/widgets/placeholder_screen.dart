import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: AppText(title, fontWeight: FontWeight.bold, color: AppColors.surface(context)),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: AppText(
          title,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}
