import 'package:ai_nexus/core/database/isar_service.dart';
import 'package:ai_nexus/core/network/api_client.dart';
import 'package:ai_nexus/core/network/auth_interceptor.dart';
import 'package:ai_nexus/core/network/dio_client.dart';
import 'package:ai_nexus/core/storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthInterceptor(storage);
});

final dioClientProvider = Provider<DioClient>((ref) {
  final authInterceptor = ref.watch(authInterceptorProvider);
  return DioClient(authInterceptor);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiClient(dioClient);
});

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});
