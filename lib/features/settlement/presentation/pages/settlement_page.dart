import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/settlement_models.dart';
import '../widgets/settlement_bottom_nav.dart';

enum SettlementStatus { completed, pending, failed }

class SettlementItem {
  const SettlementItem({
    required this.amount,
    required this.reference,
    required this.date,
    required this.status,
  });

  final String amount;
  final String reference;
  final String date;
  final SettlementStatus status;
}

class SettlementPage extends StatefulWidget {
  const SettlementPage({super.key});

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  static const double _maxBalance = 840500;
  static const double _processingFee = 100;

  int _selectedTab = 0;

  final _items = const <SettlementItem>[
    SettlementItem(
      amount: '₦50,000.00',
      reference: 'SET-99281',
      date: 'Oct 24, 2023',
      status: SettlementStatus.completed,
    ),
    SettlementItem(
      amount: '₦120,000.00',
      reference: 'SET-99280',
      date: 'Oct 22, 2023',
      status: SettlementStatus.pending,
    ),
    SettlementItem(
      amount: '₦25,400.00',
      reference: 'SET-99279',
      date: 'Oct 20, 2023',
      status: SettlementStatus.completed,
    ),
    SettlementItem(
      amount: '₦88,000.00',
      reference: 'SET-99278',
      date: 'Oct 18, 2023',
      status: SettlementStatus.failed,
    ),
    SettlementItem(
      amount: '₦310,000.00',
      reference: 'SET-99277',
      date: 'Oct 15, 2023',
      status: SettlementStatus.completed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(textTheme: textTheme),
                Expanded(
                  child: SingleChildScrollView(
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
                          'Manage your fuel revenue and payouts',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _summaryCard(textTheme),
                        const SizedBox(height: AppSpacing.lg),
                        _filters(textTheme),
                        const SizedBox(height: AppSpacing.md),
                        _settlementList(textTheme),
                      ],
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

  Widget _summaryCard(TextTheme textTheme) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metric(
                      textTheme,
                      'Available Balance',
                      '₦840,500.00',
                      AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _metric(
                      textTheme,
                      'Total Earnings',
                      '₦2,450,000.00',
                      Colors.white,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _metric(
                      textTheme,
                      'Pending Settlement',
                      '₦120,000.00',
                      AppColors.tertiary,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _metric(
                      textTheme,
                      'Available Balance',
                      '₦840,500.00',
                      AppColors.secondary,
                    ),
                  ),
                  const VerticalDivider(color: Colors.white10),
                  Expanded(
                    child: _metric(
                      textTheme,
                      'Total Earnings',
                      '₦2,450,000.00',
                      Colors.white,
                    ),
                  ),
                  const VerticalDivider(color: Colors.white10),
                  Expanded(
                    child: _metric(
                      textTheme,
                      'Pending Settlement',
                      '₦120,000.00',
                      AppColors.tertiary,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.secondary],
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x338B80FF), blurRadius: 18),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _openRequestPayoutModal,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                icon: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.onPrimaryContainer,
                ),
                label: Text(
                  'Request Settlement',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(TextTheme textTheme, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: textTheme.headlineSmall?.copyWith(color: color)),
      ],
    );
  }

  Widget _filters(TextTheme textTheme) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0x80010F1F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [_tabButton('Weekly', 0), _tabButton('Monthly', 1)],
          ),
        ),
        SizedBox(
          width: 260,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.muted,
                size: 18,
              ),
              hintText: 'Search transactions...',
              hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white38),
              filled: true,
              fillColor: const Color(0x660D1C2D),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white12),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: const Color(0x660D1C2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'October 2023',
              dropdownColor: AppColors.surface,
              iconEnabledColor: AppColors.muted,
              items: const [
                DropdownMenuItem(
                  value: 'October 2023',
                  child: Text('October 2023'),
                ),
                DropdownMenuItem(
                  value: 'September 2023',
                  child: Text('September 2023'),
                ),
                DropdownMenuItem(
                  value: 'August 2023',
                  child: Text('August 2023'),
                ),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0x3300B954) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.secondary : AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _settlementList(TextTheme textTheme) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0x1AFFFFFF)),
              columns: const [
                DataColumn(label: Text('Settlement Amount')),
                DataColumn(label: Text('Reference ID')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('')),
              ],
              rows: _items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.amount,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.reference,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.date,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        DataCell(_statusChip(item.status, textTheme)),
                        DataCell(
                          Icon(
                            item.status == SettlementStatus.failed
                                ? Icons.refresh
                                : Icons.receipt_long,
                            color: AppColors.primaryContainer,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'View All Settlement History',
                style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(SettlementStatus status, TextTheme textTheme) {
    late final Color color;
    late final String label;
    switch (status) {
      case SettlementStatus.completed:
        color = AppColors.secondary;
        label = 'Completed';
        break;
      case SettlementStatus.pending:
        color = AppColors.tertiary;
        label = 'Pending';
        break;
      case SettlementStatus.failed:
        color = const Color(0xFFFFB4AB);
        label = 'Failed';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }

  void _openRequestPayoutModal() {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xCC010F1F),
      builder: (context) {
        return _RequestPayoutModal(
          maxBalance: _maxBalance,
          processingFee: _processingFee,
        );
      },
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
        color: Color(0x66122131),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x338B80FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33C6C0FF)),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'FUELCREDIT',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _RequestPayoutModal extends StatefulWidget {
  const _RequestPayoutModal({
    required this.maxBalance,
    required this.processingFee,
  });

  final double maxBalance;
  final double processingFee;

  @override
  State<_RequestPayoutModal> createState() => _RequestPayoutModalState();
}

class _RequestPayoutModalState extends State<_RequestPayoutModal> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _inputAmount {
    final value = double.tryParse(_amountController.text) ?? 0;
    if (value < 0) {
      return 0;
    }
    if (value > widget.maxBalance) {
      return widget.maxBalance;
    }
    return value;
  }

  String _currency(double value) {
    return '₦${value.toStringAsFixed(2)}';
  }

  void _setMax() {
    setState(() {
      _amountController.text = widget.maxBalance.toStringAsFixed(2);
    });
  }

  Future<void> _confirmPayout() async {
    if (_inputAmount <= 0 || _isProcessing) {
      return;
    }
    setState(() => _isProcessing = true);

    final result = await AppServices.instance.settlementRepository
        .requestSettlement(RequestSettlementRequest(amount: _inputAmount));

    if (!mounted) {
      return;
    }

    switch (result) {
      case ApiSuccess<RequestSettlementResponse> _:
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.of(context).pop();
        }
      case ApiFailure<RequestSettlementResponse> failure:
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final receiveAmount = (_inputAmount - widget.processingFee)
        .clamp(0, double.infinity)
        .toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Request Payout', style: textTheme.headlineSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Settlement Ledger ID: #FOP-9921',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Amount to Withdraw',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _setMax,
                    child: Text(
                      'Max: ${_currency(widget.maxBalance)}',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white24)),
                ),
                child: Row(
                  children: [
                    Text(
                      '₦',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        style: textTheme.headlineSmall,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Destination Bank Account',
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xs),
              GlassCard(
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0x33273647),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zenith Bank',
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '****1234 • Current Account',
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.expand_more, color: AppColors.muted),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Processing Fee',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        Text(
                          _currency(widget.processingFee),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'You will receive',
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _currency(receiveAmount),
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: _isSuccess
                          ? const [
                              AppColors.secondary,
                              AppColors.secondaryContainer,
                            ]
                          : const [
                              AppColors.primaryContainer,
                              AppColors.secondary,
                            ],
                    ),
                  ),
                  child: FilledButton.icon(
                    onPressed: (_isSuccess || _isProcessing)
                        ? null
                        : _confirmPayout,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    icon: Icon(
                      _isSuccess
                          ? Icons.check_circle
                          : _isProcessing
                          ? Icons.sync
                          : Icons.send,
                      color: AppColors.onPrimaryContainer,
                    ),
                    label: Text(
                      _isSuccess
                          ? 'Success'
                          : _isProcessing
                          ? 'Processing...'
                          : 'Confirm Payout',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Secured by FUELCREDIT Real-Time Clearing System',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
