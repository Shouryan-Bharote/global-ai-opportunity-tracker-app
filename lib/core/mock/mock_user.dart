import 'package:ai_nexus/features/auth/models/user_model.dart';

class MockUser {
  static const UserModel currentUser = UserModel(
    id: 'user_123',
    email: 'test@example.com',
    name: 'Jane Doe',
    avatarUrl: 'https://i.pravatar.cc/150?u=jane',
  );
}
