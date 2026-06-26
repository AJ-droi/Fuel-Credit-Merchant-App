import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class DashboardBottomShell extends StatelessWidget {
  const DashboardBottomShell({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryContainer.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active ? Border.all(color: AppColors.primary.withOpacity(0.35)) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: active ? AppColors.primaryContainer : AppColors.muted),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: active ? AppColors.primaryContainer : AppColors.muted,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
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
                  navItem(icon: Icons.dashboard_rounded, label: 'Dashboard', active: true),
                  navItem(
                    icon: Icons.local_gas_station_rounded,
                    label: 'Fuel Sale',
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
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 72,
            child: SizedBox(
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.fuelSale),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                  icon: const Icon(Icons.local_gas_station_rounded, color: AppColors.onPrimary),
                  label: Text(
                    'Sell Fuel',
                    style: textTheme.headlineSmall?.copyWith(color: AppColors.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
