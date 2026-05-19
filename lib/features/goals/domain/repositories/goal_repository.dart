import 'package:expense_management/features/goals/domain/entities/goal.dart';

abstract class GoalRepository {
  Stream<List<AppGoal>> getGoals(String userId);
  Future<void> addGoal(String userId, AppGoal goal);
  Future<void> updateGoal(String userId, AppGoal goal);
  Future<void> deleteGoal(String userId, String goalId);
  Future<void> addFundsToGoal(String userId, String goalId, double amount);
}
