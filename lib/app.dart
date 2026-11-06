import 'package:ai_nexus/core/constants/app_constants.dart';
import 'package:ai_nexus/core/providers/theme_provider.dart';
import 'package:ai_nexus/core/router/app_router.dart';
import 'package:ai_nexus/core/security/session_manager.dart';
import 'package:ai_nexus/core/theme/app_theme.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final router = ref.read(routerProvider);

    return SessionManager(
      onSessionExpired: () async {
        // Only log out if the user is actually authenticated.
        final isAuthenticated = ref.read(authProvider).isAuthenticated;
        if (isAuthenticated) {
          await ref.read(authProvider.notifier).logout();
        }
      },
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        // Disable the built-in AnimatedTheme transition.
        themeAnimationDuration: Duration.zero,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
