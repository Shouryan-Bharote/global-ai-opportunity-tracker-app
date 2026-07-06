# AI Progress Rules

> **Mandatory rules for every AI coding agent working on this repository.**
>
> These rules exist to ensure continuity between sessions, prevent lost work, and keep documentation synchronized with the codebase. **Every agent must follow these rules without exception.**

---

## Table of Contents

1. [Before Starting Work](#before-starting-work)
2. [During Development](#during-development)
3. [After Completing Work](#after-completing-work)
4. [Never](#never)
5. [Handoff Requirements](#handoff-requirements)
6. [Documentation Priority](#documentation-priority)
7. [Phase Status Definitions](#phase-status-definitions)
8. [Task Status Definitions](#task-status-definitions)

---

## Before Starting Work

**Every AI agent MUST complete these steps before writing any code:**

### Step 1 — Read the Roadmap

```
Read: docs/ROADMAP.md
```

Understand the current state of the project. Identify which phase is active, which are completed, and which are blocked.

### Step 2 — Identify the Active Phase

Find the phase marked as **In Progress** in `ROADMAP.md`. If no phase is In Progress:

- If there are **Not Started** phases, the first Not Started phase becomes the active phase.
- If all phases are **Completed**, the project is finished — report this to the user.

### Step 3 — Read the Phase File

```
Read: docs/phases/PHASE_XX.md
```

Read the **entire** phase file — not just the checklist. Pay special attention to:

- **Completed Work** — know what previous agents already built.
- **Current Work** — know what was being worked on when the last session ended.
- **Remaining Work** — know what is left to do.
- **Blockers** — check if anything is preventing progress.
- **Decisions Made** — respect architectural decisions made by previous agents.
- **Notes For Next Agent** — **this is the most important section**. It contains exactly what you need to continue.

### Step 4 — Understand Unfinished Tasks

Review the task checklist in `PHASE_XX.md`. Identify:

- Tasks marked **Not Started** that are ready to begin.
- Tasks marked **In Progress** that may need continuation.
- Tasks marked **Blocked** and their blockers.

### Step 5 — Continue Existing Work

**Do NOT duplicate work.** If another agent has already completed part of a task, read their code first. If a task is marked **In Progress**, check the codebase to see how far it got before continuing.

```mermaid
flowchart TD
    Start([Agent Session Starts]) --> R1[Read ROADMAP.md]
    R1 --> R2[Identify active phase]
    R2 --> R3[Read PHASE_XX.md]
    R3 --> R4[Read "Notes For Next Agent"]
    R4 --> R5[Review completed work + current code]
    R5 --> R6{Work already started?}
    R6 -->|Yes| R7[Continue existing work]
    R6 -->|No| R8[Start next unblocked task]
    R7 --> Dev[Write code]
    R8 --> Dev
```

---

## During Development

**Whenever the AI completes meaningful work, it MUST:**

### Update Task Statuses

- Change task status from `Not Started` → `In Progress` when beginning work on a task.
- Change task status from `In Progress` → `Completed` when a task is fully finished and verified.

### Mark Completed Items

- Check off completed items in the task checklist.
- Update the completion percentage for the phase.

### Add Newly Discovered Tasks

If work reveals tasks that were not in the original checklist:

1. Add them to the task checklist with status `Not Started`.
2. Assign appropriate priority.
3. Add a note explaining why the task was discovered late.

### Record Implementation Decisions

If you make an architectural or implementation decision that a future agent needs to know about:

1. Add it to the **Decisions Made** section.
2. Include the **decision**, **rationale**, and **date**.
3. If the decision affects other phases, note that explicitly.

### Record Blockers

If you encounter anything preventing progress:

1. Add it to the **Blockers** section.
2. Describe the blocker clearly.
3. Suggest a potential resolution if possible.
4. If the blocker affects the phase status, update `ROADMAP.md` to mark the phase as `Blocked`.

### Record Modified Files

When you create or modify files, note them in the **Completed Work** log with the date and a brief description of what was done.

### Record Important Notes for Future Agents

Use the **Notes For Next Agent** section to leave context. This should answer:

- ✅ What was done and why
- ✅ What remains and in what order
- ✅ Any warnings or pitfalls discovered
- ✅ Assumptions made
- ✅ Suggestions for the next agent
- ❌ Do NOT include overly verbose descriptions — be concise and actionable

---

## After Completing Work

**Before ending a session, every AI agent MUST:**

### 1. Update PHASE_XX.md

Update **all** of the following sections in the active phase file:

| Section | What to Update |
|---------|---------------|
| **Task Checklist** | Mark completed tasks, update statuses |
| **Completed Work** | Add entries with date, description, and files modified |
| **Current Work** | Clear this section (you are no longer working) or describe the last thing you were doing if interrupted |
| **Remaining Work** | Update to reflect what is genuinely left |
| **Blockers** | Update blocker list (add/remove/resolve) |
| **Decisions Made** | Add any new decisions |
| **Notes For Next Agent** | **Rewrite this entire section** with current context |
| Completion Percentage | Recalculate based on tasks completed / total tasks |

### 2. Update ROADMAP.md (Only If Phase Status Changed)

Update `ROADMAP.md` **only** when the overall status of a phase changes:

| Change | When to Update |
|--------|---------------|
| Phase: `Not Started` → `In Progress` | When the first task in the phase begins |
| Phase: `In Progress` → `Completed` | When ALL tasks in the phase are completed and verified |
| Phase: `In Progress` → `Blocked` | When a critical blocker prevents all progress |
| Phase: `Blocked` → `In Progress` | When the blocker is resolved |
| Milestone achieved | When a milestone is reached |
| Changelog | Add an entry describing what changed |

**Do NOT** update `ROADMAP.md` for individual task completions within a phase. Only update it for phase-level status changes.

---

## Never

**The following actions are strictly prohibited for all AI agents:**

| ❌ Rule | Why |
|--------|-----|
| **Never delete historical progress** | Past entries in "Completed Work" are the project's history. They must be preserved. |
| **Never remove completed logs** | A completed task log tells future agents what was built and when. Removing it destroys context. |
| **Never overwrite another agent's notes** | Append your notes. If you need to update the "Notes For Next Agent" section, rewrite it completely but reference what the previous agent did. |
| **Never mark work as complete without verification** | Only mark a task `Completed` if you have tested or verified that it works. "I wrote the code" is not sufficient — "I wrote the code and verified it builds/runs" is. |
| **Never skip documentation updates after development** | Documentation must always reflect the current state of the codebase. Updating docs is part of the work, not optional. |
| **Never start work in a new phase without updating the previous phase's docs** | Before moving to the next phase, ensure the current phase file is fully updated. |
| **Never modify files outside your assigned scope** | Unless explicitly instructed, work only within the feature/phase you were assigned. |
| **Never edit auto-generated files manually** | Files in `gen/`, `.dart_tool/`, or generated by `build_runner` must never be hand-edited. |
| **Never hardcode values that should be constants** | Use the constants defined in `core/constants/` or `core/theme/`. |
| **Never create duplicate implementations** | Check if a widget, provider, or utility already exists before creating a new one. |

---

## Handoff Requirements

**Before ending a session, every AI agent must ensure the next agent can continue immediately without reading the entire repository.**

### The handoff must answer these questions:

| Question | Where It Lives |
|----------|---------------|
| What phase are we in? | `ROADMAP.md` — "Current Active Phase" |
| What was just completed? | `PHASE_XX.md` — "Completed Work" |
| What should I work on next? | `PHASE_XX.md` — "Notes For Next Agent" |
| Are there any blockers? | `PHASE_XX.md` — "Blockers" |
| Were any decisions made? | `PHASE_XX.md` — "Decisions Made" |
| What files were changed? | `PHASE_XX.md` — "Completed Work" (column) |

### Handoff checklist before ending:

- [ ] All task statuses are accurate
- [ ] "Completed Work" log has today's entries
- [ ] "Notes For Next Agent" is freshly written
- [ ] "Remaining Work" is updated
- [ ] Blockers are documented (if any)
- [ ] `ROADMAP.md` is updated (if phase status changed)
- [ ] The project builds with no errors (`flutter analyze` clean)

---

## Documentation Priority

### Rule: Documentation truth > Code truth

Whenever documentation becomes inconsistent with the repository, the AI agent should:

1. **Determine which is correct:**
   - If the **code** is correct (recent work changed the structure), update the documentation to match.
   - If the **documentation** is correct (code was changed incorrectly), fix the code to match the documentation.

2. **Update documentation before ending the session:**
   - If a new file was created that's not mentioned in the docs, add it.
   - If a file was renamed or moved, update all references.
   - If a new dependency was added, update `MODULE1_MOBILE_OVERVIEW.md` tech stack table.
   - If the directory structure changed, update `CODEBASE_GUIDE.md`.

3. **Prefer updating existing docs over creating new ones:**
   - Add entries to existing checklists rather than creating new documents.
   - Append to existing "Notes" sections rather than writing parallel documents.

### Inconsistency Detection

During work, if you notice any of these inconsistencies, fix the documentation:

| Inconsistency | Fix |
|--------------|-----|
| `ROADMAP.md` says phase is "Completed" but tasks are not all checked | Update phase status to "In Progress" |
| `CODEBASE_GUIDE.md` shows a file path that doesn't exist | Update the path to match actual structure |
| `ARCHITECTURE.md` describes a pattern not used in the code | Update the doc or note the deviation in Decisions Made |
| `FEATURES_AND_FLOWS.md` describes a screen that doesn't match the implementation | Update the doc or note the change |
| `pubspec.yaml` has a dependency not listed in `MODULE1_MOBILE_OVERVIEW.md` | Add it to the tech stack table |

---

## Phase Status Definitions

Use these exact status values in `ROADMAP.md`:

| Status | Emoji | Definition | When to Set |
|--------|:-----:|------------|-------------|
| **Not Started** | ⚪ | No work has been committed for this phase. No files created or modified. | Initial state, or when phase is reset |
| **In Progress** | 🔵 | At least one task is being actively worked on or has been completed. | When the first task begins |
| **Blocked** | 🔴 | A critical blocker prevents any progress on this phase. | When an external dependency is unavailable |
| **Completed** | 🟢 | All tasks are completed, verified, and documented. Phase file is fully updated. | When all tasks pass verification |

---

## Task Status Definitions

Use these exact status values in `PHASE_XX.md` task checklists:

| Status | Definition | When to Set |
|--------|------------|-------------|
| **Not Started** | The task has not been started. No code written. | Initial state |
| **In Progress** | Work on this task has begun but is not complete. | When coding begins on the task |
| **Blocked** | This task cannot proceed due to a dependency or external issue. | When a specific blocker is identified |
| **Completed** | The task is fully implemented, tested/verified, and documented. | When the task is verified working |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│           AI AGENT SESSION CHECKLIST                │
├─────────────────────────────────────────────────────┤
│ START OF SESSION:                                   │
│   ☐ Read docs/ROADMAP.md                           │
│   ☐ Read docs/phases/PHASE_XX.md                   │
│   ☐ Read "Notes For Next Agent"                    │
│   ☐ Review completed work and current code         │
│   ☐ Continue existing work (don't duplicate)        │
│                                                      │
│ DURING WORK:                                        │
│   ☐ Update task statuses as you go                  │
│   ☐ Record decisions, blockers, new tasks            │
│   ☐ Note modified files                             │
│                                                      │
│ END OF SESSION:                                     │
│   ☐ Update PHASE_XX.md (all sections)               │
│   ☐ Update ROADMAP.md (if phase status changed)    │
│   ☐ Write fresh "Notes For Next Agent"             │
│   ☐ Verify project builds (flutter analyze)        │
│   ☐ Fix any doc ↔ code inconsistencies            │
└─────────────────────────────────────────────────────┘
```

---

## File Reference

| Document | Path | Updated By |
|----------|------|-----------|
| Master Roadmap | `docs/ROADMAP.md` | Agent (only on phase status change) |
| Phase Details | `docs/phases/PHASE_XX.md` | Agent (every session) |
| Project Overview | `docs/PROJECT_OVERVIEW.md` | Agent (when project scope changes) |
| Architecture | `docs/ARCHITECTURE.md` | Agent (when patterns change) |
| Codebase Guide | `docs/CODEBASE_GUIDE.md` | Agent (when structure changes) |
| Features & Flows | `docs/FEATURES_AND_FLOWS.md` | Agent (when screens/features change) |
| Module Overview | `docs/MODULE1_MOBILE_OVERVIEW.md` | Agent (when tech stack/dependencies change) |
| Dev Workflow | `docs/DEVELOPMENT_WORKFLOW.md` | Agent (when process changes) |
| **This Document** | `docs/AI_PROGRESS_RULES.md` | Human (only) |
