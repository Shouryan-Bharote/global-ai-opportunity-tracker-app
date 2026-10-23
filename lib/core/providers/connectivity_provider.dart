import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus {
  online,
  offline,
}

class ConnectivityNotifier extends StateNotifier<NetworkStatus> {
  ConnectivityNotifier(this._connectivity) : super(NetworkStatus.online) {
    unawaited(_init());
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      _updateStatus(initial);
    } on Object catch (_) {
      state = NetworkStatus.online;
    }

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isOffline = results.isEmpty ||
        results.contains(ConnectivityResult.none) ||
        !results.any((r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet ||
            r == ConnectivityResult.vpn);

    final newStatus = isOffline ? NetworkStatus.offline : NetworkStatus.online;
    if (state != newStatus) {
      state = newStatus;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, NetworkStatus>((ref) {
  return ConnectivityNotifier(Connectivity());
});
