import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class AddFundsToGoalUseCase {
  final GoalRepository repository;

  AddFundsToGoalUseCase(this.repository);

  Future<void> call(String userId, String goalId, double amount) {
    return repository.addFundsToGoal(userId, goalId, amount);
  }
}
