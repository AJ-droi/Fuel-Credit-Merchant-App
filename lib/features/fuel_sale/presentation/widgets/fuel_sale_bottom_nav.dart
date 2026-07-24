import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class FuelSaleBottomNav extends StatelessWidget {
  const FuelSaleBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Container(
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
          navItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: false,
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.dashboard),
          ),
          navItem(
            icon: Icons.bolt_rounded,
            label: 'Sell',
            active: true,
            onTap: () {},
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
    );
  }
}
