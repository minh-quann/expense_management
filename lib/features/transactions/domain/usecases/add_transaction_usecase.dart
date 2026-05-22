import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> call(String userId, AppTransaction transaction) {
    return repository.addTransaction(userId, transaction);
  }
}
