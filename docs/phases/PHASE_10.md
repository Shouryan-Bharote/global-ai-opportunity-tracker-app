# Phase 10 — Polish & Testing

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 10 |
| **Phase Name** | Polish & Testing |
| **Objective** | Apply final polish to the application: full dark mode support, page transition animations, shimmer loading states, pull-to-refresh on all lists, accessibility labels, and comprehensive unit and widget tests. Perform a performance audit. |
| **Scope** | Entire `lib/` directory — theme system, all screens, all widgets, `test/` directory |
| **Expected Deliverables** | Production-ready app with dark mode, smooth animations, proper loading states, accessibility labels, passing test suite (unit + widget), no critical performance issues |
| **Dependencies** | Phase 08 (offline mode), Phase 09 (notifications) — all features must be complete before polish |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | **Dark Mode**: verify all screens render correctly in dark theme, fix any contrast/readability issues, ensure images/icons adapt | Mobile | High | Phase 08, 09 |
| 2 | Not Started | **Dark Mode**: implement theme toggle persistence — save preference to SharedPreferences, apply on app launch | Mobile | High | 1 |
| 3 | Not Started | **Page Transitions**: add consistent route transition animations (slide-in for push routes, fade for tab switches) | Mobile | Medium | — |
| 4 | Not Started | **Shimmer Loading**: replace all spinner/loading indicators with shimmer skeleton placeholders on Home, Explore, Schedule, Event Details | Mobile | High | — |
| 5 | Not Started | **Pull to Refresh**: add `RefreshIndicator` with `onRefresh` to Home (event list), Explore (search results), Schedule (bookmarked events) | Mobile | High | — |
| 6 | Not Started | **Error States**: verify all error states show user-friendly messages and retry buttons across every screen | Mobile | High | — |
| 7 | Not Started | **Empty States**: verify all empty states show illustrations and action buttons (no events, no bookmarks, no notifications, no search results) | Mobile | High | — |
| 8 | Not Started | **Accessibility**: add `Semantics` labels to all interactive elements (buttons, cards, tabs, icons), ensure screen reader compatibility | Mobile | Medium | — |
| 9 | Not Started | **Accessibility**: verify minimum touch target sizes (48x48dp), sufficient color contrast ratios (4.5:1 for text) | Mobile | Medium | — |
| 10 | Not Started | **Unit Tests**: write tests for all repositories (auth, events, explore, schedule, profile, notifications) | Mobile | High | — |
| 11 | Not Started | **Unit Tests**: write tests for all providers (auth state transitions, search debounce, filter state, connectivity) | Mobile | High | — |
| 12 | Not Started | **Widget Tests**: write widget tests for auth screens (form validation, error display, navigation) | Mobile | High | — |
| 13 | Not Started | **Widget Tests**: write widget tests for event card, event details screen, explore screen | Mobile | High | — |
| 14 | Not Started | **Widget Tests**: write widget tests for schedule screen (calendar interaction, bookmarked events) | Mobile | Medium | — |
| 15 | Not Started | **Widget Tests**: write widget tests for profile screen (display, sign out flow) | Mobile | Medium | — |
| 16 | Not Started | **Performance Audit**: use Flutter DevTools to profile app startup time, scroll performance, and memory usage | Mobile | High | — |
| 17 | Not Started | **Performance Fixes**: optimize any issues found — lazy loading for lists, image caching, reduce unnecessary rebuilds | Mobile | High | 16 |
| 18 | Not Started | **Final Verification**: run `flutter analyze` (zero errors), run `flutter test` (all passing), test on both Android and iOS physical devices | Mobile | High | All above |

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

All tasks remain. Work is organized into **4 tracks** that can run in parallel:

| Track | Tasks | Description |
|-------|-------|-------------|
| **UI Polish** | 1–7 | Dark mode, animations, shimmer, pull-to-refresh, error/empty states |
| **Accessibility** | 8–9 | Semantic labels, touch targets, contrast ratios |
| **Testing** | 10–15 | Unit tests (repositories + providers) + Widget tests (screens) |
| **Performance** | 16–17 | DevTools profiling + optimization |
| **Final** | 18 | Full verification (analyze + test + device test) |

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
- Phases 01–09 must all be complete. Every feature is built, connected to the backend, supports offline, and has notifications.
- This is the **final phase** — no new features are added here. Only polish, testing, and optimization.
- The app should already have a working dark theme from Phase 01, but it needs verification and edge-case fixes.

### What Was Done
- Nothing yet.

### What Remains
- All 18 tasks. See the 4 parallel tracks above.

### Suggested Next Steps
1. **UI Polish track first** (tasks 1–7) — this has the most visible impact. Start with dark mode verification, then shimmer loading, then pull-to-refresh.
2. **Testing track next** (tasks 10–15) — write repository tests first (they're the foundation), then provider tests, then widget tests.
3. **Accessibility track** (tasks 8–9) — add semantic labels, verify touch targets.
4. **Performance track** (tasks 16–17) — profile with DevTools, fix issues.
5. **Final verification** (task 18) — `flutter analyze`, `flutter test`, device testing.

### Warnings
- Shimmer loading requires the `shimmer` package or a custom implementation. Add to `pubspec.yaml` if needed.
- `flutter analyze` with `very_good_analysis` will likely produce many warnings on existing code — address them systematically, do NOT suppress all of them.
- Widget tests require mocking Riverpod providers. Use `ProviderContainer` with `overrides` in test setup. See `test/helpers/test_helpers.dart` for reusable mocks.
- Performance profiling should be done on a **release build** (`flutter run --release`), not debug. Debug mode has intentionally slower performance.
- Test on both Android and iOS — there may be platform-specific rendering differences (especially for dark mode and system UI).

### Assumptions
- The `shimmer` package (or similar) is acceptable to add for loading skeletons.
- Tests use `mockito` or `mocktail` for mocking — confirm which is already in `pubspec.yaml`.
- `flutter test` should be run with coverage: `flutter test --coverage`.
- Performance targets: app startup < 2 seconds, list scroll > 55fps, no memory leaks on screen transitions.
- Physical device testing is available (both Android and iOS).

### Useful Context
- See [`CODEBASE_GUIDE.md`](../CODEBASE_GUIDE.md) "Linting & Analysis" section for `very_good_analysis` rules.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) "Design System" for theme structure.
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) for UI states that must be verified in each screen.
- See [`DEVELOPMENT_WORKFLOW.md`](../DEVELOPMENT_WORKFLOW.md) "Phase 10 — Polish" checklist for the full verification list.
