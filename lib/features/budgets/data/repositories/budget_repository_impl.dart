import 'dart:async';
import 'package:expense_management/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource _localDataSource;
  final _controller = StreamController<List<AppBudget>>.broadcast();

  // Accept optional parameter for backwards compatibility
  BudgetRepositoryImpl([dynamic _]) : _localDataSource = BudgetLocalDataSourceImpl();

  BudgetRepositoryImpl.withDataSource(this._localDataSource);

  Future<void> _fetchAndEmit() async {
    try {
      final list = await _localDataSource.getBudgets();
      _controller.add(list);
    } catch (e) {
      _controller.addError(e);
    }
  }

  @override
  Stream<List<AppBudget>> getBudgets(String userId) {
    _fetchAndEmit();
    return _controller.stream;
  }

  @override
  Future<void> addBudget(String userId, AppBudget budget) async {
    await _localDataSource.addBudget(budget);
    await _fetchAndEmit();
  }

  @override
  Future<void> updateBudget(String userId, AppBudget budget) async {
    await _localDataSource.updateBudget(budget);
    await _fetchAndEmit();
  }

  @override
  Future<void> deleteBudget(String userId, String budgetId) async {
    await _localDataSource.deleteBudget(budgetId);
    await _fetchAndEmit();
  }
}
