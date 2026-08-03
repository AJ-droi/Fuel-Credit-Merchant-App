import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../management/data/models/paginated_sales_model.dart';
import '../../data/models/merchant_transaction.dart';

enum _TxnRange { all, today, week, month }

enum _TxnStatusFilter { all, completed, pending, failed }

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final List<MerchantTransaction> _items = [];
  var _page = 1;
  var _hasMore = false;
  var _isLoading = false;
  var _initialized = false;
  String? _error;
  _TxnRange _range = _TxnRange.all;
  _TxnStatusFilter _status = _TxnStatusFilter.all;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  ({String? fromDate, String? toDate}) _dateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_range) {
      case _TxnRange.all:
        return (fromDate: null, toDate: null);
      case _TxnRange.today:
        return (
          fromDate: today.toIso8601String(),
          toDate: today.add(const Duration(days: 1)).toIso8601String(),
        );
      case _TxnRange.week:
        return (
          fromDate: today.subtract(const Duration(days: 7)).toIso8601String(),
          toDate: now.toIso8601String(),
        );
      case _TxnRange.month:
        return (
          fromDate: today.subtract(const Duration(days: 30)).toIso8601String(),
          toDate: now.toIso8601String(),
        );
    }
  }

  String? _statusQuery() {
    switch (_status) {
      case _TxnStatusFilter.all:
        return null;
      case _TxnStatusFilter.completed:
        return 'completed';
      case _TxnStatusFilter.pending:
        return 'awaiting_confirmation';
      case _TxnStatusFilter.failed:
        return 'failed';
    }
  }

  Future<void> _load({required bool reset}) async {
    if (_isLoading) return;

    if (reset) {
      _page = 1;
      _items.clear();
      _error = null;
    }

    setState(() => _isLoading = true);

    final range = _dateRange();
    final result = await AppServices.instance.transactionsRepository.fetchTransactions(
      page: _page,
      limit: 20,
      fromDate: range.fromDate,
      toDate: range.toDate,
      status: _statusQuery(),
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    if (!mounted) return;

    if (result case ApiSuccess<PaginatedSalesResponse> success) {
      setState(() {
        _items.addAll(success.data.items);
        _hasMore = success.data.hasMore;
        _isLoading = false;
        _initialized = true;
      });
    } else if (result case ApiFailure<PaginatedSalesResponse> failure) {
      setState(() {
        _error = failure.error.message;
        _isLoading = false;
        _initialized = true;
      });
    }
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
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : () => _load(reset: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sales history',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: '$_sortBy|$_sortOrder',
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: 'createdAt|desc',
                      child: Text('Newest'),
                    ),
                    DropdownMenuItem(
                      value: 'createdAt|asc',
                      child: Text('Oldest'),
                    ),
                    DropdownMenuItem(
                      value: 'amount|desc',
                      child: Text('Amount high'),
                    ),
                    DropdownMenuItem(
                      value: 'amount|asc',
                      child: Text('Amount low'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    final parts = value.split('|');
                    setState(() {
                      _sortBy = parts[0];
                      _sortOrder = parts[1];
                    });
                    _load(reset: true);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _TxnRange.values.map((range) {
                  final selected = _range == range;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(_rangeLabel(range)),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _range = range);
                        _load(reset: true);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _TxnStatusFilter.values.map((status) {
                  final selected = _status == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(_statusFilterLabel(status)),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _status = status);
                        _load(reset: true);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildList(textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(TextTheme textTheme) {
    if (!_initialized && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => _load(reset: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty && !_isLoading) {
      return const Center(child: Text('No transactions found.'));
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return TextButton(
              onPressed: () {
                _page += 1;
                _load(reset: false);
              },
              child: const Text('Load more'),
            );
          }
          return _TransactionListTile(
            item: _items[index],
            onReportCustomer: _items[index].userId == null ||
                    _items[index].userId!.isEmpty
                ? null
                : () => _reportCustomer(_items[index]),
          );
        },
      ),
    );
  }

  String _rangeLabel(_TxnRange range) {
    switch (range) {
      case _TxnRange.all:
        return 'All time';
      case _TxnRange.today:
        return 'Today';
      case _TxnRange.week:
        return '7 days';
      case _TxnRange.month:
        return '30 days';
    }
  }

  String _statusFilterLabel(_TxnStatusFilter status) {
    switch (status) {
      case _TxnStatusFilter.all:
        return 'All status';
      case _TxnStatusFilter.completed:
        return 'Completed';
      case _TxnStatusFilter.pending:
        return 'Pending';
      case _TxnStatusFilter.failed:
        return 'Failed';
    }
  }

  Future<void> _reportCustomer(MerchantTransaction item) async {
    final customerUserId = item.userId;
    if (customerUserId == null || customerUserId.isEmpty) return;

    const reasons = <String, String>{
      'fraud': 'Fraud / scam',
      'harassment': 'Harassment',
      'inappropriate_behavior': 'Inappropriate behavior',
      'safety_concern': 'Safety concern',
      'other': 'Other',
    };

    var selectedReason = 'other';
    final detailsCtrl = TextEditingController();
    var submitting = false;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Report customer',
                style: TextStyle(color: AppColors.onBackground),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.customerName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.customerName!,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      items: reasons.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: submitting
                          ? null
                          : (value) {
                              if (value == null) return;
                              setDialogState(() => selectedReason = value);
                            },
                      decoration: const InputDecoration(labelText: 'Reason'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsCtrl,
                      maxLines: 4,
                      enabled: !submitting,
                      decoration: const InputDecoration(
                        labelText: 'Details',
                        hintText: 'Describe what happened (min 10 characters)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      submitting ? null : () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final details = detailsCtrl.text.trim();
                          if (details.length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please add a bit more detail.'),
                              ),
                            );
                            return;
                          }
                          setDialogState(() => submitting = true);
                          final result = await AppServices
                              .instance.accountRepository
                              .reportCustomer(
                            customerUserId: customerUserId,
                            reason: selectedReason,
                            details: details,
                            transactionId: item.id,
                          );
                          if (!ctx.mounted) return;
                          if (result case ApiFailure(:final error)) {
                            setDialogState(() => submitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                            return;
                          }
                          Navigator.of(ctx).pop(true);
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    detailsCtrl.dispose();
    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Our team will review it.')),
      );
    }
  }
}

class _TransactionListTile extends StatelessWidget {
  const _TransactionListTile({
    required this.item,
    this.onReportCustomer,
  });

  final MerchantTransaction item;
  final VoidCallback? onReportCustomer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(item);
    final title =
        item.businessName.isEmpty ? item.referenceCode : item.businessName;

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
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusLabel(item.status),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(color: statusColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetaBlock(
            label: 'Reference',
            value: item.referenceCode,
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetaBlock(label: 'Amount', value: _currency(item.amount)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetaBlock(
                  label: 'Fuel Litres',
                  value: _litresLabel(item.fuelLitres),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetaBlock(
                  label: 'Method',
                  value: item.disbursementMethod.toUpperCase(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetaBlock(
                  label: 'Price/L',
                  value: _currency(item.pricePerLitre),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetaBlock(
            label: 'Date',
            value: _fullDateLabel(item.createdAt),
            fullWidth: true,
          ),
          if (onReportCustomer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onReportCustomer,
                icon: const Icon(Icons.flag_outlined, size: 18, color: AppColors.danger),
                label: const Text(
                  'Report customer',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.onBackground),
          ),
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
    return AppColors.secondary;
  }
  return AppColors.danger;
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
