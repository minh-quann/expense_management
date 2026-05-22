import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_event.dart';
import 'package:expense_management/features/goals/presentation/bloc/goal_state.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/goals/presentation/screens/add_goal_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    final userId = AuthTokenManager.getUserId();
    context.read<GoalBloc>().add(LoadGoals(userId));
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.background(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          'Mục tiêu tiết kiệm',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary(context), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            if (state is GoalLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GoalLoaded) {
              final goals = state.goals;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (goals.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: AppText('Bạn chưa có mục tiêu nào'),
                        ),
                      )
                    else
                      ...goals.map((g) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildGoalCard(
                            context,
                            title: g.name,
                            icon: Icons.track_changes,
                            iconColor: AppColors.blue500,
                            targetAmount: g.targetAmount,
                            currentAmount: g.currentAmount,
                          ),
                        );
                      }),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Tạo mục tiêu mới',
                      icon: Icons.add,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalScreen()));
                      },
                    ),
                  ],
                ),
              );
            }
            return const Center(child: AppText('Lỗi tải mục tiêu'));
          },
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
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(26),
        ),
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
                    AppText(title, fontSize: 16, fontWeight: FontWeight.w500),
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
          ClipRSuperellipse(
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
              AppText('₫${(currentAmount / 1000000).toStringAsFixed(1)}M', color: iconColor, fontWeight: FontWeight.w500),
              AppText('₫${(targetAmount / 1000000).toStringAsFixed(1)}M', color: AppColors.textSecondary(context)),
            ],
          ),
        ],
      ),
    );
  }
}
