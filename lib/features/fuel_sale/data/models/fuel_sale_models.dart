class CreateFuelSaleRequest {
  const CreateFuelSaleRequest({
    required this.purchaseId,
    required this.fuelLitres,
  });

  final String purchaseId;
  final double fuelLitres;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'purchaseId': purchaseId,
        'fuelLitres': fuelLitres,
      };
}

class GenerateQrRequest {
  const GenerateQrRequest({
    required this.fuelLitres,
  });

  final double fuelLitres;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fuelLitres': fuelLitres,
      };
}

class FuelSaleResponse {
  const FuelSaleResponse({
    required this.transactionId,
    required this.status,
    this.amount = 0,
    this.fuelLitres = 0,
    this.pricePerLitre = 0,
    this.expiresAt,
  });

  final String transactionId;
  final String status;
  final double amount;
  final double fuelLitres;
  final double pricePerLitre;
  final DateTime? expiresAt;

  bool get isAwaitingConfirmation {
    final s = status.toLowerCase();
    return s == 'awaiting_confirmation' || s == 'pending';
  }

  bool get isCompleted => status.toLowerCase() == 'completed';

  factory FuelSaleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return FuelSaleResponse(
      transactionId: (data['transactionId'] ?? data['id'] ?? data['_id'] ?? '')
          .toString(),
      status: (data['status'] ?? '').toString(),
      amount: _toDouble(data['amount']),
      fuelLitres: _toDouble(data['fuelLitres']),
      pricePerLitre: _toDouble(data['pricePerLitre']),
      expiresAt: DateTime.tryParse((data['expiresAt'] ?? '').toString()),
    );
  }
}

class FuelPriceResponse {
  const FuelPriceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final FuelPriceData data;

  factory FuelPriceResponse.fromJson(Map<String, dynamic> json) {
    return FuelPriceResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: FuelPriceData.fromJson(
        (json['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class FuelPriceData {
  const FuelPriceData({
    required this.fuelPricePerLitre,
    required this.currency,
    required this.updatedAt,
  });

  final double fuelPricePerLitre;
  final String currency;
  final DateTime? updatedAt;

  factory FuelPriceData.fromJson(Map<String, dynamic> json) {
    return FuelPriceData(
      fuelPricePerLitre: _toDouble(json['fuelPricePerLitre']),
      currency: (json['currency'] ?? 'NGN').toString(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}

class QrPaymentResponse {
  const QrPaymentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final QrPaymentData data;

  factory QrPaymentResponse.fromJson(Map<String, dynamic> json) {
    return QrPaymentResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: QrPaymentData.fromJson(
        (json['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class QrPaymentData {
  const QrPaymentData({
    required this.transactionId,
    required this.qrPayload,
    required this.amount,
    required this.fuelLitres,
    required this.pricePerLitre,
    required this.expiresAt,
    required this.status,
  });

  final String transactionId;
  final String qrPayload;
  final double amount;
  final double fuelLitres;
  final double pricePerLitre;
  final DateTime? expiresAt;
  final String status;

  factory QrPaymentData.fromJson(Map<String, dynamic> json) {
    return QrPaymentData(
      transactionId: (json['transactionId'] ?? '').toString(),
      qrPayload: (json['qrPayload'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      fuelLitres: _toDouble(json['fuelLitres']),
      pricePerLitre: _toDouble(json['pricePerLitre']),
      expiresAt: DateTime.tryParse((json['expiresAt'] ?? '').toString()),
      status: (json['status'] ?? '').toString(),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
