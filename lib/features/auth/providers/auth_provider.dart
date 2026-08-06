import 'package:ai_nexus/core/providers/providers.dart';
import 'package:ai_nexus/features/auth/models/user_model.dart';
import 'package:ai_nexus/features/auth/repositories/mock_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<MockAuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthState {

  const AuthState({this.user, this.isLoading = false, this.error});
  final UserModel? user;
  final bool isLoading;
  final String? error;
  
  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
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

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email, password);
    
    result.when(
      success: (user) {
        // Save token to secure storage in a real app
        state = state.copyWith(user: user, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(error: error.toString(), isLoading: false);
      },
    );
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(name, email, password);
    
    result.when(
      success: (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(error: error.toString(), isLoading: false);
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    
    ref.read(secureStorageProvider).deleteToken();
    state = const AuthState(); // Reset
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
