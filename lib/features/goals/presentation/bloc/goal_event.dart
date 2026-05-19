import 'package:equatable/equatable.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {
  final String userId;

  const LoadGoals(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddGoalEvent extends GoalEvent {
  final String userId;
  final AppGoal goal;

  const AddGoalEvent(this.userId, this.goal);

  @override
  List<Object?> get props => [userId, goal];
}

class UpdateGoalEvent extends GoalEvent {
  final String userId;
  final AppGoal goal;

  const UpdateGoalEvent(this.userId, this.goal);

  @override
  List<Object?> get props => [userId, goal];
}

class DeleteGoalEvent extends GoalEvent {
  final String userId;
  final String goalId;

  const DeleteGoalEvent(this.userId, this.goalId);

  @override
  List<Object?> get props => [userId, goalId];
}

class AddFundsToGoalEvent extends GoalEvent {
  final String userId;
  final String goalId;
  final double amount;

  const AddFundsToGoalEvent(this.userId, this.goalId, this.amount);

  @override
  List<Object?> get props => [userId, goalId, amount];
}
