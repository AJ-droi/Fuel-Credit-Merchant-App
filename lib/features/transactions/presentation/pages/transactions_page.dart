import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/merchant_transaction.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late Future<ApiResult<List<MerchantTransaction>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _loadTransactions();
  }

  Future<ApiResult<List<MerchantTransaction>>> _loadTransactions() {
    return AppServices.instance.transactionsRepository.fetchTransactions(
      page: 1,
      limit: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: FutureBuilder<ApiResult<List<MerchantTransaction>>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final result = snapshot.data!;
            switch (result) {
              case ApiSuccess<List<MerchantTransaction>> success:
                if (success.data.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }

                return ListView.separated(
                  itemCount: success.data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return _TransactionListTile(item: success.data[index]);
                  },
                );
              case ApiFailure<List<MerchantTransaction>> failure:
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        failure.error.message,
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _transactionsFuture = _loadTransactions();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _TransactionListTile extends StatelessWidget {
  const _TransactionListTile({required this.item});

  final MerchantTransaction item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(item);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.businessName.isEmpty ? item.referenceCode : item.businessName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusLabel(item.status),
                  style: textTheme.labelSmall?.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaBlock(label: 'Reference', value: item.referenceCode),
              _MetaBlock(label: 'Amount', value: _currency(item.amount)),
              _MetaBlock(label: 'Fuel Litres', value: _litresLabel(item.fuelLitres)),
              _MetaBlock(label: 'Method', value: item.disbursementMethod.toUpperCase()),
              _MetaBlock(label: 'Price/L', value: _currency(item.pricePerLitre)),
              _MetaBlock(label: 'Date', value: _fullDateLabel(item.createdAt)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
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

String _fullDateLabel(DateTime? createdAt) {
  if (createdAt == null) {
    return 'Unknown';
  }

  final local = createdAt.toLocal();
  final month = <String>[
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
  ][local.month - 1];

  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month ${local.day}, ${local.year} $hour:$minute';
}
