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
                iconColor: AppColors.primary,
                backgroundColor: AppColors.kpiSalesBg,
              ),
              KpiCardModel(
                title: 'Gross Amount',
                value: _currency(summary.today.grossAmount),
                suffix: '',
                meta: 'Unsettled: ${_currency(summary.today.unsettledAmount)}',
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFFA16207),
                backgroundColor: AppColors.kpiGrossBg,
              ),
              KpiCardModel(
                title: 'Pending Settlements',
                value: summary.pendingSettlements.count.toString(),
                suffix: '',
                meta: _currency(summary.pendingSettlements.totalAmount),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.slate700,
                backgroundColor: AppColors.kpiSettlementBg,
                chip: summary.merchantId,
              ),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 860;
                final isWide = constraints.maxWidth > 520;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop || isWide ? 3 : 1,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: isDesktop
                        ? 2.35
                        : isWide
                            ? 1.55
                            : 3.1,
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
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: model.backgroundColor,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: model.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(model.icon, color: model.iconColor, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            model.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              height: 1.1,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          if (model.chip != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.primary.withOpacity(0.1),
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: Text(
                model.chip!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Text(
              model.meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
                fontSize: 10,
              ),
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
