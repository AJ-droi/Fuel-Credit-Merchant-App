final class ApiEndpoints {
  const ApiEndpoints._();

  static const String login = '/auth/login';
  static const String changePassword = '/auth/change-password';

  static const String dashboardSummary = '/merchant/dashboard';
  static const String dashboardTransactions = '/merchant/transactions';
  static const String merchantFuelPrice = '/merchant/fuel-price';

  static const String fuelSaleCreate = '/fuel-sales';
  static const String fuelSaleGenerateQr = '/merchant/disbursements/qr';

  static const String settlements = '/settlements';
  static const String settlementsRequest = '/settlements/request';

  static const String merchantProfile = '/merchant/profile';
  static const String merchantTransactions = '/merchant/transactions';
  static const String merchantBranches = '/merchant/branches';
  static const String merchantSellers = '/merchant/sellers';
  static const String merchantInviteSeller = '/merchant/sellers/invite';
}
