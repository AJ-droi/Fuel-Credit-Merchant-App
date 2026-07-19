class AppConfig {
  AppConfig._();

  /// Override with: `--dart-define=API_BASE_URL=https://...`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fuel-lending-app.onrender.com/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
