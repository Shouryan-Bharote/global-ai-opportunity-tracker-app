import 'package:ai_nexus/core/network/dio_client.dart';
import 'package:ai_nexus/core/utils/result.dart';

class ApiClient {

  ApiClient(this._dioClient);
  final DioClient _dioClient;

  Future<Result<T, Exception>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        path,
        queryParameters: queryParameters,
      );
      
      final data = parser != null ? parser(response.data) : response.data as T;
      return Result.success(data);
    } catch (e) {
      return Result.failure(Exception(e.toString()));
    }
  }

  // Add post, put, delete similarly as needed
}
