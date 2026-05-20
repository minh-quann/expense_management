import 'dart:async';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final List<AppBudget> _budgets = [];
  final _controller = StreamController<List<AppBudget>>.broadcast();

  BudgetRepositoryImpl([dynamic _]);

  @override
  Stream<List<AppBudget>> getBudgets(String userId) {
    _controller.add(List.unmodifiable(_budgets));
    return _controller.stream;
  }

  @override
  Future<void> addBudget(String userId, AppBudget budget) async {
    _budgets.add(budget);
    _controller.add(List.unmodifiable(_budgets));
  }

  @override
  Future<void> updateBudget(String userId, AppBudget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      _controller.add(List.unmodifiable(_budgets));
    }
  }

  @override
  Future<void> deleteBudget(String userId, String budgetId) async {
    _budgets.removeWhere((b) => b.id == budgetId);
    _controller.add(List.unmodifiable(_budgets));
  }
}
