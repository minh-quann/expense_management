import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class ToggleFavoriteWalletUseCase {
  final WalletRepository repository;

  ToggleFavoriteWalletUseCase(this.repository);

  Future<void> call(String userId, String walletId) {
    return repository.toggleFavoriteWallet(userId, walletId);
  }
}
