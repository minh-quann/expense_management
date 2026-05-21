import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_management/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/budgets/presentation/screens/add_budget_screen.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    final userId = AuthTokenManager.getUserId();
    context.read<BudgetBloc>().add(LoadBudgets(userId));
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
        child: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, budgetState) {
            if (budgetState is BudgetLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (budgetState is BudgetLoaded) {
              return BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, txState) {
                  List<AppTransaction> currentMonthTx = [];
                  if (txState is TransactionLoaded) {
                    final now = DateTime.now();
                    currentMonthTx = txState.transactions.where((tx) {
                      return tx.date.month == now.month && tx.date.year == now.year && tx.type == TransactionType.expense;
                    }).toList();
                  }

                  final budgets = budgetState.budgets;
                  final totalBudget = budgets.where((b) => b.categoryId == null).firstOrNull;
                  final categoryBudgets = budgets.where((b) => b.categoryId != null).toList();

                  double totalSpent = 0;
                  if (totalBudget != null) {
                    totalSpent = currentMonthTx.fold(0, (sum, tx) => sum + tx.amount);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (totalBudget != null) ...[
                          _buildBudgetCard(
                            context,
                            title: 'Tổng chi tiêu tháng này',
                            totalAmount: totalBudget.amountLimit,
                            spentAmount: totalSpent,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 32),
                        ],
                        
                        if (categoryBudgets.isNotEmpty) ...[
                          AppText(
                            'Ngân sách danh mục',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                          const SizedBox(height: 16),
                          ...categoryBudgets.map((b) {
                            final spent = currentMonthTx
                                .where((tx) => tx.categoryId == b.categoryId)
                                .fold(0.0, (sum, tx) => sum + tx.amount);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildBudgetCard(
                                context,
                                title: b.categoryName ?? 'Danh mục',
                                icon: Icons.category,
                                iconColor: AppColors.orange500,
                                totalAmount: b.amountLimit,
                                spentAmount: spent,
                                color: AppColors.orange500,
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        if (budgets.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: AppText('Bạn chưa có ngân sách nào'),
                            ),
                          ),

                        AppButton(
                          label: 'Tạo ngân sách mới',
                          icon: Icons.add,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBudgetScreen()));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const Center(child: AppText('Lỗi tải ngân sách'));
          },
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
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(24),
        ),
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
          ClipRSuperellipse(
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
