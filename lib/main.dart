import 'package:ai_nexus/app.dart';
import 'package:ai_nexus/core/config/env_config.dart';
import 'package:ai_nexus/core/database/isar_service.dart';
import 'package:ai_nexus/core/security/session_manager.dart';
import 'package:ai_nexus/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (guard against duplicate-app on hot restart)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Load environment variables
  await EnvConfig.load();

  // Initialize local database (Isar 3.x lacks out-of-the-box web support)
  if (!kIsWeb) {
    await IsarService().init();
  }

  // ── Security hardening ────────────────────────────────────────────────────

  // Prevent the OS from capturing the app's UI in recent-apps thumbnails,
  // screenshots, and screen recordings. This protects sensitive content such
  // as personal event data, tokens, and profile information.
  await ScreenProtection.enable();

  // Lock the app to portrait orientation to prevent unintended UI exposure.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─────────────────────────────────────────────────────────────────────────

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
