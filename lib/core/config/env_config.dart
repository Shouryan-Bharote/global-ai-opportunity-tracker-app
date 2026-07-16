import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static Future<void> load() async {
    await dotenv.load();
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.example.com/v1';
}
