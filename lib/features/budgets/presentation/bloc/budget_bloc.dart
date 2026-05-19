import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/budgets/domain/entities/budget.dart';
import 'package:expense_management/features/budgets/domain/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository repository;
  StreamSubscription? _subscription;

  BudgetBloc({required this.repository}) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudgetEvent>(_onAddBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<_BudgetsUpdated>((event, emit) => emit(BudgetLoaded(event.budgets)));
    on<_BudgetError>((event, emit) => emit(BudgetError(event.error)));
  }

  void _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) {
    emit(BudgetLoading());
    _subscription?.cancel();
    _subscription = repository.getBudgets(event.userId).listen(
      (budgets) {
        if (!isClosed) {
          add(_BudgetsUpdated(budgets));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_BudgetError(error.toString()));
        }
      },
    );
  }

  void _onAddBudget(AddBudgetEvent event, Emitter<BudgetState> emit) async {
    try {
      await repository.addBudget(event.userId, event.budget);
    } catch (e) {
      emit(BudgetError('Lỗi thêm ngân sách: $e'));
    }
  }

  void _onUpdateBudget(UpdateBudgetEvent event, Emitter<BudgetState> emit) async {
    try {
      await repository.updateBudget(event.userId, event.budget);
    } catch (e) {
      emit(BudgetError('Lỗi cập nhật ngân sách: $e'));
    }
  }

  void _onDeleteBudget(DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    try {
      await repository.deleteBudget(event.userId, event.budgetId);
    } catch (e) {
      emit(BudgetError('Lỗi xoá ngân sách: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _BudgetsUpdated extends BudgetEvent {
  final List<AppBudget> budgets;
  const _BudgetsUpdated(this.budgets);
}

class _BudgetError extends BudgetEvent {
  final String error;
  const _BudgetError(this.error);
}
