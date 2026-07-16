# Phase 05 — Feature Development

> **Status**: Completed | **Completion**: 100% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

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
| 1 | Completed | Create `lib/features/explore/models/search_filter_model.dart` — Freezed model for search query and filter state (mode, platform, status, date range) | Mobile | High | Phase 04 |
| 2 | Completed | Create `lib/features/explore/data/explore_repository.dart` — repository that filters mock events by search query and filter criteria | Mobile | High | 1 |
| 3 | Completed | Create `lib/features/explore/providers/search_provider.dart` — debounced search provider (300ms) | Mobile | High | 2 |
| 4 | Completed | Create `lib/features/explore/providers/filter_provider.dart` — manages active filter state (chips) | Mobile | High | 1 |
| 5 | Completed | Create `lib/features/explore/presentation/widgets/search_bar.dart` — custom search input with debounce | Mobile | High | 3 |
| 6 | Completed | Create `lib/features/explore/presentation/widgets/filter_chip_group.dart` — horizontal scrollable filter chips | Mobile | Medium | 4 |
| 7 | Completed | Update `lib/features/explore/presentation/screens/explore_screen.dart` — integrate search bar, filters, and filtered event list/grid | Mobile | High | 3, 4, 5, 6 |
| 8 | Completed | Add UI states to Explore: initial (all events), searching (loading), results, no results, error | Mobile | High | 7 |
| 9 | Completed | Create `lib/features/schedule/data/schedule_repository.dart` — repository that returns bookmarked mock events + events filtered by date | Mobile | High | Phase 04 |
| 10 | Completed | Create `lib/features/schedule/providers/schedule_provider.dart` — manages calendar selected date and bookmarked events list | Mobile | High | 9 |
| 11 | Completed | Create `lib/features/schedule/presentation/widgets/calendar_widget.dart` — month calendar grid with event dot indicators | Mobile | High | 10 |
| 12 | Completed | Update `lib/features/schedule/presentation/screens/schedule_screen.dart` — segmented control (Calendar / Bookmarked), calendar view with events below, bookmarked events list | Mobile | High | 10, 11 |
| 13 | Completed | Add UI states to Schedule: loading, calendar with events, no events this month, no bookmarks, error | Mobile | Medium | 12 |
| 14 | Completed | Create `lib/features/profile/data/profile_repository.dart` — mock repository returning user profile data | Mobile | High | Phase 04 |
| 15 | Completed | Create `lib/features/profile/providers/profile_provider.dart` — manages user profile state, sign-out action | Mobile | High | 14 |
| 16 | Completed | Create `lib/features/profile/presentation/widgets/profile_header.dart` — avatar (initials), name, email display | Mobile | Medium | 15 |
| 17 | Completed | Update `lib/features/profile/presentation/screens/profile_screen.dart` — profile header, stats row, menu items (Edit, Settings, About, Sign Out), sign out confirmation dialog | Mobile | High | 15, 16 |
| 18 | Completed | Implement Edit Profile: allow updating name via in-place edit or dialog, update mock repository | Mobile | Medium | 17 |
| 19 | Completed | Implement Sign Out flow: confirmation dialog → clear SecureStorage → clear Isar → navigate to `/auth` | Mobile | High | 15, 17 |
| 20 | Completed | Test all three features independently: Explore search + filter, Schedule calendar + bookmarks, Profile edit + sign out | Mobile | High | All above |

---

## Completed Work

> Explore and Schedule feature tracks are complete.

| Date | Completed | Files Modified | Notes |
|------|-----------|----------------|-------|
| 2026-07-16 | Repository pattern migration | `event_repository.dart`, `mock_event_repository.dart`, `events_provider.dart`, `repository_providers.dart`, `home_provider.dart`, `home_screen.dart`, `schedule_provider.dart`, `explore_provider.dart`, `explore_results.dart`, `schedule_screen.dart`, `schedule_event_card.dart`, `event_details_screen.dart` | Fully decoupled frontend from data source. All pages now derive from single `eventsProvider` → `EventRepository`. One-line swap for real backend. |
| 2026-07-15 | UI polish across all pages | `category_chips.dart`, `explore_filter_chips.dart`, `explore_categories.dart`, `popular_cities.dart`, `explore_search_bar.dart`, `schedule_event_card.dart`, `schedule_screen.dart` | Consistent blue gradients, interactive press animations, dynamic search bar, typography refinement. |
| 2026-07-15 | Tasks 9-13 (Schedule) | `schedule_screen.dart`, `schedule_provider.dart`, `schedule_event_card.dart` | Schedule screen completely built matching Figma design with Tabs and Swipe-to-delete. |
| 2026-07-15 | Tasks 1-8 (Explore) | `explore_screen.dart`, `explore_provider.dart`, `explore_results.dart` | Explore screen completely built matching Figma with functional search and dynamic filter chips. |

---

## Current Work

> Nothing is currently being worked on.

---

## Remaining Work

Only the **Profile track** remains:

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
| Repository Pattern (D11) | All data flows through abstract `EventRepository` → `eventsProvider`. Swapping mock → real requires changing only `repository_providers.dart`. | 2026-07-16 |
| Consistent blue gradient for active states | User preference for cohesive visual language across all tabs, chips, and buttons. | 2026-07-15 |
| TabBar + TabBarView for Schedule | Smooth horizontal swiping between Today/Upcoming/Saved, better UX than manual chips. | 2026-07-15 |

---

## Notes For Next Agent

> ⚠️ **Read this section before starting work. It contains everything you need to continue without rereading the repository.**

### Context
- Explore and Schedule are **complete** with full UI polish (gradients, animations, search bar).
- The **Repository Pattern** is fully implemented (see Decision D11). All event data flows through `eventsProvider` → `EventRepository`.
- The **Profile track** (tasks 14–19) is the only remaining work.

### What Was Done
- Explore screen: search, filters, categories, popular cities, result cards with press animations.
- Schedule screen: TabBar swiping (Today/Upcoming/Saved), bookmark sync, swipe-to-delete.
- Repository pattern: Abstract `EventRepository` interface, `MockEventRepository`, global `eventsProvider` (AsyncNotifier), all pages wired through single source of truth.
- UI polish: Consistent blue gradient for active states, dynamic search bar, refined typography.

### What Remains
- Tasks 14–19: Build the Profile screen (repository, provider, header widget, screen, edit, sign out).
- Task 20: Integration test of all three features.

### Suggested Next Steps
1. Create `lib/features/profile/data/profile_repository.dart` — mock user profile data.
2. Create `lib/features/profile/providers/profile_provider.dart` — manage user state.
3. Build `profile_header.dart` and `profile_screen.dart`.
4. Implement edit profile and sign out flow.
5. Test all three features together.

### Warnings
- **Do NOT create a separate data source.** Use the existing repository pattern. If Profile needs user data, create a `UserRepository` with the same abstract interface pattern.
- Sign Out must clear **both** SecureStorage (token) AND Isar (cached data).
- The `scheduleEventsProvider` StateNotifier has been **removed**. All bookmark operations go through `eventsProvider.notifier.toggleBookmark()`. Do not recreate it.
- `home_provider.dart` now derives from `eventsProvider` — do NOT add a separate `FutureProvider` for home events.

### Key Architecture Files
| File | Purpose |
|------|---------|
| `lib/features/events/repositories/event_repository.dart` | Abstract interface |
| `lib/features/events/repositories/mock_event_repository.dart` | Mock implementation |
| `lib/core/providers/repository_providers.dart` | DI — swap mock for real here |
| `lib/features/events/providers/events_provider.dart` | Global AsyncNotifier (single source of truth) |

### Useful Context
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) for detailed specs of each feature.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) for the provider pattern examples.
- See [`CODEBASE_GUIDE.md`](../CODEBASE_GUIDE.md) for the exact directory structure per feature.
