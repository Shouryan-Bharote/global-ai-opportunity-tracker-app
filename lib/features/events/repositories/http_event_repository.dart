import 'package:ai_nexus/features/events/models/event_model.dart';
import 'package:ai_nexus/features/events/repositories/event_repository.dart';
import 'package:dio/dio.dart';

class HttpEventRepository implements EventRepository {
  HttpEventRepository(this._dio);

  // Reserved for future API implementation calls.
  // ignore: unused_field
  final Dio _dio;

  @override
  Future<List<EventModel>> getEvents({double? latitude, double? longitude}) async {
    // TODO(backend): Connect to real backend
    // final response = await _dio.get('/events', queryParameters: {
    //   if (latitude != null) 'lat': latitude,
    //   if (longitude != null) 'lng': longitude,
    // });
    // return (response.data as List).map((e) => EventModel.fromJson(e)).toList();
    
    throw UnimplementedError('API endpoints needed');
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    throw UnimplementedError('API endpoints needed');
  }

  @override
  Future<void> toggleBookmark(String eventId) async {
    throw UnimplementedError('API endpoints needed');
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    throw UnimplementedError('API endpoints needed');
  }

  @override
  Future<List<EventModel>> getEventsByFilter({
    String? category,
    String? city,
    bool? isOnline,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) async {
    throw UnimplementedError('API endpoints needed');
  }
}
