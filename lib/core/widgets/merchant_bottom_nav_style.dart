import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared bottom-nav item styling for merchant screens.
Widget merchantNavItem({
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

BoxDecoration merchantNavBarDecoration() {
  return BoxDecoration(
    color: AppColors.navBar,
    border: const Border(top: BorderSide(color: AppColors.slate200)),
    boxShadow: [
      BoxShadow(
        color: AppColors.slate900.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, -4),
      ),
    ],
  );
}
