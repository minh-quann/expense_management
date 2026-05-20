import 'dart:async';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/wallets/data/models/wallet_model.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final ApiClient _apiClient = ApiClient();
  final _walletsController = StreamController<List<Wallet>>.broadcast();

  // Accept optional firestore parameter to maintain backwards compatibility during migration
  WalletRepositoryImpl([dynamic _]);

  // Helper method to fetch from backend and update stream
  Future<void> _fetchAndEmit(String userId) async {
    try {
      final response = await _apiClient.dio.get('/wallets');
      final list = (response.data as List).map((json) {
        return WalletModel(
          id: json['id'],
          userId: json['user_id'],
          name: json['name'],
          type: _parseWalletType(json['type']),
          balance: (json['balance'] ?? 0.0).toDouble(),
          currency: json['currency'] ?? 'VND',
          icon: json['icon'],
          color: json['color'],
          excludeFromTotal: json['exclude_from_total'] ?? false,
          isFavorite: json['is_favorite'] ?? false,
        );
      }).toList();
      _walletsController.add(list);
    } catch (e) {
      _walletsController.addError(e);
    }
  }

  static WalletType _parseWalletType(String typeStr) {
    switch (typeStr) {
      case 'CASH':
        return WalletType.cash;
      case 'BANK':
        return WalletType.bank;
      case 'CREDIT_CARD':
        return WalletType.credit;
      case 'E_WALLET':
        return WalletType.eWallet;
      default:
        return WalletType.cash;
    }
  }

  static String _walletTypeToString(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'CASH';
      case WalletType.bank:
        return 'BANK';
      case WalletType.credit:
        return 'CREDIT_CARD';
      case WalletType.eWallet:
        return 'E_WALLET';
    }
  }

  @override
  Stream<List<Wallet>> getWallets(String userId) {
    _fetchAndEmit(userId);
    return _walletsController.stream;
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    await _apiClient.dio.post('/wallets', data: {
      'name': wallet.name,
      'type': _walletTypeToString(wallet.type),
      'balance': wallet.balance,
      'currency': wallet.currency,
      'icon': wallet.icon,
      'color': wallet.color,
      'exclude_from_total': wallet.excludeFromTotal,
      'is_favorite': wallet.isFavorite,
    });
    await _fetchAndEmit(wallet.userId);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    await _apiClient.dio.put('/wallets/${wallet.id}', data: {
      'name': wallet.name,
      'type': _walletTypeToString(wallet.type),
      'balance': wallet.balance,
      'currency': wallet.currency,
      'icon': wallet.icon,
      'color': wallet.color,
      'exclude_from_total': wallet.excludeFromTotal,
      'is_favorite': wallet.isFavorite,
    });
    await _fetchAndEmit(wallet.userId);
  }

  @override
  Future<void> deleteWallet(String id) async {
    throw UnimplementedError('Use deleteWalletForUser instead');
  }

  @override
  Future<void> deleteWalletForUser(String userId, String walletId) async {
    await _apiClient.dio.delete('/wallets/$walletId');
    await _fetchAndEmit(userId);
  }

  @override
  Future<void> toggleFavoriteWallet(String userId, String walletId) async {
    await _apiClient.dio.patch('/wallets/$walletId/favorite');
    await _fetchAndEmit(userId);
  }
}
