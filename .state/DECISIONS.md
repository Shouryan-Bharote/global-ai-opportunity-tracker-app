# Decisions

> **Architectural and implementation decisions made during development.**
> These decisions are binding — future agents must follow them unless explicitly reversed.
> Updated by the agent when a significant decision is made.

---

## Active Decisions

| ID | Decision | Rationale | Date | Phase | Affects |
|----|----------|-----------|------|:-----:|---------|
| D01 | Feature-first architecture (not layer-first) | AI agents work better with isolated features. Each feature contains its own data, models, providers, and presentation. | 2026-07-06 | — | All phases |
| D02 | Riverpod for state management | Modern, compile-time safe, feature-scoped providers. | 2026-07-06 | — | All phases |
| D03 | GoRouter for navigation | Declarative routing with auth redirect and ShellRoute support. | 2026-07-06 | — | All phases |
| D04 | Freezed + json_serializable for models | Immutable models with code-generated JSON parsing. | 2026-07-06 | — | All phases |
| D05 | Isar for offline cache | Fast NoSQL local database ideal for caching event documents. | 2026-07-06 | — | Phase 02, 08 |
| D06 | Mock data strategy for Phases 1–6 | Mobile can be fully built without backend. Mock repositories swap for real ones with a single provider change. | 2026-07-06 | — | Phase 01–07 |
| D07 | Reusable Event Details screen at `/events/:id` | Single screen shared from Home, Explore, Schedule, Notifications. Never duplicate. | 2026-07-06 | — | Phase 04, 06 |
| D08 | JWT tokens stored in flutter_secure_storage | Secure storage for auth tokens. Auth interceptor attaches token to all requests. | 2026-07-06 | — | Phase 02, 03 |
| D09 | Cached Hybrid scraping approach (backend team) | 99% of scrapes use cached selectors; LLM only invoked for repair. | 2026-07-06 | — | Backend (context) |
| D10 | very_good_analysis for linting | Strict, consistent code quality rules across the codebase. | 2026-07-06 | — | All phases |
| D11 | Repository pattern with abstract `EventRepository` interface | All data access goes through `EventRepository`. Swapping mock for real backend requires changing only `repository_providers.dart`. UI code never touches data sources directly. | 2026-07-16 | 05 | Phase 05–10 |
| D12 | Conditional Isar compilation for Web compatibility | Auto-generated Isar code has large 64-bit integer values that fail JavaScript representation on web targets. Use conditional exports to stub IsarService on Web, allowing compilation. | 2026-07-16 | 05 | All phases |
| D13 | Profile metric shift & My Tickets removal | Removed the confusing "My Tickets" barcode/passes layout and changed the "Attended" metric to "Interests" count. The app aggregates third-party listings where tickets are not issued internally. | 2026-07-16 | 07 | Phase 07 |
| D14 | Pinned AppHeader inside AppShell viewport | Migrated AppHeader into AppShell so that it is fixed globally at the top of the viewport. Sub-screen layouts can scroll underneath without duplicating headers. | 2026-07-16 | 07 | Phase 07 |
| D15 | Native image picker and system share sheet integration | Integrated `image_picker` for custom avatar selection and `share_plus` to invoke Android/iOS system-level share dialogs with dynamic event info. | 2026-07-16 | 07 | Phase 07 |
| D16 | Disable Kotlin incremental compilation & upgrade compileSdk | Set `kotlin.incremental=false` to fix Windows relative path cross-drive conflicts, and set `compileSdk=36` to satisfy package dependencies. | 2026-07-16 | 07 | All phases |
| D17 | Canonical Firestore `OpportunityModel` & Direct Firestore SDK | Migrated Flutter domain model from legacy mock `EventModel` to canonical backend Pydantic `Opportunity` contract and Firestore `opportunities` collection (`FirestoreOpportunityRepository`). Handled camelCase/snake_case boundary, defensive Timestamp/ISO date parsing, and safe enum fallbacks. | 2026-08-23 | 07 | Phase 07, Explore, Home, Schedule |


---

## Reversed Decisions

| ID | Decision | Reversed On | Reason | What Replaced It |
|----|----------|-------------|--------|-----------------|
| — | — | — | — | — |

---

## Decision Categories

### Architecture
- D01 — Feature-first module structure
- D02 — Riverpod state management
- D03 — GoRouter navigation
- D14 — Pinned AppHeader inside AppShell viewport

### Data Layer
- D04 — Freezed models
- D05 — Isar local cache
- D08 — Secure token storage
- D11 — Repository pattern (abstract interface + DI swap)
- D12 — Conditional compilation for Isar stub on Web

### Development Process
- D06 — Mock data before backend
- D10 — Strict linting
- D16 — Disable Kotlin incremental compilation & upgrade compileSdk to 36

### UI
- D07 — Reusable event details screen
- D13 — Profile metric shift & My Tickets removal
- D15 — Native image picker and system share sheet integration

### Backend (Context Only)
- D09 — Cached hybrid scraping

---

## Notes

- When making a decision that contradicts an existing one, document it in "Reversed Decisions" — do not silently ignore previous decisions.
- Each decision should include enough rationale that a future agent understands **why** it was made.
- Decisions marked "All phases" affect every future phase. Decisions marked for specific phases are scoped.
- Backend decisions (D09) are recorded here for context only — the mobile agent cannot change them.
