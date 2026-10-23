import 'dart:async';

import 'package:ai_nexus/core/constants/ai_interest_catalog.dart';
import 'package:ai_nexus/core/storage/secure_storage.dart';
import 'package:ai_nexus/features/auth/providers/auth_provider.dart';
import 'package:ai_nexus/features/profile/providers/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// StateNotifier for onboarding completion status
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._storage) : super(false) {
    unawaited(_init());
  }

  final SecureStorage _storage;

  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      final completed = await _storage.isOnboardingComplete(userId: uid);
      state = completed;
    } else {
      state = false;
    }
  }

  bool get onboarded => state;
  set onboarded(bool value) => state = value;

  Future<void> completeOnboarding({
    required String nickname,
    required String role,
    required List<String> interests,
    required String eventMode,
    required WidgetRef? ref,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await _storage.saveUserNickname(nickname.trim(), userId: uid);
    await _storage.saveUserRole(role, userId: uid);
    await _storage.saveUserInterests(interests, userId: uid);
    await _storage.saveUserEventMode(eventMode, userId: uid);
    await _storage.setOnboardingComplete(userId: uid);

    state = true;

    // Update Riverpod states
    if (ref != null) {
      await ref.read(userInterestsNotifierProvider.notifier).setInterests(interests);
      ref.read(userRoleProvider.notifier).state = role;
      ref.read(userEventModeProvider.notifier).state = eventMode;

      // Update Firebase display name if logged in
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        final currentProfile = await profileRepo.getUserProfile();
        if (currentProfile != null) {
          final updated = currentProfile.copyWith(name: nickname.trim());
          await profileRepo.updateUserProfile(updated);
          ref
            ..invalidate(profileProvider)
            ..invalidate(authProvider);
        }
      } on Exception catch (_) {
        // Fallback gracefully
      }
    }
  }

  Future<void> resetOnboarding({String? userId}) async {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    await _storage.setOnboardingComplete(userId: uid, complete: false);
    state = false;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return OnboardingNotifier(storage);
});

// User interests notifier with persistence
class UserInterestsNotifier extends StateNotifier<List<String>> {
  UserInterestsNotifier(this._storage) : super(AiInterestCatalog.defaultSelectedNames) {
    unawaited(_init());
  }

  final SecureStorage _storage;

  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final saved = await _storage.getUserInterests(userId: uid);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> toggleInterest(String interestName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final current = List<String>.from(state);
    final index = current.indexWhere(
      (i) => i.toLowerCase() == interestName.toLowerCase(),
    );
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(interestName);
    }
    state = current;
    await _storage.saveUserInterests(current, userId: uid);
  }

  Future<void> setInterests(List<String> interests) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    state = List<String>.from(interests);
    await _storage.saveUserInterests(interests, userId: uid);
  }
}

final userInterestsNotifierProvider =
    StateNotifierProvider<UserInterestsNotifier, List<String>>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return UserInterestsNotifier(storage);
});

final userRoleProvider = StateProvider<String>((ref) => 'AI Developer');
final userEventModeProvider = StateProvider<String>((ref) => 'All');
