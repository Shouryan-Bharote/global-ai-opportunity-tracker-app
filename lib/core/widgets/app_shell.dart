import 'package:ai_nexus/core/widgets/custom_nav_bar.dart';
import 'package:ai_nexus/core/widgets/app_header.dart';
import 'package:ai_nexus/core/providers/theme_provider.dart';
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

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/schedule');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final isForward = currentIndex > _previousIndex;
    final isDarkMode = ref.watch(isDarkModeProvider);

    String pageTitle = 'AI Nexus';
    String? subtitle = 'Opportunity Tracker';
    switch (currentIndex) {
      case 0:
        pageTitle = 'AI Nexus';
        subtitle = 'Opportunity Tracker';
        break;
      case 1:
        pageTitle = 'Explore';
        subtitle = 'Discover events';
        break;
      case 2:
        pageTitle = 'My Schedule';
        subtitle = 'Your events';
        break;
      case 3:
        pageTitle = 'Profile';
        subtitle = 'Manage account';
        break;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              pageTitle: pageTitle,
              subtitle: subtitle,
              isDarkMode: isDarkMode,
              onThemeToggle: (value) => ref.read(isDarkModeProvider.notifier).state = value,
            ),
            Expanded(
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final isEntering = child.key == ValueKey(currentIndex);

                      final inOffset = Tween<Offset>(
                        begin: Offset(isForward ? 1.0 : -1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);

                      final outOffset = Tween<Offset>(
                        begin: Offset(isForward ? -1.0 : 1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);

                      return SlideTransition(
                        position: isEntering ? inOffset : outOffset,
                        child: child,
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(currentIndex),
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
                        setState(() {
                          _previousIndex = currentIndex;
                        });
                        _onItemTapped(index, context);
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
