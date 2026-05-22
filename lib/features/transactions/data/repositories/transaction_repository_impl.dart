import 'dart:async';
import 'package:expense_management/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  final _transactionsController = StreamController<List<AppTransaction>>.broadcast();

  // Accept optional parameter to maintain backwards compatibility with Firebase configuration
  TransactionRepositoryImpl([dynamic _]) : _remoteDataSource = TransactionRemoteDataSourceImpl();

  TransactionRepositoryImpl.withDataSource(this._remoteDataSource);

  Future<void> _fetchAndEmit(String userId, [String? walletId]) async {
    try {
      final list = await _remoteDataSource.getTransactions(walletId: walletId);
      _transactionsController.add(list);
    } catch (e) {
      _transactionsController.addError(e);
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
    await _remoteDataSource.addTransaction(transaction);
    await _fetchAndEmit(userId);
  }

  @override
  Future<void> updateTransaction(String userId, AppTransaction transaction) async {
    await _remoteDataSource.updateTransaction(transaction);
    await _fetchAndEmit(userId);
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _remoteDataSource.deleteTransaction(transactionId);
    await _fetchAndEmit(userId);
  }
}
