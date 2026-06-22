import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/settlement_models.dart';

class SettlementRepository {
  const SettlementRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<MerchantSettlementList>> listSettlements({String? status}) {
    return _apiClient.get<MerchantSettlementList>(
      ApiEndpoints.merchantSettlements,
      queryParameters: status != null ? {'status': status} : null,
      parser: (json) => MerchantSettlementList.fromJson(json),
    );
  }

  Future<ApiResult<MerchantSettlement>> confirmSettlement(String settlementId) {
    return _apiClient.post<MerchantSettlement>(
      '${ApiEndpoints.merchantSettlements}/$settlementId/confirm',
      parser: (json) {
        final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
        final data = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : map;
        return MerchantSettlement.fromJson(data);
      },
    );
  }
}
