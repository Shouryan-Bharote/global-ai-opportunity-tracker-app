class IsarService {
  factory IsarService() {
    return _instance;
  }

  IsarService._internal();

  static final IsarService _instance = IsarService._internal();

  // Dummy db getter on web since Isar is not initialized
  dynamic get db => null;

  Future<void> init() async {
    // Do nothing on web
  }
}
