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

- **Never read a file larger than 15KB** unless the command explicitly requires it
- **Read `solution.sdl.yaml`** — always fine (it's the source of truth, kept compact)
- **Read `_manifest.json` / `blueprint.json`** — fine (structured, compact)
- **Do NOT read `data-model.md`, `setup-env.md`, `security-architecture.md`, `application-architecture.md`** unless the current command is explicitly updating that file — these are large output artifacts, not inputs
- **Do NOT read `sprint-backlog.md`, `result.md`, `next-steps.md`** — these are summaries for humans, not AI inputs
- If you need entity names: read `solution.sdl.yaml` data section (compact)
- If you need API shape: read `solution.sdl.yaml` — not the generated api-docs

## Output Quality Rules

- Use tables instead of prose lists wherever possible (4x more information-dense)
- Do not repeat the same information in multiple sections
- Do not add filler headings like "Overview", "Introduction", "Background" — start with the content
- Do not add a "Next Steps" or "CTA" footer unless the command explicitly requires it
- Do not explain what you're about to do — just do it
