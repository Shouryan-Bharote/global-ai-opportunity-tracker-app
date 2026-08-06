import 'package:ai_nexus/core/config/env_config.dart';
import 'package:ai_nexus/core/constants/api_constants.dart';
import 'package:ai_nexus/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient {

  DioClient(AuthInterceptor authInterceptor) {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      ),
    );

    _dio.interceptors.addAll([
      authInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _logger.d(obj.toString()),
      ),
    ]);
  }
  late final Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;
}
