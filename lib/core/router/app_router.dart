import 'package:ai_nexus/core/widgets/app_shell.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/providers/onboarding_provider.dart';
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
import 'package:ai_nexus/features/onboarding/screens/onboarding_questionnaire_screen.dart';
import 'package:ai_nexus/features/profile/screens/profile_screen.dart';
import 'package:ai_nexus/features/schedule/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (prev, next) => notifyListeners(),
    );
    _ref.listen<bool>(
      onboardingProvider,
      (prev, next) => notifyListeners(),
    );
  }

  final Ref _ref;

  bool get isAuthenticated => _ref.read(authProvider).isAuthenticated;
  bool get isOnboarded => _ref.read(onboardingProvider);
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.keepAlive();
  final notifier = _RouterNotifier(ref);

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'root'),

    initialLocation: '/splash',

    refreshListenable: notifier,

    redirect: (context, state) {
      // Always allow the splash screen to present its entrance experience.
      // SplashScreen handles navigating to /home, /onboarding, or /auth when finished.
      if (state.matchedLocation == '/splash') {
        return null;
      }

      final isAuthenticated = notifier.isAuthenticated;
      final isOnboarded = notifier.isOnboarded;

      final isAuthRoute =
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/reset-password' ||
          state.matchedLocation == '/welcome';

      // User is NOT logged in.
      // Keep them on login/signup/forgot-password pages.
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }

      // User IS logged in.
      if (isAuthenticated) {
        // First-time onboarding redirect
        if (!isOnboarded && state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        // Send them to home if they try to access login pages or onboarding when already done.
        if (isOnboarded && (isAuthRoute || state.matchedLocation == '/onboarding')) {
          return '/home';
        }
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
        path: '/onboarding',
        builder: (context, state) => const OnboardingQuestionnaireScreen(),
      ),

      GoRoute(
        path: '/events/:id',
        pageBuilder: (context, state) {
          final eventId = Uri.decodeComponent(state.pathParameters['id']!);
          final imageUrl = state.extra as String?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: EventDetailsScreen(
              eventId: eventId,
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
