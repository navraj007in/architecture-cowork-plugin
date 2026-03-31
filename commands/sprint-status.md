---
description: Show current sprint progress by cross-referencing backlog with activity logs
---

# /architect:sprint-status

## Trigger

`/architect:sprint-status`

## Purpose

Reads the sprint backlog markdown from `architecture-output/sprint-backlog.md` (or split files), then cross-references story titles against the project's `_activity.jsonl` logs using keyword matching to estimate completion status. Reports done, in-progress, and pending stories with percentage complete.

## Workflow

### Step 1: Find sprint backlog

Look for sprint backlog files in `architecture-output/`:
- `sprint-backlog.md`
- `sprint-backlog-1.md`, `sprint-backlog-2.md`, etc.
- If none found, inform the user and suggest running `/architect:blueprint`

### Step 2: Parse stories

Extract all checklist items from the backlog:
- `- [ ] Story title` → pending
- `- [x] Story title` → check against activity for confirmation

### Step 3: Read activity logs

Read `architecture-output/_activity.jsonl` and all `<component>/_activity.jsonl` files. Collect all `filesCreated` entries (scaffold writes `filesCreated`, not `filesChanged`).

### Step 4: Keyword matching

For each story, extract keywords (words > 3 chars). Match against activity file paths and summaries:
- 0 matches → **pending**
- 1 match → **in-progress**
- 2+ matches → **done**

### Step 5: Report

Print a progress table:

```
Sprint: Sprint 1 — Core Features

| # | Story | Status | Matched Files |
|---|-------|--------|---------------|
| 1 | User authentication | ✅ done | auth.ts, login.tsx +2 |
| 2 | Product catalog | 🔄 in-progress | products.ts |
| 3 | Checkout flow | ⏳ pending | — |

Progress: 1/3 done (33%)
```

## Output Rules

- Use the **founder-communication** skill for tone
- Do NOT include the CTA footer
- Keep the analysis lightweight — this is a heuristic, not a git blame
