import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;
  StreamSubscription? _transactionsSubscription;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<_TransactionsUpdated>((event, emit) => emit(TransactionLoaded(event.transactions)));
    on<_TransactionsError>((event, emit) => emit(TransactionError(event.error)));
  }

  void _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) {
    emit(TransactionLoading());
    _transactionsSubscription?.cancel();
    _transactionsSubscription = repository.getTransactions(event.userId).listen(
      (transactions) {
        if (!isClosed) {
          add(_TransactionsUpdated(transactions));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(_TransactionsError(error.toString()));
        }
      },
    );
  }

  void _onAddTransaction(AddTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await repository.addTransaction(event.userId, event.transaction);
      // We don't emit a loaded state here since the stream subscription handles updates
      // But we can emit a success state if we want to show a toast, though usually 
      // listening to stream is enough. To be safe, emit operation success and then load?
      // Stream will automatically push new list.
    } catch (e) {
      emit(TransactionError('Lỗi thêm giao dịch: $e'));
    }
  }

  void _onUpdateTransaction(UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await repository.updateTransaction(event.userId, event.transaction);
    } catch (e) {
      emit(TransactionError('Lỗi cập nhật giao dịch: $e'));
    }
  }

  void _onDeleteTransaction(DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await repository.deleteTransaction(event.userId, event.transactionId);
    } catch (e) {
      emit(TransactionError('Lỗi xoá giao dịch: $e'));
    }
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}

class _TransactionsUpdated extends TransactionEvent {
  final List<AppTransaction> transactions;
  const _TransactionsUpdated(this.transactions);
}

class _TransactionsError extends TransactionEvent {
  final String error;
  const _TransactionsError(this.error);
}
