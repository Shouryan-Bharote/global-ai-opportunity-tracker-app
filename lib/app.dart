import 'package:ai_nexus/core/constants/app_constants.dart';
import 'package:ai_nexus/core/router/app_router.dart';
import 'package:ai_nexus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // IMPORTANT: use ref.read — GoRouter must be created ONCE.
    // Using ref.watch would rebuild App (and reset routerConfig) every
    // time auth state changes, tearing down the entire navigation stack.
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
