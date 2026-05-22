import 'package:expense_management/features/budgets/data/models/budget_model.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> addBudget(AppBudget budget);
  Future<void> updateBudget(AppBudget budget);
  Future<void> deleteBudget(String budgetId);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final List<BudgetModel> _budgets = [];

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return List.from(_budgets);
  }

  @override
  Future<void> addBudget(AppBudget budget) async {
    _budgets.add(BudgetModel.fromEntity(budget));
  }

  @override
  Future<void> updateBudget(AppBudget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = BudgetModel.fromEntity(budget);
    }
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    _budgets.removeWhere((b) => b.id == budgetId);
  }
}
