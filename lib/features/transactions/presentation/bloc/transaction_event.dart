import 'package:equatable/equatable.dart';
import 'package:expense_management/features/transactions/domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String userId;

  const LoadTransactions(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddTransactionEvent extends TransactionEvent {
  final String userId;
  final AppTransaction transaction;

  const AddTransactionEvent(this.userId, this.transaction);

  @override
  List<Object?> get props => [userId, transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final String userId;
  final AppTransaction transaction;

  const UpdateTransactionEvent(this.userId, this.transaction);

  @override
  List<Object?> get props => [userId, transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String userId;
  final String transactionId;

  const DeleteTransactionEvent(this.userId, this.transactionId);

  @override
  List<Object?> get props => [userId, transactionId];
}
