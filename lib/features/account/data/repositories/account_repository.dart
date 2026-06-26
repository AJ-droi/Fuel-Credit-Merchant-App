import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/branch_model.dart';
import '../models/profile_model.dart';

class AccountRepository {
  AccountRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<ProfileResponse>> fetchProfile() async {
    return _apiClient.get<ProfileResponse>(
      ApiEndpoints.merchantProfile,
      parser: (json) => ProfileResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<BranchesResponse>> fetchBranches() async {
    return _apiClient.get<BranchesResponse>(
      ApiEndpoints.merchantBranches,
      parser: (json) => BranchesResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<BranchDetailModel>> fetchBranchDetail(String branchId) {
    return _apiClient.get<BranchDetailModel>(
      ApiEndpoints.merchantBranch(branchId),
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return BranchDetailModel.fromJson(data);
        }
        return BranchDetailModel.fromJson(map);
      },
    );
  }

  Future<ApiResult<BranchModel>> updateBranch({
    required String branchId,
    String? name,
    String? address,
    String? city,
    String? lga,
    String? state,
    String? landmark,
    String? status,
    bool? isPrimary,
  }) {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (address != null) payload['address'] = address;
    if (city != null) payload['city'] = city;
    if (lga != null) payload['lga'] = lga;
    if (state != null) payload['state'] = state;
    if (landmark != null) payload['landmark'] = landmark;
    if (status != null) payload['status'] = status;
    if (isPrimary != null) payload['isPrimary'] = isPrimary;

    return _apiClient.patch<BranchModel>(
      ApiEndpoints.merchantBranch(branchId),
      data: payload,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return BranchModel.fromJson(data);
        }
        return BranchModel.fromJson(map);
      },
    );
  }

  Future<ApiResult<BranchModel>> createBranch({
    required String name,
    required String address,
    required String city,
    required String lga,
    required String state,
    required String landmark,
    bool isPrimary = false,
  }) async {
    return _apiClient.post<BranchModel>(
      ApiEndpoints.merchantBranches,
      data: {
        'name': name,
        'address': address,
        'city': city,
        'lga': lga,
        'state': state,
        'landmark': landmark,
        'isPrimary': isPrimary,
      },
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return BranchModel.fromJson(data);
        }
        return BranchModel.fromJson(map);
      },
    );
  }

  Future<ApiResult<bool>> updateFuelPrice(double fuelPricePerLitre) async {
    return _apiClient.put<bool>(
      ApiEndpoints.merchantFuelPrice,
      data: {'fuelPricePerLitre': fuelPricePerLitre},
      parser: (json) =>
          (json as Map<String, dynamic>)['success'] as bool? ?? true,
    );
  }
}
