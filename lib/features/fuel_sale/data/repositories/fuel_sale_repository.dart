import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/fuel_sale_models.dart';

class FuelSaleRepository {
  const FuelSaleRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<FuelSaleResponse>> createSale(CreateFuelSaleRequest request) {
    return _apiClient.post<FuelSaleResponse>(
      ApiEndpoints.fuelSaleCreate,
      data: request.toJson(),
      parser: (json) => FuelSaleResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<QrPaymentResponse>> generateQr(CreateFuelSaleRequest request) {
    return _apiClient.post<QrPaymentResponse>(
      ApiEndpoints.fuelSaleGenerateQr,
      data: request.toJson(),
      parser: (json) => QrPaymentResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
