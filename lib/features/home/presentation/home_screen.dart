import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';

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
                  AppText(AppLocalizations.of(context)!.home_total_balance, color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
                ],
              ),
              const Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          const AppText(
            '\$3,257.00',
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpenseItem(
                icon: Icons.arrow_downward_rounded,
                label: AppLocalizations.of(context)!.home_income,
                amount: '\$2,350.00',
              ),
              _buildIncomeExpenseItem(
                icon: Icons.arrow_upward_rounded,
                label: AppLocalizations.of(context)!.home_expenses,
                amount: '\$950.00',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseItem({
    required IconData icon,
    required String label,
    required String amount,
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
    return Column(
      children: [
        _buildTransactionItem(context, 
          icon: Icons.person,
          iconBgColor: AppColors.iconBgPerson,
          iconColor: AppColors.iconColorPerson,
          title: 'Chuyển tiền',
          time: '12:35',
          amount: '-\$450',
          amountColor: AppColors.transactionExpense,
        ),
        const SizedBox(height: 20),
        _buildTransactionItem(context, 
          icon: Icons.paypal,
          iconBgColor: AppColors.iconBgPaypal,
          iconColor: AppColors.iconColorPaypal,
          title: 'Ví PayPal',
          time: '10:20',
          amount: '+\$1200',
          amountColor: AppColors.transactionIncome,
        ),
        const SizedBox(height: 20),
        _buildTransactionItem(context, 
          icon: Icons.directions_car,
          iconBgColor: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : Colors.black,
          iconColor: AppColors.isDark(context) ? Colors.white : Colors.white,
          title: 'Grab/Taxi',
          time: '08:40',
          amount: '-\$150',
          amountColor: AppColors.transactionExpense,
        ),
        const SizedBox(height: 20),
        _buildTransactionItem(context, 
          icon: Icons.storefront_rounded,
          iconBgColor: AppColors.iconBgStore,
          iconColor: AppColors.iconColorStore,
          title: 'Siêu thị',
          time: 'Hôm qua',
          amount: '-\$200',
          amountColor: AppColors.transactionExpense,
        ),
        const SizedBox(height: 20),
        _buildTransactionItem(context, 
          icon: Icons.account_balance,
          iconBgColor: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : AppColors.iconBgLight,
          iconColor: AppColors.textPrimary(context),
          title: 'Chuyển khoản',
          time: 'Hôm qua',
          amount: '-\$600',
          amountColor: AppColors.transactionExpense,
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
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
              ),
              const SizedBox(height: 4),
              AppText(
                time,
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
        AppText(
          amount,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: amountColor,
        ),
      ],
    );
  }
}
