# Development Workflow & AI Agent Guide

> How to build, test, and iterate on the Flutter mobile module. Optimized for both developers and AI coding agents.

## Frontend Development Phases

```mermaid
gantt
    title Flutter Mobile Development Phases
    dateFormat  YYYY-MM-DD
    axisFormat  %b %d

    section Phase 1 - Research
    Flutter, Riverpod, GoRouter research
    Design System (Theme, Colors, Typography)

    section Phase 2 - Core Infra
    Dio client, Riverpod setup
    GoRouter, Isar DB, Secure Storage
    Mock data layer

    section Phase 3 - Auth
    Auth screen (Sign In / Sign Up)
    Mock authentication flow

    section Phase 4 - Navigation
    AppShell + Bottom Nav
    All screens with dummy data

    section Phase 5 - Features
    Explore (Search, Filters)
    Schedule (Calendar, Bookmarks)
    Profile (User info, Settings)

    section Phase 6 - Event Details
    Reusable Event Details screen
    Bookmark, Share, Register actions

    section Phase 7 - Integration
    Replace mock with real API
    Connect all data flows

    section Phase 8 - Offline
    Isar cache for events
    Offline reading mode

    section Phase 9 - Notifications
    FCM setup
    Notification screen + badges

    section Phase 10 - Polish
    Dark mode, Animations
    Performance, Accessibility, Testing
```

### Phase Details

| Phase | Focus | Deliverable | Backend Needed? |
|-------|-------|------------|:---:|
| **1 — Research** | Flutter, Riverpod, GoRouter study; Design system | Theme, Colors, Typography files | ❌ |
| **2 — Core Infra** | Dio, Riverpod, GoRouter, Isar, SecureStorage | `core/` infrastructure complete | ❌ |
| **3 — Auth** | Sign In/Sign Up screens, mock auth flow | Working auth UI with mock | ❌ |
| **4 — Navigation Shell** | AppShell, bottom nav, all screens with dummy data | Navigable app skeleton | ❌ |
| **5 — Feature Dev** | Explore, Schedule, Profile features independently | Each feature testable | ❌ |
| **6 — Event Details** | Reusable event details screen (from Home, Explore, Schedule) | Shared screen complete | ❌ |
| **7 — Backend Integration** | Replace mock data with real API calls (Dio → backend) | Fully functional app | ✅ |
| **8 — Offline Mode** | Isar caching for events, offline reading | Works without network | ✅ |
| **9 — Notifications** | FCM integration, notification screen, badges | Push notifications working | ✅ |
| **10 — Polish** | Dark mode, animations, performance, accessibility, tests | Production-ready | ✅ |

> **Key Insight**: Phases 1–6 are **fully independent** of the backend. You can build the entire UI with mock data.

---

## Mock Data Strategy (Phases 1–6)

During phases before backend integration, use **static mock data** so the entire UI is functional and testable.

```dart
// lib/core/mock/mock_events.dart

final mockEvents = [
  Event(
    id: '1',
    title: 'AI Hackathon 2025',
    description: 'Build innovative AI solutions...',
    platform: 'unstop',
    platformUrl: 'https://unstop.com/...',
    bannerUrl: null,
    mode: EventMode.online,
    startDate: DateTime(2025, 3, 15),
    endDate: DateTime(2025, 3, 17),
    registrationDeadline: DateTime(2025, 3, 10),
    prize: '₹50,000',
    teamSize: '2-4',
    tags: ['AI', 'Hackathon', 'ML'],
    status: EventStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  // ... more mock events
];
```

```dart
// Mock repository that returns mock data instead of calling Dio
class MockEventsRepository implements EventsRepository {
  @override
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return mockEvents;
  }
}
```

Switch from mock to real repository by changing the Riverpod provider — **no UI code changes needed**:

```dart
// During Phase 1-6
@Riverpod(keepAlive: true)
EventsRepository eventsRepository(EventsRepositoryRef ref) {
  return MockEventsRepository();
}

// During Phase 7+ (swap this single line)
@Riverpod(keepAlive: true)
EventsRepository eventsRepository(EventsRepositoryRef ref) {
  return ApiEventsRepository(ref.read(eventsApiServiceProvider), ref.read(isarProvider));
}
```

---

## Development Setup

### Prerequisites

- **Flutter SDK**: ≥ 3.12.2
- **Dart SDK**: ≥ 3.12.2
- **IDE**: VS Code + Flutter extension (recommended) or Android Studio
- **Code generator**: `build_runner` (for Freezed, json_serializable, Riverpod code gen)

### Initial Setup

```bash
# 1. Clone and navigate to project
cd "D:/Major Project/ai_event"

# 2. Install dependencies
flutter pub get

# 3. (One-time) Generate code for Freezed/Riverpod models
dart run build_runner build --delete-conflicting-outputs

# 4. Create .env file (copy from .env.example)
cp .env.example .env

# 5. Run the app
flutter run
```

### Commands Reference

| Command | When to Use |
|---------|------------|
| `flutter pub get` | After changing `pubspec.yaml` |
| `dart run build_runner build --delete-conflicting-outputs` | After adding/modifying Freezed models or Riverpod providers |
| `dart run build_runner watch` | During active model development (auto-regenerates on save) |
| `flutter run` | Run on connected device/emulator |
| `flutter run -d chrome` | Run on web (for quick testing) |
| `flutter test` | Run all unit and widget tests |
| `flutter analyze` | Run static analysis (lints) |
| `dart format .` | Format all Dart files |

---

## AI Agent Guidelines

### How to Work Effectively with AI Agents

This project is designed to be **AI-agent-friendly**. Follow these rules:

#### 1. Point to a Single Feature

When assigning work to an AI agent, specify the **feature folder** and the **feature spec** from [FEATURES_AND_FLOWS.md](FEATURES_AND_FLOWS.md):

> "Implement the Explore feature in `lib/features/explore/`. Follow the spec in FEATURES_AND_FLOWS.md section 4."

The agent can then work in that folder without needing the entire codebase context.

#### 2. Provide Context Files

When starting a new agent session, load these files:

```
docs/PROJECT_OVERVIEW.md      # What the project is
docs/ARCHITECTURE.md           # How it's built
docs/CODEBASE_GUIDE.md         # How to organize code
docs/FEATURES_AND_FLOWS.md    # What to build
```

This gives the agent everything it needs to write consistent, architecture-aligned code.

#### 3. Follow Feature Isolation

```mermaid
graph TD
    Agent[AI Agent] -->|reads| Docs[docs/*.md]
    Agent -->|reads| Feature[features/<feature>/*]
    Agent -->|reads| Core[core/widgets/*, core/theme/*]
    Agent -->|writes| Feature

    Agent -.->|should not touch| OtherFeatures[features/other_*/
    Agent -.->|should not touch| Generated[gen/*]
```

**Rules for agents:**
- ✅ Read and modify files within the assigned feature folder.
- ✅ Use shared widgets from `core/widgets/`.
- ✅ Follow patterns from `CODEBASE_GUIDE.md`.
- ✅ Use Freezed models from `features/*/models/`.
- ❌ Never edit other feature folders unless explicitly asked.
- ❌ Never manually edit files in `gen/` (auto-generated).
- ❌ Never modify `core/router/` or `main.dart` without understanding the full navigation tree.

#### 4. Testing Convention

```dart
// test/features/explore/providers/search_provider_test.dart

void main() {
  late MockEventsRepository mockRepo;

  setUp(() {
    mockRepo = MockEventsRepository();
  });

  group('searchProvider', () {
    test('returns filtered events when search query matches', () async {
      // Arrange
      when(mockRepo.searchEvents('hackathon')).thenAnswer(
        (_) async => [mockHackathonEvent],
      );

      // Act
      final container = ProviderContainer(
        overrides: [eventsRepositoryProvider.overrideWithValue(mockRepo)],
      );
      final result = await container.read(searchProvider('hackathon').future);

      // Assert
      expect(result.length, 1);
      expect(result.first.title, contains('Hackathon'));
    });
  });
}
```

---

## Feature Specification Template

When starting a new feature, create a brief spec document:

```markdown
# Feature: <Feature Name>

## Purpose
<One-sentence description of why this feature exists>

## User Flow
1. User does X
2. System responds with Y
3. User can then Z

## UI States
| State | What to Display |
|-------|----------------|
| Loading | ... |
| Empty | ... |
| Error | ... |
| Success | ... |

## API Endpoints
| Method | Endpoint | Used For |
|--------|----------|----------|
| GET | /... | ... |

## Data Models
<List relevant Freezed models>

## Acceptance Criteria
- [ ] Feature works offline with cached data
- [ ] Loading state shows skeleton/spinner
- [ ] Error state shows retry button
- [ ] Back navigation works correctly
```

This spec is enough for an AI agent to implement the feature independently.

---

## Checklist: Phase Completion

### Phase 1 — Research ✅

- [x] Flutter project created and running
- [x] Design system defined (`core/theme/`)
- [x] Color palette established (light + dark)
- [x] Typography scale defined
- [x] Spacing and radius constants set

### Phase 2 — Core Infrastructure ✅

- [x] Dio client configured with interceptors
- [x] Riverpod setup with `ProviderContainer`
- [x] GoRouter configured with auth redirect
- [x] Isar database initialized
- [x] `SecureStorage` wrapper ready
- [x] Mock data layer in place
- [x] `Result` type for error handling

### Phase 3 — Authentication ✅

- [x] Sign In screen with form validation
- [x] Sign Up screen with form validation
- [x] Mock auth provider (stores token locally)
- [x] Auth state persists across app restarts
- [x] Token stored in SecureStorage
- [x] Redirect to `/auth` when not authenticated

### Phase 4 — Navigation Shell ✅

- [x] AppShell with bottom navigation
- [x] All 4 tab routes working
- [x] Placeholder screens for all tabs
- [x] Navigation state preserved on tab switch
- [x] Event details route accessible from all tabs

### Phase 5 — Feature Development ⏳

- [x] Explore: search + filters working with mock data
- [x] Schedule: calendar view + bookmarked events
- [ ] Profile: user info display + menu items
- [ ] Each feature independently testable

### Phase 6 — Event Details ✅

- [x] Reusable event details screen
- [x] Bookmark toggle functional
- [x] Share action works
- [x] Registration link opens in browser
- [x] Accessible from all entry points

### Phase 7 — Backend Integration 🔲

- [ ] All mock repositories replaced with API versions
- [ ] Auth uses real JWT from backend
- [ ] Events fetched from real API
- [ ] Bookmarks synced with backend
- [ ] Error handling for network failures

### Phase 8 — Offline Mode 🔲

- [ ] Events cached in Isar after fetch
- [ ] Offline banner shown when disconnected
- [ ] Cached data displayed when offline
- [ ] Bookmarks queued for sync

### Phase 9 — Notifications 🔲

- [ ] FCM device token registered on login
- [ ] Push notifications received in foreground
- [ ] Notification screen displays history
- [ ] Tap notification → event details
- [ ] Unread badge count on bell icon

### Phase 10 — Polish 🔲

- [ ] Dark mode fully implemented
- [ ] Page transition animations
- [ ] Pull-to-refresh on all lists
- [ ] Shimmer loading states
- [ ] Accessibility labels on interactive elements
- [ ] Unit tests for repositories
- [ ] Widget tests for key screens
- [ ] Performance profiling done

---

## Quick Reference: Key Files to Read First

When an AI agent starts a new session, read these files in order:

| Priority | File | Why |
|----------|------|-----|
| 1 | `docs/PROJECT_OVERVIEW.md` | Understand the project |
| 2 | `docs/ARCHITECTURE.md` | Understand the architecture |
| 3 | `docs/CODEBASE_GUIDE.md` | Know where to put code |
| 4 | `docs/FEATURES_AND_FLOWS.md` | Know what to build |
| 5 | `pubspec.yaml` | See current dependencies |
| 6 | `lib/core/theme/app_theme.dart` | Understand the design system |
| 7 | `lib/core/router/app_router.dart` | Understand navigation |
| 8 | `lib/core/widgets/` | Reusable components available |
