import 'package:ai_nexus/core/mock/mock_user.dart';
import 'package:ai_nexus/core/utils/result.dart';
import 'package:ai_nexus/features/auth/models/user_model.dart';

class MockAuthRepository {
  Future<Result<UserModel, Exception>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    if (email == 'test@example.com' && password == 'password') {
      return const Result.success(MockUser.currentUser);
    }
    
    return Result.failure(Exception('Invalid email or password'));
  }

  Future<Result<UserModel, Exception>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return Result.success(MockUser.currentUser.copyWith(name: name, email: email));
  }

  Future<Result<void, Exception>> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Result.success(null);
  }
}
