import 'package:ai_nexus/app.dart';
import 'package:ai_nexus/core/config/env_config.dart';
import 'package:ai_nexus/core/database/isar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvConfig.load();
  
  // Initialize local database (Isar 3.x lacks out-of-the-box web support)
  if (!kIsWeb) {
    await IsarService().init();
  }

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
