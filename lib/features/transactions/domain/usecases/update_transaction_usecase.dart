import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<void> call(String userId, AppTransaction transaction) {
    return repository.updateTransaction(userId, transaction);
  }
}
