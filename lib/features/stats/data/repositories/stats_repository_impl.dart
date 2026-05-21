import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/stats/data/models/transaction_stats_model.dart';
import 'package:expense_management/features/stats/domain/entities/transaction_stats.dart';
import 'package:expense_management/features/stats/domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<TransactionStats> getStats({
    int? month,
    int? year,
    String? walletId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (month != null) {
      queryParams['month'] = month;
    }
    if (year != null) {
      queryParams['year'] = year;
    }
    if (walletId != null && walletId.isNotEmpty) {
      queryParams['wallet_id'] = walletId;
    }

    final response = await _apiClient.dio.get(
      '/transactions/statistics',
      queryParameters: queryParams,
    );

    return TransactionStatsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
