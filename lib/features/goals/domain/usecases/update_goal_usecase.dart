import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class UpdateGoalUseCase {
  final GoalRepository repository;

  UpdateGoalUseCase(this.repository);

  Future<void> call(String userId, AppGoal goal) {
    return repository.updateGoal(userId, goal);
  }
}
