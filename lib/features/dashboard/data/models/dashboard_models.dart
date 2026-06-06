class DashboardSummary {
  const DashboardSummary({
    required this.pumpPrice,
    required this.totalLitres,
    required this.totalAmount,
  });

  final String pumpPrice;
  final String totalLitres;
  final String totalAmount;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      pumpPrice: (json['pumpPrice'] ?? '₦650/L').toString(),
      totalLitres: (json['totalLitres'] ?? '1,240L').toString(),
      totalAmount: (json['totalAmount'] ?? '₦806,000').toString(),
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
