import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class DeleteGoalUseCase {
  final GoalRepository repository;

  DeleteGoalUseCase(this.repository);

  Future<void> call(String userId, String goalId) {
    return repository.deleteGoal(userId, goalId);
  }
}
