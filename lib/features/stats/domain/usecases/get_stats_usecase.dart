import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';
import 'package:expense_management/features/stats/domain/repositories/stats_repository.dart';

class GetStatsUseCase {
  final StatsRepository repository;

  GetStatsUseCase(this.repository);

  Future<TransactionStats> call({
    int? month,
    int? year,
    String? walletId,
  }) {
    return repository.getStats(
      month: month,
      year: year,
      walletId: walletId,
    );
  }
}
