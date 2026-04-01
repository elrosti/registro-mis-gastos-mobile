import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    developer.log('onError: statusCode=$statusCode, type=${err.type}',
        name: 'AuthInterceptor');

    if (statusCode == 401 || statusCode == 403) {
      developer.log(
          '401/403 detected, clearing token and notifying auth service',
          name: 'AuthInterceptor');
      await _secureStorage.delete(key: 'auth_token');
      authService.notifyTokenExpired();
    }

    return handler.next(err);
  }

  bool _shouldSkipAuth(String path) {
    const publicPaths = ['/auth/register', '/auth/login', '/auth/oauth'];
    return publicPaths.any((p) => path.startsWith(p));
  }
}

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio, required String baseUrl}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => developer.log('$obj', name: 'API'),
      ),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    developer.log(
        '_handleError: type=${e.type}, statusCode=${e.response?.statusCode}, data=${e.response?.data}',
        name: 'ApiClient');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timeout');
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        developer.log(
            'badResponse: statusCode=$statusCode, data type=${data.runtimeType}',
            name: 'ApiClient');

        String message = 'Server error';
        if (data is Map) {
          message = (data['message'] ??
                  data['error'] ??
                  data['title'] ??
                  'Server error')
              .toString();
          developer.log('Extracted message: $message', name: 'ApiClient');
        } else if (data is String && data.isNotEmpty) {
          message = data;
        }

        if (statusCode == 401) {
          return AuthException(message: message);
        }
        if (statusCode == 403) {
          return AuthException(message: 'Acceso denegado: $message');
        }
        return ServerException(message: message, statusCode: statusCode);
      default:
        return ServerException(
          message: e.message ?? 'Unknown error',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
