import 'package:ai_nexus/features/auth/models/user_model.dart';
import 'package:ai_nexus/features/profile/data/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

class ProfileNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getUserProfile();
  }

  Future<void> updateName(String newName) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(name: newName);
    
    // Optimistic update
    state = AsyncValue.data(updated);

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateUserProfile(updated);
    } catch (e, st) {
      // Revert if error
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAvatarUrl(String newUrl) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(avatarUrl: newUrl);
    
    // Optimistic update
    state = AsyncValue.data(updated);

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateUserProfile(updated);
    } catch (e, st) {
      // Revert if error
      state = AsyncValue.error(e, st);
    }
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserModel?>(() {
  return ProfileNotifier();
});