import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PaymentAlertBottomNav extends StatelessWidget {
  const PaymentAlertBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget navItem({
      required IconData icon,
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: active ? const Color(0x3300B954) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: active ? AppColors.secondary : AppColors.muted),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: active ? AppColors.secondary : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 10),
      decoration: const BoxDecoration(
        color: Color(0xCC122131),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          navItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            active: false,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.dashboard),
          ),
          navItem(
            icon: Icons.ev_station_rounded,
            label: 'Fuel Sale',
            active: true,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.fuelSale),
          ),
          navItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Settlement',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.settlement),
          ),
          navItem(
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
