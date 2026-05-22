import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';

class GetRecurringsUseCase {
  final RecurringRepository repository;

  GetRecurringsUseCase(this.repository);

  Stream<List<AppRecurring>> call(String userId) {
    return repository.getRecurrings(userId);
  }
}
