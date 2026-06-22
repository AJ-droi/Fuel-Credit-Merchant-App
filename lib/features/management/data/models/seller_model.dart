class SellersResponse {
  final bool success;
  final String message;
  final List<SellerModel> data;

  const SellersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SellersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SellersResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(SellerModel.fromJson)
                .toList()
          : const <SellerModel>[],
    );
  }
}

class SellerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String branchId;
  final String branchName;
  final DateTime? createdAt;

  const SellerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  String get fullName {
    final parts = <String>[
      if (firstName.isNotEmpty) firstName,
      if (lastName.isNotEmpty) lastName,
    ];
    return parts.join(' ').trim();
  }
}
