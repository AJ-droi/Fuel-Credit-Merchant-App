final class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';

  static const String merchantDashboard = '/merchant/dashboard';
  static const String merchantSettlements = '/merchant/settlements';
  static const String merchantSalesSnapshots = '/merchant/sales-snapshots';

  static const String fuelSaleCreate = '/merchant/fuel-sales';
  static const String fuelSaleGenerateQr = '/merchant/fuel-sales/qr';

  static const String merchantProfile = '/merchant/profile';
}
