# Phase 06 — Event Details

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 06 |
| **Phase Name** | Event Details |
| **Objective** | Build a fully reusable Event Details screen with complete UI: banner, title, platform badge, date/time, mode, description, prize, team size, tags, and action buttons (bookmark, share, register). This screen must be accessible from Home, Explore, Schedule, and Notifications. |
| **Scope** | `lib/features/events/` (presentation screens and widgets), `lib/core/widgets/` (shared bookmark button) |
| **Expected Deliverables** | Complete Event Details screen with all UI elements, bookmark toggle, share action, register (open external link), accessible from all entry points |
| **Dependencies** | Phase 05 (all features must have event cards that navigate to this screen) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Create `lib/features/events/providers/event_detail_provider.dart` — `FutureProvider` that loads a single event by ID from the (mock) repository | Mobile | High | Phase 05 |
| 2 | Not Started | Create `lib/features/events/presentation/widgets/event_info_tile.dart` — reusable info row widget (icon + label + value) used for date, prize, team size | Mobile | Medium | Phase 05 |
| 3 | Not Started | Create `lib/features/events/presentation/widgets/bookmark_button.dart` — toggleable bookmark icon button (filled/outline), updates local state | Mobile | High | 1 |
| 4 | Not Started | Build Event Details screen layout: banner image (with placeholder fallback), title, platform badge, mode badge, date/time display, description, tags chips | Mobile | High | 1, 2 |
| 5 | Not Started | Add prize and team size sections (conditionally shown only when data exists) | Mobile | Medium | 4 |
| 6 | Not Started | Add registration deadline with countdown text ("X days left to register") | Mobile | Medium | 4 |
| 7 | Not Started | Add bookmark action button — toggles bookmark state, shows snackbar confirmation | Mobile | High | 3, 4 |
| 8 | Not Started | Add share action button — uses `share_plus` or system share sheet to share event title + platform URL | Mobile | Medium | 4 |
| 9 | Not Started | Add register action button — opens `platform_url` in external browser via `url_launcher` | Mobile | High | 4 |
| 10 | Not Started | Add UI states: loading shimmer, success (full details), not found ("Event not found" + back button), error (message + retry) | Mobile | High | 4 |
| 11 | Not Started | Verify Event Details opens correctly from all entry points: Home event card, Explore search result, Schedule bookmark, (future Notifications tap) | Mobile | High | All above |
| 12 | Not Started | Add `url_launcher` and `share_plus` dependencies to `pubspec.yaml` if not already present | Mobile | High | 8, 9 |

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

1. Add new dependencies (task 12) → create event detail provider (task 1)
2. Build core UI layout (task 4) → add conditional sections (tasks 5, 6)
3. Build action buttons: bookmark (task 3, 7), share (task 8), register (task 9)
4. Add UI states (task 10) → verify from all entry points (task 11)

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
- Phase 05 must be complete. Event cards in Home, Explore, and Schedule already navigate to `/events/:id`.
- The Event Details screen was created as a placeholder in Phase 04. This phase replaces it with the full implementation.
- The Event model (`Freezed`) should already exist from Phase 02.

### What Was Done
- Nothing yet.

### What Remains
- All 12 tasks. See checklist above.

### Suggested Next Steps
1. Add `url_launcher` and `share_plus` to `pubspec.yaml` (task 12).
2. Create the event detail provider (task 1).
3. Build the full Event Details screen layout (task 4) — this is the main task.
4. Add conditional sections (tasks 5–6).
5. Implement the three action buttons: bookmark (task 3, 7), share (task 8), register (task 9).
6. Add all UI states: loading shimmer, error, not found (task 10).
7. Test navigation from all entry points (task 11).

### Warnings
- **Do NOT duplicate** the Event Details screen. There must be exactly one screen at `/events/:id`.
- The bookmark state is mock-local in this phase — it toggles UI state only. Real bookmark sync happens in Phase 07.
- `url_launcher` requires platform-specific configuration (Android manifest, iOS Info.plist). Add the necessary configurations.
- If `share_plus` is not desired, use Flutter's built-in `Share.share()` from the `share` package instead — it's simpler.
- The banner image should have a placeholder (colored container with icon) when `bannerUrl` is null.

### Assumptions
- Event Details is a **push route** (full screen), not a bottom sheet or dialog.
- The screen receives `eventId` from GoRouter's `pathParameters`.
- Bookmark button state is ephemeral (memory only) in this phase.
- Share shares: event title + short description + platform URL.
- Register opens the external platform URL — the user registers on the source platform, not in this app.

### Useful Context
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) "Event Details Screen" section for full spec.
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) for the provider pattern to use.
- See [`PROJECT_OVERVIEW.md`](../PROJECT_OVERVIEW.md) for the Event model schema (all fields).
