# /architect:review — Steps 1–4

_Part 1 of 2. Read review-index.md first, then this file, then review-2.md._

---

## Step 1: Parse the Invocation

Parse the full argument string against these four forms in order:

| Form | Detection | Sets |
|------|----------|------|
| `[component] --pr <N>` | Token + `--pr` flag + integer | `review_mode=pr`, `component_filter=token`, `pr_number=N` |
| `[component]:<file>` | Token containing a colon | `review_mode=file`, `component_filter=token before colon`, `file_filter=token after colon` |
| `[component]` | Single token, no flags, no colon | `review_mode=uncommitted`, `component_filter=token` |
| _(empty)_ | No argument | `review_mode=all`, `component_filter=null` |

### 1a. Component validation

If `component_filter` is set:
1. Check `architecture-output/_state.json` for a matching entry in `components[].name`.
2. If not in `_state.json`, check whether the directory exists on disk.
3. If neither: abort with — "Component '{name}' not found. Check `_state.json` for registered components or verify the directory exists on disk."

### 1b. PR mode prerequisite

The `--pr` flag requires the GitHub CLI. Check availability:
```bash
gh --version
```
If the command fails: abort with — "The `--pr` flag requires the GitHub CLI (`gh`). Install it from https://cli.github.com or review using the default git diff mode."

### 1c. `--fix` flag

Detect `--fix` anywhere in the argument string. Strip it before parsing the remaining tokens.

- `--fix` is compatible with all `review_mode` values.
- `--fix` is NOT compatible with `review_mode=file` (single-file review doesn't produce enough context for safe auto-fix) — if both are present, warn: "`--fix` is not supported for single-file review. Run without a file filter to enable auto-fix." and proceed as a normal review without fix.

### 1d. Output of Step 1 (internal state)

```
review_mode:       "uncommitted" | "pr" | "file" | "all"
component_filter:  "api-server" | null
pr_number:         42 | null
file_filter:       "app/routers/orders.py" | null
auto_fix:          true | false
```

---

## Step 2: Acquire the Diff

Run from the component directory unless otherwise specified. Combine staged and unstaged changes — a developer may have staged some hunks and left others unstaged.

### Mode: `uncommitted`

Run from within `<component_filter>/`:
```bash
git diff HEAD -- .
git diff --cached HEAD -- .
```
Combine both outputs. If both are empty, check for untracked new files:
```bash
git ls-files --others --exclude-standard
```
For each untracked file, produce a synthetic diff:
```bash
git diff --no-index /dev/null <file>
```
If all three sources are empty: output — "No changes found in {component} — nothing to review." and stop.

### Mode: `pr`

Run from the repo root:
```bash
gh pr diff <pr_number> -- <component_filter>/
```
If the output is empty (PR has no changes in that component): output — "PR #{pr_number} has no changes in {component}." and stop.

### Mode: `file`

Run from the repo root:
```bash
git diff HEAD -- <component_filter>/<file_filter>
```
If the file has uncommitted changes, that is the diff. If empty (no uncommitted changes), fall back to the current file content:
```bash
git show HEAD:<component_filter>/<file_filter>
```
Present the full file content as the review target with a note: "No uncommitted changes — reviewing current committed version of `<file>`."

### Mode: `all`

Discover which components have changes:
```bash
git diff HEAD --name-only
git diff --cached HEAD --name-only
```
Extract the leading path segment (the component directory) from each changed file. Cross-reference against `_state.json.components[].name`. Process only paths that match a registered component. Deduplicate. Set `components_to_review` to the resulting list.

If the list is empty: output — "No uncommitted changes found in any registered component." and stop.

### Diff size guard

If the diff for a single component exceeds 800 lines:
> "Diff for {component} is {N} lines — large diffs reduce review precision. Consider reviewing a specific file: `/architect:review {component}:<file>`. Proceeding with full diff."

Do not abort — warn and continue.

### Output of Step 2 (internal state)

```
diff_content:          { "api-server": "<diff text>", "web-app": "<diff text>" }
diff_source:           "git-uncommitted" | "git-pr-42" | "git-file"
components_to_review:  ["api-server", "web-app"]
```

---

## Step 3: Load Project Context

Read in this order — cheapest first, stop when you have what you need.

**1. `architecture-output/_state.json`** — read in full (always under 15KB).
Extract: `tech_stack`, `components[]` (names, types, frameworks), `entities[]`.

**2. SDL** — follow the global SDL reading procedure (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then relevant modules). Read only sections relevant to the components being reviewed. Extract per component:
- `architecture.projects[]` entry (framework, runtime, type)
- `auth` section — which routes require authentication, service token model
- `application_patterns` — folder convention, architecture style (used for architecture fitness check)
- `design.boundaries` or equivalent — which components are permitted to import from which

**3. OpenAPI contract** — if `architecture-output/contracts/<component>.openapi.yaml` exists, read it. Cross-reference `security` blocks to identify which routes require auth. Used in the security surface scan.

**Do not read** `data-model.md`, `user-personas.md`, or other large deliverables — the reviewer only needs structural context, not domain content.

### Output of Step 3 (internal state)

```
sdl_context: {
  "api-server": {
    "auth_strategy": "jwt",
    "protected_routes": ["/orders", "/users/:id"],
    "component_boundaries": { "api-server": ["shared-lib"], "web-app": ["shared-lib"] }
  }
}
```

---

## Step 4: Detect Pattern Fingerprint

**This step runs before any review check begins. It is mandatory regardless of how small the diff is.**

The fingerprint is what defines "correct code" for this component. Without it, pattern conformance cannot be assessed.

For each component in `components_to_review`:

### 4a. Verify the component exists on disk

If `<component-name>/` does not exist: abort with — "Component '{name}' has not been scaffolded yet. Run `/architect:scaffold-component {name}` first."

### 4b. Detect the fingerprint

Run these reads (use Glob and Grep — no full file reads unless necessary):

| Signal | Detection method |
|--------|-----------------|
| **Runtime** | `package.json` → `engines.node`; `go.mod`; `*.csproj`; `pyproject.toml`; `build.gradle.kts`; `Podfile`/`Package.swift` (iOS); `pubspec.yaml` (Flutter) |
| **Framework** | `package.json` deps (`express`, `fastify`, `@nestjs/core`, `next`); `requirements.txt` or `pyproject.toml` (`fastapi`, `django`, `flask`); `.csproj` SDK attribute; `pom.xml` spring-boot-starter; `go.mod` require (`gin-gonic/gin`, `labstack/echo`) |
| **Folder convention** | List top-level dirs inside `src/` or `app/` or project root |
| **Route style** | Grep `src/` or `app/` for: `router\.get\|router\.post` (Express), `@Get\|@Post\|@Controller` (NestJS), `@app\.get\|@router\.get` (FastAPI/Flask), `http\.HandleFunc\|r\.GET` (Go), `\[HttpGet\]\|\[HttpPost\]` (.NET), `@GetMapping\|@PostMapping` (Spring) |
| **Service layer** | Check if a `services/` or `application/` or `use_cases/` directory exists |
| **ORM / data access** | Grep `package.json`/`pyproject.toml`/`.csproj`/`go.mod`/`pom.xml` for: `prisma`, `drizzle`, `typeorm`, `sequelize`, `sqlalchemy`, `alembic`, `tortoise-orm`, `entity-framework`, `gorm`, `spring-data`, `jpa` |
| **Validation library** | Grep `src/` for: `z\.object\|z\.string` (zod), `Joi\.object` (Joi), `class-validator` (NestJS), `pydantic\|BaseModel` (Python), `FluentValidation` (.NET), `validator\.` (Go), `@Valid\|@NotNull` (Java) |
| **Error response format** | Read first 60 lines of one existing route/controller file — extract the error return shape |
| **Import alias** | `tsconfig.json` → `paths`; `vite.config.*` → `resolve.alias`; Python uses relative imports |
| **Test runner + location** | `package.json` → `scripts.test`; `pytest.ini`/`pyproject.toml [tool.pytest]`; `go test` (Go); `dotnet test` (.NET); `./gradlew test` (Java). Scan for `tests/`, `__tests__/`, `spec/`, co-located `*.test.*`, `*_test.*`, `*Spec.*` |
| **Naming convention** | Read 2 existing service files — camelCase functions vs snake_case, class-based vs functional |
| **Logger** | Grep `src/` or `app/` for: `pino\|winston\|bunyan` (Node.js), `structlog\|logging` (Python), `slog\|zap\|logrus` (Go), `Serilog\|ILogger` (.NET), `slf4j\|logback` (Java) — record the logger name used |

### 4c. Build the fingerprint object

```json
{
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
}
```

### 4d. Check for component-level CLAUDE.md

If `<component-name>/CLAUDE.md` exists, read it. Treat its rules as additional constraints — they take priority over fingerprint defaults.

### Output of Step 4 (internal state)

```
fingerprints: { "api-server": { ...fingerprint object... }, "web-app": { ...fingerprint object... } }
```

---

Proceed to `review-2.md` for Steps 5–8.
