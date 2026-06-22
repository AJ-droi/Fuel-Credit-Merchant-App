import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/seller_model.dart';

class ManagementRepository {
  const ManagementRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<SellersResponse>> fetchSellers() {
    return _apiClient.get<SellersResponse>(
      ApiEndpoints.merchantSellers,
      parser: (json) => SellersResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<bool>> inviteSeller({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String branchId,
  }) {
    return _apiClient.post<bool>(
      ApiEndpoints.merchantInviteSeller,
      data: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'branchId': branchId,
      },
      parser: (json) =>
          (json as Map<String, dynamic>)['success'] as bool? ?? true,
    );
  }
}
