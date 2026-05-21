import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';

abstract class StatsRepository {
  Future<TransactionStats> getStats({
    int? month,
    int? year,
    String? walletId,
  });
}
