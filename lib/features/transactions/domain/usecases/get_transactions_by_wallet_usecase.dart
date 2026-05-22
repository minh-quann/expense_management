import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsByWalletUseCase {
  final TransactionRepository repository;

  GetTransactionsByWalletUseCase(this.repository);

  Stream<List<AppTransaction>> call(String userId, String walletId) {
    return repository.getTransactionsByWallet(userId, walletId);
  }
}
