import 'package:ai_nexus/core/providers/theme_provider.dart';
import 'package:ai_nexus/core/widgets/app_header.dart';
import 'package:ai_nexus/core/widgets/custom_nav_bar.dart';
import 'package:ai_nexus/core/widgets/network_state_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isDarkMode = ref.watch(isDarkModeProvider);

    final pageTitle = switch (currentIndex) {
      0 => 'AI Nexus',
      1 => 'Explore',
      2 => 'My Schedule',
      3 => 'Profile',
      _ => 'AI Nexus',
    };

    final subtitle = switch (currentIndex) {
      0 => 'Opportunity Tracker',
      1 => 'Discover events',
      2 => 'Your events',
      3 => 'Manage account',
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              pageTitle: pageTitle,
              subtitle: subtitle,
              isDarkMode: isDarkMode,
              onThemeToggle: (value) =>
                  ref.read(isDarkModeProvider.notifier).state = value,
            ),
            const NetworkStateBanner(),
            Expanded(
              child: Stack(
                children: [
                  navigationShell,
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomNavBar(
                      selectedIndex: currentIndex,
                      onDestinationSelected: (index) {
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
