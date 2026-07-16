import 'package:ai_nexus/core/mock/mock_user.dart';
import 'package:ai_nexus/features/auth/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(UserModel user);
}

class MockProfileRepository implements ProfileRepository {
  UserModel _user = MockUser.currentUser;

  @override
  Future<UserModel> getUserProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _user;
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _user = user;
  }
}