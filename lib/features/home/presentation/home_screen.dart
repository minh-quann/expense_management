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
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/shared/widgets/transaction_item_builder.dart';

import 'package:go_router/go_router.dart';

import 'package:expense_management/shared/widgets/screen_header.dart';

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
    return ScreenHeader(
      title: AppLocalizations.of(context)!.home_title,
      padding: EdgeInsets.zero,
      leading: ScreenHeader.circleButton(
        context: context,
        onTap: () {
          // TODO: Mở màn hình thông báo
        },
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
      trailing: ScreenHeader.circleButton(
        context: context,
        onTap: () => context.push('/add-transaction'),
        child: Icon(Icons.add_rounded, color: AppColors.textPrimary(context), size: 24),
      ),
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
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.balanceGradientStart,
                AppColors.balanceGradientMiddle,
                AppColors.balanceGradientEnd,
              ],
            ),
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(28),
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
                fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w500,
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
          fontWeight: FontWeight.w600,
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TransactionItemBuilder.buildItem(context: context, tx: tx),
              );
            }).toList(),
          );
        }
        return const Center(child: AppText('Lỗi tải giao dịch'));
      },
    );
  }
}
