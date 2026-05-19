import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/wallets/data/models/wallet_model.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';
import 'package:expense_management/features/wallets/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepositoryImpl(this._firestore);

  @override
  Stream<List<Wallet>> getWallets(String userId) {
    return _firestore
        .collection('wallets')
        .where('userId', isEqualTo: userId)
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
    await _firestore.collection('wallets').add(model.toFirestore());
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
    await _firestore.collection('wallets').doc(wallet.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _firestore.collection('wallets').doc(id).delete();
  }
}
