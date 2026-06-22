class DashboardSummary {
  const DashboardSummary({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final MerchantDashboardData data;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: MerchantDashboardData.fromJson(
        (json['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}

class MerchantDashboardData {
  const MerchantDashboardData({
    required this.merchantId,
    required this.businessName,
    required this.today,
    required this.pendingSettlements,
    required this.lastPaidSettlement,
  });

  final String merchantId;
  final String businessName;
  final DashboardToday today;
  final DashboardPendingSettlements pendingSettlements;
  final DashboardSettlement? lastPaidSettlement;

  factory MerchantDashboardData.fromJson(Map<String, dynamic> json) {
    return MerchantDashboardData(
      merchantId: (json['merchantId'] ?? '').toString(),
      businessName: (json['businessName'] ?? '').toString(),
      today: DashboardToday.fromJson(
        (json['today'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      pendingSettlements: DashboardPendingSettlements.fromJson(
        (json['pendingSettlements'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      lastPaidSettlement: json['lastPaidSettlement'] is Map<String, dynamic>
          ? DashboardSettlement.fromJson(json['lastPaidSettlement'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DashboardToday {
  const DashboardToday({
    required this.salesCount,
    required this.grossAmount,
    required this.unsettledAmount,
  });

  final int salesCount;
  final double grossAmount;
  final double unsettledAmount;

  factory DashboardToday.fromJson(Map<String, dynamic> json) {
    return DashboardToday(
      salesCount: _toInt(json['salesCount']),
      grossAmount: _toDouble(json['grossAmount']),
      unsettledAmount: _toDouble(json['unsettledAmount']),
    );
  }
}

class DashboardPendingSettlements {
  const DashboardPendingSettlements({
    required this.count,
    required this.totalAmount,
  });

  final int count;
  final double totalAmount;

  factory DashboardPendingSettlements.fromJson(Map<String, dynamic> json) {
    return DashboardPendingSettlements(
      count: _toInt(json['count']),
      totalAmount: _toDouble(json['totalAmount']),
    );
  }
}

class DashboardSettlement {
  const DashboardSettlement({
    required this.referenceId,
    required this.amount,
    required this.paidAt,
  });

  final String referenceId;
  final double amount;
  final DateTime? paidAt;

  factory DashboardSettlement.fromJson(Map<String, dynamic> json) {
    return DashboardSettlement(
      referenceId: (json['referenceId'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()),
    );
  }
}

class DashboardTransaction {
  const DashboardTransaction({
    required this.code,
    required this.amount,
    required this.litres,
    required this.status,
    required this.timeAgo,
  });

  final String code;
  final String amount;
  final String litres;
  final String status;
  final String timeAgo;

  factory DashboardTransaction.fromJson(Map<String, dynamic> json) {
    return DashboardTransaction(
      code: (json['code'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      litres: (json['litres'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      timeAgo: (json['timeAgo'] ?? '').toString(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
