# Task Queue

> **Aggregated view of upcoming and in-progress tasks across all phases.**
> Updated by the agent when tasks are added, completed, or reordered.
> For detailed task checklists per phase, see `docs/phases/PHASE_XX.md`.

---

## Currently Active Tasks

> Tasks the agent should work on **right now**.

| # | Phase | Task | Status | Priority |
|---|:-----:|------|:------:|:--------:|
| 1 | 07 | Verify backend API is deployed and accessible | Not Started | High |
| 2 | 07 | Update `.env` with backend URL | Not Started | High |
| 3 | 07 | Implement auth API services & repository | Not Started | High |
| 4 | 07 | Implement events API services & repository | Not Started | High |
| 5 | 07 | Implement real bookmark CRUD & sync | Not Started | High |
| 6 | 07 | Implement real profile management endpoints | Not Started | High |

---

## Upcoming Tasks (Next Phase)

> Tasks from the next phase that will become active once the current phase is complete.

| # | Phase | Task | Priority |
|---|:-----:|------|:--------:|
| 1 | 08 | Implement Isar caching for events after fetch | High |
| 2 | 08 | Implement offline banner status check | Medium |
| 3 | 08 | Display cached events when disconnected | High |
| 4 | 08 | Queue bookmark mutations for background sync | High |

---

## Task Discovery Log

| Date | Phase | Task Added | Reason |
|------|:-----:|------------|--------|
| 2026-07-06 | 01 | 18 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 02 | 18 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 03 | 12 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 04 | 12 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 05 | 20 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 06 | 12 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 07 | 16 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 08 | 14 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 09 | 17 tasks planned | Initial phase planning from ROADMAP |
| 2026-07-06 | 10 | 18 tasks planned | Initial phase planning from ROADMAP |

> **Total planned tasks: 147**

---

## Notes

- This queue provides a cross-phase view. For the **authoritative task list** within a phase, always refer to `docs/phases/PHASE_XX.md`.
- Tasks are pulled from phase files. When a phase becomes active, its tasks move into "Currently Active Tasks".
- New tasks discovered during development are logged here with the reason for their late addition.
