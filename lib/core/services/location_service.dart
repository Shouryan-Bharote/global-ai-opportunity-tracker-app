import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  final Logger _logger = Logger();

  /// Gets the current location. Requests permission if needed.
  /// Returns null if permission is denied or location services are disabled.
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.w('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.w(
          'Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      _logger.e('Error getting location: $e');
      return null;
    }
  }

  /// Opens the device location settings or app permission settings.
  Future<void> openSettings() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }
}
