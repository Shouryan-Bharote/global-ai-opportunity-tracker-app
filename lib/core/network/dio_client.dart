import 'package:ai_nexus/core/config/env_config.dart';
import 'package:ai_nexus/core/constants/api_constants.dart';
import 'package:ai_nexus/core/network/auth_interceptor.dart';
import 'package:ai_nexus/core/security/certificate_pinning_interceptor.dart';
import 'package:ai_nexus/core/security/security_headers_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Central Dio HTTP client configured with all security interceptors.
///
/// Interceptor execution order (request phase):
/// 1. [SecurityHeadersInterceptor] — adds security headers, validates host
/// 2. [AuthInterceptor] — injects Bearer token, handles 401 retry
/// 3. [LogInterceptor] — logs request/response (debug builds only)
///
/// TLS certificate pinning is applied via [CertificatePinningInterceptor]
/// which replaces the [HttpClientAdapter] on release builds.
class DioClient {
  DioClient(AuthInterceptor authInterceptor) {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // Follow at most one redirect to prevent open-redirect attacks.
        maxRedirects: 1,
        followRedirects: true,
      ),
    );

    // 1. Security headers (host whitelist + request headers).
    _dio.interceptors.add(
      SecurityHeadersInterceptor(
        allowedHosts: {
          // Add all allowed API hosts here.
          'global-ai-opportunity-tracker-backend.onrender.com',
          'identitytoolkit.googleapis.com',
          'securetoken.googleapis.com',
        },
      ),
    );

    // 2. Auth token injection + 401 handling.
    _dio.interceptors.add(authInterceptor);

    // 3. Logger — only in non-release builds to avoid leaking tokens/PII.
    if (!kReleaseMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          // Mask Authorization header in logs.
          requestHeader: false,
          logPrint: (obj) => _logger.d(obj.toString()),
        ),
      );
    }

    // 4. Certificate pinning — replaces HttpClientAdapter in release mode.
    CertificatePinningInterceptor.applyTo(_dio);
  }

  late final Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;
}
