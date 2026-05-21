import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/widgets/app_button.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_event.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/l10n/app_localizations.dart';

/// A modal bottom sheet widget that allows the user to add a new wallet.
class AddWalletSheet extends StatefulWidget {
  const AddWalletSheet({super.key});

  @override
  State<AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<AddWalletSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    if (name.isNotEmpty) {
      final userId = AuthTokenManager.getUserId();
      final newWallet = Wallet(
        id: '',
        userId: userId,
        name: name,
        type: WalletType.cash,
        balance: balance,
        currency: 'VND',
        icon: '',
        color: '',
        excludeFromTotal: false,
      );
      context.read<WalletBloc>().add(AddWalletEvent(newWallet));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: ShapeDecoration(
        color: AppColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText(
              AppLocalizations.of(context)!.wallets_add,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: ShapeDecoration(
              color: AppColors.background(context),
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Tên ví (vd: Tiền mặt, Techcombank)',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: ShapeDecoration(
              color: AppColors.background(context),
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                hintText: 'Số dư ban đầu (₫)',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: AppLocalizations.of(context)!.wallets_add,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
