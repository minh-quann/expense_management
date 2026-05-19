import 'package:equatable/equatable.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';

abstract class RecurringState extends Equatable {
  const RecurringState();

  @override
  List<Object?> get props => [];
}

class RecurringInitial extends RecurringState {}

class RecurringLoading extends RecurringState {}

class RecurringLoaded extends RecurringState {
  final List<AppRecurring> recurrings;

  const RecurringLoaded(this.recurrings);

  @override
  List<Object?> get props => [recurrings];
}

class RecurringError extends RecurringState {
  final String message;

  const RecurringError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecurringOperationSuccess extends RecurringState {}
