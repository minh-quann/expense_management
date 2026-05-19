import 'package:expense_management/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<AppTransaction>> getTransactions(String userId);
  Stream<List<AppTransaction>> getTransactionsByWallet(String userId, String walletId);
  Future<void> addTransaction(String userId, AppTransaction transaction);
  Future<void> updateTransaction(String userId, AppTransaction transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
}
