import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';

class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  Future<void> call(String userId, String budgetId) {
    return repository.deleteBudget(userId, budgetId);
  }
}
