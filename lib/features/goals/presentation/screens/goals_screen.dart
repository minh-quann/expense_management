import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

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
          'Mục tiêu tiết kiệm',
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
              _buildGoalCard(
                context,
                title: 'Mua iPhone 16 Pro Max',
                icon: Icons.phone_iphone,
                iconColor: AppColors.blue500,
                targetAmount: 35000000,
                currentAmount: 15000000,
              ),
              const SizedBox(height: 16),
              _buildGoalCard(
                context,
                title: 'Du lịch Nhật Bản',
                icon: Icons.flight_takeoff,
                iconColor: AppColors.pink500,
                targetAmount: 50000000,
                currentAmount: 10000000,
              ),
              const SizedBox(height: 16),
              _buildGoalCard(
                context,
                title: 'Quỹ khẩn cấp',
                icon: Icons.health_and_safety,
                iconColor: AppColors.green500,
                targetAmount: 100000000,
                currentAmount: 85000000,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const AppText('Tạo mục tiêu mới', fontWeight: FontWeight.bold),
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

  Widget _buildGoalCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required double targetAmount,
    required double currentAmount,
  }) {
    final percentage = currentAmount / targetAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontSize: 16, fontWeight: FontWeight.w600),
                    const SizedBox(height: 4),
                    AppText(
                      'Hoàn thành ${(percentage * 100).toStringAsFixed(1)}%',
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : AppColors.gray100,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText('₫${(currentAmount / 1000000).toStringAsFixed(1)}M', color: iconColor, fontWeight: FontWeight.w600),
              AppText('₫${(targetAmount / 1000000).toStringAsFixed(1)}M', color: AppColors.textSecondary(context)),
            ],
          ),
        ],
      ),
    );
  }
}
