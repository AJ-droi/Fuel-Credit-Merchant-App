import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/paginated_sales_model.dart';
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

  Future<ApiResult<SellerModel>> fetchSeller(String sellerId) {
    return _apiClient.get<SellerModel>(
      ApiEndpoints.merchantSeller(sellerId),
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return SellerModel.fromJson(data);
        }
        return SellerModel.fromJson(map);
      },
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

  Future<ApiResult<SellerModel>> updateSeller({
    required String sellerId,
    String? firstName,
    String? lastName,
    String? phone,
    String? branchId,
    String? accountStatus,
  }) {
    final payload = <String, dynamic>{};
    if (firstName != null) payload['firstName'] = firstName;
    if (lastName != null) payload['lastName'] = lastName;
    if (phone != null) payload['phone'] = phone;
    if (branchId != null) payload['branchId'] = branchId;
    if (accountStatus != null) payload['accountStatus'] = accountStatus;

    return _apiClient.patch<SellerModel>(
      ApiEndpoints.merchantSeller(sellerId),
      data: payload,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return SellerModel.fromJson(data);
        }
        return SellerModel.fromJson(map);
      },
    );
  }

  Future<ApiResult<bool>> deactivateSeller(String sellerId) {
    return _apiClient.delete<bool>(
      ApiEndpoints.merchantSeller(sellerId),
      parser: (json) =>
          (json as Map<String, dynamic>)['success'] as bool? ?? true,
    );
  }

  Future<ApiResult<PaginatedSalesResponse>> fetchSellerSales({
    required String sellerId,
    int page = 1,
    int limit = 20,
    String? fromDate,
    String? toDate,
    String sortBy = 'completedAt',
    String sortOrder = 'desc',
  }) {
    return _apiClient.get<PaginatedSalesResponse>(
      ApiEndpoints.merchantSellerSales(sellerId),
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (fromDate != null) 'fromDate': fromDate,
        if (toDate != null) 'toDate': toDate,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
      parser: (json) =>
          PaginatedSalesResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<PaginatedSalesResponse>> fetchBranchSales({
    required String branchId,
    int page = 1,
    int limit = 20,
    String? fromDate,
    String? toDate,
    String sortBy = 'completedAt',
    String sortOrder = 'desc',
  }) {
    return _apiClient.get<PaginatedSalesResponse>(
      ApiEndpoints.merchantSales,
      queryParameters: <String, dynamic>{
        'branchId': branchId,
        'page': page,
        'limit': limit,
        if (fromDate != null) 'fromDate': fromDate,
        if (toDate != null) 'toDate': toDate,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
      parser: (json) =>
          PaginatedSalesResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
