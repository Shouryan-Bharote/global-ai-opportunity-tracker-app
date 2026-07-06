# Phase 08 — Offline Mode

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 08 |
| **Phase Name** | Offline Mode |
| **Objective** | Implement Isar-based caching for events so the app remains functional without internet. Events fetched from the API are cached locally. When offline, the app displays cached data with an offline indicator. Bookmarks and profile updates are queued for sync. |
| **Scope** | `lib/core/database/` (Isar collections, sync logic), `lib/features/events/data/events_repository.dart` (cache layer), `lib/core/widgets/offline_banner.dart`, `lib/core/providers/connectivity_provider.dart` |
| **Expected Deliverables** | Events cached in Isar after every API fetch, offline banner shown when disconnected, cached events browsable without network, bookmark/profile changes queued and synced on reconnect |
| **Dependencies** | Phase 07 (backend integration must be working — cache stores real API data) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Add `connectivity_plus` dependency to `pubspec.yaml` for network state detection | Mobile | High | Phase 07 |
| 2 | Not Started | Create `lib/core/providers/connectivity_provider.dart` — Riverpod `StreamProvider` that emits `true`/`false` based on network connectivity | Mobile | High | 1 |
| 3 | Not Started | Create `lib/core/widgets/offline_banner.dart` — dismissible Material banner showing "You're offline — viewing cached data" | Mobile | High | 2 |
| 4 | Not Started | Integrate offline banner into `AppShell` — shown at top of scaffold when connectivity is `false` | Mobile | High | 2, 3 |
| 5 | Not Started | Update `lib/features/events/data/events_repository.dart` — on fetch: save events to Isar. On next fetch: return cached data first, then update from API (stale-while-revalidate) | Mobile | High | Phase 07 |
| 6 | Not Started | Update `events_repository.getEventById()` — cache individual event details in Isar after fetch | Mobile | High | 5 |
| 7 | Not Started | Handle offline fetch gracefully: when network unavailable, return cached Isar data. If no cache exists, show empty/error state with "Connect to internet" message | Mobile | High | 5, 6 |
| 8 | Not Started | Create bookmark sync queue: when offline and user bookmarks, store action in a local queue (Isar or SharedPreferences) | Mobile | Medium | 5 |
| 9 | Not Started | Create profile update sync queue: when offline and user edits profile, store update locally | Mobile | Medium | 5 |
| 10 | Not Started | Implement sync-on-reconnect: when connectivity changes from `false` to `true`, flush queued bookmark and profile actions to the API | Mobile | High | 8, 9 |
| 11 | Not Started | Update Schedule feature: when offline, show cached bookmarked events from Isar (not from API) | Mobile | Medium | 5 |
| 12 | Not Started | Update Explore search: when offline, perform local search on cached Isar events (text matching on title, description, tags) | Mobile | Medium | 5 |
| 13 | Not Started | Add cache expiry: events not seen for 7+ days are marked inactive or removed from local cache | Mobile | Low | 5 |
| 14 | Not Started | Test offline scenarios: disconnect network → verify cached data shows → reconnect → verify sync happens → verify new data loads | Mobile | High | All above |

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

1. Connectivity detection (tasks 1–2) → offline banner (tasks 3–4)
2. Event caching in repository (tasks 5–7)
3. Sync queues for bookmarks and profile (tasks 8–10)
4. Update features for offline behavior (tasks 11–12)
5. Cache expiry (task 13) → test offline scenarios (task 14)

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
- Phase 07 must be complete. The app is connected to the real backend and fetching real data.
- Isar is already initialized (from Phase 02) but currently not used for caching — only as a placeholder.
- This phase adds the caching layer between the repository and the API service.

### What Was Done
- Nothing yet.

### What Remains
- All 14 tasks. See checklist above.

### Suggested Next Steps
1. Add `connectivity_plus` dependency (task 1).
2. Create the connectivity provider and offline banner (tasks 2–4).
3. Update the events repository with Isar caching (tasks 5–7) — this is the core work.
4. Build sync queues for bookmarks and profile (tasks 8–10).
5. Update Explore and Schedule for offline behavior (tasks 11–12).
6. Add cache expiry (task 13) and test thoroughly (task 14).

### Warnings
- `connectivity_plus` reports **network availability**, not **internet reachability**. A device on Wi-Fi without actual internet access will still report `true`. Consider adding a simple API ping check as a fallback.
- The stale-while-revalidate pattern means the user sees cached data instantly, then the UI updates when fresh data arrives. Make sure the UI handles this transition without flicker.
- Sync queues can fail if the queued action is no longer valid (e.g., user deleted the event). Handle sync failures gracefully — log the error and discard the action if unrecoverable.
- Isar writes must happen inside a `writeTxn()` block — batch multiple writes together for performance.

### Assumptions
- Events are cached after every successful API fetch — the entire list response.
- Cache is used as fallback only when the network is unavailable.
- Sync queue uses Isar (consistent with the rest of the storage strategy).
- Cache expiry is time-based (7 days) rather than count-based.
- The offline banner is dismissible — the user can close it, but it reappears on the next connectivity change.

### Useful Context
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) "Offline Strategy" for the flowchart.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) "Offline Behavior by Feature" table.
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) offline notes in each feature spec.
