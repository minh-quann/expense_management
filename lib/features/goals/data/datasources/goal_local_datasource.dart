import 'package:expense_management/features/goals/data/models/goal_model.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';

abstract class GoalLocalDataSource {
  Future<List<GoalModel>> getGoals();
  Future<void> addGoal(AppGoal goal);
  Future<void> updateGoal(AppGoal goal);
  Future<void> deleteGoal(String goalId);
  Future<void> addFundsToGoal(String goalId, double amount);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final List<GoalModel> _goals = [];

  @override
  Future<List<GoalModel>> getGoals() async {
    return List.from(_goals);
  }

  @override
  Future<void> addGoal(AppGoal goal) async {
    _goals.add(GoalModel.fromEntity(goal));
  }

  @override
  Future<void> updateGoal(AppGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = GoalModel.fromEntity(goal);
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<void> addFundsToGoal(String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final old = _goals[index];
      _goals[index] = GoalModel(
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
    }
  }
}
