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
| 1 | Completed | Verify backend API is deployed and accessible — test endpoints with `curl` or Postman | Backend | High | — |
| 2 | Completed | Update `.env` with production backend URL (`API_BASE_URL`) | Mobile | High | 1 |
| 3 | Completed | Implement Firebase Auth & Google Sign-In (`signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `signInWithGoogle`) | Mobile | High | 1 |
| 4 | Completed | Implement `GoogleSignInButton` and update `AuthNotifier` with persistent currentUser session restoration | Mobile | High | 3 |
| 5 | Completed | Test real auth flow: Sign in / Sign up / Google Sign-in → redirect to `/home` → persist session across app cold restart | Mobile | High | 4 |
| 6 | Completed | Create `lib/features/events/repositories/http_event_repository.dart` — real API service calling `GET /events` | Mobile | High | 1 |
| 7 | Completed | Update `lib/core/providers/repository_providers.dart` — swapped mock with `HttpEventRepository` | Mobile | High | 6 |
| 8 | Completed | Test real events flow: home loads events from API, explore searches, event details loads by ID | Mobile | High | 7 |
| 9 | Completed | Implement real bookmark functionality: persistent with `FlutterSecureStorage` locally and bidirectional cloud synchronization with Cloud Firestore (`users/{uid}`) | Mobile | High | 4, 7 |
| 10 | Completed | Update Schedule feature to use real bookmarked events from API and persistent storage | Mobile | High | 9 |
| 11 | Not Started | Implement real profile management: `GET /users/me` (fetch), `PUT /users/me` (update name) | Mobile | High | 4 |
| 12 | In Progress | Update Profile feature: interests directly linked to `userInterestsProvider` & recommendation engine | Mobile | High | 11 |
| 13 | Completed | Implement network error handling: show user-friendly error messages, retry buttons, fallback to cached data if available | Mobile | High | All above |
| 14 | Not Started | Handle token expiry: 401 response → clear token → redirect to `/auth` (verify auth interceptor works) | Mobile | High | 4 |
| 15 | Not Started | Remove all mock data files and mock repository implementations | Mobile | Medium | All above |
| 16 | Not Started | End-to-end test: complete user journey from sign up to browsing events to bookmarking to viewing profile | Mobile | High | All above |

---

## Completed Work

| Date | Log Entry | Files Changed | Impact / Details |
|------|-----------|---------------|------------------|
| 2026-10-24 | Resolved Firebase Gradle build failure (`cannot find symbol: variable customAuthDomain`): aligned Firebase library suite to stable compatible versions (`firebase_core: 4.13.0`, `cloud_firestore: 6.8.0`, `firebase_auth: 6.5.7`) to prevent breaking changes introduced in Kotlin-refactored `firebase_core 4.15+`. Successfully built debug APK (`assembleDebug`) with 0 errors and verified 0 static analysis issues. | [`pubspec.yaml`](../../pubspec.yaml), [`pubspec.lock`](../../pubspec.lock) | Debug APK builds cleanly. All Firebase authentication, cloud Firestore, and cloud messaging services function seamlessly. |
| 2026-10-24 | Successfully deployed TrackIT Backend to Render Cloud (Live 🟢): deployed container service `global-ai-opportunity-tracker-backend` on Render running FastAPI, SQLModel, and SQLite with 273 curated AI opportunities. Verified `/health` (HTTP 200) and `/api/v1/opportunities` (HTTP 200). Updated mobile client configuration in `.env` (`API_BASE_URL=https://global-ai-opportunity-tracker-backend.onrender.com/api/v1`) and `ApiConstants.baseUrl`. Successfully stopped and purged local Docker containers. Resolved all static analysis warnings (clean exit 0). | [`.env`](../../.env), [`lib/core/constants/api_constants.dart`](../../lib/core/constants/api_constants.dart), [`lib/features/events/screens/event_details_screen.dart`](../../lib/features/events/screens/event_details_screen.dart), [`lib/features/profile/screens/profile_screen.dart`](../../lib/features/profile/screens/profile_screen.dart), [`lib/core/storage/secure_storage.dart`](../../lib/core/storage/secure_storage.dart) | Cloud backend is live 24/7 over HTTPS. Mobile app operates completely decoupled from local PC and Docker. |
| 2026-10-24 | Redesigned Splash Screen to modern AI Nexus brand aesthetic & fixed boot bypass: eliminated generic pastel 'AI' circle placeholder in favor of an obsidian/slate dark-canvas AI Nexus Hub Crest emblem with staggered scale, fade, and slide entrance animations; exempted `/splash` from premature GoRouter redirect so the splash screen displays reliably on every app cold start regardless of user sign-in state; modernized `WelcomeScreen` to dynamic user greetings with AI Nexus styling. Verified zero analyzer errors. | [`lib/features/auth/screens/splash_screen.dart`](../../lib/features/auth/screens/splash_screen.dart), [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart), [`lib/features/auth/screens/welcome_screen.dart`](../../lib/features/auth/screens/welcome_screen.dart) | Splash screen now reliably presents on every launch, smoothly routing to /home, /onboarding, or /auth. Clean exit 0 with 0 issues. |
| 2026-10-24 | Fixed Google Sign-In onboarding bypass bug: migrated `SecureStorage` onboarding flag, nickname, role, interests, and event mode to per-user keys (`${key}_${userId}`) so new Google and email accounts are correctly prompted with the 3-step onboarding questionnaire (nickname, AI interests catalog, event mode) instead of jumping directly to `/home` with device defaults; synced in-memory `onboardingProvider` state synchronously prior to setting `AuthState` so `GoRouter` redirect evaluates atomically; added mounted guards and getters/setters adhering strictly to Flutter analysis rules. Verified `flutter analyze` passes with 0 errors and 0 warnings. | [`lib/core/storage/secure_storage.dart`](../../lib/core/storage/secure_storage.dart), [`lib/features/auth/providers/onboarding_provider.dart`](../../lib/features/auth/providers/onboarding_provider.dart), [`lib/features/auth/providers/auth_provider.dart`](../../lib/features/auth/providers/auth_provider.dart), [`lib/features/auth/screens/splash_screen.dart`](../../lib/features/auth/screens/splash_screen.dart) | New Google logins and fresh users are properly routed to the Nickname & Interests questionnaire, saving personalized choices and updating the home feed. Zero analyze errors. |
| 2026-10-24 | Prepared TrackIT Backend API for Render cloud deployment: resolved Poetry lockfile synchronization with `poetry lock`, updated `Dockerfile` to bind dynamically to Render's injected `$PORT` via `CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-8000}"]` with dynamic health check, authored declarative `render.yaml` Blueprint specification, committed the full `api/`, `shared/database`, and pre-seeded 273-opportunity `opportunities.db` database, and pushed commit `f4018c3` to GitHub `origin main`. Increased Flutter app network timeouts to 45 seconds to gracefully handle cloud cold-start spin-ups. | [`Dockerfile`](../../../backend/global-ai-opportunity-tracker-backend/Dockerfile), [`render.yaml`](../../../backend/global-ai-opportunity-tracker-backend/render.yaml), [`lib/core/constants/api_constants.dart`](../../lib/core/constants/api_constants.dart) | Backend repository is fully staged and pushed to GitHub with production Dockerfile and Render Blueprint. Mobile client prepared for cloud endpoints. |
| 2026-10-24 | Implemented Cloud Bookmarks Sync and Offline Mode (Phase 8 gaps): integrated Cloud Firestore (`cloud_firestore`) into `HttpEventRepository` with automatic bidirectional merge between local `FlutterSecureStorage` and cloud doc `users/{uid}`; implemented Isar local cache (`IsarService`) for all opportunities fetched over network with seamless offline fallback in `getEvents()`, `getEventById()`, `searchEvents()`, and `getEventsByFilter()`; added real-time connectivity monitor (`connectivity_plus`) and animated glassmorphic `NetworkStateBanner` in `AppShell` with offline indicator and auto-dismissing 'Back Online' feedback. | [`lib/features/events/repositories/http_event_repository.dart`](../../lib/features/events/repositories/http_event_repository.dart), [`lib/core/database/isar_service_native.dart`](../../lib/core/database/isar_service_native.dart), [`lib/core/database/isar_service_stub.dart`](../../lib/core/database/isar_service_stub.dart), [`lib/core/providers/repository_providers.dart`](../../lib/core/providers/repository_providers.dart), [`lib/core/providers/connectivity_provider.dart`](../../lib/core/providers/connectivity_provider.dart), [`lib/core/widgets/network_state_banner.dart`](../../lib/core/widgets/network_state_banner.dart), [`lib/core/widgets/app_shell.dart`](../../lib/core/widgets/app_shell.dart), [`pubspec.yaml`](../../pubspec.yaml) | Cloud bookmarks sync across devices via Firestore and offline browsing is active with local cache and real-time network state banner. All static analysis passes with 0 issues. |
| 2026-10-24 | Implemented Event Details "WOW" Suite: added PlatformBadge detection (Unstop, Devpost, Devfolio, MLH, Luma, Kaggle, Eventbrite) to header tags and details card; built AiMatchCard and AiMatchScoreCalculator matching user interests and roles with events for personalized match percentages and skill tags; added 1-tap 'Add to Google Calendar' intent with UTC RFC-5545 timestamp generation and URL launcher. Fixed event time display bug where scrapers provided identical start/end times. | [`lib/features/events/widgets/ai_match_card.dart`](../../lib/features/events/widgets/ai_match_card.dart), [`lib/features/events/widgets/platform_badge.dart`](../../lib/features/events/widgets/platform_badge.dart), [`lib/features/events/screens/event_details_screen.dart`](../../lib/features/events/screens/event_details_screen.dart) | Completed AI match scoring, smart platform badges, and 1-tap calendar integration. Clean static analysis with exit code 0. |
| 2026-10-23 | Integrated Google Sign-In and persistent session restoration: added GoogleSignInButton widget with official multi-color vector brand mark and loading states to AuthScreen & SignUpScreen; implemented signInWithGoogle() and dual signout in AuthNotifier; updated build() to automatically restore currentUser on app cold boot without re-prompting; pinned google_sign_in to stable 6.x and verified zero flutter analyze issues. | [`lib/features/auth/providers/auth_provider.dart`](../../lib/features/auth/providers/auth_provider.dart), [`lib/features/auth/widgets/google_sign_in_button.dart`](../../lib/features/auth/widgets/google_sign_in_button.dart), [`lib/features/auth/screens/auth_screen.dart`](../../lib/features/auth/screens/auth_screen.dart), [`lib/features/auth/screens/sign_up_screen.dart`](../../lib/features/auth/screens/sign_up_screen.dart), [`pubspec.yaml`](../../pubspec.yaml) | Full Google authentication & persistent login integrated. All static analysis passes cleanly with 0 errors. |
| 2026-10-18 | Completed 13-point app audit and code fixes against live FastAPI backend: dynamic event counts, removed fake speakers in EventDetailsScreen, removed dead 'Free/Paid' chips, linked Profile interests to userInterestsProvider & Home feed, epoch-sentinel 'Date TBA' handling for dateless events, persistent bookmarks with FlutterSecureStorage, dynamic 'Register' CTA based on isOnline, boolean isOnline filtering for cities/remote, decoupled GPS location watch from full-events refetch, network error card with retry button on Home, disabled 'Coming soon' map button, extracted shared AnimatedFilterChip widget, and added clear-filter action in Home screen. | [`lib/features/home/screens/home_screen.dart`](../../lib/features/home/screens/home_screen.dart), [`lib/features/events/screens/event_details_screen.dart`](../../lib/features/events/screens/event_details_screen.dart), [`lib/features/explore/widgets/explore_filter_chips.dart`](../../lib/features/explore/widgets/explore_filter_chips.dart), [`lib/features/profile/screens/profile_screen.dart`](../../lib/features/profile/screens/profile_screen.dart), [`lib/features/events/models/event_model.dart`](../../lib/features/events/models/event_model.dart), [`lib/features/events/repositories/http_event_repository.dart`](../../lib/features/events/repositories/http_event_repository.dart), [`lib/core/storage/secure_storage.dart`](../../lib/core/storage/secure_storage.dart), [`lib/features/explore/providers/explore_provider.dart`](../../lib/features/explore/providers/explore_provider.dart), [`lib/features/events/providers/events_provider.dart`](../../lib/features/events/providers/events_provider.dart), [`lib/features/explore/widgets/explore_results.dart`](../../lib/features/explore/widgets/explore_results.dart), [`lib/features/explore/widgets/animated_filter_chip.dart`](../../lib/features/explore/widgets/animated_filter_chip.dart) | Replaced all fake/illogical mock data with verified live backend data. All Dart static analysis passed with zero errors. |
| 2026-08-17 | Fixed Flutter SDK corruption, resolved all project Dart warnings, configured Gradle Java 8 suppression, updated EventDetailsScreen dark mode borders, and implemented directional dynamic slide transitions (forward right-to-left, reverse left-to-right) across all GoRouter navigation shell tabs. | [`lib/core/widgets/app_shell.dart`](../../lib/core/widgets/app_shell.dart), [`lib/core/router/app_router.dart`](../../lib/core/router/app_router.dart), [`lib/features/events/screens/event_details_screen.dart`](../../lib/features/events/screens/event_details_screen.dart) | Confirmed app uses `go_router` with `ShellRoute`. Added directional index tracking in `AppShell` with `AnimatedSwitcher` slide & fade transitions (`Offset(0.25, 0)` forward / `Offset(-0.25, 0)` reverse) across Home, Explore, Schedule, and Profile tabs. |
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
- Connected the app to the live backend running on `http://10.0.2.2:8000` (Android emulator) / `http://localhost:8000` via `HttpEventRepository`.
- Completed full 13-point app audit and implemented/verified all 13 fixes across `home_screen.dart`, `explore_results.dart`, `event_details_screen.dart`, `profile_screen.dart`, `http_event_repository.dart`, and `secure_storage.dart`.
- Replaced fake data with real API feeds: dynamic event counts, removed fake speakers, removed dead filter chips, linked profile interests dynamically to home recommendations, epoch-sentinel for TBA dates, persistent local bookmark storage via `FlutterSecureStorage`, decoupled GPS watch from full-events refetch, and added network error recovery state.
- All Dart code passes static analysis with 0 errors and 0 warnings.

### What Remains
- Tasks 3, 4, 5 (Real Auth API integration: `POST /auth/login` and `POST /auth/signup` with JWT storage and session persistence).
- Task 11 (Real Profile fetch/update endpoints on backend).
- Tasks 14, 15, 16 (Token expiry interceptor, removing legacy mock repository files, and end-to-end integration test).

### Suggested Next Steps
1. Implement real auth repository (`auth_api_service.dart` and `auth_repository.dart`) connecting login/signup to the backend auth endpoints.
2. Store the returned JWT token securely using `secure_storage.dart`.
3. Add the remote bookmarks synchronization endpoint (`POST /events/:id/bookmark` or `GET /users/me/bookmarks`) when backend auth is in place.
4. Clean up legacy mock data files after end-to-end testing passes.

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
