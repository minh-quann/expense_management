import 'package:expense_management/features/wallets/domain/entities/wallet.dart';

abstract class WalletRepository {
  Stream<List<Wallet>> getWallets(String userId);
  Future<void> addWallet(Wallet wallet);
  Future<void> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String id);
}
