import 'package:ai_nexus/core/database/collections/event_collection.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  factory IsarService() {
    return _instance;
  }

  IsarService._internal();
  late final Isar db;

  static final IsarService _instance = IsarService._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = dir.path;
    
    db = await Isar.open(
      [EventEntitySchema],
      directory: dirPath,
    );
  }
}
