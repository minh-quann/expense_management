import 'dart:async';
import 'package:expense_management/features/wallets/data/datasources/wallet_remote_datasource.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;
  final _walletsController = StreamController<List<Wallet>>.broadcast();

  // Maintain constructor with dynamic parameter for backwards compatibility with Firebase configuration
  WalletRepositoryImpl([dynamic _]) : _remoteDataSource = WalletRemoteDataSourceImpl();

  WalletRepositoryImpl.withDataSource(this._remoteDataSource);

  Future<void> _fetchAndEmit(String userId) async {
    try {
      final list = await _remoteDataSource.getWallets();
      _walletsController.add(list);
    } catch (e) {
      _walletsController.addError(e);
    }
  }

  @override
  Stream<List<Wallet>> getWallets(String userId) {
    _fetchAndEmit(userId);
    return _walletsController.stream;
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    await _remoteDataSource.addWallet(wallet);
    await _fetchAndEmit(wallet.userId);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    await _remoteDataSource.updateWallet(wallet);
    await _fetchAndEmit(wallet.userId);
  }

  @override
  Future<void> deleteWallet(String id) async {
    throw UnimplementedError('Use deleteWalletForUser instead');
  }

  @override
  Future<void> deleteWalletForUser(String userId, String walletId) async {
    await _remoteDataSource.deleteWallet(walletId);
    await _fetchAndEmit(userId);
  }

  @override
  Future<void> toggleFavoriteWallet(String userId, String walletId) async {
    await _remoteDataSource.toggleFavoriteWallet(walletId);
    await _fetchAndEmit(userId);
  }
}
