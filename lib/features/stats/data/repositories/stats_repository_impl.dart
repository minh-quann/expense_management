import 'package:expense_management/features/stats/data/datasources/stats_remote_datasource.dart';
import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';
import 'package:expense_management/features/stats/domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource _remoteDataSource;

  // Accept optional parameter for backwards compatibility
  StatsRepositoryImpl([dynamic _]) : _remoteDataSource = StatsRemoteDataSourceImpl();

  StatsRepositoryImpl.withDataSource(this._remoteDataSource);

  @override
  Future<TransactionStats> getStats({
    int? month,
    int? year,
    String? walletId,
  }) async {
    return _remoteDataSource.getStats(
      month: month,
      year: year,
      walletId: walletId,
    );
  }
}
