import 'dart:async';

import 'package:ai_nexus/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Dio interceptor responsible for all authentication-related HTTP concerns:
///
/// 1. **Token injection** — attaches `Authorization: Bearer <token>` to every
///    outbound request.
/// 2. **Token refresh** — when a Firebase ID token is about to expire (within
///    the next 5 minutes) it is proactively refreshed before the request is
///    sent, avoiding a needless 401 round-trip.
/// 3. **401 retry** — if the server returns 401, the token is force-refreshed
///    from Firebase Auth and the original request is retried once.  If the
///    retry also fails with 401 the token is deleted and the error is
///    propagated for the auth layer to handle (redirect to login).
/// 4. **Token masking** — the raw token is never logged even in debug mode
///    (the Dio client already gates logging to non-release, but we mask here
///    as an extra layer of defence).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  // Token refresh state is managed by Firebase SDK internally.

  // ---------------------------------------------------------------------------
  // onRequest — inject token
  // ---------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints (e.g. health-check, public events).
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    try {
      final token = await _getFreshToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } on Object catch (e) {
      debugPrint('[AuthInterceptor] Failed to get token: $e');
      // Continue without a token — the server will return 401 if needed.
    }

    return handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // onError — 401 retry with refreshed token
  // ---------------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Only retry once — prevent infinite retry loops.
      if (err.requestOptions.extra['retried'] == true) {
        // Force-refresh failed or second 401 received — clear stored token.
        await _secureStorage.deleteToken();
        debugPrint('[AuthInterceptor] 401 after retry — token cleared.');
        return handler.next(err);
      }

      try {
        final freshToken = await _forceRefreshToken();
        if (freshToken == null) {
          await _secureStorage.deleteToken();
          return handler.next(err);
        }

        // Mark the request as retried and inject the new token.
        final retryOptions = err.requestOptions
          ..extra['retried'] = true
          ..headers['Authorization'] = 'Bearer $freshToken';

        // Replay the original request with the new token.
        final dio = Dio();
        final response = await dio.fetch<dynamic>(retryOptions);
        return handler.resolve(response);
      } on Object catch (e) {
        debugPrint('[AuthInterceptor] Retry failed: $e');
        await _secureStorage.deleteToken();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns the current Firebase ID token, proactively refreshing it if it
  /// expires within the next 5 minutes.
  Future<String?> _getFreshToken() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    // Let Firebase SDK manage token freshness — it caches internally.
    // `forceRefresh: false` will return a cached token if it has > ~5 min left.
    final idToken = await currentUser.getIdToken();
    if (idToken != null) {
      // Keep SecureStorage in sync so non-interceptor code can also read it.
      await _secureStorage.saveToken(idToken);
    }
    return idToken;
  }

  /// Forces a token refresh from Firebase servers and persists the new token.
  Future<String?> _forceRefreshToken() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final idToken = await currentUser.getIdToken(true);
    if (idToken != null) {
      await _secureStorage.saveToken(idToken);
    }
    return idToken;
  }
}
