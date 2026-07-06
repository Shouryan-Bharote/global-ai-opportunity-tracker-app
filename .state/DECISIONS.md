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

### Data Layer
- D04 — Freezed models
- D05 — Isar local cache
- D08 — Secure token storage

### Development Process
- D06 — Mock data before backend
- D10 — Strict linting

### UI
- D07 — Reusable event details screen

### Backend (Context Only)
- D09 — Cached hybrid scraping

---

## Notes

- When making a decision that contradicts an existing one, document it in "Reversed Decisions" — do not silently ignore previous decisions.
- Each decision should include enough rationale that a future agent understands **why** it was made.
- Decisions marked "All phases" affect every future phase. Decisions marked for specific phases are scoped.
- Backend decisions (D09) are recorded here for context only — the mobile agent cannot change them.
