import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class DashboardBottomShell extends StatelessWidget {
  const DashboardBottomShell({super.key});

  @override
  Widget build(BuildContext context) {
    Widget navItem({
      required IconData icon,
      required String label,
      required bool active,
      VoidCallback? onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: active ? AppColors.primary : AppColors.slate400,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.primary : AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 136,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 72,
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
              decoration: BoxDecoration(
                color: AppColors.navBar,
                border: const Border(top: BorderSide(color: AppColors.slate200)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slate900.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  navItem(icon: Icons.home_rounded, label: 'Home', active: true),
                  navItem(
                    icon: Icons.bolt_rounded,
                    label: 'Sell',
                    active: false,
                    onTap: () => Navigator.of(context).pushNamed(AppRouter.fuelSale),
                  ),
                  navItem(
                    icon: Icons.group_rounded,
                    label: 'Staff',
                    active: false,
                    onTap: () => Navigator.of(context).pushNamed(AppRouter.management),
                  ),
                  navItem(
                    icon: Icons.payments_outlined,
                    label: 'Settle',
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
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 72,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRouter.fuelSale),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.local_gas_station_rounded),
                label: const Text(
                  'Sell Fuel',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
