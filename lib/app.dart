import 'package:ai_nexus/core/constants/app_constants.dart';
import 'package:ai_nexus/core/providers/theme_provider.dart';
import 'package:ai_nexus/core/router/app_router.dart';
import 'package:ai_nexus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current dark/light mode
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Get router
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,

      // Light theme
      theme: AppTheme.lightTheme,

      // Dark theme
      darkTheme: AppTheme.darkTheme,

      // IMPORTANT:
      // This tells Flutter which theme to display.
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      routerConfig: router,

      debugShowCheckedModeBanner: false,
    );
  }
}
