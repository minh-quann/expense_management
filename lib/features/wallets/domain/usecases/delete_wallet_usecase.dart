import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class DeleteWalletUseCase {
  final WalletRepository repository;

  DeleteWalletUseCase(this.repository);

  Future<void> call(String userId, String walletId) {
    return repository.deleteWalletForUser(userId, walletId);
  }
}
