# Archon Plugin — Global Rules

These rules apply to ALL commands in this plugin. They override any conflicting instruction.

## Output File Size Limits

Every generated output file MUST stay within these limits:

| File type | Max size |
|---|---|
| Any single `.md` deliverable | 15KB |
| Any single `.json` output | 8KB |
| ORM schema file | 10KB |
| Wireframe JSON spec | 2KB |

**If a deliverable would exceed the limit, split it:**
- Write a `{name}-summary.md` (key decisions + table of contents, ≤2KB)
- Write `{name}-{section}.md` for each section (e.g. `data-model-users.md`, `data-model-orders.md`)

## Read Budget Per Task

Before reading any file, check if you already have the information you need. Apply these rules:

- **Read `solution.sdl.yaml`** — always fine (source of truth, compact by design)
- **Read `_manifest.json` / `blueprint.json`** — fine (structured, compact)
- **For large output files** (`data-model.md`, `setup-env.md`, `security-architecture.md`, `application-architecture.md`, `sprint-backlog.md`): use **Grep** to extract only the section you need — do not read the full file
- **`result.md`, `next-steps.md`** — human summaries, do not read as AI inputs
- If a file is under 10KB, reading the full file is fine
- If a file is over 15KB, always use Grep first

## Output Quality Rules

- Use tables instead of prose lists wherever possible (4x more information-dense)
- Do not repeat the same information in multiple sections
- Do not add filler headings like "Overview", "Introduction", "Background" — start with the content
- Do not add a "Next Steps" or "CTA" footer unless the command explicitly requires it
- Do not explain what you're about to do — just do it
