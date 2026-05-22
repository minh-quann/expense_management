import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  Stream<List<AppBudget>> call(String userId) {
    return repository.getBudgets(userId);
  }
}
