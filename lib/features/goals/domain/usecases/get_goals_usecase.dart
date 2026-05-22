import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';

class GetGoalsUseCase {
  final GoalRepository repository;

  GetGoalsUseCase(this.repository);

  Stream<List<AppGoal>> call(String userId) {
    return repository.getGoals(userId);
  }
}
