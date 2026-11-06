import 'package:flutter/foundation.dart';

/// Client-side rate limiter that prevents excessive API calls.
///
/// This is a best-effort layer on the client side.  The authoritative rate
/// limit enforcement lives on the backend. This class is used to:
///
/// 1. Protect users from accidental UI-driven spam (double-taps, infinite
///    retry loops).
/// 2. Provide early feedback ("slow down") without making a network round-trip.
///
/// Usage:
/// ```dart
/// final limiter = RateLimiter(
///   maxRequests: 10,
///   window: const Duration(minutes: 1),
/// );
///
/// if (!limiter.allow(key: '/api/events')) {
///   throw Exception('Rate limit exceeded. Please wait before retrying.');
/// }
/// ```
class RateLimiter {
  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  /// Maximum number of requests permitted within [window].
  final int maxRequests;

  /// Rolling time window for the [maxRequests] limit.
  final Duration window;

  /// Timestamps of recent requests, keyed by an arbitrary route/action key.
  final Map<String, List<DateTime>> _timestamps = {};

  /// Returns `true` when the call is allowed, `false` when the rate limit
  /// has been exceeded.
  bool allow({required String key}) {
    final now = DateTime.now();
    final cutoff = now.subtract(window);

    final times = (_timestamps[key] ?? [])
      ..removeWhere((t) => t.isBefore(cutoff));

    if (times.length >= maxRequests) {
      debugPrint(
        '[RateLimiter] limit exceeded for "$key" '
        '(${times.length}/$maxRequests in ${window.inSeconds}s)',
      );
      return false;
    }

    times.add(now);
    _timestamps[key] = times;
    return true;
  }

  /// Returns the [Duration] until the oldest request in the window expires
  /// and a new request would be permitted.  Returns [Duration.zero] if a
  /// request can be made immediately.
  Duration retryAfter({required String key}) {
    final now = DateTime.now();
    final cutoff = now.subtract(window);
    final times = (_timestamps[key] ?? [])
      ..removeWhere((t) => t.isBefore(cutoff));

    if (times.length < maxRequests) return Duration.zero;

    final oldest = times.reduce((a, b) => a.isBefore(b) ? a : b);
    final expiresAt = oldest.add(window);
    final diff = expiresAt.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Clears rate-limit state for a specific [key].
  void reset({required String key}) => _timestamps.remove(key);

  /// Clears all rate-limit state.
  void resetAll() => _timestamps.clear();
}

/// Singleton auth-endpoint rate limiter.
///
/// Used to guard login, register, and password-reset endpoints.
final authRateLimiter = RateLimiter(
  maxRequests: 5,
  window: const Duration(minutes: 1),
);

/// Singleton general API rate limiter.
final apiRateLimiter = RateLimiter(
  maxRequests: 60,
  window: const Duration(minutes: 1),
);
