import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_state.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_management/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/shared/utils/category_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildBalanceCard(context),
              const SizedBox(height: 32),
              _buildTransactionsHeader(context),
              const SizedBox(height: 16),
              _buildTransactionsList(context),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.iconBgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.grid_view_rounded, color: AppColors.textPrimary(context), size: 24),
        ),
        AppText(
          AppLocalizations.of(context)!.home_title,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.iconBgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary(context), size: 24),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        double totalBalance = 0;
        if (state is WalletLoaded) {
          totalBalance = state.wallets
              .where((w) => !w.excludeFromTotal)
              .fold(0, (sum, w) => sum + w.balance);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.balanceGradientStart,
                AppColors.balanceGradientMiddle,
                AppColors.balanceGradientEnd,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppText(AppLocalizations.of(context)?.home_total_balance ?? 'Tổng số dư', color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
                    ],
                  ),
                  const Icon(Icons.more_horiz, color: Colors.white),
                ],
              ),
              const SizedBox(height: 12),
              AppText(
                CurrencyFormatter.format(context, totalBalance),
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 32),
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, txState) {
                  double totalIncome = 0;
                  double totalExpense = 0;
                  
                  if (txState is TransactionLoaded) {
                    final now = DateTime.now();
                    for (var tx in txState.transactions) {
                      if (tx.date.month == now.month && tx.date.year == now.year) {
                        if (tx.type == TransactionType.income) {
                          totalIncome += tx.amount;
                        } else if (tx.type == TransactionType.expense) {
                          totalExpense += tx.amount;
                        }
                      }
                    }
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIncomeExpenseItem(
                        icon: Icons.arrow_downward_rounded,
                        label: AppLocalizations.of(context)?.home_income ?? 'Thu nhập',
                        amount: CurrencyFormatter.format(context, totalIncome),
                        isIncome: true,
                      ),
                      _buildIncomeExpenseItem(
                        icon: Icons.arrow_upward_rounded,
                        label: AppLocalizations.of(context)?.home_expenses ?? 'Chi tiêu',
                        amount: CurrencyFormatter.format(context, totalExpense),
                        isIncome: false,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomeExpenseItem({
    required IconData icon,
    required String label,
    required String amount,
    required bool isIncome,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(label, color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
            const SizedBox(height: 4),
            AppText(
              amount,
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          AppLocalizations.of(context)!.home_transactions,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary(context),
        ),
        AppText(
          AppLocalizations.of(context)!.home_see_all,
          fontSize: 14,
          color: Colors.grey[500],
        ),
      ],
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded) {
          final recentTx = state.transactions.take(5).toList();
          
          if (recentTx.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AppText('Chưa có giao dịch nào', color: AppColors.textSecondary(context)),
              ),
            );
          }

          return Column(
            children: recentTx.map((tx) {
              return Column(
                children: [
                  _buildTransactionItem(
                    context, 
                    icon: tx.type == TransactionType.transfer 
                        ? Icons.swap_horiz 
                        : (tx.categoryIcon != null ? CategoryHelper.getIcon(tx.categoryIcon!) : Icons.category),
                    iconBgColor: tx.categoryColor != null 
                        ? CategoryHelper.getColor(tx.categoryColor!).withValues(alpha: 0.1) 
                        : (AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : AppColors.gray50),
                    iconColor: tx.categoryColor != null 
                        ? CategoryHelper.getColor(tx.categoryColor!) 
                        : (tx.type == TransactionType.income ? AppColors.green500 : (tx.type == TransactionType.expense ? AppColors.red500 : AppColors.blue500)),
                    title: tx.note != null && tx.note!.isNotEmpty 
                        ? tx.note! 
                        : (tx.categoryName ?? (tx.type == TransactionType.transfer ? 'Chuyển khoản' : 'Khác')),
                    subtitle: tx.note != null && tx.note!.isNotEmpty 
                        ? (tx.categoryName ?? (tx.type == TransactionType.transfer ? 'Chuyển khoản' : 'Khác'))
                        : null,
                    time: _formatDateLabel(tx.date),
                    amount: '${tx.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.format(context, tx.amount)}',
                    amountColor: tx.type == TransactionType.income ? AppColors.transactionIncome : (tx.type == TransactionType.expense ? AppColors.transactionExpense : AppColors.blue500),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          );
        }
        return const Center(child: AppText('Lỗi tải giao dịch'));
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    required String time,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
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
                color: AppColors.textPrimary(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppText(
              amount,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
            const SizedBox(height: 4),
            AppText(
              time,
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hôm nay';
    } else if (dateToCheck == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd thg MM', 'vi_VN').format(date);
    }
  }
}
