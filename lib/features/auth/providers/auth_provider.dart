import 'package:ai_nexus/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final UserModel? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login(
    String email,
    String password,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please try again.',
        );
        return;
      }

      // Make sure the latest Firebase user information is loaded.
      await firebaseUser.reload();

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to load your account.',
        );
        return;
      }

      final userEmail = currentUser.email ?? email.trim();

      final userName =
          currentUser.displayName != null &&
              currentUser.displayName!.trim().isNotEmpty
          ? currentUser.displayName!.trim()
          : _nameFromEmail(userEmail);

      final user = UserModel(
        id: currentUser.uid,
        email: userEmail,
        name: userName,
        avatarUrl: currentUser.photoURL,
      );

      state = AuthState(
        user: user,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _loginErrorMessage(e),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter your name.',
      );
      return;
    }

    if (trimmedEmail.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter your email address.',
      );
      return;
    }

    if (password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Please enter your password.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: trimmedEmail,
            password: password,
          );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. Please try again.',
        );
        return;
      }

      // ========================================================
      // SAVE THE ACTUAL NAME IN FIREBASE AUTH
      // ========================================================

      await firebaseUser.updateDisplayName(trimmedName);

      // Reload so Firebase.currentUser contains the new name.
      await firebaseUser.reload();

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to load your new account.',
        );
        return;
      }

      final user = UserModel(
        id: currentUser.uid,
        email: currentUser.email ?? trimmedEmail,
        name: currentUser.displayName?.trim().isNotEmpty == true
            ? currentUser.displayName!.trim()
            : trimmedName,
        avatarUrl: currentUser.photoURL,
      );

      state = AuthState(
        user: user,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _registerErrorMessage(e),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<String?> resetPassword(
    String email,
  ) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'user-not-found':
          return 'No account found with this email address.';

        case 'too-many-requests':
          return 'Too many requests. Please try again later.';

        default:
          return e.message ?? 'Could not send password reset email.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await FirebaseAuth.instance.signOut();

      // Clear local authentication state.
      state = const AuthState();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to logout. Please try again.',
      );
    }
  }

  // ============================================================
  // LOGIN ERROR MESSAGES
  // ============================================================

  String _loginErrorMessage(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }

  // ============================================================
  // REGISTER ERROR MESSAGES
  // ============================================================

  String _registerErrorMessage(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      case 'operation-not-allowed':
        return 'Email/password registration is not enabled in Firebase.';

      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  // ============================================================
  // FALLBACK NAME
  // ============================================================

  String _nameFromEmail(
    String email,
  ) {
    if (email.isEmpty) {
      return 'User';
    }

    final username = email.split('@').first;

    if (username.isEmpty) {
      return 'User';
    }

    final words = username
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .toList();

    return words.join(' ');
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
