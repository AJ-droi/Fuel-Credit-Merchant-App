import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/fuel_sale_models.dart';
import '../../../payment_alert/presentation/pages/payment_alert_page.dart';
import '../widgets/fuel_sale_bottom_nav.dart';

class FuelSalePage extends StatefulWidget {
  const FuelSalePage({super.key});

  @override
  State<FuelSalePage> createState() => _FuelSalePageState();
}

class _FuelSalePageState extends State<FuelSalePage> {
  final TextEditingController _nairaController = TextEditingController();
  final TextEditingController _litresController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();

  double _fuelRate = 1250;
  String _currency = 'NGN';
  bool _updatingFromNaira = false;
  bool _updatingFromLitres = false;
  bool _isLoadingFuelPrice = true;
  bool _isGeneratingQr = false;
  bool _isProcessingIdPayment = false;
  bool _qrReady = false;
  QrPaymentData? _qrPaymentData;
  Timer? _qrExpiryTimer;
  Duration _qrRemaining = Duration.zero;
  int _paymentTab = 0; // 0 = Show QR, 1 = Purchase ID

  @override
  void initState() {
    super.initState();
    _nairaController.addListener(_onNairaChanged);
    _litresController.addListener(_onLitresChanged);
    _loadFuelPrice();
  }

  @override
  void dispose() {
    _qrExpiryTimer?.cancel();
    _nairaController
      ..removeListener(_onNairaChanged)
      ..dispose();
    _litresController
      ..removeListener(_onLitresChanged)
      ..dispose();
    _customerIdController.dispose();
    super.dispose();
  }

  void _onNairaChanged() {
    if (_updatingFromLitres) {
      return;
    }

    final value = double.tryParse(_nairaController.text);
    _updatingFromNaira = true;
    if (value == null) {
      _litresController.text = '';
    } else {
      _litresController.text = (value / _fuelRate).toStringAsFixed(2);
    }
    _updatingFromNaira = false;
  }

  void _onLitresChanged() {
    if (_updatingFromNaira) {
      return;
    }

    final value = double.tryParse(_litresController.text);
    _updatingFromLitres = true;
    if (value == null) {
      _nairaController.text = '';
    } else {
      _nairaController.text = (value * _fuelRate).toStringAsFixed(2);
    }
    _updatingFromLitres = false;
  }

  Future<void> _loadFuelPrice() async {
    final result = await AppServices.instance.fuelSaleRepository
        .fetchFuelPrice();
    if (!mounted) {
      return;
    }

    switch (result) {
      case ApiSuccess<FuelPriceResponse> success:
        setState(() {
          _fuelRate = success.data.data.fuelPricePerLitre <= 0
              ? _fuelRate
              : success.data.data.fuelPricePerLitre;
          _currency = success.data.data.currency;
          _isLoadingFuelPrice = false;
        });
        _onNairaChanged();
      case ApiFailure<FuelPriceResponse> failure:
        setState(() => _isLoadingFuelPrice = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.error.message)));
    }
  }

  Future<void> _generateQr() async {
    final amount = double.tryParse(_nairaController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount before generating QR.')),
      );
      return;
    }

    setState(() => _isGeneratingQr = true);
    final request = GenerateQrRequest(amount: amount);
    final result = await AppServices.instance.fuelSaleRepository.generateQr(
      request,
    );
    if (!mounted) {
      return;
    }
    switch (result) {
      case ApiSuccess<QrPaymentResponse> success:
        setState(() {
          _isGeneratingQr = false;
          _qrReady = true;
          _qrPaymentData = success.data.data;
        });
        _startQrTimer(success.data.data.expiresAt);
      case ApiFailure<QrPaymentResponse> failure:
        setState(() => _isGeneratingQr = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.error.message)));
    }
  }

  String _formattedAmount() {
    final amount = double.tryParse(_nairaController.text) ?? 12500;
    return '₦${amount.toStringAsFixed(0)}';
  }

  String _formattedLitres() {
    final litres = double.tryParse(_litresController.text) ?? 19.2;
    return '${litres.toStringAsFixed(1)}L';
  }

  bool get _isQrExpired {
    if (_qrPaymentData?.expiresAt == null) {
      return false;
    }
    return _qrRemaining <= Duration.zero;
  }

  void _startQrTimer(DateTime? expiresAt) {
    _qrExpiryTimer?.cancel();
    if (expiresAt == null) {
      setState(() => _qrRemaining = Duration.zero);
      return;
    }

    void syncRemaining() {
      final remaining = expiresAt.toUtc().difference(DateTime.now().toUtc());
      if (!mounted) {
        return;
      }
      setState(() {
        _qrRemaining = remaining.isNegative ? Duration.zero : remaining;
      });
      if (remaining.isNegative || remaining == Duration.zero) {
        _qrExpiryTimer?.cancel();
      }
    }

    syncRemaining();
    _qrExpiryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => syncRemaining(),
    );
  }

  void _openPaymentAlert(
    PaymentAlertStatus status, {
    String? transactionId,
    String? message,
  }) {
    Navigator.of(context).pushNamed(
      AppRouter.paymentAlert,
      arguments: PaymentAlertArgs(
        status: status,
        amount: _formattedAmount(),
        litres: _formattedLitres(),
        fuelType: 'PMS 95',
        customerId: _customerIdController.text.trim().isEmpty
            ? '—'
            : _customerIdController.text.trim(),
        transactionId: transactionId ??
            _qrPaymentData?.transactionId ??
            '—',
        message: message,
      ),
    );
  }

  Future<void> _processIdPayment() async {
    if (_isProcessingIdPayment) {
      return;
    }

    final purchaseId = _customerIdController.text.trim().replaceAll(RegExp(r'\D'), '');
    final amount = double.tryParse(_nairaController.text.trim()) ?? 0;

    if (purchaseId.length != 9) {
      _openPaymentAlert(
        PaymentAlertStatus.failure,
        message: 'Enter a valid 9-digit customer purchase ID',
      );
      return;
    }

    if (amount <= 0) {
      _openPaymentAlert(
        PaymentAlertStatus.failure,
        message: 'Enter a valid purchase amount',
      );
      return;
    }

    setState(() => _isProcessingIdPayment = true);

    final result = await AppServices.instance.fuelSaleRepository.createSale(
      CreateFuelSaleRequest(purchaseId: purchaseId, amount: amount),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isProcessingIdPayment = false);

    switch (result) {
      case ApiSuccess<FuelSaleResponse> success:
        _openPaymentAlert(
          PaymentAlertStatus.success,
          transactionId: success.data.transactionId,
          message: 'Fuel credit disbursed successfully',
        );
      case ApiFailure<FuelSaleResponse> failure:
        _openPaymentAlert(
          PaymentAlertStatus.failure,
          message: failure.error.message,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Stack(
        children: [
          Column(
            children: [
              _TopBar(textTheme: textTheme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    120,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.local_gas_station_rounded,
                                  color: AppColors.primaryDark,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Station Fuel Checkout',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enter amount, then show QR or take the customer purchase ID.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.emeraldMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _stepOneCard(textTheme),
                        const SizedBox(height: AppSpacing.md),
                        _paymentTabs(textTheme),
                        const SizedBox(height: AppSpacing.md),
                        if (_paymentTab == 0) _qrBlock(textTheme) else _idPaymentBlock(textTheme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: FuelSaleBottomNav()),
          ),
        ],
      ),
    );
  }

  Widget _paymentTabs(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PaymentTabButton(
              label: 'Show QR',
              selected: _paymentTab == 0,
              onTap: () => setState(() => _paymentTab = 0),
            ),
          ),
          Expanded(
            child: _PaymentTabButton(
              label: 'Purchase ID',
              selected: _paymentTab == 1,
              onTap: () => setState(() => _paymentTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepOneCard(TextTheme textTheme) {
    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Volume & Value',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _isLoadingFuelPrice
                    ? 'Loading rate...'
                    : 'Rate: ${_currencySymbol(_currency)}${_fuelRate.toStringAsFixed(2)}/L',
                style: textTheme.labelSmall?.copyWith(color: AppColors.slate500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 580;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _amountField(textTheme)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _litresField(textTheme)),
                  ],
                );
              }
              return Column(
                children: [
                  _amountField(textTheme),
                  const SizedBox(height: AppSpacing.md),
                  _litresField(textTheme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Payment methods use Show QR / Purchase ID tabs above.

  Widget _qrBlock(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Payment',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Present this code to the customer to complete payment',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_qrReady) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: QrImageView(
                      data: _qrPaymentData?.qrPayload ?? '',
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        color: AppColors.primary,
                        eyeShape: QrEyeShape.square,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        color: AppColors.primary,
                        dataModuleShape: QrDataModuleShape.square,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isQrExpired
                              ? AppColors.danger
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _isQrExpired
                            ? 'QR expired'
                            : 'QR active • expires in ${_formatDuration(_qrRemaining)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: _isQrExpired
                              ? AppColors.danger
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isQrExpired
                        ? 'This code is no longer valid. Generate a fresh code to continue.'
                        : 'This code is live and ready for customer payment.',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  if (_qrPaymentData != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0x22051A24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = constraints.maxWidth > 420
                              ? (constraints.maxWidth - AppSpacing.md) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.md,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _qrInfoChip(
                                  context,
                                  label: 'Amount',
                                  value:
                                      '${_currencySymbol(_currency)}${_qrPaymentData!.amount.toStringAsFixed(0)}',
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _qrInfoChip(
                                  context,
                                  label: 'Litres',
                                  value: _qrPaymentData!.fuelLitres
                                      .toStringAsFixed(1),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _qrInfoChip(
                                  context,
                                  label: 'Status',
                                  value: _qrPaymentData!.status.toUpperCase(),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _qrInfoChip(
                                  context,
                                  label: 'Txn',
                                  value: _compactTransactionId(
                                    _qrPaymentData!.transactionId,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _isQrExpired
                            ? AppColors.danger.withOpacity(0.12)
                            : AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isQrExpired
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isQrExpired
                                ? Icons.timer_off_rounded
                                : Icons.verified_user_outlined,
                            size: 18,
                            color: _isQrExpired
                                ? AppColors.danger
                                : AppColors.accent,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _isQrExpired
                                  ? 'The payment window has closed for this code.'
                                  : 'The payment window remains open until the timer runs out.',
                              style: textTheme.labelSmall?.copyWith(
                                color: _isQrExpired
                                    ? AppColors.danger
                                    : AppColors.emeraldMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (_isQrExpired)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _generateQr,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 24),
                        label: const Text(
                          'Generate New Code',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _openPaymentAlert(PaymentAlertStatus.success),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondaryContainer,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Complete Payment'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openPaymentAlert(PaymentAlertStatus.failure),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              foregroundColor: AppColors.danger,
                            ),
                            icon: const Icon(Icons.error_outline_rounded),
                            label: const Text('Decline Payment'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton.icon(
                onPressed: _isGeneratingQr ? null : _generateQr,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  foregroundColor: AppColors.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                ),
                icon: Icon(
                  _isGeneratingQr ? Icons.sync : Icons.qr_code_scanner,
                  size: 28,
                  color: AppColors.accent,
                ),
                label: Text(
                  _isGeneratingQr ? 'Generating...' : 'Generate Payment QR',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _idPaymentBlock(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFFA16207)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Credit ID',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Enter the customer\'s 9-digit purchase ID',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _customerIdController,
            keyboardType: TextInputType.number,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 700237721',
              hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              filled: true,
              fillColor: AppColors.slate50,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isProcessingIdPayment ? null : _processIdPayment,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isProcessingIdPayment
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(Icons.verified_user_rounded),
              label: Text(
                _isProcessingIdPayment ? 'Processing...' : 'Authorize Fuel Purchase',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountField(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text('Amount (NGN)', style: textTheme.labelSmall),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            children: [
              Text(
                '₦',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _nairaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: textTheme.displayLarge,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _litresField(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text('Volume (Litres)', style: textTheme.labelSmall),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _litresController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: textTheme.displayLarge,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'L',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qrInfoChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.onBackground),
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
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel checkout',
                      style: textTheme.labelSmall?.copyWith(color: AppColors.emeraldMuted),
                    ),
                    Text(
                      'Sell Fuel',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_outlined, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTabButton extends StatelessWidget {
  const _PaymentTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.slate700,
            ),
          ),
        ),
      ),
    );
  }
}

String _currencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'NGN':
      return '₦';
    default:
      return currency.toUpperCase();
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _compactTransactionId(String transactionId) {
  if (transactionId.length <= 12) {
    return transactionId;
  }
  return '${transactionId.substring(0, 6)}...${transactionId.substring(transactionId.length - 4)}';
}
