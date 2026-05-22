import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';

class DeleteRecurringUseCase {
  final RecurringRepository repository;

  DeleteRecurringUseCase(this.repository);

  Future<void> call(String userId, String recurringId) {
    return repository.deleteRecurring(userId, recurringId);
  }
}
