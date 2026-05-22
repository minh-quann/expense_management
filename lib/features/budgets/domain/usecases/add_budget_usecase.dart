import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';

class AddBudgetUseCase {
  final BudgetRepository repository;

  AddBudgetUseCase(this.repository);

  Future<void> call(String userId, AppBudget budget) {
    return repository.addBudget(userId, budget);
  }
}
