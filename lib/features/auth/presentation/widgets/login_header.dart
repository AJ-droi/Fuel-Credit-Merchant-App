import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_gas_station_rounded,
            color: AppColors.accent,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'FUELCREDIT',
          style: textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'MERCHANT PORTAL',
          style: textTheme.labelSmall?.copyWith(
            letterSpacing: 2.4,
            color: AppColors.slate500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
