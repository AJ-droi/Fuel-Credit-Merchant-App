class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
      };
}

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final LoginData data;

  String get accessToken => data.accessToken;
  String get refreshToken => data.refreshToken;
  MerchantUser get user => data.user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: LoginData.fromJson((json['data'] as Map<String, dynamic>? ?? <String, dynamic>{})),
    );
  }
}

class LoginData {
  const LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final MerchantUser user;

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      expiresIn: _toInt(json['expiresIn']),
      user: MerchantUser.fromJson((json['user'] as Map<String, dynamic>? ?? <String, dynamic>{})),
    );
  }
}

class MerchantUser {
  const MerchantUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.tier,
    required this.hasPaymentCard,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.isKycVerified,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final MerchantTier tier;
  final bool hasPaymentCard;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool isKycVerified;

  String get fullName {
    final parts = <String>[firstName, lastName].where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Merchant' : parts.join(' ');
  }

  factory MerchantUser.fromJson(Map<String, dynamic> json) {
    return MerchantUser(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      tier: MerchantTier.fromJson((json['tier'] as Map<String, dynamic>? ?? <String, dynamic>{})),
      hasPaymentCard: json['hasPaymentCard'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
      isEmailVerified: json['isEmailVerified'] == true,
      isKycVerified: json['isKycVerified'] == true,
    );
  }
}

class MerchantTier {
  const MerchantTier({
    required this.id,
    required this.code,
    required this.name,
    required this.creditLimit,
  });

  final String id;
  final String code;
  final String name;
  final double creditLimit;

  factory MerchantTier.fromJson(Map<String, dynamic> json) {
    return MerchantTier(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      creditLimit: _toDouble(json['creditLimit']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
