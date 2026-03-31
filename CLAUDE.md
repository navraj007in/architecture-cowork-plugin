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

## Reading SDL — Single-File and Multi-File Format

SDL can be stored in two ways. **Always check both:**

1. **Single file** (default): `solution.sdl.yaml` at the project root — read this first
2. **Multi-file** (large projects): a `sdl/` directory with module files (`sdl/core.yaml`, `sdl/services.yaml`, `sdl/data.yaml`, etc.) — if `solution.sdl.yaml` is missing or if `sdl/` exists alongside it, read `sdl/README.md` first to understand the module layout, then read the relevant module files

**When reading SDL for a specific concern** (e.g., only need `data` section for data-model generation): check `sdl/data.yaml` directly if the `sdl/` directory exists — faster than reading the full merged file.

**The authoritative single-file SDL is always `solution.sdl.yaml` at the project root.** The `sdl/` directory is for human readability; the merged root file is what tooling uses.

**Global SDL reading procedure** (all commands follow this):
1. Check for `solution.sdl.yaml` in the project root — if it exists, use it
2. If `solution.sdl.yaml` is missing, check for an `sdl/` directory — if it exists, read `sdl/README.md` first, then read the relevant module files
3. Never read a file named `sdl.yaml` — this is a legacy filename. If found, treat it as `solution.sdl.yaml`
4. When reading SDL for a specific concern (e.g., only `auth` section), use Grep on `solution.sdl.yaml` rather than reading the full file

## Design State — _state.json.design is Authoritative

If `_state.json.design` is fully populated (has `primary`, `heading_font`, `body_font`, `personality`), it is the **authoritative source for all design decisions**. Commands MUST use it verbatim — never derive, re-invent, or override design direction from domain heuristics or training defaults.

Only derive design from domain when `_state.json.design` is absent AND no `design-tokens.json` exists.

## _state.json — AI Context Layer

`architecture-output/_state.json` is a compact machine-readable file that accumulates structured facts from every command that runs. It is the **first thing to read** when you need project context — cheaper than reading SDL or large markdown files.

### Schema

```json
{
  "project": { "name": "...", "description": "...", "type": "app|agent|hybrid", "stage": "concept|mvp|growth" },
  "tech_stack": {
    "frontend": ["Next.js 14", "Tailwind CSS"],
    "backend": ["Node.js", "Express", "Prisma"],
    "database": "PostgreSQL",
    "auth": "Clerk",
    "deployment": "Vercel + Railway",
    "integrations": ["Stripe", "SendGrid", "Sentry"]
  },
  "components": [
    { "name": "web-app", "type": "web", "port": 3000, "framework": "Next.js" }
  ],
  "entities": [
    { "name": "User", "fields": ["id", "email", "name", "role", "createdAt"], "owner": "api-server" }
  ],
  "personas": [
    { "name": "Sarah Chen", "role": "Procurement Manager", "priority": "P1", "top_pain": "3h/week reconciling invoices manually" }
  ],
  "market_research": {
    "competitors": [{ "name": "Coupa", "pricing": "$50k+/yr", "weakness": "too expensive for SMBs" }],
    "market_size": "$2.5B TAM, 14% CAGR",
    "key_insight": "70% of SMBs still use spreadsheets for procurement"
  },
  "mvp_scope": {
    "must_have": ["user auth", "vendor catalog", "order management"],
    "wont_have": ["mobile app", "AI recommendations"]
  },
  "top_risks": [
    { "id": "R-001", "title": "PMF risk — buyers won't switch from spreadsheets", "score": 20, "level": "Critical" }
  ],
  "design": {
    "personality": "bold-commercial",
    "primary": "#f97316",
    "primary_dark": "#ea580c",
    "secondary": "#0ea5e9",
    "accent": "#fbbf24",
    "surface": "#ffffff",
    "surface_elevated": "#f8fafc",
    "text_primary": "#0f172a",
    "text_secondary": "#64748b",
    "border_radius": "8px",
    "shadow": "0 1px 3px rgba(0,0,0,0.12)",
    "heading_font": "Clash Display",
    "body_font": "Poppins",
    "mono_font": "JetBrains Mono",
    "icon_library": "lucide-react",
    "component_library": "shadcn/ui",
    "tokens_file": "architecture-output/design-system/design-tokens.json"
  }
}
```

### Schema Enforcement Rules

These field names are canonical. Commands MUST use exactly these names — no aliases, no camelCase variants:

| Field path | Type | Notes |
|------------|------|-------|
| `project.name` | string | |
| `project.description` | string | |
| `project.type` | `"app"\|"agent"\|"hybrid"` | |
| `project.stage` | `"concept"\|"mvp"\|"growth"\|"enterprise"` | |
| `tech_stack.frontend` | string[] | |
| `tech_stack.backend` | string[] | |
| `tech_stack.database` | string | |
| `tech_stack.auth` | string | identity provider name |
| `tech_stack.deployment` | string | |
| `tech_stack.integrations` | string[] | |
| `components[].name` | string | |
| `components[].type` | string | |
| `components[].port` | number | |
| `components[].framework` | string | |
| `design.personality` | string | |
| `design.primary` | string | hex — NOT `primary_color` |
| `design.primary_dark` | string | hex |
| `design.secondary` | string | hex |
| `design.accent` | string | hex |
| `design.surface` | string | hex |
| `design.surface_elevated` | string | hex |
| `design.text_primary` | string | hex |
| `design.text_secondary` | string | hex |
| `design.border_radius` | string | e.g. `"8px"` — NOT `borderRadius` |
| `design.shadow` | string | CSS shadow value |
| `design.heading_font` | string | snake_case — NOT `headingFont` |
| `design.body_font` | string | snake_case — NOT `bodyFont` |
| `design.mono_font` | string | snake_case — NOT `monoFont` |
| `design.icon_library` | string | snake_case — NOT `iconLibrary` |
| `design.component_library` | string | snake_case — NOT `componentLibrary` |
| `design.tokens_file` | string | relative path |
| `blueprint.deepen_passes` | number | starts at 0 |

Any command that reads a field must use the exact name above. Any command that writes a field must use the exact name above. There are no acceptable aliases.

### Read rules

- **Always check `_state.json` first** before reading large markdown files
- If `_state.json` exists: read it in full (always under 15KB), use its facts directly
- If `_state.json` is missing: fall back to `solution.sdl.yaml` and `intent.json`
- `_state.json` does NOT replace `solution.sdl.yaml` — SDL is authoritative for architecture spec. `_state.json` holds research outputs (competitors, personas, risks, MVP scope) that SDL doesn't contain
- For deep detail not in `_state.json`: use Grep on the relevant markdown file

### Write rules

Commands that generate output MUST update `_state.json` after writing their markdown deliverable:
1. Read existing `_state.json` (or start with `{}` if it doesn't exist)
2. Merge only the fields this command owns (do NOT overwrite other fields)
3. Write back to `architecture-output/_state.json`

| Command | Fields it writes |
|---------|-----------------|
| `import` | `project`, `tech_stack`, `components`, `design` (from reverse-engineered SDL) |
| `blueprint` | `project`, `tech_stack`, `components`, `design` (initial values from SDL), `blueprint.deepen_passes` |
| `sdl` | `project`, `tech_stack` (Mode 1 generate only) |
| `design-system` | `design` (full palette, fonts, tokens — overwrites blueprint's initial values) |
| `generate-data-model` | `entities` |
| `user-personas` | `personas` |
| `deep-research` | `market_research` |
| `mvp-scope` | `mvp_scope` |
| `risk-register` | `top_risks` |
| `prototype` | `prototype` (`screens`, `personality`, `component_library`, `complete`) |
| `prototype-iterate` | `prototype.screens` (updates screen count only) |
| `sync-backlog` | `backlog_sync` (`platform`, `synced_at`, `sprints`, `stories`, `board_url`) |
| `technical-roadmap` | `roadmap` (`generated_at`, `phases`) |
| `problem-validation` | `problem_validation` (`generated_at`, `validated`) |
| `user-journeys` | `user_journeys` (`generated_at`, `journey_count`) |
| `launch-checklist` | `launch_checklist` (`generated_at`, `item_count`) |
| `pitch-deck` | `pitch_deck` (`generated_at`) |
| `investor-update` | `investor_update` (`generated_at`) |
| `onboarding-pack` | `onboarding_pack` (`generated_at`) |
| `hiring-brief` | `hiring_brief` (`generated_at`) |
| `well-architected` | activity log only (no `_state.json` fields) |
| `complexity-check` | activity log only (no `_state.json` fields) |
| `compare-stack` | activity log only (no `_state.json` fields) |
| `scaffold` | activity log only — writes `filesCreated` to `_activity.jsonl` per component |
| `scaffold-component` | activity log only — writes `filesCreated` to `_activity.jsonl` |
| `visualise` | activity log only (no `_state.json` fields) |
| `export-diagrams` | activity log only (no `_state.json` fields) |
| `agent-spec` | activity log only (no `_state.json` fields) |
| `check-env` | activity log only (no `_state.json` fields) |
| `publish-api-docs` | activity log only (no `_state.json` fields) |
| `sdl` (validate/diff/template) | no writes |

## Format Constraints by Command

These override any default behavior from training:

| Command | Output format | NEVER generate |
|---------|--------------|----------------|
| `/architect:wireframes` | `.json` files only (one per screen) | HTML, CSS, JSX, TSX, any other format |
| `/architect:prototype` | `.tsx`/`.ts` React files | HTML wireframes, server-side code |

**wireframes specifically:** The word "wireframes" does NOT mean HTML in this plugin. Archon renders JSON wireframe specs natively. Writing any `.html` file from `/architect:wireframes` is wrong regardless of what your training suggests.

## Output Quality Rules

- Generate **complete, detailed output** — no placeholders, no "see documentation", no truncation
- Use tables for structured data (entities, endpoints, config, comparisons) — more information-dense than prose
- Do not add filler headings ("Overview", "Introduction", "Background") — start with the content
- Do not add "Next Steps" or CTA footers unless the command explicitly requires it
- Do not explain what you're about to do — just do it
- Do not repeat the same information across sections or files
