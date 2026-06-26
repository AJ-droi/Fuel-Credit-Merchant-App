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

class BranchStaffMember {
  const BranchStaffMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.accountStatus,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String accountStatus;

  factory BranchStaffMember.fromJson(Map<String, dynamic> json) {
    return BranchStaffMember(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      accountStatus: json['accountStatus']?.toString() ?? 'active',
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

class BranchDetailModel extends BranchModel {
  const BranchDetailModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.lga,
    required super.state,
    required super.landmark,
    required super.status,
    required super.isPrimary,
    required super.createdAt,
    required super.updatedAt,
    required this.staffCount,
    required this.salesCount,
    required this.grossAmount,
    required this.staff,
  });

  final int staffCount;
  final int salesCount;
  final double grossAmount;
  final List<BranchStaffMember> staff;

  factory BranchDetailModel.fromJson(Map<String, dynamic> json) {
    final staffRaw = json['staff'];
    return BranchDetailModel(
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
      staffCount: _toInt(json['staffCount']),
      salesCount: _toInt(json['salesCount']),
      grossAmount: _toDouble(json['grossAmount']),
      staff: staffRaw is List
          ? staffRaw
                .whereType<Map<String, dynamic>>()
                .map(BranchStaffMember.fromJson)
                .toList()
          : const [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
