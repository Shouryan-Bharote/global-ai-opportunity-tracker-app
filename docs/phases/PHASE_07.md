# Phase 07 — Backend Integration

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 07 |
| **Phase Name** | Backend Integration |
| **Objective** | Replace all mock repositories with real API-backed repositories. Connect authentication, events, bookmarks, and profile to the live backend REST API. Update the `.env` configuration for production-like endpoints. |
| **Scope** | `lib/features/*/data/` (all repositories), `lib/core/network/` (API client updates), `lib/core/providers/providers.dart` (swap mock → real providers), `.env` |
| **Expected Deliverables** | Fully functional app connected to real backend — real auth with JWT, real event data from API, real bookmark CRUD, real profile management, proper error handling for network failures |
| **Dependencies** | Phase 06 (all mobile features complete), Backend API must be deployed and accessible |
| **Assigned Module** | Mobile + Backend (coordination required) |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Verify backend API is deployed and accessible — test endpoints with `curl` or Postman | Backend | High | — |
| 2 | Not Started | Update `.env` with production backend URL (`API_BASE_URL`) | Mobile | High | 1 |
| 3 | Not Started | Create `lib/features/auth/data/auth_api_service.dart` — real API service calling `POST /auth/login` and `POST /auth/signup` | Mobile | High | 1 |
| 4 | Not Started | Update `lib/features/auth/data/auth_repository.dart` — replace mock with real API service, store real JWT token | Mobile | High | 3 |
| 5 | Not Started | Test real auth flow: sign up → receive JWT → store → redirect to home → persist across restart | Mobile | High | 4 |
| 6 | Not Started | Create `lib/features/events/data/events_api_service.dart` — real API service calling `GET /events`, `GET /events/:id`, `GET /events/search?q=` | Mobile | High | 1 |
| 7 | Not Started | Update `lib/features/events/data/events_repository.dart` — replace mock with real API service | Mobile | High | 6 |
| 8 | Not Started | Test real events flow: home loads events from API, explore searches, event details loads by ID | Mobile | High | 7 |
| 9 | Not Started | Implement real bookmark functionality: `POST /events/:id/bookmark` (toggle), `GET /users/me/bookmarks` (list) | Mobile | High | 4, 7 |
| 10 | Not Started | Update Schedule feature to use real bookmarked events from API | Mobile | High | 9 |
| 11 | Not Started | Implement real profile management: `GET /users/me` (fetch), `PUT /users/me` (update name) | Mobile | High | 4 |
| 12 | Not Started | Update Profile feature to use real profile data from API | Mobile | High | 11 |
| 13 | Not Started | Implement network error handling: show user-friendly error messages, retry buttons, fallback to cached data if available | Mobile | High | All above |
| 14 | Not Started | Handle token expiry: 401 response → clear token → redirect to `/auth` (verify auth interceptor works) | Mobile | High | 4 |
| 15 | Not Started | Remove all mock data files and mock repository implementations | Mobile | Medium | All above |
| 16 | Not Started | End-to-end test: complete user journey from sign up to browsing events to bookmarking to viewing profile | Mobile | High | All above |

---

## Completed Work

| 2026-08-17 | Implemented Progressive Loading, Location integration (LocationService + locationProvider), Shimmer Skeleton Loaders, Location Header Badge, and HttpEventRepository skeleton for Home Screen architecture. | [`lib/core/services/location_service.dart`](../../lib/core/services/location_service.dart), [`lib/core/providers/location_provider.dart`](../../lib/core/providers/location_provider.dart), [`lib/core/widgets/skeleton_loader.dart`](../../lib/core/widgets/skeleton_loader.dart), [`lib/features/events/repositories/event_repository.dart`](../../lib/features/events/repositories/event_repository.dart), [`lib/features/events/repositories/mock_event_repository.dart`](../../lib/features/events/repositories/mock_event_repository.dart), [`lib/features/events/repositories/http_event_repository.dart`](../../lib/features/events/repositories/http_event_repository.dart), [`lib/features/events/providers/events_provider.dart`](../../lib/features/events/providers/events_provider.dart), [`lib/features/home/screens/home_screen.dart`](../../lib/features/home/screens/home_screen.dart), [`android/app/src/main/AndroidManifest.xml`](../../android/app/src/main/AndroidManifest.xml) | Integrated geolocator package and Android permissions. Added progressive loading pattern with shimmer skeleton cards instead of blocking splash screen. Added real-time location badge on home screen header. |
| 2026-08-05 | Fixed splash screen freeze issue by adding automatic 2-second navigation timer and scale/fade entrance transition to `/auth` (or `/home` if authenticated). All tests pass 100%. | [`lib/features/auth/screens/splash_screen.dart`](../../lib/features/auth/screens/splash_screen.dart), [`test/widget_test.dart`](../../test/widget_test.dart) | Replaced static StatelessWidget with ConsumerStatefulWidget containing auto-navigation timer and entrance animation. |
| 2026-08-05 | Resolved router redirection bug, missing path_provider dependency, failing widget test, and auto-fixed 88 lint/deprecation issues across 25 files. All unit tests pass cleanly with zero build errors. | [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart), [`pubspec.yaml`](../../pubspec.yaml), [`test/widget_test.dart`](../../test/widget_test.dart), [`lib/core/network/api_client.dart`](../../lib/core/network/api_client.dart), [`lib/features/events/repositories/mock_event_repository.dart`](../../lib/features/events/repositories/mock_event_repository.dart) | Resolved GoRouter redirect bug blocking initial `/splash` route rendering for unauthenticated app boot. Added `path_provider` dependency. Applied `dart fix --apply` across project files and updated `graphify-out` AST index. |
| 2026-07-16 | Refactored Profile feature to match final UI design requirements: interests chip gradients, avatar selector, removed "My Tickets", dynamically calculated stats. | [`lib/features/profile/screens/profile_screen.dart`](../../lib/features/profile/screens/profile_screen.dart), [`lib/features/profile/presentation/widgets/profile_header.dart`](../../lib/features/profile/presentation/widgets/profile_header.dart), [`lib/features/profile/providers/profile_provider.dart`](../../lib/features/profile/providers/profile_provider.dart) | Closed layout feedback loops. Switched mock metrics to active interests count, saved events, and commitment hours. Added bottom sheet to upload custom/preset profile avatar images. |
| 2026-07-16 | Migrated AppHeader to AppShell, simplifying sub-screens and pinning it at the top of the viewport globally. Added native share support and local device image picker. Resolved Windows Kotlin daemon cross-drive compilation lock issue and upgraded compileSdk to version 36. | [`lib/core/widgets/app_shell.dart`](../../lib/core/widgets/app_shell.dart), [`lib/features/home/screens/home_screen.dart`](../../lib/features/home/screens/home_screen.dart), [`lib/features/explore/screens/explore_screen.dart`](../../lib/features/explore/screens/explore_screen.dart), [`lib/features/schedule/screens/schedule_screen.dart`](../../lib/features/schedule/screens/schedule_screen.dart), [`lib/features/profile/screens/profile_screen.dart`](../../lib/features/profile/screens/profile_screen.dart), [`android/gradle.properties`](../../android/gradle.properties), [`android/app/build.gradle.kts`](../../android/app/build.gradle.kts), [`android/build.gradle.kts`](../../android/build.gradle.kts) | Unified AppHeader in shell, reducing layout code duplication and ensuring dynamic updates via riverpod provider. Set kotlin.incremental=false and compileSdk=36 to fix Windows Android builds. |
| 2026-07-16 | Standardized codebase folder structure by removing intermediate presentation folders in profile and events features and sorting imports. | [`lib/features/profile/widgets/profile_header.dart`](../../lib/features/profile/widgets/profile_header.dart), [`lib/features/events/screens/event_details_screen.dart`](../../lib/features/events/screens/event_details_screen.dart), [`lib/features/profile/screens/profile_screen.dart`](../../lib/features/profile/screens/profile_screen.dart), [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart) | Aligned all features to the same simplified structure: models, providers, screens, and widgets folders directly under the feature directory. |
| 2026-07-16 | Replaced vector graphics placeholder in ScheduleEventCard with network image loading, using widget.event.imageUrl or random fallback. | [`lib/features/schedule/widgets/schedule_event_card.dart`](../../lib/features/schedule/widgets/schedule_event_card.dart) | Display active event image cover or placeholder with loader/error indicators. Resolved all remaining lints. |

---

## Current Work

> Nothing is currently being worked on.

---

## Remaining Work

All tasks remain. The **critical path** is:

1. Verify backend API is live (task 1) → update `.env` (task 2)
2. Auth integration (tasks 3–5) → Events integration (tasks 6–8)
3. Bookmark + Profile integration (tasks 9–12)
4. Error handling + token management (tasks 13–14)
5. Cleanup mock code (task 15) → end-to-end test (task 16)

---

## Blockers

| Blocker | Impact | Since | Resolution |
|---------|--------|-------|------------|
| **Backend API not available** | ALL tasks blocked | — | Cannot start until backend is deployed. Coordinate with Member 2. |
| API schema mismatch | Events/auth data fails to parse | — | Compare API response with Freezed models. Adjust models if needed. |

---

## Decisions Made

| Decision | Rationale | Date |
|----------|-----------|------|
| — | — | — |

---

## Notes For Next Agent

> ⚠️ **Read this section before starting work. It contains everything you need to continue without rereading the repository.**

### Context
- This is the **first phase that requires the backend**. Phases 01–06 were fully independent.
- All mock repositories will be replaced with real API-backed implementations.
- The swap should require changing **only the Riverpod provider overrides** in `providers.dart` — no UI code should change.
- Coordinate with Member 2 (backend) to confirm the API is ready and the schema matches.

### What Was Done
- Nothing yet.

### What Remains
- All 16 tasks. The phase is blocked until the backend API is available.

### Suggested Next Steps
1. **Do NOT start this phase** until the backend API is deployed and testable.
2. Verify the API with `curl` — test `/auth/login`, `/events`, `/events/:id` endpoints.
3. Compare the API JSON response structure with the Freezed Event and User models. Adjust if needed.
4. Start with auth integration (the simplest dependency chain).
5. Then events, bookmarks, profile.
6. Add comprehensive error handling.
7. Remove all mock code.
8. Run full end-to-end test.

### Warnings
- **API schema mismatch is the most common issue in this phase.** Before writing any code, print/log the actual API response and compare field names with your Freezed models (snake_case vs camelCase, missing fields, type differences).
- Dio's `AuthInterceptor` must handle 401 gracefully — check if the token exists before redirecting, otherwise infinite redirects may occur.
- If the backend is slow or unreliable during testing, keep mock providers available as a fallback to continue UI development.
- Do NOT delete mock files until integration is fully verified (task 15 is intentionally late).

### Assumptions
- The backend uses snake_case for JSON fields. The `json_serializable` `FieldRename` annotation should handle the conversion to Dart's camelCase.
- The backend returns errors in a consistent format (e.g., `{ "error": "message" }`).
- JWT tokens have an expiration time. The auth interceptor handles 401 by clearing the token and redirecting.
- Pagination is cursor or page-based. Check with Member 2 for the exact approach.

### Repository Pattern — Already Set Up (Read This First!)

> **CRITICAL**: The repository pattern has already been fully implemented during Phase 5.
> The frontend is 100% decoupled from any data source. **You do NOT need to refactor any UI code.**
> You only need to create real repository implementations and change ONE provider.

#### Architecture Diagram

```
UI Screens (Home, Explore, Schedule)
    │  watch
    ▼
Feature Providers (home_provider, explore_provider)
    │  derive from
    ▼
eventsProvider (AsyncNotifier)  ← Single source of truth
    │  calls
    ▼
EventRepository (abstract interface)  ← THE SWAP POINT
    │
    ├── MockEventRepository  ← Current (mock data)
    └── HttpEventRepository  ← What you will create
```

#### The Interface You Must Implement

File: `lib/features/events/repositories/event_repository.dart`

```dart
abstract class EventRepository {
  Future<List<EventModel>> getEvents();
  Future<EventModel?> getEventById(String id);
  Future<void> toggleBookmark(String eventId);
  Future<List<EventModel>> searchEvents(String query);
  Future<List<EventModel>> getEventsByFilter({
    String? category,
    String? city,
    bool? isOnline,
    List<String>? tags,
  });
}
```

#### Step-by-Step Integration

**Step 1**: Create `lib/features/events/repositories/http_event_repository.dart`:
```dart
class HttpEventRepository implements EventRepository {
  final Dio _dio;
  HttpEventRepository(this._dio);

  @override
  Future<List<EventModel>> getEvents() async {
    final response = await _dio.get('/events');
    return (response.data as List)
        .map((j) => EventModel.fromJson(j))
        .toList();
  }
  // ... implement all other methods mapping to API endpoints
}
```

**Step 2**: Change ONE line in `lib/core/providers/repository_providers.dart`:
```diff
- return MockEventRepository();
+ return HttpEventRepository(ref.read(dioProvider));
```

**That's it.** No UI files, no provider files, no widget files need to change.

#### Key Files Reference

| File | Purpose |
|------|---------|
| `lib/features/events/repositories/event_repository.dart` | Abstract interface (contract) |
| `lib/features/events/repositories/mock_event_repository.dart` | Current mock implementation (reference for behavior) |
| `lib/core/providers/repository_providers.dart` | **THE ONE FILE TO CHANGE** when swapping |
| `lib/features/events/providers/events_provider.dart` | Global AsyncNotifier — DO NOT MODIFY |
| `lib/features/events/models/event_model.dart` | Freezed model with `fromJson`/`toJson` — may need updates if API schema differs |

#### What the UI Already Handles

- ✅ Loading states (CircularProgressIndicator while data loads)
- ✅ Error states (error messages displayed)
- ✅ Optimistic bookmark updates (instant UI response, reverts on failure)
- ✅ Single source of truth (bookmark on any page syncs everywhere)

#### Warnings

- Check if the API returns `snake_case` keys — the `EventModel.fromJson` currently expects `camelCase`. You may need to add `@JsonKey(name: 'start_date')` annotations or configure a `FieldRename`.
- The mock repository simulates delays (800ms). Remove `Future.delayed` in the real one — the network itself provides the delay.
- Keep `MockEventRepository` available as a fallback during testing. Only delete it in task 15.

### Useful Context
- See [`PROJECT_OVERVIEW.md`](../PROJECT_OVERVIEW.md) for the expected API contract and Event model schema.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) for the error handling strategy and auth flow diagram.
- See [`DEVELOPMENT_WORKFLOW.md`](../DEVELOPMENT_WORKFLOW.md) for the mock-to-real provider swap pattern.
