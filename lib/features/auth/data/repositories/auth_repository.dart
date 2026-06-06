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

    if (result is ApiSuccess<LoginResponse>) {
      final token = result.data.accessToken;
      if (token.isNotEmpty) {
        await _tokenStorage.saveAccessToken(token);
      }
    }

    return result;
  }

  Future<void> logout() => _tokenStorage.clear();
}
