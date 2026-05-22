import 'dart:async';
import 'package:expense_management/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource _localDataSource;
  final _controller = StreamController<List<AppGoal>>.broadcast();

  // Accept optional parameter for backwards compatibility
  GoalRepositoryImpl([dynamic _]) : _localDataSource = GoalLocalDataSourceImpl();

  GoalRepositoryImpl.withDataSource(this._localDataSource);

  Future<void> _fetchAndEmit() async {
    try {
      final list = await _localDataSource.getGoals();
      _controller.add(list);
    } catch (e) {
      _controller.addError(e);
    }
  }

  @override
  Stream<List<AppGoal>> getGoals(String userId) {
    _fetchAndEmit();
    return _controller.stream;
  }

  @override
  Future<void> addGoal(String userId, AppGoal goal) async {
    await _localDataSource.addGoal(goal);
    await _fetchAndEmit();
  }

  @override
  Future<void> updateGoal(String userId, AppGoal goal) async {
    await _localDataSource.updateGoal(goal);
    await _fetchAndEmit();
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _localDataSource.deleteGoal(goalId);
    await _fetchAndEmit();
  }

  @override
  Future<void> addFundsToGoal(String userId, String goalId, double amount) async {
    await _localDataSource.addFundsToGoal(goalId, amount);
    await _fetchAndEmit();
  }
}
