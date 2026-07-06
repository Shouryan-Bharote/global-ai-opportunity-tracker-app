# Phase 03 — Authentication

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 03 |
| **Phase Name** | Authentication |
| **Objective** | Build the Sign In and Sign Up screens with full form validation, mock authentication flow, JWT token storage in SecureStorage, and auth state persistence across app restarts. |
| **Scope** | `lib/features/auth/` (data, models, providers, presentation) |
| **Expected Deliverables** | Working auth UI with form validation, mock auth provider that stores/retrieves tokens, automatic redirect to `/auth` when not authenticated, auth state persists across app restarts |
| **Dependencies** | Phase 02 (core infrastructure, GoRouter auth redirect, SecureStorage, mock repositories) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Create `lib/features/auth/data/auth_api_service.dart` — mock API service with login/signup methods returning mock tokens | Mobile | High | Phase 02 |
| 2 | Not Started | Create `lib/features/auth/data/auth_repository.dart` — repository wrapping the API service, handles token storage via SecureStorage | Mobile | High | 1 |
| 3 | Not Started | Create `lib/features/auth/providers/auth_provider.dart` — Riverpod `StateNotifierProvider` managing auth state (unauthenticated, authenticated, loading, error) | Mobile | High | 2 |
| 4 | Not Started | Create `lib/features/auth/presentation/screens/auth_screen.dart` — single screen with tab toggle between Sign In and Sign Up | Mobile | High | 3 |
| 5 | Not Started | Create `lib/features/auth/presentation/screens/login_screen.dart` — email + password form with validation | Mobile | High | 4 |
| 6 | Not Started | Create `lib/features/auth/presentation/screens/signup_screen.dart` — name + email + password + confirm password form with validation | Mobile | High | 4 |
| 7 | Not Started | Create `lib/features/auth/presentation/widgets/auth_form.dart` — reusable form widget shared by login and signup | Mobile | Medium | 5, 6 |
| 8 | Not Started | Wire auth_provider to GoRouter redirect — unauthenticated users redirect to `/auth`, authenticated users redirect to `/home` | Mobile | High | 3 |
| 9 | Not Started | Implement token persistence — on app restart, check SecureStorage for valid token and auto-authenticate | Mobile | High | 2, 8 |
| 10 | Not Started | Add form validation: email format, password length ≥ 6, passwords match (signup), required fields | Mobile | High | 5, 6 |
| 11 | Not Started | Add UI states for auth screens: initial, loading (spinner on button, inputs disabled), error (message below form), success (navigate) | Mobile | High | 5, 6 |
| 12 | Not Started | Test full auth flow: open app → see splash → redirected to auth → sign up → redirected to home → close and reopen → still authenticated | Mobile | High | All above |

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

1. Mock API service (task 1) → Auth repository (task 2) → Auth provider (task 3)
2. Auth screens with forms (tasks 4–7) → form validation (task 10) → UI states (task 11)
3. GoRouter auth redirect wiring (task 8) → token persistence (task 9)
4. End-to-end flow test (task 12)

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
- Phase 02 must be completed first. The core infrastructure (Dio, SecureStorage, GoRouter, Riverpod, mock data layer) should be in place.
- Authentication is **mock** in this phase. Real API integration happens in Phase 07.
- The auth screen uses a **single page with tab toggle** (not separate routes for login vs. signup).

### What Was Done
- Nothing yet.

### What Remains
- All 12 tasks. See checklist above.

### Suggested Next Steps
1. Create the mock auth API service and repository (tasks 1–2).
2. Create the auth provider with full state management (task 3).
3. Build the auth UI: tab-based screen with login/signup forms (tasks 4–7).
4. Add form validation and UI state handling (tasks 10–11).
5. Wire the auth state to GoRouter redirect (task 8).
6. Implement token persistence across app restarts (task 9).
7. Test the complete flow end-to-end (task 12).

### Warnings
- The GoRouter redirect in `app_router.dart` (from Phase 02) needs to read the auth provider state. Make sure the provider is accessible before the router is created — consider using `ref` or a global auth state listener.
- `flutter_secure_storage` may throw on web/platforms without keychain support. Handle gracefully for debugging.
- Mock auth should simulate a 1–2 second delay so loading states are visible.
- The `UserModel` should already exist from Phase 02. If not, create it before proceeding.

### Assumptions
- Auth state has 4 states: `initial`, `loading`, `authenticated`, `unauthenticated`, `error`.
- On successful auth, the JWT token is stored in SecureStorage and a `User` object is held in Riverpod state.
- The sign-up flow auto-logs the user in (no separate confirmation step needed for mock).
- Form validation errors appear inline below each field.

### Useful Context
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) section "Authentication" for the full spec.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) "Authentication Flow" for the sequence diagram.
- See [`CODEBASE_GUIDE.md`](../CODEBASE_GUIDE.md) for the exact file structure under `features/auth/`.
