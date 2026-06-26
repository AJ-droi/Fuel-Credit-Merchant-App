import 'package:flutter/material.dart';

import '../../features/account/presentation/pages/account_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/fuel_sale/presentation/pages/fuel_sale_page.dart';
import '../../features/payment_alert/presentation/pages/payment_alert_page.dart';
import '../../features/settlement/presentation/pages/settlement_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/management/presentation/pages/management_page.dart';
import '../../features/management/presentation/pages/create_branch_page.dart';
import '../../features/management/presentation/pages/branch_detail_page.dart';
import '../../features/management/presentation/pages/edit_branch_page.dart';
import '../../features/management/presentation/pages/staff_detail_page.dart';

final class AppRouter {
  const AppRouter._();

  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String fuelSale = '/fuel-sale';
  static const String paymentAlert = '/payment-alert';
  static const String settlement = '/settlement';
  static const String account = '/account';
  static const String transactions = '/transactions';
  static const String management = '/management';
  static const String createBranch = '/management/create-branch';
  static const String branchDetail = '/management/branch';
  static const String editBranch = '/management/branch/edit';
  static const String staffDetail = '/management/staff';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
      case fuelSale:
        return MaterialPageRoute<void>(
          builder: (_) => const FuelSalePage(),
          settings: settings,
        );
      case paymentAlert:
        final args = settings.arguments;
        if (args is PaymentAlertArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => PaymentAlertPage(args: args),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case settlement:
        return MaterialPageRoute<void>(
          builder: (_) => const SettlementPage(),
          settings: settings,
        );
      case account:
        return MaterialPageRoute<void>(
          builder: (_) => const AccountPage(),
          settings: settings,
        );
      case transactions:
        return MaterialPageRoute<void>(
          builder: (_) => const TransactionsPage(),
          settings: settings,
        );
      case management:
        return MaterialPageRoute<void>(
          builder: (_) => const ManagementPage(),
          settings: settings,
        );
      case createBranch:
        return MaterialPageRoute<bool>(
          builder: (_) => const CreateBranchPage(),
          settings: settings,
        );
      case branchDetail:
        final branchId = settings.arguments as String?;
        if (branchId == null || branchId.isEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => const ManagementPage(),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => BranchDetailPage(branchId: branchId),
          settings: settings,
        );
      case editBranch:
        final branchId = settings.arguments as String?;
        if (branchId == null || branchId.isEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => const ManagementPage(),
            settings: settings,
          );
        }
        return MaterialPageRoute<bool>(
          builder: (_) => EditBranchPage(branchId: branchId),
          settings: settings,
        );
      case staffDetail:
        final sellerId = settings.arguments as String?;
        if (sellerId == null || sellerId.isEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => const ManagementPage(),
            settings: settings,
          );
        }
        return MaterialPageRoute<bool>(
          builder: (_) => StaffDetailPage(sellerId: sellerId),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
