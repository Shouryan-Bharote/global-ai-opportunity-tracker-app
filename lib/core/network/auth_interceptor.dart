import 'dart:async';
import 'package:ai_nexus/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {

  AuthInterceptor(this._secureStorage);
  final SecureStorage _secureStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized (e.g. clear token, trigger logout)
      unawaited(_secureStorage.deleteToken());
    }
    
    return handler.next(err);
  }
}
