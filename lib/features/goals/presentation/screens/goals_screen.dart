import 'dart:ui';
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
import 'package:expense_management/shared/widgets/screen_header.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    // Delay loading to prevent transition animation lag
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final userId = AuthTokenManager.getUserId();
        context.read<GoalBloc>().add(LoadGoals(userId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.background(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 64.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Content
          Positioned.fill(
            child: BlocBuilder<GoalBloc, GoalState>(
              builder: (context, state) {
                if (state is GoalLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GoalLoaded) {
                  final goals = state.goals;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 24),
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

          // 2. Transparent Header with Gradient Blur (Pinned at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Stack(
              children: [
                // 2.1. Fading Blur Layer
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.35, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),

                // 2.2. Fading Background Color Layer
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor,
                          bgColor.withValues(alpha: 0.8),
                          bgColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2.3. Actual Header Widgets
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.only(top: statusBarHeight),
                    alignment: Alignment.center,
                    child: ScreenHeader(
                      title: 'Mục tiêu tiết kiệm',
                      showBackButton: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
