# Phase 02 — Core Infrastructure

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 02 |
| **Phase Name** | Core Infrastructure |
| **Objective** | Set up the complete core infrastructure — Dio HTTP client, Riverpod provider container, GoRouter with auth redirect, Isar database initialization, SecureStorage wrapper, and a mock data layer. No screens yet. |
| **Scope** | `lib/core/network/`, `lib/core/router/`, `lib/core/database/`, `lib/core/storage/`, `lib/core/mock/`, `lib/main.dart`, `lib/app.dart` |
| **Expected Deliverables** | Fully wired app entry point, Dio client with interceptors, GoRouter with auth redirect logic, Isar singleton initialized, SecureStorage wrapper, mock repositories returning dummy data, `ProviderContainer` configured |
| **Dependencies** | Phase 01 (design system, dependencies, utilities) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Create `lib/core/network/dio_client.dart` — configured Dio instance with base URL, timeouts, and logging interceptor | Mobile | High | Phase 01 |
| 2 | Not Started | Create `lib/core/network/auth_interceptor.dart` — attaches Bearer token from SecureStorage to all requests, handles 401 → redirect to auth | Mobile | High | 1 |
| 3 | Not Started | Create `lib/core/network/api_client.dart` — base API client with typed error handling (Result type) | Mobile | High | 1, 2 |
| 4 | Not Started | Create `lib/core/storage/secure_storage.dart` — wrapper around flutter_secure_storage (get/set/delete token) | Mobile | High | Phase 01 |
| 5 | Not Started | Create `lib/core/database/isar_service.dart` — Isar initialization singleton with all collections registered | Mobile | High | Phase 01 |
| 6 | Not Started | Create `lib/core/database/collections/event_collection.dart` — Isar collection definition for Event model | Mobile | High | 5 |
| 7 | Not Started | Create `lib/core/router/app_router.dart` — GoRouter with all routes defined, auth redirect logic, ShellRoute for bottom nav | Mobile | High | Phase 01 |
| 8 | Not Started | Create `lib/core/providers/providers.dart` — global Riverpod providers for Dio, Isar, SecureStorage | Mobile | High | 1, 4, 5 |
| 9 | Not Started | Create `lib/core/mock/mock_events.dart` — 10+ realistic mock Event objects | Mobile | Medium | Phase 01 |
| 10 | Not Started | Create `lib/core/mock/mock_user.dart` — mock User object for auth | Mobile | Medium | Phase 01 |
| 11 | Not Started | Create `lib/features/auth/models/user_model.dart` — Freezed User model with json_serializable | Mobile | High | Phase 01 |
| 12 | Not Started | Create `lib/features/events/models/event_model.dart` — Freezed Event model with json_serializable | Mobile | High | Phase 01 |
| 13 | Not Started | Create mock repository implementations for Events and Auth (return mock data with simulated delay) | Mobile | High | 9, 10, 11, 12 |
| 14 | Not Started | Update `lib/main.dart` — initialize Isar, configure ProviderScope, set up app entry point | Mobile | High | 5, 8 |
| 15 | Not Started | Create `lib/app.dart` — MaterialApp.router with GoRouter and theme injection | Mobile | High | 7, 14 |
| 16 | Not Started | Create placeholder `SplashScreen` widget (simple, no logic yet) | Mobile | Medium | 15 |
| 17 | Not Started | Create placeholder `AuthScreen` widget (simple, no logic yet) | Mobile | Medium | 15 |
| 18 | Not Started | Verify full app boots to splash screen with no errors | Mobile | High | All above |

---

## Completed Work

> No work has been completed in this phase yet.

| Date | Completed | Files Modified | Notes |
|------|-----------|----------------|-------|
| — | — | — | — |

---

## Current Work

> Nothing is currently being worked on.

---

## Remaining Work

All tasks remain. The **critical path** is:

1. Models first (User, Event — tasks 11, 12) → `dart run build_runner build`
2. Network layer (Dio, interceptors — tasks 1, 2, 3)
3. Storage + Database (SecureStorage, Isar — tasks 4, 5, 6)
4. Router (GoRouter — task 7)
5. Global providers (task 8)
6. Mock data + repositories (tasks 9–13)
7. Wire it all together in main.dart + app.dart (tasks 14–17)
8. Verify app boots (task 18)

---

## Blockers

| Blocker | Impact | Since | Resolution |
|---------|--------|-------|------------|
| None | — | — | — |

---

## Decisions Made

| Decision | Rationale | Date |
|----------|-----------|------|
| — | — | — |

---

## Notes For Next Agent

> ⚠️ **Read this section before starting work. It contains everything you need to continue without rereading the repository.**

### Context
- Phase 01 must be completed before starting this phase.
- The design system, utilities, and dependencies should already exist in `lib/core/theme/`, `lib/core/utils/`, and `pubspec.yaml`.
- This phase builds the **infrastructure layer** — no visual screens beyond simple placeholders.

### What Was Done
- Nothing yet.

### What Remains
- All 18 tasks. See checklist above.

### Suggested Next Steps
1. Create the Freezed models first (User, Event) — they're needed by everything else.
2. Run `dart run build_runner build` to generate model code.
3. Build the network layer (Dio + interceptors).
4. Build storage and database layers.
5. Set up GoRouter with auth redirect.
6. Create mock data and repositories.
7. Wire everything in main.dart and app.dart.

### Warnings
- Isar initialization must happen **before** `runApp()` — typically in `main()`.
- Freezed code generation creates files in `.dart_tool/` or `lib/gen/` — do not manually edit these.
- The GoRouter auth redirect checks SecureStorage for a token. Since SecureStorage depends on platform initialization, test this carefully on both Android and iOS (or use `flutter_secure_storage` web compatibility for testing).
- Mock repositories should simulate network delay (1–2 seconds) so loading states can be tested in later phases.

### Assumptions
- The app uses `MaterialApp.router()` (not `MaterialApp()`).
- `ProviderScope` wraps the entire app at the root.
- All global providers use `@Riverpod(keepAlive: true)`.
- Isar stores events for offline use — the collection schema should mirror the API Event model.

### Useful Context
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) for the dependency flow diagram (UI → Providers → Repos → Services → Dio).
- See [`CODEBASE_GUIDE.md`](../CODEBASE_GUIDE.md) for the exact file paths and naming conventions.
- See [`PROJECT_OVERVIEW.md`](../PROJECT_OVERVIEW.md) for the expected API contract and Event model schema.
