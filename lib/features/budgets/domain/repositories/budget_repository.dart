import 'package:expense_management/features/budgets/domain/entities/budget.dart';

abstract class BudgetRepository {
  Stream<List<AppBudget>> getBudgets(String userId);
  Future<void> addBudget(String userId, AppBudget budget);
  Future<void> updateBudget(String userId, AppBudget budget);
  Future<void> deleteBudget(String userId, String budgetId);
}
