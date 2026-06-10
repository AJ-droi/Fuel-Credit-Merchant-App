import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static final TokenStorage instance = TokenStorage._();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return _accessToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      return _refreshToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _refreshToken = prefs.getString(_refreshTokenKey);
    return _refreshToken;
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
