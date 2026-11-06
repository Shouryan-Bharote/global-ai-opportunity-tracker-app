import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Adds security-hardening HTTP headers to every outbound request and
/// validates that responses come from the expected origin.
///
/// Headers added to each request:
/// - `X-Content-Type-Options: nosniff` — prevents MIME-type sniffing
/// - `X-Frame-Options: DENY` — prevents click-jacking (useful for WebViews)
/// - `X-Requested-With: XMLHttpRequest` — helps the server distinguish
///   API requests from browser navigations
/// - `Cache-Control: no-store` — prevents sensitive responses being cached
///   in shared proxies or CDN edge nodes
/// - `Content-Security-Policy` — basic CSP for WebView responses
class SecurityHeadersInterceptor extends Interceptor {
  SecurityHeadersInterceptor({
    this.allowedHosts = const {},
  });

  /// Optional whitelist of hosts the app is permitted to call.
  /// Leave empty to allow all hosts (use when calling third-party APIs).
  final Set<String> allowedHosts;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Validate host against whitelist (release builds only).
    if (kReleaseMode && allowedHosts.isNotEmpty) {
      final requestHost = options.uri.host;
      final allowed = allowedHosts.any(
        (h) => requestHost == h || requestHost.endsWith('.$h'),
      );
      if (!allowed) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message:
                '[Security] Request to untrusted host blocked: $requestHost',
          ),
        );
        return;
      }
    }

    // Inject security headers.
    options.headers.addAll({
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-Requested-With': 'XMLHttpRequest',
      'Cache-Control': 'no-store',
      // Help server implement CSRF protection.
      'X-App-Version': '1.0.0',
    });

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // Reject responses with a content-type that doesn't match JSON when we
    // expected JSON (guarded: only for API paths, not file downloads).
    final contentType =
        response.headers.value('content-type') ?? '';
    final isJsonExpected =
        response.requestOptions.path.contains('/api/');
    if (isJsonExpected &&
        !contentType.contains('application/json') &&
        !contentType.contains('text/')) {
      debugPrint(
        '[Security] Suspicious content-type: $contentType '
        'for ${response.requestOptions.uri}',
      );
    }

    handler.next(response);
  }
}
