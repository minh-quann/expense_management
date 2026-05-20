import 'dart:async';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_management/features/transactions/data/models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final ApiClient _apiClient = ApiClient();
  final _transactionsController = StreamController<List<AppTransaction>>.broadcast();

  // Accept optional firestore parameter to maintain backwards compatibility during migration
  TransactionRepositoryImpl([dynamic _]);

  // Helper method to fetch from backend and update stream
  Future<void> _fetchAndEmit(String userId, [String? walletId]) async {
    try {
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
      _transactionsController.add(list);
    } catch (e) {
      _transactionsController.addError(e);
    }
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

  @override
  Stream<List<AppTransaction>> getTransactions(String userId) {
    _fetchAndEmit(userId);
    return _transactionsController.stream;
  }

  @override
  Stream<List<AppTransaction>> getTransactionsByWallet(String userId, String walletId) {
    _fetchAndEmit(userId, walletId);
    return _transactionsController.stream;
  }

  @override
  Future<void> addTransaction(String userId, AppTransaction transaction) async {
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
    // Trigger reload
    await _fetchAndEmit(userId);
  }

  @override
  Future<void> updateTransaction(String userId, AppTransaction transaction) async {
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
    // Trigger reload
    await _fetchAndEmit(userId);
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _apiClient.dio.delete('/transactions/$transactionId');
    // Trigger reload
    await _fetchAndEmit(userId);
  }
}
