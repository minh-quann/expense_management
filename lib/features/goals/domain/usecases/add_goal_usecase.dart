import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class AddGoalUseCase {
  final GoalRepository repository;

  AddGoalUseCase(this.repository);

  Future<void> call(String userId, AppGoal goal) {
    return repository.addGoal(userId, goal);
  }
}
