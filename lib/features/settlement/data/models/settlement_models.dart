class MerchantSettlement {
  const MerchantSettlement({
    required this.id,
    required this.merchantCode,
    required this.settlementDate,
    required this.grossAmount,
    required this.totalLitres,
    required this.transactionCount,
    required this.status,
    this.paymentReference,
    this.paidAt,
    this.confirmedAt,
  });

  final String id;
  final String merchantCode;
  final String settlementDate;
  final double grossAmount;
  final double totalLitres;
  final int transactionCount;
  final String status;
  final String? paymentReference;
  final String? paidAt;
  final String? confirmedAt;

  factory MerchantSettlement.fromJson(Map<String, dynamic> json) {
    return MerchantSettlement(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      merchantCode: (json['merchantCode'] ?? '').toString(),
      settlementDate: (json['settlementDate'] ?? '').toString(),
      grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0,
      totalLitres: (json['totalLitres'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      paymentReference: json['paymentReference']?.toString(),
      paidAt: json['paidAt']?.toString(),
      confirmedAt: json['confirmedAt']?.toString(),
    );
  }
}

class MerchantSettlementList {
  const MerchantSettlementList({required this.items});

  final List<MerchantSettlement> items;

  factory MerchantSettlementList.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final data = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : map;
    final rawItems = data['items'] as List<dynamic>? ?? <dynamic>[];

    return MerchantSettlementList(
      items: rawItems
          .map((item) => MerchantSettlement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
