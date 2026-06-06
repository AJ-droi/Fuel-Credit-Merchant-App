final class ApiConfig {
  const ApiConfig._();

  // Update with your backend host, e.g. https://api.fuelops.ng
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
