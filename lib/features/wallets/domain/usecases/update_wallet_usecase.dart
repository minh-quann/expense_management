import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class UpdateWalletUseCase {
  final WalletRepository repository;

  UpdateWalletUseCase(this.repository);

  Future<void> call(Wallet wallet) {
    return repository.updateWallet(wallet);
  }
}
