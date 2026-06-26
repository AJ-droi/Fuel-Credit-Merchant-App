import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SettlementBottomNav extends StatelessWidget {
  const SettlementBottomNav({super.key});

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
              color: active ? AppColors.primaryLight.withOpacity(0.4) : Colors.transparent,
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
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A3A3541),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          navItem(
            icon: Icons.local_gas_station_rounded,
            label: 'Sales',
            active: false,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.fuelSale),
          ),
          navItem(
            icon: Icons.history_rounded,
            label: 'History',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.transactions),
          ),
          navItem(
            icon: Icons.group_rounded,
            label: 'Staff',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.management),
          ),
          navItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Settlement',
            active: true,
            onTap: () {},
          ),
          navItem(
            icon: Icons.person_outline_rounded,
            label: 'Account',
            active: false,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.account),
          ),
        ],
      ),
    );
  }
}
