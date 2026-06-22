import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_error.dart';
import 'api_result.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return ApiSuccess<T>(parser(response.data));
    } on DioException catch (error) {
      return ApiFailure<T>(ApiError.fromDioException(error));
    }
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiSuccess<T>(parser(response.data));
    } on DioException catch (error) {
      return ApiFailure<T>(ApiError.fromDioException(error));
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiSuccess<T>(parser(response.data));
    } on DioException catch (error) {
      return ApiFailure<T>(ApiError.fromDioException(error));
    }
  }

  static Dio createDio({List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll(interceptors);
    return dio;
  }
}
