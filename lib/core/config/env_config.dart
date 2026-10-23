import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static bool _initialized = false;
  static String _apiBaseUrl = '';

  static Future<void> load() async {
    await dotenv.load();
    _apiBaseUrl = await _resolveApiBaseUrl();
    _initialized = true;
  }

  static Future<String> _resolveApiBaseUrl() async {
    var url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

    // On Android, localhost/127.0.0.1 points to the device itself.
    // - Android Emulator: needs 10.0.2.2 to reach the host machine
    // - Physical device with `adb reverse tcp:8000 tcp:8000`: keep localhost as-is
    if (!kIsWeb && Platform.isAndroid) {
      var isEmulator = false;
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        isEmulator = !androidInfo.isPhysicalDevice;
      } on Object catch (_) {
        // Assume physical if detection fails — safer, avoids wrong remapping
        isEmulator = false;
      }

      if (isEmulator) {
        // Emulator: remap localhost to host machine at 10.0.2.2
        if (url.contains('localhost')) {
          url = url.replaceAll('localhost', '10.0.2.2');
        } else if (url.contains('127.0.0.1')) {
          url = url.replaceAll('127.0.0.1', '10.0.2.2');
        }
      }
      // Physical device with adb reverse: keep localhost — it tunnels to PC
    }

    if (!url.endsWith('/')) {
      url = '$url/';
    }
    return url;
  }

  static String get apiBaseUrl {
    assert(
      _initialized,
      'EnvConfig.load() must be awaited before accessing apiBaseUrl',
    );
    return _apiBaseUrl;
  }
}
