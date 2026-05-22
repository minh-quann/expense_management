import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<void> call(String userId, AppBudget budget) {
    return repository.updateBudget(userId, budget);
  }
}
