import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/payment_alert_bottom_nav.dart';

enum PaymentAlertStatus { success, failure }

class PaymentAlertArgs {
  const PaymentAlertArgs({
    required this.status,
    required this.amount,
    required this.litres,
    required this.fuelType,
    required this.customerId,
    required this.transactionId,
    this.message,
  });

  final PaymentAlertStatus status;
  final String amount;
  final String litres;
  final String fuelType;
  final String customerId;
  final String transactionId;
  final String? message;
}

class PaymentAlertPage extends StatelessWidget {
  const PaymentAlertPage({super.key, required this.args});

  final PaymentAlertArgs args;

  bool get _isSuccess => args.status == PaymentAlertStatus.success;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _isSuccess ? AppColors.primary : AppColors.danger;
    final icon = _isSuccess ? Icons.check_circle : Icons.cancel;
    final title = _isSuccess ? 'Payment Successful' : 'Payment Failed';
    final subtitle = _isSuccess
        ? 'TRANSACTION COMPLETE'
        : 'TRANSACTION DECLINED';

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(textTheme: textTheme),
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(0.06),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          120,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.xl),
                            _StatusBadge(accent: accent, icon: icon),
                            const SizedBox(height: AppSpacing.md),
                            Text(title, style: textTheme.headlineSmall),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              style: textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.3,
                                color: AppColors.muted,
                              ),
                            ),
                            if (args.message != null &&
                                args.message!.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                args.message!,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: accent,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            GlassCard(
                              borderRadius: BorderRadius.circular(12),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                children: [
                                  Text(
                                    'AMOUNT PAID',
                                    style: textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    args.amount,
                                    style: textTheme.displayLarge?.copyWith(
                                      color: accent,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  const Divider(color: AppColors.border),
                                  const SizedBox(height: AppSpacing.md),
                                  _ReceiptRow(
                                    leftTitle: 'Litres Dispensed',
                                    leftValue: args.litres,
                                    rightTitle: 'Fuel Type',
                                    rightValue: args.fuelType,
                                    chipColor: accent,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _ReceiptRow(
                                    leftTitle: 'Customer ID',
                                    leftValue: args.customerId,
                                    rightTitle: 'Transaction ID',
                                    rightValue: args.transactionId,
                                    chipColor: accent,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (_isSuccess) ...[
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                        AppRouter.fuelSale,
                                        (route) => false,
                                      ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add_shopping_cart_rounded),
                                  label: Text(
                                    'Make Another Sale',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                        AppRouter.dashboard,
                                        (route) => false,
                                      ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.onBackground,
                                    side: const BorderSide(color: AppColors.border),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                  ),
                                  icon: const Icon(Icons.dashboard_outlined),
                                  label: Text(
                                    'Back to Dashboard',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                        AppRouter.fuelSale,
                                        (route) => false,
                                      ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: AppColors.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    'Try New Sale',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: PaymentAlertBottomNav()),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: Color(0x1A051424),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'FUELCREDIT',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withOpacity(0.2),
      ),
      child: Center(child: Icon(icon, size: 56, color: accent)),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
    required this.chipColor,
  });

  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftTitle.toUpperCase(), style: textTheme.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                leftValue,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.onBackground),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rightTitle.toUpperCase(), style: textTheme.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: chipColor.withOpacity(0.1),
                  border: Border.all(color: chipColor.withOpacity(0.3)),
                ),
                child: Text(
                  rightValue,
                  style: textTheme.labelSmall?.copyWith(color: chipColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
