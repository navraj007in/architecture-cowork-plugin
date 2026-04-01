# /architect:review — Steps 5–8

_Part 2 of 2. Read review-index.md and review-1.md first._

---

## Step 5: Delegate to Reviewer Agent

For each component in `components_to_review`, invoke the `reviewer` agent (`agents/reviewer.md`).

Invoke each component's agent **independently** — a failure in one component's review must not block others. Collect all result objects before proceeding to Step 6.

### Input contract per invocation

```json
{
  "component_name": "api-server",
  "diff_content": "<full git diff text for this component>",
  "diff_source": "git-uncommitted",
  "pattern_fingerprint": {
    "runtime": "python",
    "framework": "fastapi",
    "folder_style": "flat-app",
    "route_style": "fastapi-router",
    "service_exists": true,
    "orm": "sqlalchemy",
    "validation": "pydantic",
    "error_format": {"detail": "string"},
    "import_style": "relative",
    "test_runner": "pytest",
    "test_location": "tests/",
    "naming": "snake_case",
    "language": "python",
    "logger": "structlog"
  },
  "sdl_context": {
    "auth_strategy": "jwt",
    "protected_routes": ["/orders", "/users/:id"],
    "component_boundaries": {
      "api-server": ["shared-lib"],
      "web-app": ["shared-lib"]
    }
  }
}
```

---

## Step 6: Aggregate Findings

Collect the findings arrays from all reviewer agent results. Then:

1. **Sort**: Blockers first → Warnings → Suggestions. Within each severity level, sort by file path (alphabetical) for readability.
2. **Deduplicate**: if the same file appears in multiple components' diffs (e.g., a shared type file), deduplicate by `file + line + check_id`. Keep the first occurrence.
3. **Count**: tally findings by component and by severity for the summary blocks.

---

## Step 7: Print the Report

### Finding format

One finding per line. No prose paragraphs.

```
<SEVERITY>  <component>/<relative-path>:<line>   <what is wrong> — <what to do>
```

- `<SEVERITY>` is `BLOCKER`, `WARNING`, or `SUGGEST`
- `<line>` is omitted when the finding applies to an entire file (e.g., missing test file)
- The "what to do" portion is a concrete action or minimal code snippet — not a generic recommendation
- The component name is the leading path segment so findings remain scoped when multiple components are reviewed

**Example output:**

```
BLOCKER  api-server/app/routers/orders.py:42     Missing auth check — GET /orders/:id fetches without verifying caller owns the order. Add ownership check before returning: `if order.user_id != current_user.id: raise HTTPException(403)`

BLOCKER  api-server/app/services/products.py:17  SQL injection via f-string — `f"SELECT * FROM products WHERE id={pid}"`. Use ORM: `db.query(Product).filter(Product.id == pid).first()`

WARNING  api-server/app/services/orders.py:88    `console.log` in service — replace with structlog: `logger.info("order_fetched", order_id=order_id)`

WARNING  api-server/tests/test_orders.py          No test for `get_order_by_id` — add: happy path, 404 not-found, 403 unauthorized caller

SUGGEST  api-server/app/services/orders.py:120   Stripe call inline in service — extract to `lib/stripe.py` to match existing `lib/mailer.py` pattern
```

### Summary block (per component)

Print immediately after that component's findings:

```
Review Summary — api-server [python / fastapi]
  Blockers:       2
  Warnings:       3
  Suggestions:    1
  Files reviewed: 6 (312 lines changed)
  Source:         git-uncommitted
```

### Combined total (when multiple components reviewed)

After all per-component summaries:

```
Total — 2 components reviewed
  Blockers:    3
  Warnings:    5
  Suggestions: 1
```

### Report file

Write the full report (all findings + summaries + Next Actions block) to `.archon/reviews/`. Create the directory if it does not exist.

| Mode | File path |
|------|----------|
| `uncommitted` | `.archon/reviews/<component>-review.md` |
| `file` | `.archon/reviews/<component>-review.md` |
| `all` (multiple components) | `.archon/reviews/<component>-review.md` per component |
| `pr` | `.archon/reviews/<component>-pr-<pr_number>.md` |

Format each file as a markdown document:
- Heading: `# Review — <component> [<runtime> / <framework>]`
- Sub-heading: `Source: <diff_source> — <ISO-8601 timestamp>`
- Then the findings, summary block, and Next Actions block exactly as printed to the conversation

Always write the file — for all modes, not just PR. This gives the developer a persistent record they can open in an editor, share, or link from a PR description.

### No findings

If all agents return zero findings:
```
No issues found in <component> [<runtime> / <framework>]
  Files reviewed: 6 (312 lines changed)
  Source:         git-uncommitted
```

### Next Actions block

Always append this block after the combined totals, even if `--fix` is not set. Format each finding as a ready-to-run `/architect:implement` command so the user can copy-paste directly.

**Construct the implement argument** from the finding's component, path, line, what-is-wrong, and what-to-do fields:

```
## Next Actions

**BLOCKERs — fix before merging:**
/architect:implement "Fix: <what is wrong> — <what to do> [<component>/<path>:<line>]"
/architect:implement "Fix: <what is wrong> — <what to do> [<component>/<path>:<line>]"

**WARNINGs — address this sprint:**
/architect:implement "Fix: <what is wrong> — <what to do> [<component>/<path>:<line>]"
... (list all WARNINGs)

**Suggestions — review and decide:**
- <component>/<path>:<line> — <what is wrong>
... (listed as plain text — too minor to auto-invoke)

Run /architect:review again after fixing BLOCKERs to verify resolution.
```

Rules for constructing the implement argument string:
- Keep it under 200 characters — truncate the "what to do" if needed, keeping the file:line reference intact
- Include `[component/path:line]` at the end so the implementer can locate the code without re-reading the report
- If a finding has no line number (file-level finding), use `[component/path]`
- Suggestions are listed as plain text, not as `/architect:implement` commands — they require developer judgement before acting

If there are zero BLOCKERs, omit the BLOCKERs section and open with WARNINGs. If zero findings total, omit the block entirely.

---

## Step 8: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"review","source":"git-uncommitted|git-pr-42|git-file","components":["api-server"],"outcome":"completed","blockers":2,"warnings":3,"suggestions":1,"files_reviewed":6,"lines_reviewed":312,"report":".archon/reviews/api-server-review.md","summary":"Review: 2 blockers, 3 warnings, 1 suggestion across api-server. Source: git-uncommitted."}
```

For multi-component reviews, `components` is the full array and the counts are combined totals.

`outcome` is `"completed"` when all agents returned a result (including zero findings). `"partial"` when one or more agents returned `outcome: "partial"` — list the affected components in the `summary` field.

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

---

## Step 9: Auto-Fix BLOCKERs (only when `auto_fix: true`)

Skip this step entirely if `auto_fix` is `false`.

If there are no BLOCKERs, print:
```
--fix: No BLOCKERs to fix. Review the WARNINGs above and run /architect:implement manually for any you want to address.
```
and stop.

Otherwise:

### 9a. Announce

```
--fix mode: fixing <N> BLOCKER(s) in sequence. WARNINGs and suggestions are left for manual review.
```

### 9b. Execute each BLOCKER fix sequentially

For each BLOCKER finding (in the order they appear in the report):

1. Print:
   ```
   Fixing [<N>/<total>]: <component>/<path>:<line> — <what is wrong>
   ```
2. Invoke the **implementer** agent (`agents/implementer.md`) with:
   ```json
   {
     "task": "Fix: <what is wrong> — <what to do>",
     "component": "<component>",
     "target_file": "<path>",
     "target_line": <line>,
     "context": "<full finding text from the report>",
     "mode": "fix"
   }
   ```
3. Wait for the implementer to complete before starting the next BLOCKER — fixes may be order-dependent (e.g., a security fix that changes a function signature that the next fix also touches).
4. If the implementer returns an error or marks the fix as `partial`, print a warning and continue to the next BLOCKER:
   ```
   ⚠ Fix [<N>/<total>] could not be fully applied — review manually: <component>/<path>:<line>
   ```

### 9c. Re-run review after all fixes

After all BLOCKERs are processed, re-run the review automatically (same scope, same mode, `auto_fix: false`) to verify the fixes didn't introduce new issues and the original BLOCKERs are resolved.

Print before re-running:
```
Re-running review to verify fixes...
```

If the re-review returns zero BLOCKERs:
```
✓ All BLOCKERs resolved. <N> warning(s) remain — see Next Actions above.
```

If BLOCKERs remain after re-review:
```
⚠ <N> BLOCKER(s) remain after auto-fix — manual intervention required:
  <list remaining BLOCKERs>
```

### 9d. Log --fix activity

Append a second entry to `_activity.jsonl` for the fix pass:
```json
{"ts":"<ISO-8601>","phase":"review-fix","blockers_attempted":<N>,"blockers_resolved":<M>,"blockers_remaining":<N-M>,"components":["api-server"],"outcome":"completed|partial","summary":"Auto-fixed <M>/<N> blockers in api-server. <N-M> require manual review."}
```
