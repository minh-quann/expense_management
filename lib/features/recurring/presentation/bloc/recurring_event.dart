import 'package:equatable/equatable.dart';
import 'package:expense_management/features/recurring/domain/entities/recurring.dart';

abstract class RecurringEvent extends Equatable {
  const RecurringEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecurrings extends RecurringEvent {
  final String userId;

  const LoadRecurrings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddRecurringEvent extends RecurringEvent {
  final String userId;
  final AppRecurring recurring;

  const AddRecurringEvent(this.userId, this.recurring);

  @override
  List<Object?> get props => [userId, recurring];
}

class UpdateRecurringEvent extends RecurringEvent {
  final String userId;
  final AppRecurring recurring;

  const UpdateRecurringEvent(this.userId, this.recurring);

  @override
  List<Object?> get props => [userId, recurring];
}

class DeleteRecurringEvent extends RecurringEvent {
  final String userId;
  final String recurringId;

  const DeleteRecurringEvent(this.userId, this.recurringId);

  @override
  List<Object?> get props => [userId, recurringId];
}
