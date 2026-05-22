import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/stats/data/models/transaction_stats_model.dart';

abstract class StatsRemoteDataSource {
  Future<TransactionStatsModel> getStats({
    int? month,
    int? year,
    String? walletId,
  });
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final ApiClient _apiClient;

  StatsRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<TransactionStatsModel> getStats({
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
