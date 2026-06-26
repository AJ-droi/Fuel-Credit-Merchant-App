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
  bool _qrReady = false;
  QrPaymentData? _qrPaymentData;
  Timer? _qrExpiryTimer;
  Duration _qrRemaining = Duration.zero;

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

  void _openPaymentAlert(PaymentAlertStatus status) {
    Navigator.of(context).pushNamed(
      AppRouter.paymentAlert,
      arguments: PaymentAlertArgs(
        status: status,
        amount: _formattedAmount(),
        litres: _formattedLitres(),
        fuelType: 'PMS 95',
        customerId: _customerIdController.text.trim().isEmpty
            ? 'KNTC-8821'
            : _customerIdController.text.trim(),
        transactionId: _qrPaymentData?.transactionId ?? 'TXN-PENDING',
      ),
    );
  }

  void _processIdPayment() {
    final customer = _customerIdController.text.trim();
    if (customer.isEmpty || !customer.contains('-')) {
      _openPaymentAlert(PaymentAlertStatus.failure);
      return;
    }
    _submitCreditPayment(customer);
  }

  Future<void> _submitCreditPayment(String customerId) async {
    final request = CreateFuelSaleRequest(
      amount: double.tryParse(_nairaController.text) ?? 0,
      litres: double.tryParse(_litresController.text) ?? 0,
      customerId: customerId,
      fuelType: 'PMS 95',
    );

    final result = await AppServices.instance.fuelSaleRepository.createSale(
      request,
    );
    if (!mounted) {
      return;
    }

    switch (result) {
      case ApiSuccess<FuelSaleResponse> _:
        _openPaymentAlert(PaymentAlertStatus.success);
      case ApiFailure<FuelSaleResponse> _:
        _openPaymentAlert(PaymentAlertStatus.failure);
    }
  }

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
                      AppSpacing.md,
                      AppSpacing.md,
                      120,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transaction Engine'.toUpperCase(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: AppColors.secondary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      'Fuel Sale',
                                      style: textTheme.headlineSmall,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'PUMP 04 LIVE',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _stepOneCard(textTheme),
                          const SizedBox(height: AppSpacing.md),
                          _stepTwoCard(textTheme),
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
            child: SafeArea(top: false, child: FuelSaleBottomNav()),
          ),
        ],
      ),
    );
  }

  Widget _stepOneCard(TextTheme textTheme) {
    return GlassCard(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0x33C6C0FF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Volume & Value', style: textTheme.headlineSmall),
              ),
              Text(
                _isLoadingFuelPrice
                    ? 'Loading rate...'
                    : 'Rate: ${_currencySymbol(_currency)}${_fuelRate.toStringAsFixed(2)}/L',
                style: textTheme.labelSmall,
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

  Widget _stepTwoCard(TextTheme textTheme) {
    return GlassCard(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0x334AE176),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '2',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Payment Methods', style: textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _qrBlock(textTheme),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.white10)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('OR', style: textTheme.labelSmall),
              ),
              const Expanded(child: Divider(color: Colors.white10)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _idPaymentBlock(textTheme),
        ],
      ),
    );
  }

  Widget _qrBlock(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0x1A0D1C2D),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Payment',
                      style: textTheme.headlineSmall?.copyWith(fontSize: 18),
                    ),
                    Text(
                      'Present this code to the customer to complete payment',
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_qrReady) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: QrImageView(
                        data: _qrPaymentData?.qrPayload ?? '',
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          color: Colors.black,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          color: Colors.black,
                          dataModuleShape: QrDataModuleShape.square,
                        ),
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
                              ? const Color(0xFFFFB4AB)
                              : AppColors.secondary,
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
                              ? const Color(0xFFFFB4AB)
                              : AppColors.secondary,
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
                      color: AppColors.muted,
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
                        border: Border.all(color: Colors.white10),
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
                            ? const Color(0x1AFFB4AB)
                            : const Color(0x1A4AE176),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isQrExpired
                              ? const Color(0x44FFB4AB)
                              : const Color(0x444AE176),
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
                                ? const Color(0xFFFFB4AB)
                                : AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _isQrExpired
                                  ? 'The payment window has closed for this code.'
                                  : 'The payment window remains open until the timer runs out.',
                              style: textTheme.labelSmall?.copyWith(
                                color: _isQrExpired
                                    ? const Color(0xFFFFB4AB)
                                    : AppColors.secondary,
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
                      child: FilledButton.icon(
                        onPressed: _generateQr,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Generate New Code'),
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
                              side: const BorderSide(color: Color(0x66FFB4AB)),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              foregroundColor: const Color(0xFFFFB4AB),
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
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.secondary],
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: _isGeneratingQr ? null : _generateQr,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                  icon: Icon(
                    _isGeneratingQr ? Icons.sync : Icons.qr_code_scanner,
                    color: AppColors.onPrimaryContainer,
                  ),
                  label: Text(
                    _isGeneratingQr ? 'Generating...' : 'Generate Payment QR',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
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
        borderRadius: BorderRadius.circular(12),
        color: const Color(0x1A0D1C2D),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Credit ID',
                      style: textTheme.headlineSmall?.copyWith(fontSize: 18),
                    ),
                    Text(
                      'Corporate or Fleet Customer ID',
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _customerIdController,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            decoration: InputDecoration(
              hintText: 'Enter Customer ID (e.g. FF-9821)',
              hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white38),
              filled: true,
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _processIdPayment,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primary,
              ),
              label: Text(
                'Process ID Payment',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
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
            color: const Color(0x260D1C2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
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
            color: const Color(0x260D1C2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
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
                  color: AppColors.secondary,
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
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
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
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
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
        border: Border(bottom: BorderSide(color: Colors.white10)),
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
