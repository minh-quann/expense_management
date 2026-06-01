import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/recurring/presentation/screens/add_recurring_screen.dart';
import 'package:expense_management/shared/widgets/screen_header.dart';
import 'package:expense_management/shared/widgets/fading_blur_layer.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  void initState() {
    super.initState();
    // Delay loading to prevent transition animation lag
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final userId = AuthTokenManager.getUserId();
        context.read<RecurringBloc>().add(LoadRecurrings(userId));
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
            child: BlocBuilder<RecurringBloc, RecurringState>(
              builder: (context, state) {
                if (state is RecurringLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RecurringLoaded) {
                  final recurrings = state.recurrings;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, headerHeight + 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recurrings.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: AppText('Chưa có giao dịch định kỳ nào'),
                            ),
                          )
                        else
                          ...recurrings.map((r) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildRecurringCard(
                                context,
                                title: r.note ?? 'Giao dịch',
                                amount: r.amount,
                                frequency: r.frequency.name.toUpperCase(),
                                icon: r.type == RecurringType.income ? Icons.download : Icons.upload,
                                iconColor: r.type == RecurringType.income ? AppColors.green500 : AppColors.blue500,
                                isExpense: r.type == RecurringType.expense,
                                isActive: r.isActive,
                              ),
                            );
                          }),
                        const SizedBox(height: 32),
                        AppButton(
                          label: 'Tạo giao dịch định kỳ',
                          icon: Icons.add,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecurringScreen()));
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: AppText('Lỗi tải giao dịch định kỳ'));
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
                Positioned.fill(
                  child: const FadingBlurLayer(stops: [0.35, 1.0]),
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
                      title: 'Giao dịch định kỳ',
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

  Widget _buildRecurringCard(
    BuildContext context, {
    required String title,
    required double amount,
    required String frequency,
    required IconData icon,
    required Color iconColor,
    required bool isExpense,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? iconColor.withValues(alpha: 0.1) : AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? iconColor : AppColors.gray500, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
                ),
                const SizedBox(height: 4),
                AppText(
                  frequency,
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '${isExpense ? '-' : '+'}₫${(amount / 1000).toStringAsFixed(0)}k',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive 
                  ? (isExpense ? AppColors.transactionExpense : AppColors.transactionIncome)
                  : AppColors.textSecondary(context),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: isActive ? AppColors.green100 : AppColors.gray200,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: AppText(
                  isActive ? 'Đang bật' : 'Tạm dừng',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.green700 : AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
