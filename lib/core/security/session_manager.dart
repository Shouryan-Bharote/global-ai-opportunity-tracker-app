import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages application-level session security:
///
/// 1. **Session timeout** — logs the user out automatically after a configurable
///    period of inactivity (no user interaction events).
/// 2. **Background locking** — the session is suspended (but not immediately
///    logged out) when the app enters the background; the user is given a grace
///    period before a full logout is forced.
///
/// Wire this to your root widget using [SessionManager].
///
/// ### Integration
/// ```dart
/// // In main.dart / App widget:
/// final sessionManager = SessionManager(
///   ref: ref,
///   inactivityTimeout: const Duration(minutes: 30),
///   backgroundGracePeriod: const Duration(minutes: 5),
///   onSessionExpired: () => ref.read(authProvider.notifier).logout(),
/// );
///
/// @override
/// Widget build(BuildContext context) {
///   return sessionManager.wrap(child: MaterialApp(...));
/// }
/// ```
class SessionManager extends StatefulWidget {
  const SessionManager({
    required this.child,
    required this.onSessionExpired,
    this.inactivityTimeout = const Duration(minutes: 30),
    this.backgroundGracePeriod = const Duration(minutes: 5),
    super.key,
  });

  final Widget child;

  /// Called when the session expires due to inactivity or background timeout.
  final Future<void> Function() onSessionExpired;

  /// Duration of user inactivity after which the session expires.
  final Duration inactivityTimeout;

  /// Grace period when app is backgrounded before the session expires.
  final Duration backgroundGracePeriod;

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager>
    with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  Timer? _backgroundTimer;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    _backgroundTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // App lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _backgroundedAt = DateTime.now();
        _startBackgroundTimer();

      case AppLifecycleState.resumed:
        _backgroundTimer?.cancel();
        if (_backgroundedAt != null) {
          final elapsed = DateTime.now().difference(_backgroundedAt!);
          if (elapsed >= widget.backgroundGracePeriod) {
            _expireSession();
            return;
          }
        }
        _backgroundedAt = null;
        _resetInactivityTimer();

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Timers
  // ---------------------------------------------------------------------------

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(widget.inactivityTimeout, _expireSession);
  }

  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer(widget.backgroundGracePeriod, _expireSession);
  }

  void _expireSession() {
    _inactivityTimer?.cancel();
    _backgroundTimer?.cancel();
    unawaited(widget.onSessionExpired());
  }

  // ---------------------------------------------------------------------------
  // User interaction detection
  // ---------------------------------------------------------------------------

  void _onUserInteraction(PointerEvent _) {
    _resetInactivityTimer();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onUserInteraction,
      onPointerMove: _onUserInteraction,
      onPointerUp: _onUserInteraction,
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Screen-content protection
// ---------------------------------------------------------------------------

/// Applies OS-level screen capture / screenshot prevention.
///
/// Call [ScreenProtection.enable] early in main() (after
/// [WidgetsFlutterBinding.ensureInitialized]) to prevent the app UI from
/// appearing in:
/// - Android recent-apps thumbnail
/// - iOS/Android screenshots and screen recordings (on supported OS versions)
///
/// Call [ScreenProtection.disable] if you have a specific screen where capture
/// is acceptable (e.g. a public event listing page).
class ScreenProtection {
  ScreenProtection._();

  static const _channel = MethodChannel('ai_nexus/screen_protection');

  /// Enables FLAG_SECURE on Android to block screenshots and screen recording.
  static Future<void> enable() async {
    try {
      await _channel.invokeMethod<void>('enableSecureFlag');
    } on MissingPluginException {
      // Running on a platform that has not implemented the channel (web/desktop).
      // Fail gracefully — do not crash the app.
    } on PlatformException catch (e) {
      debugPrint('[ScreenProtection] Failed to enable: ${e.message}');
    }
  }

  /// Removes FLAG_SECURE, allowing normal screen capture.
  static Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('disableSecureFlag');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    } on PlatformException catch (e) {
      debugPrint('[ScreenProtection] Failed to disable: ${e.message}');
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Exposes a simple notifier that can be used to track session validity
/// independently from the auth provider (e.g. to show a "session expired" overlay).
class SessionStateNotifier extends StateNotifier<SessionStatus> {
  SessionStateNotifier() : super(SessionStatus.active);

  void expire() => state = SessionStatus.expired;

  void restore() => state = SessionStatus.active;
}

enum SessionStatus { active, expired }

final sessionStateProvider =
    StateNotifierProvider<SessionStateNotifier, SessionStatus>(
  (ref) => SessionStateNotifier(),
);
