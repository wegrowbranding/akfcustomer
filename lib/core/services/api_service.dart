import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/preference_service.dart';

class ApiService {
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    _setupInterceptors();
  }
  late Dio _dio;
  final String _baseUrl = ApiConstants.baseUrl;

  void _setupInterceptors() {
    // Request interceptor to add auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await PreferenceService.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            options.headers['Accept'] = 'application/json';

            if (kDebugMode) {
              debugPrint('API Request: ${options.method} ${options.uri}');
              if (options.data != null) {
                debugPrint('Request Data: ${options.data}');
              }
            }

            handler.next(options);
          } catch (e) {
            handler.reject(DioException(error: e, requestOptions: options));
          }
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              'API Response: ${response.statusCode} ${response.realUri}',
            );
            debugPrint('Response Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint('API Error: ${error.type} ${error.message}');
            if (error.response != null) {
              debugPrint('Error Response: ${error.response?.data}');
            }
          }

          // Handle auth errors
          if (error.response?.statusCode == 401) {
            // Token expired, clear auth
            PreferenceService.clearAuth();
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.error});

  factory ApiException.fromDioError(DioException dioError) {
    String message = 'An unexpected error occurred';
    final int? statusCode = dioError.response?.statusCode;

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 400:
            message = 'Bad request. Please check your input.';
            break;
          case 401:
            message = 'Unauthorized.';
            break;
          case 403:
            message = 'Access forbidden. You do not have permission.';
            break;
          case 404:
            message = 'Resource not found.';
            break;
          case 409:
            message = 'Conflict. The resource already exists.';
            break;
          case 500:
            message = 'Internal server error. Please try again later.';
            break;
          case 502:
          case 503:
          case 504:
            message = 'Server unavailable. Please try again later.';
            break;
          default:
            message = dioError.response?.statusMessage ?? 'An error occurred';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection failed. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
        message = dioError.message ?? 'An unknown error occurred';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error. Please check your SSL configuration.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      error: dioError.response?.data,
    );
  }
  final String message;
  final int? statusCode;
  final dynamic error;

  @override
  String toString() => 'ApiException: $message';
}
