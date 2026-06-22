class ProfileResponse {
  final bool success;
  final String message;
  final ProfileModel data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProfileModel.fromJson(json['data'] ?? {}),
    );
  }
}

class ProfileModel {
  final String merchantId;
  final String merchantName;
  final String businessName;
  final String businessLocation;
  final String address;
  final String lga;
  final String state;
  final String landmark;
  final String city;
  final String stationBranch;
  final double fuelPricePerLitre;
  final String status;
  final String email;
  final String phone;

  ProfileModel({
    required this.merchantId,
    required this.merchantName,
    required this.businessName,
    required this.businessLocation,
    required this.address,
    required this.lga,
    required this.state,
    required this.landmark,
    required this.city,
    required this.stationBranch,
    required this.fuelPricePerLitre,
    required this.status,
    required this.email,
    required this.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      merchantId: json['merchantId']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? '',
      businessLocation: json['businessLocation']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lga: json['lga']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      stationBranch: json['stationBranch']?.toString() ?? '',
      fuelPricePerLitre: (json['fuelPricePerLitre'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}
