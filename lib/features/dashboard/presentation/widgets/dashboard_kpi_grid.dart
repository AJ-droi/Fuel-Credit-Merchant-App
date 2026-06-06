import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import 'dashboard_models.dart';

class DashboardKpiGrid extends StatelessWidget {
  const DashboardKpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <KpiCardModel>[
      const KpiCardModel(
        title: 'Pump Price',
        value: '₦650',
        suffix: '/L',
        meta: '+2.4% vs yesterday',
        icon: Icons.local_gas_station_rounded,
        iconColor: AppColors.secondary,
      ),
      const KpiCardModel(
        title: 'Total Litres Sold',
        value: '1,240',
        suffix: 'L',
        meta: '65% target reached',
        icon: Icons.opacity_rounded,
        iconColor: AppColors.primary,
      ),
      const KpiCardModel(
        title: 'Total Amount Sold',
        value: '₦806,000',
        suffix: '',
        meta: 'Daily target: 80%',
        icon: Icons.payments_outlined,
        iconColor: AppColors.tertiary,
        chip: 'DAILY TARGET: 80%',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 860;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: isDesktop ? 1.5 : 2.7,
          ),
          itemBuilder: (_, index) => _KpiCard(model: cards[index]),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.model});

  final KpiCardModel model;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model.title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
                ),
              ),
              Icon(model.icon, color: model.iconColor),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              text: model.value,
              style: textTheme.headlineLarge?.copyWith(color: Colors.white),
              children: [
                TextSpan(
                  text: model.suffix,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.primaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (model.chip != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0x33CC7F17),
                border: Border.all(color: const Color(0x66FFB86A)),
              ),
              child: Text(
                model.chip!,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.tertiary,
                  fontSize: 10,
                ),
              ),
            )
          else
            Text(
              model.meta,
              style: textTheme.labelSmall?.copyWith(
                color: model.meta.startsWith('+') ? AppColors.secondary : AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}
