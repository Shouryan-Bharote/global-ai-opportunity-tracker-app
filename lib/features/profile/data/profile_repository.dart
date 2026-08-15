import 'package:ai_nexus/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileRepository {
  Future<UserModel?> getUserProfile();

  Future<UserModel?> updateUserProfile(UserModel user);
}

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserModel?> getUserProfile() async {
    final firebaseUser = _auth.currentUser;

    // No user is logged in
    if (firebaseUser == null) {
      return null;
    }

    // Use Firebase display name if available.
    // Otherwise use the first part of the email.
    final email = firebaseUser.email ?? '';

    final name =
        firebaseUser.displayName != null &&
            firebaseUser.displayName!.trim().isNotEmpty
        ? firebaseUser.displayName!.trim()
        : _nameFromEmail(email);

    return UserModel(
      id: firebaseUser.uid,
      email: email,
      name: name,
      avatarUrl: firebaseUser.photoURL,
    );
  }

  @override
  Future<UserModel?> updateUserProfile(UserModel user) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    // Update Firebase display name
    await firebaseUser.updateDisplayName(user.name);

    // Update profile photo if provided
    if (user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty) {
      await firebaseUser.updatePhotoURL(user.avatarUrl!.trim());
    } else {
      await firebaseUser.updatePhotoURL(null);
    }

    // Reload Firebase user so the latest data is available
    await firebaseUser.reload();

    final updatedFirebaseUser = _auth.currentUser;

    if (updatedFirebaseUser == null) {
      return null;
    }

    final email = updatedFirebaseUser.email ?? '';

    final name =
        updatedFirebaseUser.displayName != null &&
            updatedFirebaseUser.displayName!.trim().isNotEmpty
        ? updatedFirebaseUser.displayName!.trim()
        : _nameFromEmail(email);

    return UserModel(
      id: updatedFirebaseUser.uid,
      email: email,
      name: name,
      avatarUrl: updatedFirebaseUser.photoURL,
    );
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) {
      return 'User';
    }

    final username = email.split('@').first;

    if (username.isEmpty) {
      return 'User';
    }

    // Convert something like:
    // janhavi.palmate -> Janhavi Palmate
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
