# App Fix List — Global AI Opportunity Tracker

> Tracked fixes from the full app audit. All items solved and verified against static analysis and live backend integration.

---

## 🔴 Critical Fixes

| # | Status | Issue | File(s) |
|---|:------:|-------|---------|
| 1 | ✅ Done | **Fake "Design: 78 events" and "Marketing: 63 events"** — replaced hardcoded numbers with real `_countEventsForTopic()` from live backend events | `home_screen.dart` |
| 2 | ✅ Done | **Speaker tab is fictional** — removed fabricated avatars and fake titles; now displays real verified Organizer info and clean "Speakers Lineup TBA" notice | `event_details_screen.dart` |
| 3 | ✅ Done | **"Free" / "Paid" chips do nothing** — removed non-functional chips from filter bar so only functioning filters are shown | `explore_filter_chips.dart` |
| 4 | ✅ Done | **Profile interests disconnected from feed** — connected `_selectedInterests` in Profile to `userInterestsProvider`, updating stats and recommending matching events live on Home | `profile_screen.dart`, `home_provider.dart` |
| 5 | ✅ Done | **Every card shows today's date** — added `isDateTba` epoch-sentinel detection; replaced fallback `DateTime.now()` with "Date TBA" across all cards, details, and schedules | `http_event_repository.dart`, `event_model.dart`, card & detail widgets |

---

## 🟡 Medium Fixes

| # | Status | Issue | File(s) |
|---|:------:|-------|---------|
| 6 | ✅ Done | **Bookmarks reset on restart** — implemented secure persistent storage using `saveBookmarks` & `getBookmarks` via `FlutterSecureStorage` | `secure_storage.dart`, `http_event_repository.dart` |
| 7 | ✅ Done | **"Register for Online Event" button ignores in-person events** — dynamically toggles label and icon ("Register for Online Event" vs "Register for In-Person Event") | `event_details_screen.dart` |
| 8 | ✅ Done | **City filter "Online"/"Remote" broken** — changed filter logic to check `event.isOnline` boolean directly rather than fragile substring matching on location | `explore_provider.dart`, `popular_cities.dart` |
| 9 | ✅ Done | **Location change triggers full API re-fetch** — decoupled `eventsProvider` from watching `locationProvider` so GPS updates do not trigger heavy 273+ event re-fetches | `events_provider.dart` |
| 10 | ✅ Done | **No error state on Home screen** — added clear error card with "Retry Connection" button when backend API is unreachable instead of infinite shimmer skeleton | `home_screen.dart` |

---

## 🟢 Polish Fixes

| # | Status | Issue | File(s) |
|---|:------:|-------|---------|
| 11 | ✅ Done | **Map button shows snackbar** — converted misleading map button to disabled state with tooltip "Map View (Coming soon)" | `explore_results.dart` |
| 12 | ✅ Done | **Duplicate chip animation code** — extracted reusable `AnimatedFilterChip` widget, removing ~160 lines of copy-pasted animation logic | `animated_filter_chip.dart`, `explore_filter_chips.dart`, `popular_cities.dart` |
| 13 | ✅ Done | **"Continue Exploring" chip stays selected silently** — added dynamic "Clear filter" action button in the section header to reset explore filter anytime | `home_screen.dart`, `home_provider.dart` |

| 14 | ✅ Done | **Schedule lists empty for Today & Upcoming** — all 273 opportunities had null `timeline_json` falling back to 1970; populated real timestamps, added relative timeline parsing ("X days left"), active multi-day ongoing detection, and actionable "Explore Opportunities" navigation | `schedule_screen.dart`, `schedule_event_card.dart`, `http_event_repository.dart`, `opportunities.db` |

---

## Progress

- Critical: **6 / 6** done (100%)
- Medium: **5 / 5** done (100%)
- Polish: **3 / 3** done (100%)
- **Total: 14 / 14 (100% Completed & Verified)**
