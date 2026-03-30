# Archon Plugin — Global Rules

These rules apply to ALL commands in this plugin.

## Output File Splitting

Generate architecture output in **full detail — never be vague or truncate content**.

When a deliverable is large, split it across multiple files rather than reducing detail:

| Deliverable | Split pattern |
|---|---|
| `data-model.md` | `data-model-1.md`, `data-model-2.md`, … (group by domain/module) |
| `security-architecture.md` | `security-architecture-auth.md`, `security-architecture-network.md`, … |
| `application-architecture.md` | `application-architecture-backend.md`, `application-architecture-frontend.md`, … |
| `sprint-backlog.md` | `sprint-backlog-1.md`, `sprint-backlog-2.md`, … (one file per sprint or sprint group) |
| `setup-env.md` | `setup-env-services.md`, `setup-env-local.md`, … |
| ORM schemas | `schema-{domain}.prisma` per domain (e.g. `schema-auth.prisma`, `schema-orders.prisma`) |
| Any other deliverable | `{name}-{section}.md` or `{name}-{N}.md` |

**Always write an index file** when splitting: `{name}-index.md` listing what each part contains and which entities/topics are in each file. This is the file other commands should read first.

**Split threshold**: if a single file would exceed ~15KB of content, split it. There is no upper limit on total output size — generate everything in full detail.

## Read Strategy for Large Outputs

When reading a deliverable that has been split:
1. Read the `{name}-index.md` first to locate the relevant section
2. Read only the specific part file(s) that contain what you need
3. Use Grep on a part file if you need a specific entity/section within it

When reading any output file that has NOT been split but is large (>15KB):
- Use Grep to extract the relevant section rather than reading the entire file

**Always fine to read in full:** `solution.sdl.yaml`, `_manifest.json`, `blueprint.json`, any file under 10KB.

## Output Quality Rules

- Generate **complete, detailed output** — no placeholders, no "see documentation", no truncation
- Use tables for structured data (entities, endpoints, config, comparisons) — more information-dense than prose
- Do not add filler headings ("Overview", "Introduction", "Background") — start with the content
- Do not add "Next Steps" or CTA footers unless the command explicitly requires it
- Do not explain what you're about to do — just do it
- Do not repeat the same information across sections or files
