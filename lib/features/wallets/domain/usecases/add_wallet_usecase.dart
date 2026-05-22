import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class AddWalletUseCase {
  final WalletRepository repository;

  AddWalletUseCase(this.repository);

  Future<void> call(Wallet wallet) {
    return repository.addWallet(wallet);
  }
}
