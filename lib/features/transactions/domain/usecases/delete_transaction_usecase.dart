import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> call(String userId, String transactionId) {
    return repository.deleteTransaction(userId, transactionId);
  }
}
