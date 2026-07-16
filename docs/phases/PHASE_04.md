# Phase 04 — Navigation Shell

> **Status**: Completed | **Completion**: 100% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 04 |
| **Phase Name** | Navigation Shell |
| **Objective** | Build the main app shell with bottom navigation bar, create placeholder screens for all 4 tabs (Home, Explore, Schedule, Profile), implement the Event Details route, and populate all screens with dummy data so the app is fully navigable. |
| **Scope** | `lib/core/widgets/app_shell.dart`, `lib/features/home/`, `lib/features/explore/`, `lib/features/schedule/`, `lib/features/profile/`, `lib/features/events/presentation/screens/event_details_screen.dart`, `lib/core/router/app_router.dart` (update) |
| **Expected Deliverables** | Navigable app with working bottom nav, all tab screens showing dummy content, Event Details accessible from all tabs, navigation state preserved on tab switch |
| **Dependencies** | Phase 03 (authentication must work — shell only visible when authenticated) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Completed | Create `lib/core/widgets/app_shell.dart` — Scaffold with bottom navigation bar (4 tabs: Home, Explore, Schedule, Profile) | Mobile | High | Phase 03 |
| 2 | Completed | Create `lib/features/home/presentation/screens/home_screen.dart` — placeholder with "Home" title and mock event list | Mobile | High | 1 |
| 3 | Completed | Create `lib/features/explore/presentation/screens/explore_screen.dart` — placeholder with "Explore" title and mock search bar | Mobile | High | 1 |
| 4 | Completed | Create `lib/features/schedule/presentation/screens/schedule_screen.dart` — placeholder with "Schedule" title and mock calendar/list | Mobile | High | 1 |
| 5 | Completed | Create `lib/features/profile/presentation/screens/profile_screen.dart` — placeholder with user name, avatar placeholder, menu items | Mobile | High | 1 |
| 6 | Completed | Create `lib/features/events/presentation/screens/event_details_screen.dart` — full Event Details screen populated with mock data (banner, title, date, mode, description, tags, action buttons) | Mobile | High | Phase 02 |
| 7 | Completed | Create `lib/core/widgets/event_card.dart` — reusable event card widget used in all lists (Home, Explore, Schedule, Notifications) | Mobile | High | Phase 02 |
| 8 | Completed | Update `lib/core/router/app_router.dart` — wire ShellRoute to AppShell, add all tab routes, add `/events/:id` route, remove placeholder screens | Mobile | High | 1, 2, 3, 4, 5, 6 |
| 9 | Completed | Wire `event_card.dart` tap to navigate to `/events/:id` | Mobile | Medium | 6, 7, 8 |
| 10 | Completed | Verify navigation: all tabs switch correctly, back stack works, event details opens from any tab, back button returns correctly | Mobile | High | All above |
| 11 | Completed | Ensure navigation state is preserved when switching tabs (scroll position, form input, etc.) | Mobile | Medium | 8 |
| 12 | Completed | Create `lib/features/settings/presentation/screens/settings_screen.dart` — placeholder settings page | Mobile | Low | 5 |

---

> All tasks completed successfully.

| Date | Completed | Files Modified | Notes |
|------|-----------|----------------|-------|
| 2026-07-15 | All 12 Tasks | `app_shell.dart`, `app_router.dart`, various placeholders | Navigation shell working perfectly with dummy data. |

| Date | Completed | Files Modified | Notes |
|------|-----------|----------------|-------|
| — | — | — | — |

---

## Current Work

> Nothing is currently being worked on.

---

> All work is complete. Transitioning to Phase 05.

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
- Phase 03 must be complete. Auth flow works, so the app redirects to `/home` after login.
- The GoRouter from Phase 02 has placeholder routes. These will be replaced with real screens and the ShellRoute.
- Mock event data from Phase 02's `mock_events.dart` is used to populate all screens.

### What Was Done
- Nothing yet.

### What Remains
- All 12 tasks. See checklist above.

### Suggested Next Steps
1. Start with `AppShell` (task 1) — this is the container for everything.
2. Create all 4 tab screens as simple placeholders (tasks 2–5).
3. Build `EventCard` widget (task 7) — it's reused everywhere.
4. Build the `EventDetailsScreen` (task 6) — this is the most complex screen in this phase.
5. Update GoRouter to use `ShellRoute` with AppShell and wire all routes (task 8).
6. Wire EventCard tap to navigate to Event Details (task 9).
7. Test navigation thoroughly (tasks 10–12).

### Warnings
- GoRouter's `ShellRoute` preserves child state by default. Do NOT use `StatefulShellRoute.indexed` unless intentional.
- The Event Details screen should accept `eventId` as a parameter (from GoRouter's `pathParameters`), not as a constructor argument. This keeps navigation declarative.
- Make sure the placeholder screens use mock data from `mock_events.dart` — do NOT hardcode strings in widgets.
- Settings screen is low priority in this phase — it just needs to be navigable.

### Assumptions
- Bottom nav uses Material 3 `NavigationBar` (not the deprecated `BottomNavigationBar`).
- Each tab uses the icons specified in `FEATURES_AND_FLOWS.md`: `home_rounded`, `search_rounded`, `calendar_month_rounded`, `person_rounded`.
- Event Details is opened as a full-screen route (push), not a modal bottom sheet.
- The notification bell icon on the Home app bar is included but the Notifications screen is deferred.

### Useful Context
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) "Bottom Navigation Shell" section for tab specs.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) "Navigation: GoRouter" for the route diagram and skeleton code.
- See [`CODEBASE_GUIDE.md`](../CODEBASE_GUIDE.md) for the directory structure of each feature.
