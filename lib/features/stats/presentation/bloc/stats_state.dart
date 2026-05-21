import 'package:equatable/equatable.dart';
import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final TransactionStats stats;

  const StatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
