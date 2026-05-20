import 'package:expense_management/features/wallets/domain/entities/wallet.dart';

abstract class WalletEvent {}

class LoadWalletsEvent extends WalletEvent {
  final String userId;
  LoadWalletsEvent(this.userId);
}

class AddWalletEvent extends WalletEvent {
  final Wallet wallet;
  AddWalletEvent(this.wallet);
}

class UpdateWalletEvent extends WalletEvent {
  final Wallet wallet;
  UpdateWalletEvent(this.wallet);
}

class DeleteWalletEvent extends WalletEvent {
  final String userId;
  final String walletId;
  DeleteWalletEvent(this.userId, this.walletId);
}

class ToggleFavoriteWalletEvent extends WalletEvent {
  final String userId;
  final String walletId;
  ToggleFavoriteWalletEvent(this.userId, this.walletId);
}

class WalletsUpdatedInternalEvent extends WalletEvent {
  final List<Wallet> wallets;
  WalletsUpdatedInternalEvent(this.wallets);
}

class WalletsErrorInternalEvent extends WalletEvent {
  final String error;
  WalletsErrorInternalEvent(this.error);
}
