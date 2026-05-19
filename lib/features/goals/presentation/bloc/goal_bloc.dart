import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/goals/domain/entities/goal.dart';
import 'package:expense_management/features/goals/domain/repositories/goal_repository.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository repository;
  StreamSubscription? _subscription;

  GoalBloc({required this.repository}) : super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoalEvent>(_onAddGoal);
    on<UpdateGoalEvent>(_onUpdateGoal);
    on<DeleteGoalEvent>(_onDeleteGoal);
    on<AddFundsToGoalEvent>(_onAddFundsToGoal);
    on<_GoalsUpdated>((event, emit) => emit(GoalLoaded(event.goals)));
    on<_GoalError>((event, emit) => emit(GoalError(event.error)));
  }

  void _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) {
    emit(GoalLoading());
    _subscription?.cancel();
    _subscription = repository.getGoals(event.userId).listen(
      (goals) {
        if (!isClosed) {
          add(_GoalsUpdated(goals));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_GoalError(error.toString()));
        }
      },
    );
  }

  void _onAddGoal(AddGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await repository.addGoal(event.userId, event.goal);
    } catch (e) {
      emit(GoalError('Lỗi thêm mục tiêu: $e'));
    }
  }

  void _onUpdateGoal(UpdateGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await repository.updateGoal(event.userId, event.goal);
    } catch (e) {
      emit(GoalError('Lỗi cập nhật mục tiêu: $e'));
    }
  }

  void _onDeleteGoal(DeleteGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await repository.deleteGoal(event.userId, event.goalId);
    } catch (e) {
      emit(GoalError('Lỗi xoá mục tiêu: $e'));
    }
  }

  void _onAddFundsToGoal(AddFundsToGoalEvent event, Emitter<GoalState> emit) async {
    try {
      await repository.addFundsToGoal(event.userId, event.goalId, event.amount);
    } catch (e) {
      emit(GoalError('Lỗi thêm tiền vào mục tiêu: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _GoalsUpdated extends GoalEvent {
  final List<AppGoal> goals;
  const _GoalsUpdated(this.goals);
}

class _GoalError extends GoalEvent {
  final String error;
  const _GoalError(this.error);
}
