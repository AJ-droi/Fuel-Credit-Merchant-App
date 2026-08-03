final class ApiEndpoints {
  const ApiEndpoints._();

  // Paths are relative (no leading `/`) so Dio keeps the `/api/v1` base path.
  static const String login = 'auth/login';
  static const String changePassword = 'auth/change-password';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';

  static const String merchantDashboard = 'merchant/dashboard';
  static const String dashboardSummary = merchantDashboard;
  static const String dashboardTransactions = 'merchant/transactions';
  static const String merchantFuelPrice = 'merchant/fuel-price';

  static const String merchantSettlements = 'merchant/settlements';
  static const String merchantSalesSnapshots = 'merchant/sales-snapshots';

  static const String fuelSaleCreate = 'merchant/disbursements/purchase-id';
  static const String fuelSaleGenerateQr = 'merchant/disbursements/qr';
  static String merchantTransaction(String transactionId) =>
      'merchant/transactions/$transactionId';

  static const String merchantProfile = 'merchant/profile';
  static const String merchantAccount = 'merchant/account';
  static const String merchantTransactions = 'merchant/transactions';
  static const String merchantBranches = 'merchant/branches';
  static const String merchantSellers = 'merchant/sellers';
  static const String merchantInviteSeller = 'merchant/sellers/invite';
  static const String merchantSales = 'merchant/sales';
  static const String reportReasons = 'reports/reasons';

  static String merchantBranch(String branchId) => 'merchant/branches/$branchId';
  static String merchantSeller(String sellerId) => 'merchant/sellers/$sellerId';
  static String merchantSellerSales(String sellerId) =>
      'merchant/sellers/$sellerId/sales';
  static String reportCustomer(String customerUserId) =>
      'reports/customers/$customerUserId';

  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
  static const String notificationsReadAll = 'notifications/read-all';
  static String notificationRead(String id) => 'notifications/$id/read';
}
