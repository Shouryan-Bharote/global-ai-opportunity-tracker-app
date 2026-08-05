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
      final response = await _dioClient.dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      
      final data = parser != null ? parser(response.data) : response.data as T;
      return Result.success(data);
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }

  // Add post, put, delete similarly as needed
}
