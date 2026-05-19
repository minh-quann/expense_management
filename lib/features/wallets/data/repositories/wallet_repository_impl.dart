import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/wallets/data/models/wallet_model.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepositoryImpl(this._firestore);

  /// Helper to get wallet collection ref under /users/{userId}/wallets
  CollectionReference _walletsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('wallets');
  }

  @override
  Stream<List<Wallet>> getWallets(String userId) {
    return _walletsRef(userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WalletModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addWallet(Wallet wallet) async {
    final model = WalletModel(
      id: wallet.id,
      userId: wallet.userId,
      name: wallet.name,
      type: wallet.type,
      balance: wallet.balance,
      currency: wallet.currency,
      icon: wallet.icon,
      color: wallet.color,
      excludeFromTotal: wallet.excludeFromTotal,
    );
    await _walletsRef(wallet.userId).add(model.toFirestore());
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final model = WalletModel(
      id: wallet.id,
      userId: wallet.userId,
      name: wallet.name,
      type: wallet.type,
      balance: wallet.balance,
      currency: wallet.currency,
      icon: wallet.icon,
      color: wallet.color,
      excludeFromTotal: wallet.excludeFromTotal,
    );
    await _walletsRef(wallet.userId).doc(wallet.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteWallet(String id) async {
    // deleteWallet needs userId - we'll handle this via the new signature
    throw UnimplementedError('Use deleteWalletForUser instead');
  }

  @override
  Future<void> deleteWalletForUser(String userId, String walletId) async {
    await _walletsRef(userId).doc(walletId).delete();
  }
}
