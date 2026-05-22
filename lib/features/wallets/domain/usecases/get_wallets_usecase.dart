import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;

  GetWalletsUseCase(this.repository);

  Stream<List<Wallet>> call(String userId) {
    return repository.getWallets(userId);
  }
}
