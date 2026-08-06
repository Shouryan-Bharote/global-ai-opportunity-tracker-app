import 'package:ai_nexus/core/widgets/app_shell.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/screens/auth_screen.dart';
import 'package:ai_nexus/features/auth/screens/forgot_password_screen.dart';
import 'package:ai_nexus/features/auth/screens/otp_screen.dart';
import 'package:ai_nexus/features/auth/screens/reset_password_screen.dart';
import 'package:ai_nexus/features/auth/screens/sign_up_screen.dart';
import 'package:ai_nexus/features/auth/screens/splash_screen.dart';
import 'package:ai_nexus/features/auth/screens/welcome_screen.dart';
import 'package:ai_nexus/features/events/screens/event_details_screen.dart';
import 'package:ai_nexus/features/explore/screens/explore_screen.dart';
import 'package:ai_nexus/features/home/screens/home_screen.dart';
import 'package:ai_nexus/features/profile/screens/profile_screen.dart';
import 'package:ai_nexus/features/schedule/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// A [ChangeNotifier] that listens to auth state and notifies GoRouter
/// to re-evaluate its redirect logic whenever auth state changes.
///
/// This is the correct pattern for Riverpod + GoRouter: the router instance
/// is created ONCE, and only redirects are re-evaluated via
/// refreshListenable — preventing the entire navigation stack from being
/// torn down on every auth state update.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Listen to auth state and notify GoRouter's redirect when it changes.
    _ref.listen<AuthState>(authProvider, (prev, next) => notifyListeners());
  }

  final Ref _ref;

  bool get isAuthenticated => _ref.read(authProvider).isAuthenticated;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    // refreshListenable re-evaluates redirect WITHOUT recreating the router.
    refreshListenable: notifier,
    redirect: (context, state) {
      // final isAuthenticated = notifier.isAuthenticated;
      final isAuthenticated = notifier.isAuthenticated;

      final isUnauthenticatedRoute =
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot_password' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/reset_password' ||
          state.matchedLocation == '/welcome';

      // If not authenticated, stay on unauthenticated routes or force to /auth
      if (!isAuthenticated && !isUnauthenticatedRoute) {
        // return '/auth';
        return '/home';
      }

      // If authenticated, leave splash/auth routes and go to home
      if (isAuthenticated && isUnauthenticatedRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['id']!;
          final imageUrl = state.extra as String?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EventDetailsScreen(eventId: eventId, imageUrl: imageUrl),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final offsetAnimation =
                      Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
