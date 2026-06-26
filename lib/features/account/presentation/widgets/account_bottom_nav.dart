import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AccountBottomNav extends StatelessWidget {
  const AccountBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget navItem({
      required IconData icon,
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      final labelStyle = textTheme.labelSmall?.copyWith(
        color: active ? AppColors.primaryContainer : AppColors.muted,
        fontSize: 10,
        height: 1,
        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
      );

      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryContainer.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: active ? Border.all(color: AppColors.primary.withOpacity(0.35)) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: active ? AppColors.primaryContainer : AppColors.muted,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        10,
      ),
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
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            active: false,
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(AppRouter.dashboard),
          ),
          navItem(
            icon: Icons.ev_station_rounded,
            label: 'Fuel Sale',
            active: false,
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(AppRouter.fuelSale),
          ),
          navItem(
            icon: Icons.group_rounded,
            label: 'Staff',
            active: false,
            onTap: () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRouter.management),
          ),
          navItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Settlements',
            active: false,
            onTap: () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRouter.settlement),
          ),
          navItem(
            icon: Icons.person,
            label: 'Profile',
            active: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
