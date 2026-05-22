import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';

class UpdateRecurringUseCase {
  final RecurringRepository repository;

  UpdateRecurringUseCase(this.repository);

  Future<void> call(String userId, AppRecurring recurring) {
    return repository.updateRecurring(userId, recurring);
  }
}
