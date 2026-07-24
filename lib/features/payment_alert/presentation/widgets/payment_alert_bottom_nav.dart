import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/merchant_bottom_nav_style.dart';

class PaymentAlertBottomNav extends StatelessWidget {
  const PaymentAlertBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
      decoration: merchantNavBarDecoration(),
      child: Row(
        children: [
          merchantNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: false,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.dashboard),
          ),
          merchantNavItem(
            icon: Icons.bolt_rounded,
            label: 'Sell',
            active: true,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.fuelSale),
          ),
          merchantNavItem(
            icon: Icons.group_rounded,
            label: 'Staff',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.management),
          ),
          merchantNavItem(
            icon: Icons.payments_outlined,
            label: 'Settle',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.settlement),
          ),
          merchantNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.account),
          ),
        ],
      ),
    );
  }
}
