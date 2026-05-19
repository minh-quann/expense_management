import 'package:expense_management/features/wallets/domain/entities/wallet.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<Wallet> wallets;
  WalletLoaded(this.wallets);
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}
