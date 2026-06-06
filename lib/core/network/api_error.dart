import 'package:dio/dio.dart';

class ApiError implements Exception {
  ApiError({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  factory ApiError.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return ApiError(
        message: (data['message'] ?? 'Request failed').toString(),
        statusCode: statusCode,
        code: data['code']?.toString(),
      );
    }

    return ApiError(
      message: error.message ?? 'Network error occurred',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
