class MerchantTransaction {
  const MerchantTransaction({
    required this.id,
    required this.disbursementMethod,
    required this.fuelLitres,
    required this.pricePerLitre,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.businessName,
    required this.stationCode,
  });

  final String id;
  final String disbursementMethod;
  final double fuelLitres;
  final double pricePerLitre;
  final double amount;
  final String status;
  final DateTime? createdAt;
  final String businessName;
  final String stationCode;

  bool get isSuccessful => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';

  String get referenceCode {
    if (stationCode.isNotEmpty) {
      return stationCode;
    }
    return id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }

  factory MerchantTransaction.fromJson(Map<String, dynamic> json) {
    final merchantSnapshot = json['merchantSnapshot'];
    final snapshotMap =
        merchantSnapshot is Map<String, dynamic> ? merchantSnapshot : <String, dynamic>{};

    return MerchantTransaction(
      id: (json['_id'] ?? '').toString(),
      disbursementMethod: (json['disbursementMethod'] ?? '').toString(),
      fuelLitres: _toDouble(json['fuelLitres']),
      pricePerLitre: _toDouble(json['pricePerLitre']),
      amount: _toDouble(json['amount']),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      businessName: (snapshotMap['businessName'] ?? '').toString(),
      stationCode: (snapshotMap['stationCode'] ?? '').toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
