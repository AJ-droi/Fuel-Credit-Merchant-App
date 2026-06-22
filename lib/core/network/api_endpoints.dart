final class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String changePassword = '/auth/change-password';

  static const String merchantDashboard = '/merchant/dashboard';
  static const String dashboardSummary = merchantDashboard;
  static const String dashboardTransactions = '/merchant/transactions';
  static const String merchantFuelPrice = '/merchant/fuel-price';

  static const String merchantSettlements = '/merchant/settlements';
  static const String merchantSalesSnapshots = '/merchant/sales-snapshots';

  static const String fuelSaleCreate = '/merchant/disbursements/purchase-id';
  static const String fuelSaleGenerateQr = '/merchant/disbursements/qr';

  static const String merchantProfile = '/merchant/profile';
  static const String merchantTransactions = '/merchant/transactions';
  static const String merchantBranches = '/merchant/branches';
  static const String merchantSellers = '/merchant/sellers';
  static const String merchantInviteSeller = '/merchant/sellers/invite';
}
