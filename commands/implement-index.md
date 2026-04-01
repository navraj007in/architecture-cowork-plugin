---
description: Implement a specific feature or user story into an already-scaffolded codebase — route, service, model, migration stub, and tests
---

# /architect:implement

## Trigger

`/architect:implement <story-id | feature-description>`

## Arguments

| Format | Example | Resolution |
|--------|---------|-----------|
| Story ID | `S1.3`, `Story 2.4`, `US-42` | Looked up in `architecture-output/sprint-backlog.md` |
| Scoped feature | `api-server:password-reset` | Component name + feature slug |
| Free-text | `"add email notification on order placed"` | Normalized to feature slug |

## Purpose

Implements one feature end-to-end into a codebase that was bootstrapped by `/architect:scaffold` or `/architect:scaffold-component`. Reads the codebase first to match its exact patterns. Never overwrites working code. Never refactors architecture. One story per invocation.

This is the **iterative development** command — it operates on existing code, not fresh directories.

## Out of Scope

This command will NOT:
- Rename, move, or restructure existing files
- Change existing function signatures
- Refactor logic unrelated to the feature being implemented
- Run database migrations (produces the migration file, documents the manual step)
- Bootstrap a new component from scratch — use `/architect:scaffold-component`
- Implement multiple stories in one invocation
- Touch files not in the write plan

**Conflict protocol:** If implementing the feature requires changing an existing signature or refactoring shared logic, stop, explain the conflict, and tell the developer what to resolve manually before re-invoking.

## Workflow

This command is split across two files for size:

- **Steps 1–4** (story resolution, context, pattern detection, write plan): `commands/implement-1.md`
- **Steps 5–9** (file writing, wiring, build verification, summary, activity log): `commands/implement-2.md`

Read `implement-1.md` first, then `implement-2.md`. For components with more than one runtime, delegate each component to the **implementer** agent (`agents/implementer.md`) so build failures in one component do not block another.

## _state.json Write Behavior

`implement` writes to `_activity.jsonl` only. Exception: if the feature introduces a new entity (new table, new model class), append to `_state.json.entities` — field name `entities`, append only, do not overwrite other entries.
