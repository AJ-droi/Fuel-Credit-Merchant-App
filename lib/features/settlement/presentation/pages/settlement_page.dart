import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/settlement_models.dart';
import '../widgets/settlement_bottom_nav.dart';

enum _SettlementFilter { actionNeeded, pending, confirmed, all }

class SettlementPage extends StatefulWidget {
  const SettlementPage({super.key});

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  bool _loading = true;
  String? _error;
  List<MerchantSettlement> _items = const [];
  _SettlementFilter _filter = _SettlementFilter.actionNeeded;
  String? _confirmingId;

  @override
  void initState() {
    super.initState();
    _loadSettlements();
  }

  Future<void> _loadSettlements() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AppServices.instance.settlementRepository.listSettlements();

    if (!mounted) return;

    switch (result) {
      case ApiSuccess<MerchantSettlementList>(:final data):
        setState(() {
          _items = _sorted(data.items);
          _loading = false;
          if (_filter == _SettlementFilter.actionNeeded &&
              data.items.where((s) => s.status == 'paid').isEmpty &&
              data.items.isNotEmpty) {
            _filter = _SettlementFilter.all;
          }
        });
      case ApiFailure<MerchantSettlementList>(:final error):
        setState(() {
          _error = error.message;
          _loading = false;
        });
    }
  }

  List<MerchantSettlement> _sorted(List<MerchantSettlement> items) {
    final rank = <String, int>{'paid': 0, 'pending': 1, 'confirmed': 2};
    final copy = [...items];
    copy.sort((a, b) {
      final ra = rank[a.status] ?? 9;
      final rb = rank[b.status] ?? 9;
      if (ra != rb) return ra.compareTo(rb);
      return b.settlementDate.compareTo(a.settlementDate);
    });
    return copy;
  }

  List<MerchantSettlement> get _visible {
    switch (_filter) {
      case _SettlementFilter.actionNeeded:
        return _items.where((s) => s.status == 'paid').toList();
      case _SettlementFilter.pending:
        return _items.where((s) => s.status == 'pending').toList();
      case _SettlementFilter.confirmed:
        return _items.where((s) => s.status == 'confirmed').toList();
      case _SettlementFilter.all:
        return _items;
    }
  }

  Future<void> _confirmSettlement(MerchantSettlement settlement) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm payout received?'),
        content: Text(
          'Confirm only after ₦${settlement.grossAmount.toStringAsFixed(0)} '
          'has landed in your bank account'
          '${settlement.paymentReference != null ? ' (ref ${settlement.paymentReference})' : ''}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, I received it'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) return;

    setState(() => _confirmingId = settlement.id);

    final result =
        await AppServices.instance.settlementRepository.confirmSettlement(settlement.id);

    if (!mounted) return;
    setState(() => _confirmingId = null);

    switch (result) {
      case ApiSuccess<MerchantSettlement> _:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks — settlement marked as received'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadSettlements();
      case ApiFailure<MerchantSettlement>(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: AppColors.danger),
        );
    }
  }

  String _currency(double value) => '₦${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pendingTotal = _items
        .where((item) => item.status == 'pending')
        .fold<double>(0, (sum, item) => sum + item.grossAmount);
    final awaitingConfirm = _items.where((item) => item.status == 'paid').toList();
    final awaitingTotal =
        awaitingConfirm.fold<double>(0, (sum, item) => sum + item.grossAmount);
    final visible = _visible;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(textTheme: textTheme, onRefresh: _loading ? null : _loadSettlements),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadSettlements,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                        120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Settlements', style: textTheme.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'When admin pays your daily sales, confirm receipt here.',
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _HowItWorksCard(textTheme: textTheme),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: _KpiTile(
                                  label: 'Pending payout',
                                  value: _currency(pendingTotal),
                                  accent: AppColors.tertiary,
                                  icon: Icons.hourglass_top_rounded,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _KpiTile(
                                  label: 'Confirm now',
                                  value: awaitingConfirm.isEmpty
                                      ? '0'
                                      : _currency(awaitingTotal),
                                  subtitle: awaitingConfirm.isEmpty
                                      ? 'None waiting'
                                      : '${awaitingConfirm.length} paid',
                                  accent: AppColors.secondary,
                                  icon: Icons.mark_email_read_outlined,
                                  highlight: awaitingConfirm.isNotEmpty,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _SettlementFilter.values.map((filter) {
                                final selected = _filter == filter;
                                final count = switch (filter) {
                                  _SettlementFilter.actionNeeded =>
                                    _items.where((s) => s.status == 'paid').length,
                                  _SettlementFilter.pending =>
                                    _items.where((s) => s.status == 'pending').length,
                                  _SettlementFilter.confirmed =>
                                    _items.where((s) => s.status == 'confirmed').length,
                                  _SettlementFilter.all => _items.length,
                                };
                                return Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                                  child: FilterChip(
                                    selected: selected,
                                    label: Text('${_filterLabel(filter)} ($count)'),
                                    onSelected: (_) => setState(() => _filter = filter),
                                    selectedColor: AppColors.primary.withOpacity(0.18),
                                    checkmarkColor: AppColors.primaryContainer,
                                    labelStyle: textTheme.labelSmall?.copyWith(
                                      color: selected
                                          ? AppColors.primaryContainer
                                          : AppColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_error != null)
                            _ErrorState(message: _error!, onRetry: _loadSettlements)
                          else if (visible.isEmpty)
                            _EmptyState(filter: _filter)
                          else
                            ...visible.map(
                              (item) => _SettlementCard(
                                item: item,
                                confirming: _confirmingId == item.id,
                                onConfirm: () => _confirmSettlement(item),
                                currency: _currency,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: SettlementBottomNav()),
          ),
        ],
      ),
    );
  }

  String _filterLabel(_SettlementFilter filter) {
    switch (filter) {
      case _SettlementFilter.actionNeeded:
        return 'Action needed';
      case _SettlementFilter.pending:
        return 'Pending';
      case _SettlementFilter.confirmed:
        return 'Confirmed';
      case _SettlementFilter.all:
        return 'All';
    }
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW SETTLEMENT WORKS',
            style: textTheme.labelSmall?.copyWith(
              letterSpacing: 1.1,
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _StepRow(
            number: '1',
            title: 'Admin runs settlement',
            body: 'Your day’s credit sales are batched into a payout.',
          ),
          const _StepRow(
            number: '2',
            title: 'Admin sends the money',
            body: 'Status becomes Paid once they mark the bank transfer.',
          ),
          const _StepRow(
            number: '3',
            title: 'You confirm receipt',
            body: 'Tap Confirm after the funds hit your account.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  body,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    this.subtitle,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color accent;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const Spacer(),
              if (highlight)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: textTheme.labelSmall?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: textTheme.labelSmall?.copyWith(color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.item,
    required this.confirming,
    required this.onConfirm,
    required this.currency,
  });

  final MerchantSettlement item;
  final bool confirming;
  final VoidCallback onConfirm;
  final String Function(double) currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final needsAction = item.status == 'paid';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    currency(item.grossAmount),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
                _StatusChip(status: item.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _Meta(label: 'Date', value: item.settlementDate),
                _Meta(label: 'Sales', value: '${item.transactionCount}'),
                _Meta(label: 'Litres', value: '${item.totalLitres.toStringAsFixed(2)} L'),
              ],
            ),
            if (item.paymentReference != null) ...[
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: item.paymentReference!));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment reference copied')),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag, size: 16, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment ref: ${item.paymentReference}',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                      const Icon(Icons.copy, size: 14, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
            ],
            if (item.status == 'pending') ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Payout is being prepared by admin. You’ll confirm once it’s marked paid.',
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ],
            if (item.status == 'confirmed' && item.confirmedAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Confirmed ${_friendlyDate(item.confirmedAt!)}',
                style: textTheme.labelSmall?.copyWith(color: AppColors.success),
              ),
            ],
            if (needsAction) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
                ),
                child: Text(
                  'Admin marked this payout as paid. Confirm only after you see the money.',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.secondary),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: confirming ? null : onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: confirming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    confirming ? 'Confirming…' : 'Confirm settlement received',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _friendlyDate(String iso) {
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) return iso;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: textTheme.labelSmall?.copyWith(color: AppColors.muted)),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    late final Color color;
    late final String label;

    switch (status) {
      case 'confirmed':
        color = AppColors.success;
        label = 'Confirmed';
        break;
      case 'paid':
        color = AppColors.secondary;
        label = 'Paid — confirm';
        break;
      case 'pending':
        color = AppColors.tertiary;
        label = 'Pending payout';
        break;
      default:
        color = AppColors.muted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final _SettlementFilter filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final message = switch (filter) {
      _SettlementFilter.actionNeeded => 'Nothing to confirm right now.',
      _SettlementFilter.pending => 'No pending payouts.',
      _SettlementFilter.confirmed => 'No confirmed settlements yet.',
      _SettlementFilter.all => 'No settlements yet — they appear after admin runs settlement.',
    };

    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: AppColors.muted, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(AppSpacing.lg),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.textTheme, this.onRefresh});

  final TextTheme textTheme;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'SETTLEMENTS',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
