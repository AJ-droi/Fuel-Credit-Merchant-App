import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/settlement_models.dart';
import '../widgets/settlement_bottom_nav.dart';

class SettlementPage extends StatefulWidget {
  const SettlementPage({super.key});

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  bool _loading = true;
  String? _error;
  List<MerchantSettlement> _items = const [];

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
          _items = data.items;
          _loading = false;
        });
      case ApiFailure<MerchantSettlementList>(:final error):
        setState(() {
          _error = error.message;
          _loading = false;
        });
    }
  }

  Future<void> _confirmSettlement(MerchantSettlement settlement) async {
    final result =
        await AppServices.instance.settlementRepository.confirmSettlement(settlement.id);

    if (!mounted) return;

    switch (result) {
      case ApiSuccess<MerchantSettlement> _:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settlement confirmed')),
        );
        await _loadSettlements();
      case ApiFailure<MerchantSettlement>(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
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
    final awaitingConfirm = _items.where((item) => item.status == 'paid').length;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(textTheme: textTheme),
                Expanded(
                  child: RefreshIndicator(
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
                          Text('Settlement', style: textTheme.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Daily sales reconciled by admin — confirm once paid',
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          GlassCard(
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pending payout', style: textTheme.labelSmall),
                                      Text(
                                        _currency(pendingTotal),
                                        style: textTheme.headlineSmall?.copyWith(
                                          color: AppColors.tertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Awaiting confirm', style: textTheme.labelSmall),
                                      Text(
                                        '$awaitingConfirm',
                                        style: textTheme.headlineSmall?.copyWith(
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_loading)
                            const Center(child: CircularProgressIndicator())
                          else if (_error != null)
                            Text(_error!, style: textTheme.bodyMedium?.copyWith(color: Colors.red))
                          else if (_items.isEmpty)
                            Text(
                              'No settlements yet',
                              style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                            )
                          else
                            ..._items.map((item) => _settlementCard(item, textTheme)),
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

  Widget _settlementCard(MerchantSettlement item, TextTheme textTheme) {
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
                    _currency(item.grossAmount),
                    style: textTheme.headlineSmall,
                  ),
                ),
                _statusChip(item.status, textTheme),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${item.settlementDate} · ${item.transactionCount} purchases · ${item.totalLitres.toStringAsFixed(2)} L',
              style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
            ),
            if (item.paymentReference != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ref: ${item.paymentReference}',
                style: textTheme.labelSmall,
              ),
            ],
            if (item.status == 'paid') ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _confirmSettlement(item),
                  child: const Text('Confirm settlement received'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, TextTheme textTheme) {
    late final Color color;
    late final String label;

    switch (status) {
      case 'confirmed':
        color = AppColors.secondary;
        label = 'Confirmed';
        break;
      case 'paid':
        color = AppColors.tertiary;
        label = 'Paid — confirm';
        break;
      case 'pending':
        color = AppColors.primaryContainer;
        label = 'Pending payout';
        break;
      default:
        color = AppColors.muted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.textTheme});

  final TextTheme textTheme;

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
              color: const Color(0x338B80FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'FUEL OPS',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
