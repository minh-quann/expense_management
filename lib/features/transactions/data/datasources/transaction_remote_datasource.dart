import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/transactions/data/models/transaction_model.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({String? walletId});
  Future<void> addTransaction(AppTransaction transaction);
  Future<void> updateTransaction(AppTransaction transaction);
  Future<void> deleteTransaction(String transactionId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient _apiClient;

  TransactionRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<TransactionModel>> getTransactions({String? walletId}) async {
    final queryParams = <String, dynamic>{};
    if (walletId != null && walletId.isNotEmpty) {
      queryParams['wallet_id'] = walletId;
    }

    final response = await _apiClient.dio.get('/transactions', queryParameters: queryParams);
    
    final list = (response.data as List).map((json) {
      final categoryMap = json['category'] as Map<String, dynamic>?;
      final walletMap = json['wallet'] as Map<String, dynamic>?;
      final toWalletMap = json['to_wallet'] as Map<String, dynamic>?;

      return TransactionModel(
        id: json['id'],
        amount: (json['amount'] ?? 0.0).toDouble(),
        type: _parseTransactionType(json['type']),
        categoryId: json['category_id'],
        categoryName: categoryMap?['name'],
        categoryIcon: categoryMap?['icon'],
        categoryColor: categoryMap?['color'],
        walletId: json['wallet_id'] ?? '',
        walletName: walletMap?['name'],
        toWalletId: json['to_wallet_id'],
        toWalletName: toWalletMap?['name'],
        date: DateTime.parse(json['date']),
        note: json['note'] ?? '',
        imageUrl: json['image_url'] ?? '',
        recurringId: json['recurring_id'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at']) 
            : DateTime.now(),
      );
    }).toList();

    return list;
  }

  @override
  Future<void> addTransaction(AppTransaction transaction) async {
    await _apiClient.dio.post('/transactions', data: {
      'amount': transaction.amount,
      'type': _transactionTypeToString(transaction.type),
      'category_id': transaction.categoryId,
      'wallet_id': transaction.walletId,
      'to_wallet_id': transaction.toWalletId,
      'date': transaction.date.toUtc().toIso8601String(),
      'note': transaction.note ?? '',
      'image_url': transaction.imageUrl ?? '',
      'recurring_id': transaction.recurringId,
    });
  }

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {
    await _apiClient.dio.put('/transactions/${transaction.id}', data: {
      'amount': transaction.amount,
      'type': _transactionTypeToString(transaction.type),
      'category_id': transaction.categoryId,
      'wallet_id': transaction.walletId,
      'to_wallet_id': transaction.toWalletId,
      'date': transaction.date.toUtc().toIso8601String(),
      'note': transaction.note ?? '',
      'image_url': transaction.imageUrl ?? '',
      'recurring_id': transaction.recurringId,
    });
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _apiClient.dio.delete('/transactions/$transactionId');
  }

  static TransactionType _parseTransactionType(String typeStr) {
    switch (typeStr) {
      case 'INCOME':
        return TransactionType.income;
      case 'TRANSFER':
        return TransactionType.transfer;
      case 'EXPENSE':
      default:
        return TransactionType.expense;
    }
  }

  static String _transactionTypeToString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.transfer:
        return 'TRANSFER';
      case TransactionType.expense:
        return 'EXPENSE';
    }
  }
}
