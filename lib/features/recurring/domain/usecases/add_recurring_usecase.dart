import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';

class AddRecurringUseCase {
  final RecurringRepository repository;

  AddRecurringUseCase(this.repository);

  Future<void> call(String userId, AppRecurring recurring) {
    return repository.addRecurring(userId, recurring);
  }
}
