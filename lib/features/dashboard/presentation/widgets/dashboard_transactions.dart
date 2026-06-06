import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import 'dashboard_models.dart';

class DashboardTransactions extends StatelessWidget {
  const DashboardTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const transactions = <TransactionModel>[
      TransactionModel(
        code: 'KNTC-8821',
        timeAgo: '2 mins ago',
        litres: '45L',
        product: 'PMS Premium',
        amount: '₦29,250',
        verified: true,
      ),
      TransactionModel(
        code: 'LAG-4022',
        timeAgo: '8 mins ago',
        litres: '20L',
        product: 'PMS Premium',
        amount: '₦13,000',
        verified: true,
      ),
      TransactionModel(
        code: 'TAX-1192',
        timeAgo: '15 mins ago',
        litres: '62L',
        product: 'Diesel',
        amount: '₦68,200',
        verified: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Recent Transactions', style: textTheme.headlineSmall),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in transactions) ...[
          _TransactionCard(item: item),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.item});

  final TransactionModel item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x3300B954),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x664AE176)),
            ),
            child: Icon(
              item.verified ? Icons.check_circle : Icons.history,
              color: item.verified ? AppColors.secondary : AppColors.muted,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.code, style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
                Text(item.timeAgo, style: textTheme.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.litres, style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
              Text(item.product, style: textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.amount, style: textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0x224AE176),
                  border: Border.all(color: const Color(0x664AE176)),
                ),
                child: Text(
                  item.verified ? 'Verified' : 'Pending',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
