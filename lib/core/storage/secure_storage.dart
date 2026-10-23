import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage();
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _bookmarksKey = 'user_bookmarks';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _userNicknameKey = 'user_nickname';
  static const String _userRoleKey = 'user_role';
  static const String _userInterestsKey = 'user_interests';
  static const String _eventModeKey = 'user_event_mode';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveBookmarks(Set<String> bookmarkIds) async {
    await _storage.write(key: _bookmarksKey, value: jsonEncode(bookmarkIds.toList()));
  }

  Future<Set<String>> getBookmarks() async {
    final raw = await _storage.read(key: _bookmarksKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } on Exception catch (_) {
      return {};
    }
  }

  // Onboarding & Preferences
  Future<void> setOnboardingComplete({String? userId, bool complete = true}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_onboardingCompleteKey}_$userId'
        : _onboardingCompleteKey;
    await _storage.write(key: key, value: complete ? 'true' : 'false');
  }

  Future<bool> isOnboardingComplete({String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      final userVal = await _storage.read(key: '${_onboardingCompleteKey}_$userId');
      if (userVal != null) {
        return userVal == 'true';
      }
      return false;
    }
    final val = await _storage.read(key: _onboardingCompleteKey);
    return val == 'true';
  }

  Future<void> saveUserInterests(List<String> interests, {String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_userInterestsKey}_$userId'
        : _userInterestsKey;
    await _storage.write(key: key, value: jsonEncode(interests));
  }

  Future<List<String>?> getUserInterests({String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_userInterestsKey}_$userId'
        : _userInterestsKey;
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } on Exception catch (_) {
      return null;
    }
  }

  Future<void> saveUserNickname(String nickname, {String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_userNicknameKey}_$userId'
        : _userNicknameKey;
    await _storage.write(key: key, value: nickname);
  }

  Future<String?> getUserNickname({String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_userNicknameKey}_$userId'
        : _userNicknameKey;
    return _storage.read(key: key);
  }

  Future<void> saveUserRole(String role, {String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_userRoleKey}_$userId'
        : _userRoleKey;
    await _storage.write(key: key, value: role);
  }

  Future<String?> getUserRole({String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_userRoleKey}_$userId'
        : _userRoleKey;
    return _storage.read(key: key);
  }

  Future<void> saveUserEventMode(String mode, {String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_eventModeKey}_$userId'
        : _eventModeKey;
    await _storage.write(key: key, value: mode);
  }

  Future<String?> getUserEventMode({String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? '${_eventModeKey}_$userId'
        : _eventModeKey;
    return _storage.read(key: key);
  }
}
