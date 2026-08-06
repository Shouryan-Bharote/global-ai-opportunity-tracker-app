import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global dark mode state shared across all screens.
final isDarkModeProvider = StateProvider<bool>((ref) => false);
