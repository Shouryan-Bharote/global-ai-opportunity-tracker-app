import 'package:ai_nexus/core/constants/app_constants.dart';
import 'package:ai_nexus/core/router/app_router.dart';
import 'package:ai_nexus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Using light theme as default for now based on Figma
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
