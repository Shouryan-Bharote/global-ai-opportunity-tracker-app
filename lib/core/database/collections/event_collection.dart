import 'package:isar/isar.dart';

part 'event_collection.g.dart';

@collection
class EventEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String eventId;

  late String title;
  late String description;
  late String host;
  late DateTime startDate;
  late DateTime endDate;
  late String location;
  late bool isOnline;
  late String url;
  String? imageUrl;
  late List<String> tags;
  
  bool isBookmarked = false;
}
