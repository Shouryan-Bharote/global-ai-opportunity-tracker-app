# Phase 05 — Feature Development

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 05 |
| **Phase Name** | Feature Development |
| **Objective** | Build three core features independently: Explore (search + filters), Schedule (calendar view + bookmarked events), and Profile (user info display + edit + menu actions). Each feature is self-contained and uses mock data. |
| **Scope** | `lib/features/explore/`, `lib/features/schedule/`, `lib/features/profile/` |
| **Expected Deliverables** | Explore screen with working search and filter chips, Schedule screen with calendar view and bookmarked events list, Profile screen with user info and settings navigation — all functional with mock data |
| **Dependencies** | Phase 04 (navigation shell and placeholder screens must exist) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Create `lib/features/explore/models/search_filter_model.dart` — Freezed model for search query and filter state (mode, platform, status, date range) | Mobile | High | Phase 04 |
| 2 | Not Started | Create `lib/features/explore/data/explore_repository.dart` — repository that filters mock events by search query and filter criteria | Mobile | High | 1 |
| 3 | Not Started | Create `lib/features/explore/providers/search_provider.dart` — debounced search provider (300ms) | Mobile | High | 2 |
| 4 | Not Started | Create `lib/features/explore/providers/filter_provider.dart` — manages active filter state (chips) | Mobile | High | 1 |
| 5 | Not Started | Create `lib/features/explore/presentation/widgets/search_bar.dart` — custom search input with debounce | Mobile | High | 3 |
| 6 | Not Started | Create `lib/features/explore/presentation/widgets/filter_chip_group.dart` — horizontal scrollable filter chips | Mobile | Medium | 4 |
| 7 | Not Started | Update `lib/features/explore/presentation/screens/explore_screen.dart` — integrate search bar, filters, and filtered event list/grid | Mobile | High | 3, 4, 5, 6 |
| 8 | Not Started | Add UI states to Explore: initial (all events), searching (loading), results, no results, error | Mobile | High | 7 |
| 9 | Not Started | Create `lib/features/schedule/data/schedule_repository.dart` — repository that returns bookmarked mock events + events filtered by date | Mobile | High | Phase 04 |
| 10 | Not Started | Create `lib/features/schedule/providers/schedule_provider.dart` — manages calendar selected date and bookmarked events list | Mobile | High | 9 |
| 11 | Not Started | Create `lib/features/schedule/presentation/widgets/calendar_widget.dart` — month calendar grid with event dot indicators | Mobile | High | 10 |
| 12 | Not Started | Update `lib/features/schedule/presentation/screens/schedule_screen.dart` — segmented control (Calendar / Bookmarked), calendar view with events below, bookmarked events list | Mobile | High | 10, 11 |
| 13 | Not Started | Add UI states to Schedule: loading, calendar with events, no events this month, no bookmarks, error | Mobile | Medium | 12 |
| 14 | Not Started | Create `lib/features/profile/data/profile_repository.dart` — mock repository returning user profile data | Mobile | High | Phase 04 |
| 15 | Not Started | Create `lib/features/profile/providers/profile_provider.dart` — manages user profile state, sign-out action | Mobile | High | 14 |
| 16 | Not Started | Create `lib/features/profile/presentation/widgets/profile_header.dart` — avatar (initials), name, email display | Mobile | Medium | 15 |
| 17 | Not Started | Update `lib/features/profile/presentation/screens/profile_screen.dart` — profile header, stats row, menu items (Edit, Settings, About, Sign Out), sign out confirmation dialog | Mobile | High | 15, 16 |
| 18 | Not Started | Implement Edit Profile: allow updating name via in-place edit or dialog, update mock repository | Mobile | Medium | 17 |
| 19 | Not Started | Implement Sign Out flow: confirmation dialog → clear SecureStorage → clear Isar → navigate to `/auth` | Mobile | High | 15, 17 |
| 20 | Not Started | Test all three features independently: Explore search + filter, Schedule calendar + bookmarks, Profile edit + sign out | Mobile | High | All above |

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

All tasks remain. The three features can be developed **in parallel**:

- **Explore track**: tasks 1–8
- **Schedule track**: tasks 9–13
- **Profile track**: tasks 14–19
- **Final**: task 20 (integration test)

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
- Phase 04 must be complete. All placeholder screens exist in the navigation shell.
- This phase builds out the **real functionality** of three features: Explore, Schedule, and Profile.
- All features use **mock data** — no backend integration yet.

### What Was Done
- Nothing yet.

### What Remains
- All 20 tasks across three feature tracks.

### Suggested Next Steps
1. **Explore track** (tasks 1–8): Create filter model → repository → providers → search bar + filter chips → update screen.
2. **Schedule track** (tasks 9–13): Create repository → provider → calendar widget → update screen.
3. **Profile track** (tasks 14–19): Create repository → provider → profile header → update screen → sign out flow.
4. Test all three features (task 20).

### Warnings
- The debounced search (task 3) must cancel previous search requests when the user types quickly. Use Riverpod's `ref.onDispose` to cancel timers.
- The calendar widget (task 11) is the most complex UI component in this phase. Consider using a package like `table_calendar` to avoid building from scratch, but check with the team first.
- The bookmark functionality in Schedule is mock only in this phase — real sync happens in Phase 07.
- Sign Out must clear **both** SecureStorage (token) AND Isar (cached data) to prevent stale state.

### Assumptions
- Explore uses a **grid layout** for events (or list — decide based on design).
- Schedule's segmented control is a `SegmentedButton` (Material 3).
- Profile edit is inline (not a separate screen/route) — simpler for mock.
- Filter chips are toggleable (multiple can be active simultaneously).
- Calendar shows dots only (no event count number).

### Useful Context
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) for detailed specs of each feature (UI states, filters, behavior).
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) for the provider pattern examples.
- See [`CODEBASE_GUIDE.md`](../CODEBASE_GUIDE.md) for the exact directory structure per feature.
