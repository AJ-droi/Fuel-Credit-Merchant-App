import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/dashboard_models.dart';
import 'dashboard_models.dart';

class DashboardKpiGrid extends StatefulWidget {
  const DashboardKpiGrid({super.key});

  @override
  State<DashboardKpiGrid> createState() => _DashboardKpiGridState();
}

class _DashboardKpiGridState extends State<DashboardKpiGrid> {
  late Future<ApiResult<DashboardSummary>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = AppServices.instance.dashboardRepository.fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult<DashboardSummary>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _DashboardSummaryLoading();
        }

        final result = snapshot.data!;
        switch (result) {
          case ApiSuccess<DashboardSummary> success:
            final summary = success.data.data;
            final cards = <KpiCardModel>[
              KpiCardModel(
                title: 'Today Sales',
                value: summary.today.salesCount.toString(),
                suffix: '',
                meta: summary.businessName,
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.secondary,
                backgroundColor: AppColors.kpiSalesBg,
              ),
              KpiCardModel(
                title: 'Gross Amount',
                value: _currency(summary.today.grossAmount),
                suffix: '',
                meta: 'Unsettled: ${_currency(summary.today.unsettledAmount)}',
                icon: Icons.payments_outlined,
                iconColor: AppColors.primaryContainer,
                backgroundColor: AppColors.kpiGrossBg,
              ),
              KpiCardModel(
                title: 'Pending Settlements',
                value: summary.pendingSettlements.count.toString(),
                suffix: '',
                meta: _currency(summary.pendingSettlements.totalAmount),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.tertiary,
                backgroundColor: AppColors.kpiSettlementBg,
                chip: summary.merchantId,
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
          case ApiFailure<DashboardSummary> failure:
            return _DashboardSummaryError(
              message: failure.error.message,
              onRetry: () {
                setState(() {
                  _summaryFuture = AppServices.instance.dashboardRepository.fetchSummary();
                });
              },
            );
        }
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
      backgroundColor: model.backgroundColor,
      borderColor: model.iconColor.withOpacity(0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model.title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: model.iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(model.icon, color: model.iconColor, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            model.value,
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (model.chip != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primaryContainer.withOpacity(0.12),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Text(
                model.chip!,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryContainer,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Text(
              model.meta,
              style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

class _DashboardSummaryLoading extends StatelessWidget {
  const _DashboardSummaryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardSummaryError extends StatelessWidget {
  const _DashboardSummaryError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String _currency(double amount) {
  return '₦${amount.toStringAsFixed(0)}';
}
