import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: BorderRadius.circular(14),
          backgroundColor: AppColors.surfaceBright,
          borderColor: AppColors.primary.withOpacity(0.35),
          child: const Icon(
            Icons.local_gas_station_rounded,
            color: AppColors.primaryContainer,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        RichText(
          text: TextSpan(
            style: textTheme.headlineLarge,
            children: const [
              TextSpan(text: 'FUEL '),
              TextSpan(text: 'CREDIT', style: TextStyle(color: AppColors.secondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'MERCHANT PORTAL',
          style: textTheme.labelSmall?.copyWith(letterSpacing: 2.4),
        ),
      ],
    );
  }
}
