import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Override with: `--dart-define=API_BASE_URL=https://...`
  static const String _definedApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _productionApiBaseUrl =
      'https://fuel-lending-app.onrender.com/api/v1';

  static const String _localApiBaseUrl = 'http://localhost:4000/api/v1';

  /// Always ends with `/` so Dio relative paths resolve under `/api/v1`.
  /// Debug/profile → local API; release → production (unless dart-define set).
  static String get apiBaseUrl {
    final raw = _definedApiBaseUrl.isNotEmpty
        ? _definedApiBaseUrl
        : kReleaseMode
            ? _productionApiBaseUrl
            : _localApiBaseUrl;
    return raw.endsWith('/') ? raw : '$raw/';
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
