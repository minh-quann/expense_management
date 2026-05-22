import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';
import 'package:expense_management/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_management/features/recurring/domain/usecases/get_recurrings_usecase.dart';
import 'package:expense_management/features/recurring/domain/usecases/add_recurring_usecase.dart';
import 'package:expense_management/features/recurring/domain/usecases/update_recurring_usecase.dart';
import 'package:expense_management/features/recurring/domain/usecases/delete_recurring_usecase.dart';
import 'recurring_event.dart';
import 'recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final GetRecurringsUseCase _getRecurringsUseCase;
  final AddRecurringUseCase _addRecurringUseCase;
  final UpdateRecurringUseCase _updateRecurringUseCase;
  final DeleteRecurringUseCase _deleteRecurringUseCase;
  StreamSubscription? _subscription;

  RecurringBloc({
    required RecurringRepository repository,
    GetRecurringsUseCase? getRecurringsUseCase,
    AddRecurringUseCase? addRecurringUseCase,
    UpdateRecurringUseCase? updateRecurringUseCase,
    DeleteRecurringUseCase? deleteRecurringUseCase,
  })  : _getRecurringsUseCase = getRecurringsUseCase ?? GetRecurringsUseCase(repository),
        _addRecurringUseCase = addRecurringUseCase ?? AddRecurringUseCase(repository),
        _updateRecurringUseCase = updateRecurringUseCase ?? UpdateRecurringUseCase(repository),
        _deleteRecurringUseCase = deleteRecurringUseCase ?? DeleteRecurringUseCase(repository),
        super(RecurringInitial()) {
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
    _subscription = _getRecurringsUseCase(event.userId).listen(
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
      await _addRecurringUseCase(event.userId, event.recurring);
    } catch (e) {
      emit(RecurringError('Lỗi thêm giao dịch định kỳ: $e'));
    }
  }

  void _onUpdateRecurring(UpdateRecurringEvent event, Emitter<RecurringState> emit) async {
    try {
      await _updateRecurringUseCase(event.userId, event.recurring);
    } catch (e) {
      emit(RecurringError('Lỗi cập nhật giao dịch định kỳ: $e'));
    }
  }

  void _onDeleteRecurring(DeleteRecurringEvent event, Emitter<RecurringState> emit) async {
    try {
      await _deleteRecurringUseCase(event.userId, event.recurringId);
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
