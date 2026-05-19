import 'package:equatable/equatable.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {
  final String userId;

  const LoadBudgets(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddBudgetEvent extends BudgetEvent {
  final String userId;
  final AppBudget budget;

  const AddBudgetEvent(this.userId, this.budget);

  @override
  List<Object?> get props => [userId, budget];
}

class UpdateBudgetEvent extends BudgetEvent {
  final String userId;
  final AppBudget budget;

  const UpdateBudgetEvent(this.userId, this.budget);

  @override
  List<Object?> get props => [userId, budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String userId;
  final String budgetId;

  const DeleteBudgetEvent(this.userId, this.budgetId);

  @override
  List<Object?> get props => [userId, budgetId];
}
