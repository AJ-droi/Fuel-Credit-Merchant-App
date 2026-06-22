import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../transactions/data/models/merchant_transaction.dart';

class DashboardTransactions extends StatefulWidget {
  const DashboardTransactions({super.key});

  @override
  State<DashboardTransactions> createState() => _DashboardTransactionsState();
}

class _DashboardTransactionsState extends State<DashboardTransactions> {
  late Future<ApiResult<List<MerchantTransaction>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = AppServices.instance.transactionsRepository.fetchTransactions(
      page: 1,
      limit: 3,
    );
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
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.transactions),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<ApiResult<List<MerchantTransaction>>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _TransactionsLoadingState();
            }

            final result = snapshot.data!;
            switch (result) {
              case ApiSuccess<List<MerchantTransaction>> success:
                if (success.data.isEmpty) {
                  return const _TransactionsEmptyState();
                }

                return Column(
                  children: [
                    for (final item in success.data) ...[
                      _TransactionCard(item: item),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              case ApiFailure<List<MerchantTransaction>> failure:
                return _TransactionsErrorState(
                  message: failure.error.message,
                  onRetry: () {
                    setState(() {
                      _transactionsFuture =
                          AppServices.instance.transactionsRepository.fetchTransactions(
                        page: 1,
                        limit: 3,
                      );
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Icon(
              item.isSuccessful
                  ? Icons.check_circle
                  : item.isPending
                      ? Icons.schedule
                      : Icons.error_outline,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.referenceCode,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                Text(
                  _timeLabel(item.createdAt),
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _litresLabel(item.fuelLitres),
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              Text(
                item.disbursementMethod.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currency(item.amount),
                style: textTheme.bodyMedium?.copyWith(color: statusColor),
              ),
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusLabel(item.status),
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
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
    return AppColors.secondary;
  }
  if (item.isPending) {
    return AppColors.tertiary;
  }
  return const Color(0xFFFFB4AB);
}

String _statusLabel(String status) {
  if (status.isEmpty) {
    return 'Unknown';
  }
  return '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';
}

String _currency(double amount) {
  return '₦${amount.toStringAsFixed(0)}';
}

String _litresLabel(double litres) {
  if (litres == litres.roundToDouble()) {
    return '${litres.toStringAsFixed(0)}L';
  }
  return '${litres.toStringAsFixed(1)}L';
}

String _timeLabel(DateTime? createdAt) {
  if (createdAt == null) {
    return 'Unknown time';
  }

  final now = DateTime.now().toUtc();
  final difference = now.difference(createdAt.toUtc());

  if (difference.inMinutes < 1) {
    return 'Just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes} mins ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours} hrs ago';
  }
  return '${difference.inDays} days ago';
}
