import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/settlement_models.dart';

class SettlementRepository {
  const SettlementRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<RequestSettlementResponse>> requestSettlement(
    RequestSettlementRequest request,
  ) {
    return _apiClient.post<RequestSettlementResponse>(
      ApiEndpoints.settlementsRequest,
      data: request.toJson(),
      parser: (json) => RequestSettlementResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
