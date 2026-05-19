import 'package:flutter/material.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _transactionType = 'EXPENSE'; // EXPENSE, INCOME, TRANSFER
  // ignore: prefer_final_fields
  String _amount = '0';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeToggle(),
                    const SizedBox(height: 40),
                    _buildAmountInput(),
                    const SizedBox(height: 40),
                    _buildDetailsGrid(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary(context), size: 20),
            ),
          ),
          AppText(
            AppLocalizations.of(context)!.add_transaction_title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          const SizedBox(width: 40), // Balance the header
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.isDark(context) ? Colors.white.withValues(alpha: 0.05) : AppColors.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleOption('EXPENSE', AppLocalizations.of(context)!.add_transaction_expense),
          _buildToggleOption('INCOME', AppLocalizations.of(context)!.add_transaction_income),
          _buildToggleOption('TRANSFER', AppLocalizations.of(context)!.add_transaction_transfer),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String type, String label) {
    final isSelected = _transactionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _transactionType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
              ? (AppColors.isDark(context) ? AppColors.surface(context) : Colors.white)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: AppText(
              label,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                ? AppColors.textPrimary(context) 
                : AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppText(
          AppLocalizations.of(context)!.add_transaction_amount,
          fontSize: 16,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppText(
                '\$',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _transactionType == 'EXPENSE' 
                    ? AppColors.red500 
                    : (_transactionType == 'INCOME' ? AppColors.green500 : AppColors.blue500),
              ),
            ),
            const SizedBox(width: 4),
            AppText(
              _amount,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: Icons.grid_view_rounded,
                iconColor: AppColors.purple500,
                iconBgColor: AppColors.purple50,
                title: AppLocalizations.of(context)!.add_transaction_category,
                value: 'Ăn uống',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoCard(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.blue500,
                iconBgColor: AppColors.blue50,
                title: AppLocalizations.of(context)!.add_transaction_wallet,
                value: AppLocalizations.of(context)!.wallets_cash,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.orange500,
                iconBgColor: AppColors.orange50,
                title: AppLocalizations.of(context)!.add_transaction_date,
                value: '${AppLocalizations.of(context)!.transactions_today}, 10:20',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.isDark(context) ? AppColors.surface(context) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.gray500, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.add_transaction_note_hint,
                    hintStyle: TextStyle(color: AppColors.textSecondary(context), fontSize: 16),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.isDark(context) ? AppColors.surface(context) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          AppText(title, fontSize: 13, color: AppColors.textSecondary(context)),
          const SizedBox(height: 4),
          AppText(value, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary(context)),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: AppText(
          AppLocalizations.of(context)!.add_transaction_save,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
