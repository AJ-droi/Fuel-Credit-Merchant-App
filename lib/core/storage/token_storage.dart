import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static final TokenStorage instance = TokenStorage._();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_display_name';
  static const _userRoleKey = 'user_role';
  static const _userEmailKey = 'user_email';

  String? _accessToken;
  String? _refreshToken;
  String? _userName;
  String? _userRole;
  String? _userEmail;

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
    String? displayName,
    String? role,
    String? email,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    if (displayName != null && displayName.trim().isNotEmpty) {
      _userName = displayName.trim();
      await prefs.setString(_userNameKey, _userName!);
    }
    if (role != null) {
      _userRole = role;
      await prefs.setString(_userRoleKey, role);
    }
    if (email != null) {
      _userEmail = email;
      await prefs.setString(_userEmailKey, email);
    }
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

  Future<String?> getUserDisplayName() async {
    if (_userName != null && _userName!.isNotEmpty) {
      return _userName;
    }
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey);
    return _userName;
  }

  Future<String?> getUserRole() async {
    if (_userRole != null && _userRole!.isNotEmpty) {
      return _userRole;
    }
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString(_userRoleKey);
    return _userRole;
  }

  Future<String?> getUserEmail() async {
    if (_userEmail != null && _userEmail!.isNotEmpty) {
      return _userEmail;
    }
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString(_userEmailKey);
    return _userEmail;
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userName = null;
    _userRole = null;
    _userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userEmailKey);
  }
}
