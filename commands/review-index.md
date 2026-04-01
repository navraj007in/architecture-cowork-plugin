---
description: Review code changes against the project's own patterns and best practices — pattern conformance, production hardening, security surface scan, test coverage, architecture fitness
---

# /architect:review

## Trigger

`/architect:review [component] [--pr <N>] [:<file>] [--fix]`

## Arguments

| Form | Example | Behaviour |
|------|---------|-----------|
| `[component]` | `api-server` | Review all uncommitted changes in that component |
| `[component] --pr <N>` | `api-server --pr 42` | Review the diff of a specific PR (requires `gh` CLI) |
| `[component]:<file>` | `api-server:app/routers/orders.py` | Review one specific file |
| _(no argument)_ | `/architect:review` | Review all components that have uncommitted changes |
| `--fix` | `api-server --fix` | After printing the report, auto-invoke `/architect:implement` for every BLOCKER in sequence |

## Purpose

Reviews actual code changes (git diff, PR diff, or a specific file) against the project's own patterns and best practices. Surfaces actionable findings with file path, line reference, what is wrong, and what to do — organised by severity.

Sits in the development lifecycle between **implement** and **ship**:

```
scaffold → implement → review → ship
```

## Out of Scope

This command will NOT (unless `--fix` is passed):
- Modify any project file — review is strictly read-only without `--fix`
- Run automated fixes or refactors — it flags issues for the developer to resolve
- Perform the deep security pass that `/architect:security-scan` does — it does a lighter OWASP surface scan on the diff only
- Assess high-level architectural pillars (reliability, deployment, observability) — use `/architect:well-architected` for that
- Run build or test commands — it reviews code, not execution
- Review files outside the diff scope — for a full codebase scan use `/architect:security-scan`
- Implement multiple components simultaneously — each component is reviewed independently

**Conflict protocol:** if the diff contains a change that breaks an existing function signature or refactors shared logic outside the diff's own files, flag it as a Warning with a description of the downstream impact. Do not attempt to assess files outside the diff.

## Workflow

This command is split across two files for size:

- **Steps 1–4** (argument parsing, diff acquisition, context loading, fingerprint detection): `commands/review-1.md`
- **Steps 5–8** (reviewer agent delegation, aggregation, report output, activity log): `commands/review-2.md`

Read `review-1.md` first, then `review-2.md`. For each component in scope, delegate to the **reviewer** agent (`agents/reviewer.md`) so a failure in one component does not block others.

## Output Files

Review reports are written to `.archon/reviews/` — not `architecture-output/`. This keeps operational dev-workflow artifacts separate from core architecture deliverables.

| Mode | Output file |
|------|------------|
| `uncommitted` | `.archon/reviews/<component>-review.md` |
| `file` | `.archon/reviews/<component>-review.md` |
| `all` | `.archon/reviews/<component>-review.md` per component reviewed |
| `pr` | `.archon/reviews/<component>-pr-<N>.md` |

Create `.archon/reviews/` if it does not exist. Never write review output to `architecture-output/`.

## _state.json Write Behaviour

`review` writes to `_activity.jsonl` only. It does not modify `_state.json`. Findings describe a transient diff state and have no value as persistent project facts.

When `--fix` is passed, each BLOCKER fix is logged separately by the implementer agent as it would be for a normal `/architect:implement` invocation.
