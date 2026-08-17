import 'package:ai_nexus/core/providers/theme_provider.dart';
import 'package:ai_nexus/core/widgets/app_header.dart';
import 'package:ai_nexus/core/widgets/custom_nav_bar.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _previousIndex = 0;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/explore');
      case 2:
        context.go('/schedule');
      case 3:
        context.go('/profile');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _selectedIndex(context);
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Calculate direction dynamically:
    // If moving to a smaller index (e.g. from Schedule/Profile back to Home), reverse is true (slide left-to-right).
    // If moving to a larger/equal index, reverse is false (slide right-to-left).
    final isReverse = currentIndex < _previousIndex;

    // Synchronize previous index for subsequent route changes
    _previousIndex = currentIndex;

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
            Expanded(
              child: Stack(
                children: [
                  PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 150),
                    reverse: isReverse,
                    transitionBuilder: (
                      child,
                      animation,
                      secondaryAnimation,
                    ) => SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey<int>(currentIndex),
                      child: widget.child,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomNavBar(
                      selectedIndex: currentIndex,
                      onDestinationSelected: (index) {
                        if (index == currentIndex) return;
                        _navigate(context, index);
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
