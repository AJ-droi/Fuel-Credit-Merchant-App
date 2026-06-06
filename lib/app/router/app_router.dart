import 'package:flutter/material.dart';

import '../../features/account/presentation/pages/account_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/fuel_sale/presentation/pages/fuel_sale_page.dart';
import '../../features/payment_alert/presentation/pages/payment_alert_page.dart';
import '../../features/settlement/presentation/pages/settlement_page.dart';

final class AppRouter {
  const AppRouter._();

  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String fuelSale = '/fuel-sale';
  static const String paymentAlert = '/payment-alert';
  static const String settlement = '/settlement';
  static const String account = '/account';

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
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
