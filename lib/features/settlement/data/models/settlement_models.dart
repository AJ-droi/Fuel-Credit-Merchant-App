class RequestSettlementRequest {
  const RequestSettlementRequest({required this.amount});

  final double amount;

  Map<String, dynamic> toJson() => {'amount': amount};
}

class RequestSettlementResponse {
  const RequestSettlementResponse({
    required this.referenceId,
    required this.status,
  });

  final String referenceId;
  final String status;

  factory RequestSettlementResponse.fromJson(Map<String, dynamic> json) {
    return RequestSettlementResponse(
      referenceId: (json['referenceId'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
    );
  }
}
