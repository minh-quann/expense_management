import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF161A23) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          'Ngân sách',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetCard(
                context,
                title: 'Tổng chi tiêu tháng này',
                totalAmount: 15000000,
                spentAmount: 12500000,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              AppText(
                'Ngân sách danh mục',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
              const SizedBox(height: 16),
              _buildBudgetCard(
                context,
                title: 'Ăn uống',
                icon: Icons.restaurant,
                iconColor: AppColors.orange500,
                totalAmount: 5000000,
                spentAmount: 4800000,
                color: AppColors.orange500,
              ),
              const SizedBox(height: 16),
              _buildBudgetCard(
                context,
                title: 'Di chuyển',
                icon: Icons.directions_car,
                iconColor: AppColors.purple500,
                totalAmount: 2000000,
                spentAmount: 800000,
                color: AppColors.purple500,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const AppText('Tạo ngân sách mới', fontWeight: FontWeight.bold),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context, {
    required String title,
    IconData? icon,
    Color? iconColor,
    required double totalAmount,
    required double spentAmount,
    required Color color,
  }) {
    final percentage = spentAmount / totalAmount;
    final isWarning = percentage > 0.8;
    final isDanger = percentage >= 1.0;
    
    Color progressColor = color;
    if (isDanger) {
      progressColor = AppColors.red500;
    } else if (isWarning) {
      progressColor = const Color(0xFFFF9500);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null && iconColor != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: AppText(title, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText('Đã tiêu: ₫${(spentAmount / 1000).toStringAsFixed(0)}k', color: AppColors.textSecondary(context)),
              AppText('Tổng: ₫${(totalAmount / 1000).toStringAsFixed(0)}k', fontWeight: FontWeight.w600),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : AppColors.gray100,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (isWarning && !isDanger) ...[
            const SizedBox(height: 8),
            const AppText('Sắp vượt ngân sách!', color: Color(0xFFFF9500), fontSize: 12),
          ],
          if (isDanger) ...[
            const SizedBox(height: 8),
            AppText('Đã vượt ngân sách!', color: AppColors.red500, fontSize: 12),
          ]
        ],
      ),
    );
  }
}
