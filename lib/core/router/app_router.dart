import 'package:ai_nexus/core/widgets/app_shell.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/auth/screens/auth_screen.dart';
import 'package:ai_nexus/features/auth/screens/sign_up_screen.dart';
import 'package:ai_nexus/features/auth/screens/splash_screen.dart';
import 'package:ai_nexus/features/auth/screens/forgot_password_screen.dart';
import 'package:ai_nexus/features/auth/screens/otp_screen.dart';
import 'package:ai_nexus/features/auth/screens/reset_password_screen.dart';
import 'package:ai_nexus/features/auth/screens/welcome_screen.dart';
import 'package:ai_nexus/features/events/screens/event_details_screen.dart';
import 'package:ai_nexus/features/explore/screens/explore_screen.dart';
import 'package:ai_nexus/features/home/screens/home_screen.dart';
import 'package:ai_nexus/features/profile/screens/profile_screen.dart';
import 'package:ai_nexus/features/schedule/screens/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
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
    redirect: (context, state) async {
      final isAuthRoute = state.matchedLocation == '/auth' || state.matchedLocation == '/signup';
      final isSplashRoute = state.matchedLocation == '/splash';
      
      // If not authenticated, force to /auth unless already there
      if (!authState.isAuthenticated && !isAuthRoute) {
        return '/auth';
      }
      
      // If authenticated, force to /home from splash or auth screens
      if (authState.isAuthenticated && (isAuthRoute || isSplashRoute)) {
        return '/home';
      }
      
      return null;
    },
  );
});
