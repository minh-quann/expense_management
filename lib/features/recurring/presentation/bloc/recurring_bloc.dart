import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';
import 'recurring_event.dart';
import 'recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringRepository repository;
  StreamSubscription? _subscription;

  RecurringBloc({required this.repository}) : super(RecurringInitial()) {
    on<LoadRecurrings>(_onLoadRecurrings);
    on<AddRecurringEvent>(_onAddRecurring);
    on<UpdateRecurringEvent>(_onUpdateRecurring);
    on<DeleteRecurringEvent>(_onDeleteRecurring);
    on<_RecurringsUpdated>((event, emit) => emit(RecurringLoaded(event.recurrings)));
    on<_RecurringError>((event, emit) => emit(RecurringError(event.error)));
  }

  void _onLoadRecurrings(LoadRecurrings event, Emitter<RecurringState> emit) {
    emit(RecurringLoading());
    _subscription?.cancel();
    _subscription = repository.getRecurrings(event.userId).listen(
      (recurrings) {
        if (!isClosed) {
          add(_RecurringsUpdated(recurrings));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_RecurringError(error.toString()));
        }
      },
    );
  }

  void _onAddRecurring(AddRecurringEvent event, Emitter<RecurringState> emit) async {
    try {
      await repository.addRecurring(event.userId, event.recurring);
    } catch (e) {
      emit(RecurringError('Lỗi thêm giao dịch định kỳ: $e'));
    }
  }

  void _onUpdateRecurring(UpdateRecurringEvent event, Emitter<RecurringState> emit) async {
    try {
      await repository.updateRecurring(event.userId, event.recurring);
    } catch (e) {
      emit(RecurringError('Lỗi cập nhật giao dịch định kỳ: $e'));
    }
  }

  void _onDeleteRecurring(DeleteRecurringEvent event, Emitter<RecurringState> emit) async {
    try {
      await repository.deleteRecurring(event.userId, event.recurringId);
    } catch (e) {
      emit(RecurringError('Lỗi xoá giao dịch định kỳ: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _RecurringsUpdated extends RecurringEvent {
  final List<AppRecurring> recurrings;
  const _RecurringsUpdated(this.recurrings);
}

class _RecurringError extends RecurringEvent {
  final String error;
  const _RecurringError(this.error);
}
