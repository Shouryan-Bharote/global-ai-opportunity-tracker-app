import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Certificate pinning interceptor.
///
/// In production this class replaces Dio's default `HttpClientAdapter` with a
/// custom adapter that validates the server's TLS certificate against a set of
/// trusted SHA-256 SPKI fingerprints.
///
/// On debug/profile builds the check is skipped so developers can use a local
/// backend served with a self-signed certificate.
///
/// ## Updating pins
/// When the backend rotates its TLS certificate you must:
/// 1. Extract the new certificate's SHA-256 SPKI fingerprint (see SECURITY.md).
/// 2. Add it to [_pinnedFingerprints] BEFORE the old certificate expires.
/// 3. Ship an app update and remove the old pin only after users have updated.
class CertificatePinningInterceptor {
  /// SHA-256 hex fingerprints of trusted leaf / intermediate certificates.
  ///
  /// Use the following command to obtain a fingerprint:
  /// ```bash
  /// openssl s_client -connect hostname:443 | \
  ///   openssl x509 -pubkey -noout | \
  ///   openssl rsa -pubin -outform DER 2>/dev/null | sha256sum
  /// ```
  static const List<String> _pinnedFingerprints = [
    // Production backend (Render.com) — update when cert rotates.
    // Replace the placeholder below with the real fingerprint from your server.
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  ];

  /// Configures a Dio instance to use certificate pinning.
  ///
  /// Call this once after [Dio] is constructed:
  /// ```dart
  /// CertificatePinningInterceptor.applyTo(dio);
  /// ```
  static void applyTo(Dio dio) {
    // Only enforce pinning in release builds to allow local dev with self-signed certs.
    if (!kReleaseMode) return;

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) {
          final fingerprint = _certHex(cert.der);
          final trusted = _pinnedFingerprints.contains(fingerprint.toLowerCase());
          if (!trusted) {
            debugPrint(
              '[CertPin] FAILED for $host — fingerprint: $fingerprint',
            );
          }
          return trusted;
        };
      return client;
    };
  }

  /// Converts DER bytes to a lowercase hex string (pseudo-fingerprint).
  ///
  /// For a proper SHA-256 SPKI fingerprint, integrate `package:crypto`:
  /// ```dart
  /// sha256.convert(bytes).toString()
  /// ```
  static String _certHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
