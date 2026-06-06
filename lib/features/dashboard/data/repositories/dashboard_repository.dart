import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  const DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<DashboardSummary>> fetchSummary() {
    return _apiClient.get<DashboardSummary>(
      ApiEndpoints.dashboardSummary,
      parser: (json) => DashboardSummary.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<DashboardTransaction>>> fetchTransactions() {
    return _apiClient.get<List<DashboardTransaction>>(
      ApiEndpoints.dashboardTransactions,
      parser: (json) {
        final list = (json as List<dynamic>? ?? <dynamic>[])
            .map((e) => DashboardTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      },
    );
  }
}
