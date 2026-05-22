import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';
import 'package:expense_management/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:expense_management/features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final UpdateTransactionUseCase _updateTransactionUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  StreamSubscription? _transactionsSubscription;

  TransactionBloc({
    required TransactionRepository repository,
    GetTransactionsUseCase? getTransactionsUseCase,
    AddTransactionUseCase? addTransactionUseCase,
    UpdateTransactionUseCase? updateTransactionUseCase,
    DeleteTransactionUseCase? deleteTransactionUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase ?? GetTransactionsUseCase(repository),
        _addTransactionUseCase = addTransactionUseCase ?? AddTransactionUseCase(repository),
        _updateTransactionUseCase = updateTransactionUseCase ?? UpdateTransactionUseCase(repository),
        _deleteTransactionUseCase = deleteTransactionUseCase ?? DeleteTransactionUseCase(repository),
        super(TransactionInitial()) {
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
    _transactionsSubscription = _getTransactionsUseCase(event.userId).listen(
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
      await _addTransactionUseCase(event.userId, event.transaction);
    } catch (e) {
      emit(TransactionError('Lỗi thêm giao dịch: $e'));
    }
  }

  void _onUpdateTransaction(UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await _updateTransactionUseCase(event.userId, event.transaction);
    } catch (e) {
      emit(TransactionError('Lỗi cập nhật giao dịch: $e'));
    }
  }

  void _onDeleteTransaction(DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await _deleteTransactionUseCase(event.userId, event.transactionId);
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
