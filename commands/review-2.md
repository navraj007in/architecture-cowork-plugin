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

### Report file (PR mode only)

When `review_mode` is `pr`, write the full report (all findings + summaries) to:
```
architecture-output/review-pr-<pr_number>.md
```

Format the file as a markdown document with a heading `# Review — PR #<N>` and the ISO-8601 timestamp. For all other modes, print to the conversation only — do not write a file.

### No findings

If all agents return zero findings:
```
No issues found in <component> [<runtime> / <framework>]
  Files reviewed: 6 (312 lines changed)
  Source:         git-uncommitted
```

---

## Step 8: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"review","source":"git-uncommitted|git-pr-42|git-file","components":["api-server"],"outcome":"completed","blockers":2,"warnings":3,"suggestions":1,"files_reviewed":6,"lines_reviewed":312,"summary":"Review: 2 blockers, 3 warnings, 1 suggestion across api-server. Source: git-uncommitted."}
```

For multi-component reviews, `components` is the full array and the counts are combined totals.

`outcome` is `"completed"` when all agents returned a result (including zero findings). `"partial"` when one or more agents returned `outcome: "partial"` — list the affected components in the `summary` field.

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.
