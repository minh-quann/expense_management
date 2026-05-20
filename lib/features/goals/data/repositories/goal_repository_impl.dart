import 'dart:async';
import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final List<AppGoal> _goals = [];
  final _controller = StreamController<List<AppGoal>>.broadcast();

  GoalRepositoryImpl([dynamic _]);

  @override
  Stream<List<AppGoal>> getGoals(String userId) {
    _controller.add(List.unmodifiable(_goals));
    return _controller.stream;
  }

  @override
  Future<void> addGoal(String userId, AppGoal goal) async {
    _goals.add(goal);
    _controller.add(List.unmodifiable(_goals));
  }

  @override
  Future<void> updateGoal(String userId, AppGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      _controller.add(List.unmodifiable(_goals));
    }
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    _controller.add(List.unmodifiable(_goals));
  }

  @override
  Future<void> addFundsToGoal(String userId, String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final old = _goals[index];
      _goals[index] = AppGoal(
        id: old.id,
        name: old.name,
        targetAmount: old.targetAmount,
        currentAmount: old.currentAmount + amount,
        icon: old.icon,
        color: old.color,
        deadline: old.deadline,
        linkedWalletId: old.linkedWalletId,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _controller.add(List.unmodifiable(_goals));
    }
  }
}
