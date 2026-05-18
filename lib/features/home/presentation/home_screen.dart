import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText('Dashboard', fontWeight: FontWeight.bold, color: AppColors.surface(context)),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              'Chào mừng đến với Quản lý chi tiêu',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            AppText(
              'Bạn chưa có giao dịch nào.',
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Add new transaction
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface(context),
              ),
              child: const AppText('Thêm giao dịch mới'),
            ),
          ],
        ),
      ),
    );
  }
}
