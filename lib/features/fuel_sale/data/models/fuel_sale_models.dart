class CreateFuelSaleRequest {
  const CreateFuelSaleRequest({
    required this.amount,
    required this.litres,
    required this.customerId,
    required this.fuelType,
  });

  final double amount;
  final double litres;
  final String customerId;
  final String fuelType;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'litres': litres,
        'customerId': customerId,
        'fuelType': fuelType,
      };
}

class FuelSaleResponse {
  const FuelSaleResponse({required this.transactionId, required this.status});

  final String transactionId;
  final String status;

  factory FuelSaleResponse.fromJson(Map<String, dynamic> json) {
    return FuelSaleResponse(
      transactionId: (json['transactionId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class QrPaymentResponse {
  const QrPaymentResponse({required this.qrCode, required this.reference});

  final String qrCode;
  final String reference;

  factory QrPaymentResponse.fromJson(Map<String, dynamic> json) {
    return QrPaymentResponse(
      qrCode: (json['qrCode'] ?? '').toString(),
      reference: (json['reference'] ?? '').toString(),
    );
  }
}
