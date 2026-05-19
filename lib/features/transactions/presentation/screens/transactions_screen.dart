import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildFilters(context),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateGroup(context, AppLocalizations.of(context)!.transactions_today, [
                      _buildTransactionItem(context, 
                        icon: Icons.directions_car,
                        iconBgColor: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : Colors.black,
                        iconColor: AppColors.isDark(context) ? Colors.white : Colors.white,
                        title: 'Grab/Taxi',
                        time: '08:40',
                        amount: '-\$150',
                        amountColor: AppColors.transactionExpense,
                      ),
                      _buildTransactionItem(context, 
                        icon: Icons.person,
                        iconBgColor: AppColors.iconBgPerson,
                        iconColor: AppColors.iconColorPerson,
                        title: 'Chuyển tiền',
                        time: '12:35',
                        amount: '-\$450',
                        amountColor: AppColors.transactionExpense,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildDateGroup(context, AppLocalizations.of(context)!.transactions_yesterday, [
                      _buildTransactionItem(context, 
                        icon: Icons.storefront_rounded,
                        iconBgColor: AppColors.iconBgStore,
                        iconColor: AppColors.iconColorStore,
                        title: 'Siêu thị',
                        time: 'Hôm qua',
                        amount: '-\$200',
                        amountColor: AppColors.transactionExpense,
                      ),
                      _buildTransactionItem(context, 
                        icon: Icons.paypal,
                        iconBgColor: AppColors.iconBgPaypal,
                        iconColor: AppColors.iconColorPaypal,
                        title: 'Ví PayPal',
                        time: '10:20',
                        amount: '+\$1200',
                        amountColor: AppColors.transactionIncome,
                      ),
                      _buildTransactionItem(context, 
                        icon: Icons.account_balance,
                        iconBgColor: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.1) : AppColors.iconBgLight,
                        iconColor: AppColors.textPrimary(context),
                        title: 'Chuyển khoản',
                        time: 'Hôm qua',
                        amount: '-\$600',
                        amountColor: AppColors.transactionExpense,
                      ),
                    ]),
                    const SizedBox(height: 120), // Bottom nav space
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 44), // To balance the search icon
          AppText(
            AppLocalizations.of(context)!.transactions_title,
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
            child: Icon(Icons.search_rounded, color: AppColors.textPrimary(context), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildFilterChip(context, AppLocalizations.of(context)!.transactions_filter_all, isSelected: true),
          const SizedBox(width: 12),
          _buildFilterChip(context, AppLocalizations.of(context)!.transactions_filter_expense, isSelected: false),
          const SizedBox(width: 12),
          _buildFilterChip(context, AppLocalizations.of(context)!.transactions_filter_income, isSelected: false),
          const SizedBox(width: 12),
          _buildFilterChip(context, AppLocalizations.of(context)!.transactions_filter_transfer, isSelected: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : (AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: AppText(
          label,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, String dateLabel, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          dateLabel,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
        const SizedBox(height: 16),
        ...items.expand((item) => [item, const SizedBox(height: 20)]),
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
