# Codebase Guide — Flutter Mobile Module

> Directory structure, coding conventions, and file organization for AI Event Tracker.

## Directory Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp + GoRouter setup
│
├── core/                              # Shared infrastructure (used by all features)
│   ├── constants/
│   │   ├── api_constants.dart        # API endpoints, pagination defaults
│   │   └── app_constants.dart        # App-wide constants (app name, etc.)
│   │
│   ├── config/
│   │   └── env_config.dart           # Reads .env via flutter_dotenv
│   │
│   ├── database/
│   │   ├── isar_service.dart         # Isar initialization & singleton
│   │   └── collections/              # Isar collection definitions
│   │       └── event_collection.dart
│   │
│   ├── extensions/                   # Dart extensions
│   │   ├── string_extensions.dart
│   │   ├── date_extensions.dart
│   │   └── build_context_extensions.dart
│   │
│   ├── network/
│   │   ├── dio_client.dart            # Configured Dio instance
│   │   ├── auth_interceptor.dart      # Attaches JWT to requests
│   │   └── api_client.dart            # Base API client with error handling
│   │
│   ├── router/
│   │   └── app_router.dart            # GoRouter configuration
│   │
│   ├── storage/
│   │   └── secure_storage.dart       # flutter_secure_storage wrapper
│   │
│   ├── theme/
│   │   ├── app_theme.dart            # Light + Dark ThemeData
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_typography.dart       # Text styles
│   │   ├── app_spacing.dart          # Padding/margin constants
│   │   └── app_radius.dart           # Border radius constants
│   │
│   ├── utils/
│   │   ├── result.dart               # Result<T, E> type (success/failure)
│   │   ├── validators.dart           # Form validation helpers
│   │   └── date_formatter.dart       # Date formatting utilities
│   │
│   └── widgets/                      # Shared/reusable widgets
│       ├── app_shell.dart            # Bottom navigation shell
│       ├── event_card.dart           # Event list item card
│       ├── loading_indicator.dart    # Consistent loading spinner
│       ├── error_view.dart           # Reusable error/empty state
│       ├── offline_banner.dart       # "You're offline" banner
│       └── custom_app_bar.dart       # Styled app bar
│
├── features/                          # Feature modules (one folder per feature)
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_api_service.dart
│   │   ├── models/
│   │   │   └── user_model.dart       # Freezed + json_serializable
│   │   ├── providers/
│   │   │   └── auth_provider.dart     # Riverpod auth state
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── auth_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets/
│   │           ├── auth_form.dart
│   │           └── social_login_button.dart
│   │
│   ├── events/
│   │   ├── data/
│   │   │   ├── events_repository.dart
│   │   │   └── events_api_service.dart
│   │   ├── models/
│   │   │   └── event_model.dart       # Freezed model
│   │   ├── providers/
│   │   │   ├── events_provider.dart
│   │   │   └── event_detail_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── event_details_screen.dart   # Reusable across features
│   │       └── widgets/
│   │           ├── event_info_tile.dart
│   │           └── bookmark_button.dart
│   │
│   ├── home/
│   │   ├── providers/
│   │   │   └── home_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   │           └── trending_events_carousel.dart
│   │
│   ├── explore/
│   │   ├── data/
│   │   │   └── explore_repository.dart
│   │   ├── models/
│   │   │   └── search_filter_model.dart
│   │   ├── providers/
│   │   │   ├── search_provider.dart
│   │   │   └── filter_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── explore_screen.dart
│   │       └── widgets/
│   │           ├── search_bar.dart
│   │           └── filter_chip_group.dart
│   │
│   ├── schedule/
│   │   ├── data/
│   │   │   └── schedule_repository.dart
│   │   ├── providers/
│   │   │   └── schedule_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── schedule_screen.dart
│   │       └── widgets/
│   │           └── calendar_widget.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart
│   │   ├── providers/
│   │   │   └── profile_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── profile_screen.dart
│   │       └── widgets/
│   │           └── profile_header.dart
│   │
│   ├── settings/
│   │   ├── providers/
│   │   │   └── settings_provider.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           └── settings_tile.dart
│   │
│   └── notifications/
│       ├── data/
│       │   └── notification_service.dart  # FCM + local notifications
│       ├── models/
│       │   └── notification_model.dart
│       ├── providers/
│       │   └── notification_provider.dart
│       └── presentation/
│           ├── screens/
│           │   └── notifications_screen.dart
│           └── widgets/
│               └── notification_tile.dart
│
└── gen/                              # Auto-generated (Freezed, json_serializable, Riverpod)
    └── .gitkeep                      # Do not manually edit files in gen/

test/
├── features/                         # Mirror lib/features/ structure
│   ├── auth/
│   ├── events/
│   └── ...
├── core/
│   └── ...
└── helpers/
    └── test_helpers.dart             # Mock providers, fakes
```

---

## Feature Module Internal Structure

Every feature follows this **identical pattern**:

```
features/<feature_name>/
├── data/                  # Repository + API service
│   ├── <name>_repository.dart
│   └── <name>_api_service.dart
├── models/                # Freezed data classes
│   └── <name>_model.dart
├── providers/             # Riverpod providers
│   └── <name>_provider.dart
└── presentation/          # UI layer
    ├── screens/
    │   └── <name>_screen.dart
    └── widgets/
        └── <specific_widget>.dart
```

**Exceptions**: Some features may not need all four folders. For example:
- `settings/` has no `data/` or `models/` (only local preferences).
- `home/` has no `models/` (reuses `events/models/`).

---

## File Naming Conventions

| Pattern | Example | Notes |
|---------|---------|-------|
| `snake_case.dart` | `auth_provider.dart` | All files |
| `feature_entity.dart` | `events_repository.dart` | Feature-prefixed when ambiguous |
| Screen files end with `_screen.dart` | `home_screen.dart` | All screens |
| Widget files end with `_widget.dart` or descriptive noun | `event_card.dart` | Reusable widgets |
| Provider files end with `_provider.dart` | `auth_provider.dart` | All providers |
| Model files end with `_model.dart` | `event_model.dart` | Freezed models |
| Repository files end with `_repository.dart` | `events_repository.dart` | All repositories |

---

## Dart Coding Conventions

### Imports Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages (alphabetical)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. App core
import 'package:ai_event/core/constants/api_constants.dart';
import 'package:ai_event/core/theme/app_colors.dart';

// 5. App features (specific)
import 'package:ai_event/features/events/models/event_model.dart';

// 6. Relative imports
import '../../data/events_repository.dart';
```

### Class Naming

| Type | Convention | Example |
|------|-----------|---------|
| Widgets (screens) | PascalCase + `Screen` | `HomeScreen` |
| Widgets (components) | PascalCase | `EventCard`, `SearchBar` |
| Providers | PascalCase + `Notifier`/`Provider` | `AuthNotifier`, `eventsProvider` |
| Repositories | PascalCase + `Repository` | `EventsRepository` |
| Models | PascalCase | `Event`, `User` (Freezed) |
| Extensions | PascalCase + `Extension` | `DateExtension` |

### Code Style Rules

```dart
// ✅ Use Riverpod's ConsumerWidget / ConsumerStatefulWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    // ...
  }
}

// ✅ Use const constructors wherever possible
const EventCard(event: event)

// ✅ Extract complex widgets into separate files (>150 lines = split)
// ✅ Use flutter_hooks for stateful logic inside widgets
// ✅ Wrap async operations in try-catch at the repository layer
// ✅ Use the Result type from core/utils/ for error propagation
```

### Freezed Models

```dart
// lib/features/events/models/event_model.dart

@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String description,
    required String platform,
    required String platformUrl,
    String? bannerUrl,
    required EventMode mode,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? registrationDeadline,
    String? prize,
    String? teamSize,
    @Default([]) List<String> tags,
    required EventStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

enum EventMode { online, offline, hybrid }
enum EventStatus { active, completed, registrationClosed }
```

> Run `dart run build_runner build --delete-conflicting-outputs` after modifying models.

---

## Linting & Analysis

Use **very_good_analysis** (recommended) for strict, consistent code quality:

```yaml
# analysis_options.yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  errors:
    public_member_api_docs: ignore  # Relax doc requirement for speed
```

### Must-Follow Rules

| Rule | Why |
|------|-----|
| All public members documented | Maintainability |
| No `print()` statements | Use `logger` package instead |
| No hardcoded strings | Use constants or localization keys |
| No magic numbers | Extract to named constants |
| Max 200 lines per file | Split when larger |
| Max 50 lines per function | Extract sub-functions |

---

## Environment Configuration

```bash
# .env (never committed to git)
API_BASE_URL=http://localhost:3000/api
FCM_SERVER_KEY=your_key
```

```yaml
# .gitignore
.env
.env.*
```

```dart
// core/config/env_config.dart
class Env {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;
  // ...
}
```

---

## Git Workflow

```
main          ───────────────────────────── stable
  └─ feature/auth          ── merged after review
  └─ feature/home          ── merged after review
  └─ feature/explore       ── merged after review
```

### Branch Naming

| Pattern | Example |
|---------|---------|
| `feature/<name>` | `feature/schedule-screen` |
| `fix/<name>` | `fix/bookmark-sync-error` |
| `chore/<name>` | `chore/update-dependencies` |

### Commit Messages (Conventional Commits)

```
feat(events): add search with debounced input
fix(auth): handle token refresh on 401
refactor(home): extract carousel into separate widget
chore: add flutter_hooks dependency
test(events): add repository unit tests
```
