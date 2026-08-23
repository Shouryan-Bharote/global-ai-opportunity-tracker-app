import 'package:ai_nexus/core/widgets/app_shell.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/screens/auth_screen.dart';
import 'package:ai_nexus/features/auth/screens/forgot_password_screen.dart';
import 'package:ai_nexus/features/auth/screens/otp_screen.dart';
import 'package:ai_nexus/features/auth/screens/reset_password_screen.dart';
import 'package:ai_nexus/features/auth/screens/sign_up_screen.dart';
import 'package:ai_nexus/features/auth/screens/splash_screen.dart';
import 'package:ai_nexus/features/auth/screens/welcome_screen.dart';
import 'package:ai_nexus/features/opportunities/screens/opportunity_details_screen.dart';
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

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (prev, next) => notifyListeners(),
    );
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

    refreshListenable: notifier,

    redirect: (context, state) {
      final isAuthenticated = notifier.isAuthenticated;

      final isUnauthenticatedRoute =
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/reset-password' ||
          state.matchedLocation == '/welcome';

      // User is NOT logged in.
      // Keep them on login/signup/forgot-password pages.
      if (!isAuthenticated && !isUnauthenticatedRoute) {
        return '/auth';
      }

      // User IS logged in.
      // Send them to home if they try to access login pages.
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),

      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      GoRoute(
        path: '/events/:id',
        pageBuilder: (context, state) {
          final opportunityId = state.pathParameters['id']!;
          final imageUrl = state.extra as String?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: OpportunityDetailsScreen(
              opportunityId: opportunityId,
              imageUrl: imageUrl,
            ),
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

      GoRoute(
        path: '/opportunities/:id',
        pageBuilder: (context, state) {
          final opportunityId = state.pathParameters['id']!;
          final imageUrl = state.extra as String?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: OpportunityDetailsScreen(
              opportunityId: opportunityId,
              imageUrl: imageUrl,
            ),
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
