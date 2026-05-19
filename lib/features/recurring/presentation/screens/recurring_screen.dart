import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:expense_management/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_management/features/recurring/presentation/screens/add_recurring_screen.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
    context.read<RecurringBloc>().add(LoadRecurrings(userId));
  }

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
          'Giao dịch định kỳ',
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
        child: BlocBuilder<RecurringBloc, RecurringState>(
          builder: (context, state) {
            if (state is RecurringLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RecurringLoaded) {
              final recurrings = state.recurrings;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecurringScreen()));
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const AppText('Tạo giao dịch định kỳ', fontWeight: FontWeight.bold),
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
              );
            }
            return const Center(child: AppText('Lỗi tải giao dịch định kỳ'));
          },
        ),
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
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context), width: 1),
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
                  fontWeight: FontWeight.w600,
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
                fontWeight: FontWeight.bold,
                color: isActive 
                  ? (isExpense ? AppColors.transactionExpense : AppColors.transactionIncome)
                  : AppColors.textSecondary(context),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.green100 : AppColors.gray200,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: AppText(
                  isActive ? 'Đang bật' : 'Tạm dừng',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
