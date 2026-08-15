import 'package:ai_nexus/features/auth/models/user_model.dart';
import 'package:ai_nexus/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uses Firebase instead of mock profile data.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirebaseProfileRepository();
});

class ProfileNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final repository = ref.watch(profileRepositoryProvider);

    return repository.getUserProfile();
  }

  /// Update the user's name.
  Future<void> updateName(String newName) async {
    final currentUser = state.value;

    if (currentUser == null || newName.trim().isEmpty) {
      return;
    }

    final updatedUser = currentUser.copyWith(
      name: newName.trim(),
    );

    // Optimistic UI update
    state = AsyncValue.data(updatedUser);

    try {
      final repository = ref.read(profileRepositoryProvider);

      final result = await repository.updateUserProfile(updatedUser);

      if (result != null) {
        state = AsyncValue.data(result);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update the user's profile photo.
  Future<void> updateAvatarUrl(String newUrl) async {
    final currentUser = state.value;

    if (currentUser == null) {
      return;
    }

    final updatedUser = currentUser.copyWith(
      avatarUrl: newUrl.trim().isEmpty ? null : newUrl.trim(),
    );

    // Optimistic UI update
    state = AsyncValue.data(updatedUser);

    try {
      final repository = ref.read(profileRepositoryProvider);

      final result = await repository.updateUserProfile(updatedUser);

      if (result != null) {
        state = AsyncValue.data(result);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserModel?>(
  ProfileNotifier.new,
);
