import 'package:ai_nexus/core/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Stream provider for device location service status (Enabled/Disabled).
/// Listens to real-time OS location toggle changes.
final locationServiceStatusProvider = StreamProvider<ServiceStatus>((ref) {
  return Geolocator.getServiceStatusStream();
});

/// Real-time location provider that automatically re-evaluates 
/// whenever the user toggles Location ON or OFF in system settings.
final locationProvider = FutureProvider<Position?>((ref) async {
  // Listen to OS location toggle events (enabled/disabled)
  ref.watch(locationServiceStatusProvider);

  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentLocation();
});
