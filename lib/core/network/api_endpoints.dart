final class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';

  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardTransactions = '/dashboard/transactions';

  static const String fuelSaleCreate = '/fuel-sales';
  static const String fuelSaleGenerateQr = '/fuel-sales/qr';

  static const String settlements = '/settlements';
  static const String settlementsRequest = '/settlements/request';

  static const String merchantProfile = '/merchant/profile';
}
