import 'dart:async';
import 'package:ai_nexus/core/providers/connectivity_provider.dart';
import 'package:ai_nexus/features/events/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkStateBanner extends ConsumerStatefulWidget {
  const NetworkStateBanner({super.key});

  @override
  ConsumerState<NetworkStateBanner> createState() => _NetworkStateBannerState();
}

class _NetworkStateBannerState extends ConsumerState<NetworkStateBanner> {
  bool _showBackOnline = false;
  Timer? _dismissTimer;
  NetworkStatus? _previousStatus;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(connectivityProvider);

    // Detect transition from offline -> online to show brief confirmation
    if (_previousStatus == NetworkStatus.offline &&
        status == NetworkStatus.online) {
      _showBackOnline = true;
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showBackOnline = false;
          });
        }
      });
    }

    _previousStatus = status;

    final isOffline = status == NetworkStatus.offline;
    final isVisible = isOffline || _showBackOnline;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isVisible
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOffline
                    ? const Color(0xFFB45309).withValues(alpha: 0.95) // Amber
                    : const Color(0xFF047857).withValues(alpha: 0.95), // Emerald
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: isOffline
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                        : const Color(0xFF10B981).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isOffline
                              ? 'Offline Mode Active'
                              : 'Back Online!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOffline
                              ? 'Viewing saved opportunities from local storage'
                              : 'Connected — synchronizing latest opportunities',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOffline)
                    TextButton(
                      onPressed: () {
                        ref.invalidate(eventsProvider);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
