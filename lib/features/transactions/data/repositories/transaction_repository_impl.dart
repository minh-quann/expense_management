import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_management/features/transactions/data/models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepositoryImpl(this._firestore);

  @override
  Stream<List<AppTransaction>> getTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<AppTransaction>> getTransactionsByWallet(String userId, String walletId) {
    // Note: For transfers, it might be in walletId or toWalletId
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('walletId', isEqualTo: walletId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addTransaction(String userId, AppTransaction transaction) async {
    final batch = _firestore.batch();
    
    // 1. Create transaction doc
    final transactionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc();
    
    final transactionModel = TransactionModel.fromEntity(transaction);
    // Overwrite the id with the generated one
    final modelWithId = TransactionModel(
      id: transactionRef.id,
      amount: transactionModel.amount,
      type: transactionModel.type,
      categoryId: transactionModel.categoryId,
      categoryName: transactionModel.categoryName,
      categoryIcon: transactionModel.categoryIcon,
      walletId: transactionModel.walletId,
      walletName: transactionModel.walletName,
      toWalletId: transactionModel.toWalletId,
      toWalletName: transactionModel.toWalletName,
      date: transactionModel.date,
      note: transactionModel.note,
      imageUrl: transactionModel.imageUrl,
      recurringId: transactionModel.recurringId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    batch.set(transactionRef, modelWithId.toFirestore());

    // 2. Update wallet(s) balance
    final walletRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(transaction.walletId);

    if (transaction.type == TransactionType.expense) {
      batch.update(walletRef, {'balance': FieldValue.increment(-transaction.amount)});
    } else if (transaction.type == TransactionType.income) {
      batch.update(walletRef, {'balance': FieldValue.increment(transaction.amount)});
    } else if (transaction.type == TransactionType.transfer && transaction.toWalletId != null) {
      batch.update(walletRef, {'balance': FieldValue.increment(-transaction.amount)});
      
      final toWalletRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(transaction.toWalletId);
      batch.update(toWalletRef, {'balance': FieldValue.increment(transaction.amount)});
    }

    await batch.commit();
  }

  @override
  Future<void> updateTransaction(String userId, AppTransaction transaction) async {
    // Updating requires a Firestore Transaction to revert old balance and apply new one
    await _firestore.runTransaction((t) async {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id);
          
      final doc = await t.get(transactionRef);
      if (!doc.exists) return;
      
      final oldModel = TransactionModel.fromFirestore(doc);
      
      // Revert old transaction logic
      final oldWalletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(oldModel.walletId);
      if (oldModel.type == TransactionType.expense) {
        t.update(oldWalletRef, {'balance': FieldValue.increment(oldModel.amount)});
      } else if (oldModel.type == TransactionType.income) {
        t.update(oldWalletRef, {'balance': FieldValue.increment(-oldModel.amount)});
      } else if (oldModel.type == TransactionType.transfer && oldModel.toWalletId != null) {
        t.update(oldWalletRef, {'balance': FieldValue.increment(oldModel.amount)});
        final oldToWalletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(oldModel.toWalletId);
        t.update(oldToWalletRef, {'balance': FieldValue.increment(-oldModel.amount)});
      }
      
      // Apply new transaction logic
      final newWalletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(transaction.walletId);
      if (transaction.type == TransactionType.expense) {
        t.update(newWalletRef, {'balance': FieldValue.increment(-transaction.amount)});
      } else if (transaction.type == TransactionType.income) {
        t.update(newWalletRef, {'balance': FieldValue.increment(transaction.amount)});
      } else if (transaction.type == TransactionType.transfer && transaction.toWalletId != null) {
        t.update(newWalletRef, {'balance': FieldValue.increment(-transaction.amount)});
        final newToWalletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(transaction.toWalletId);
        t.update(newToWalletRef, {'balance': FieldValue.increment(transaction.amount)});
      }
      
      // Update transaction doc
      final newModel = TransactionModel.fromEntity(transaction);
      final modelMap = newModel.toFirestore();
      modelMap['updatedAt'] = FieldValue.serverTimestamp();
      
      t.update(transactionRef, modelMap);
    });
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _firestore.runTransaction((t) async {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId);
          
      final doc = await t.get(transactionRef);
      if (!doc.exists) return;
      
      final model = TransactionModel.fromFirestore(doc);
      
      // Revert balance
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(model.walletId);
      if (model.type == TransactionType.expense) {
        t.update(walletRef, {'balance': FieldValue.increment(model.amount)});
      } else if (model.type == TransactionType.income) {
        t.update(walletRef, {'balance': FieldValue.increment(-model.amount)});
      } else if (model.type == TransactionType.transfer && model.toWalletId != null) {
        t.update(walletRef, {'balance': FieldValue.increment(model.amount)});
        final toWalletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(model.toWalletId);
        t.update(toWalletRef, {'balance': FieldValue.increment(-model.amount)});
      }
      
      t.delete(transactionRef);
    });
  }
}
