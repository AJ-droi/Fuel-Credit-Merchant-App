import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/login_models.dart';

class AuthRepository {
  const AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<ApiResult<LoginResponse>> login(LoginRequest request) async {
    final result = await _apiClient.post<LoginResponse>(
      ApiEndpoints.login,
      data: request.toJson(),
      parser: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );

    if (result case ApiSuccess<LoginResponse>(:final data)) {
      if (data.success && data.accessToken.isNotEmpty) {
        await _tokenStorage.saveSession(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
      }
    }

    return result;
  }

  Future<ApiResult<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _apiClient.post<bool>(
      ApiEndpoints.changePassword,
      data: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      parser: (json) =>
          (json as Map<String, dynamic>)['success'] as bool? ?? true,
    );
  }

  Future<void> logout() => _tokenStorage.clear();
}
