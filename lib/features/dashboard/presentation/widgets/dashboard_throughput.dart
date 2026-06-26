import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class DashboardThroughput extends StatelessWidget {
  const DashboardThroughput({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget stat(String value, String suffix, String label, Color color,
        {bool leftBorder = false}) {
      return Container(
        decoration: BoxDecoration(
          border: leftBorder ? const Border(left: BorderSide(color: AppColors.border)) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                text: value,
                style: textTheme.displayLarge?.copyWith(color: color),
                children: [
                  TextSpan(text: suffix, style: textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: textTheme.labelSmall),
          ],
        ),
      );
    }

    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 16, color: AppColors.muted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Station Throughput Efficiency'.toUpperCase(),
                style: textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: AppSpacing.md,
            spacing: AppSpacing.md,
            children: [
              stat('94', '%', 'Uptime', AppColors.primary),
              stat('4.2', 'm', 'Avg Fill Time', AppColors.secondary, leftBorder: true),
              stat('12', 'k', 'Ltrs/Month', AppColors.tertiary, leftBorder: true),
              stat('0', '%', 'Discrepancy', const Color(0xFFFFB4AB), leftBorder: true),
            ],
          ),
        ],
      ),
    );
  }
}
