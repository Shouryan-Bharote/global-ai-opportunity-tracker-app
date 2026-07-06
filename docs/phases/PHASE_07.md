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

### Useful Context
- See [`PROJECT_OVERVIEW.md`](../PROJECT_OVERVIEW.md) for the expected API contract and Event model schema.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) for the error handling strategy and auth flow diagram.
- See [`DEVELOPMENT_WORKFLOW.md`](../DEVELOPMENT_WORKFLOW.md) for the mock-to-real provider swap pattern.
