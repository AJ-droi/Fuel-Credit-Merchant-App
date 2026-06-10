class BranchesResponse {
  final bool success;
  final String message;
  final List<BranchModel> data;

  const BranchesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BranchesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return BranchesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(BranchModel.fromJson)
                .toList()
          : const <BranchModel>[],
    );
  }
}

class BranchModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String lga;
  final String state;
  final String landmark;
  final String status;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.lga,
    required this.state,
    required this.landmark,
    required this.status,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      lga: json['lga']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  String get locationLabel {
    final parts = <String>[
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ];
    return parts.join(', ');
  }
}
