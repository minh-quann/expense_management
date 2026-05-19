import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';

class TransactionModel extends AppTransaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    super.categoryId,
    super.categoryName,
    super.categoryIcon,
    required super.walletId,
    super.walletName,
    super.toWalletId,
    super.toWalletName,
    required super.date,
    super.note,
    super.imageUrl,
    super.recurringId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    TransactionType type;
    final typeString = data['type'] as String?;
    if (typeString == 'INCOME') {
      type = TransactionType.income;
    } else if (typeString == 'TRANSFER') {
      type = TransactionType.transfer;
    } else {
      type = TransactionType.expense;
    }

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      type: type,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      categoryIcon: data['categoryIcon'] as String?,
      walletId: data['walletId'] as String? ?? '',
      walletName: data['walletName'] as String?,
      toWalletId: data['toWalletId'] as String?,
      toWalletName: data['toWalletName'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
      imageUrl: data['imageUrl'] as String?,
      recurringId: data['recurringId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    String typeString;
    switch (type) {
      case TransactionType.income:
        typeString = 'INCOME';
        break;
      case TransactionType.transfer:
        typeString = 'TRANSFER';
        break;
      case TransactionType.expense:
        typeString = 'EXPENSE';
        break;
    }

    return {
      'amount': amount,
      'type': typeString,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'walletId': walletId,
      'walletName': walletName,
      'toWalletId': toWalletId,
      'toWalletName': toWalletName,
      'date': Timestamp.fromDate(date),
      'note': note,
      'imageUrl': imageUrl,
      'recurringId': recurringId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TransactionModel.fromEntity(AppTransaction entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      walletId: entity.walletId,
      walletName: entity.walletName,
      toWalletId: entity.toWalletId,
      toWalletName: entity.toWalletName,
      date: entity.date,
      note: entity.note,
      imageUrl: entity.imageUrl,
      recurringId: entity.recurringId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
