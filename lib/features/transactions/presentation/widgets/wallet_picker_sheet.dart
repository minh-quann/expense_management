import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/theme/app_colors.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_bloc.dart';
import 'package:expense_management/features/wallets/presentation/bloc/wallet_state.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';

/// A bottom sheet content widget to select a wallet.
class WalletPickerSheet extends StatelessWidget {
  final ValueChanged<Wallet> onWalletSelected;

  const WalletPickerSheet({
    super.key,
    required this.onWalletSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WalletLoaded) {
          if (state.wallets.isEmpty) {
            return Center(
              child: AppText(
                'Chưa có ví nào',
                color: AppColors.textSecondary(context),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.wallets.length,
            itemBuilder: (context, index) {
              final wallet = state.wallets[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue500.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.blue500, size: 24),
                    ),
                    title: AppText(
                      wallet.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    subtitle: AppText(
                      CurrencyFormatter.format(context, wallet.balance),
                      color: AppColors.textSecondary(context),
                      fontSize: 13,
                    ),
                    trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
                    onTap: () {
                      onWalletSelected(wallet);
                      Navigator.pop(context);
                    },
                  ),
                  if (index < state.wallets.length - 1)
                    Divider(height: 1, indent: 64, color: AppColors.border(context)),
                ],
              );
            },
          );
        }
        return Center(
          child: AppText(
            'Lỗi tải ví',
            color: AppColors.textSecondary(context),
          ),
        );
      },
    );
  }
}
