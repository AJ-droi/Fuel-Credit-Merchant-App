import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../management/data/models/paginated_sales_model.dart';
import '../../../transactions/data/models/merchant_transaction.dart';

class DashboardTransactions extends StatefulWidget {
  const DashboardTransactions({super.key});

  @override
  State<DashboardTransactions> createState() => _DashboardTransactionsState();
}

class _DashboardTransactionsState extends State<DashboardTransactions> {
  static const _limit = 5;

  late Future<ApiResult<PaginatedSalesResponse>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = AppServices.instance.transactionsRepository
        .fetchTransactions(page: 1, limit: _limit);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Recent Transactions', style: textTheme.headlineSmall),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.transactions),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<ApiResult<PaginatedSalesResponse>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _TransactionsLoadingState();
            }

            final result = snapshot.data!;
            switch (result) {
              case ApiSuccess<PaginatedSalesResponse> success:
                if (success.data.items.isEmpty) {
                  return const _TransactionsEmptyState();
                }

                return Column(
                  children: [
                    for (final item in success.data.items) ...[
                      _TransactionCard(item: item),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              case ApiFailure<PaginatedSalesResponse> failure:
                return _TransactionsErrorState(
                  message: failure.error.message,
                  onRetry: () {
                    setState(() {
                      _transactionsFuture = AppServices
                          .instance.transactionsRepository
                          .fetchTransactions(page: 1, limit: _limit);
                    });
                  },
                );
            }
          },
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.item});

  final MerchantTransaction item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(item);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _litresLabel(item.fuelLitres),
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: statusColor.withOpacity(0.12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusLabel(item.status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaChip(
                label: 'Type',
                value: _purchaseTypeLabel(item.disbursementMethod),
              ),
              _MetaChip(
                label: 'Created',
                value: _createdAtLabel(item.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.slate500,
              fontSize: 9,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsLoadingState extends StatelessWidget {
  const _TransactionsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _TransactionsEmptyState extends StatelessWidget {
  const _TransactionsEmptyState();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: BorderRadius.circular(12),
      child: const Center(
        child: Text('No transactions yet.'),
      ),
    );
  }
}

class _TransactionsErrorState extends StatelessWidget {
  const _TransactionsErrorState({
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

Color _statusColor(MerchantTransaction item) {
  if (item.isSuccessful) {
    return AppColors.primary;
  }
  if (item.isPending) {
    return const Color(0xFFA16207);
  }
  return AppColors.danger;
}

String _statusLabel(String status) {
  if (status.isEmpty) {
    return 'Unknown';
  }
  return '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';
}

String _litresLabel(double litres) {
  if (litres == litres.roundToDouble()) {
    return '${litres.toStringAsFixed(0)} L';
  }
  return '${litres.toStringAsFixed(1)} L';
}

String _purchaseTypeLabel(String method) {
  final normalized = method.trim().toLowerCase();
  switch (normalized) {
    case 'qr':
      return 'QR';
    case 'purchase_id':
    case 'purchase-id':
    case 'purchaseid':
      return 'Purchase ID';
    default:
      if (method.isEmpty) return 'Unknown';
      return method
          .replaceAll('_', ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
          .join(' ');
  }
}

String _createdAtLabel(DateTime? createdAt) {
  if (createdAt == null) {
    return 'Unknown';
  }
  final local = createdAt.toLocal();
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = local.day.toString().padLeft(2, '0');
  final month = months[local.month - 1];
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day $month ${local.year}, $hour:$minute';
}
