# /architect:implement — Steps 1–4

_Part 1 of 2. Read implement-index.md first, then this file, then implement-2.md._

---

## Step 1: Resolve the Story

### 1a. Parse the argument

If the argument matches `S\d+\.\d+`, `Story \d+\.\d+`, or `US-\d+` (case-insensitive) → story ID path.
Otherwise → free-text path.

### 1b. Story ID resolution

1. Read `architecture-output/_activity.jsonl` — last `max(10, component_count)` entries. Understand what has already been implemented; skip if this story is already marked `"phase":"implement","outcome":"completed"`.
2. Check for `architecture-output/sprint-backlog-index.md` — if it exists, read it first to locate which part file contains the story. Then read only that part file.
3. If no index, check `architecture-output/sprint-backlog.md` directly.
4. Grep for the story ID pattern `Story {id}:` or `S{id}` — extract the full story block including: title, acceptance criteria, affected component tags (`component: api-server`), and story points.
5. If not found in backlog, grep `architecture-output/mvp-scope.md` for a matching feature.
6. If still not found, fall back to free-text path with the original argument.

### 1c. Free-text resolution

Normalize to a `feature_slug`: lowercase, spaces to hyphens, max 4 words.
Example: `"add email notification on order placed"` → `email-order-notification`

If the argument is `<component>:<feature>`, extract both parts directly.

### 1d. Derive acceptance criteria

If the backlog entry has explicit ACs, use them verbatim.

If no ACs exist (free-text path), derive 3–5 ACs from the description based on:
- What the user can do after the feature exists
- What the system does in response
- What data is stored or changed
- What external systems are called (if any)

In non-interactive mode (`[non_interactive:true]`): proceed with derived ACs silently.
In interactive mode: print the derived ACs and pause for confirmation before proceeding.

### 1e. Output of Step 1 (internal state)

```
story_id:              S1.3  (or "free-text")
feature_slug:          email-order-notification
story_title:           "Email notification on order placed"
acceptance_criteria:   ["AC1: ...", "AC2: ...", ...]
affected_components:   ["api-server", "web-app"]   ← from story tags or detected in Step 4
```

---

## Step 2: Load Project Context

Read in this order — cheapest first, stop when you have what you need:

**1. `architecture-output/_state.json`** — read in full (always under 15KB).
Extract: `tech_stack`, `components[]` (names, types, ports, frameworks), `entities[]`, `design`.

**2. SDL** — read only sections relevant to the affected components.
Follow the global SDL reading procedure (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then relevant modules).
Extract per affected component:
- Component entry from `architecture.projects[]` (framework, runtime, type, port, interfaces)
- `auth` section — auth strategy and service token model
- `data` section — ORM, database type, migration tool
- `application_patterns` — folder convention, architecture style
- `environments` — for env var generation

**3. OpenAPI contract** — if `architecture-output/contracts/<component>.openapi.yaml` exists for a backend component, read it. It is the authoritative route list — determines whether the feature needs a new route or extends an existing one.

**Do not read** `data-model.md`, `user-personas.md`, or `user-journeys.md` unless an entity the story touches is absent from `_state.json.entities`. If needed, use Grep on the relevant file to extract only the matching entity section.

---

## Step 3: Detect Existing Code Patterns

**This step runs before any file is written. It is mandatory regardless of how simple the feature seems.**

For each affected component:

### 3a. Verify the component exists

Check if `<component-name>/` exists on disk. If not → abort with:

> "Component '{name}' has not been scaffolded yet. Run `/architect:scaffold-component {name}` first."

### 3b. Detect the pattern fingerprint

Run these reads (use Glob and Grep — no full file reads unless necessary):

| Signal | Detection method |
|--------|-----------------|
| **Runtime** | `package.json` → `engines.node`; `go.mod`; `*.csproj`; `pyproject.toml`; `build.gradle.kts`; `Podfile`/`Package.swift` (iOS); `pubspec.yaml` (Flutter) |
| **Framework** | `package.json` deps (`express`, `fastify`, `@nestjs/core`, `next`); `requirements.txt` or `pyproject.toml` (`fastapi`, `django`, `flask`); `.csproj` SDK attribute; `pom.xml` spring-boot-starter; `go.mod` require (`gin-gonic/gin`, `labstack/echo`) |
| **Folder convention** | List top-level dirs inside `src/` or `app/` or project root |
| **Route style** | Grep `src/` or `app/` for: `router\.get\|router\.post` (Express), `@Get\|@Post\|@Controller` (NestJS), `@app\.get\|@router\.get` (FastAPI/Flask), `http\.HandleFunc\|r\.GET` (Go), `[HttpGet]\|[HttpPost]` (.NET), `@GetMapping\|@PostMapping` (Spring) |
| **Service layer** | Check if a `services/` or `application/` or `use_cases/` directory exists |
| **ORM / data access** | Grep `package.json`/`pyproject.toml`/`.csproj`/`go.mod`/`pom.xml` for: `prisma`, `drizzle`, `typeorm`, `sequelize`, `sqlalchemy`, `alembic`, `tortoise-orm`, `entity-framework`, `gorm`, `spring-data`, `jpa` |
| **Validation library** | Grep `src/` for: `z\.object\|z\.string` (zod), `Joi\.object` (Joi), `yup\.object` (Yup), `class-validator` (NestJS), `pydantic\|BaseModel` (Python), `FluentValidation` (.NET), `validator\.` (Go), `@Valid\|@NotNull` (Java) |
| **Error response format** | Read first 60 lines of one existing route/controller file — extract the error return shape |
| **Import alias** | `tsconfig.json` → `paths`; `vite.config.*` → `resolve.alias`; Python uses relative imports |
| **Test runner + location** | `package.json` → `scripts.test`; `pytest.ini`/`pyproject.toml [tool.pytest]`; `go test` (Go); `dotnet test` (.NET); `./gradlew test` (Java). Scan for `tests/`, `__tests__/`, `spec/`, co-located `*.test.*`, `*_test.*`, `*Spec.*` |
| **Naming convention** | Read 2 existing service files — camelCase functions vs snake_case, class-based vs functional, exported const vs export default |
| **Migration tool** | Grep for `prisma migrate`, `alembic`, `flyway`, `liquibase`, `golang-migrate`, `dotnet ef migrations`, `django migrations` |

### 3c. Build the fingerprint object

```json
{
  "runtime": "python",
  "framework": "fastapi",
  "folder_style": "flat-app",
  "route_style": "fastapi-router",
  "service_exists": true,
  "orm": "sqlalchemy",
  "migration_tool": "alembic",
  "validation": "pydantic",
  "error_format": {"detail": "string"},
  "import_style": "relative",
  "test_runner": "pytest",
  "test_location": "tests/",
  "naming": "snake_case",
  "language": "python"
}
```

Every file written in Steps 5–6 MUST conform to this fingerprint. Framework-appropriate libraries only — never substitute a Node.js library into a Python project or vice versa.

### 3d. Check for component-level CLAUDE.md

If `<component-name>/CLAUDE.md` exists, read it. Treat its rules as additional constraints on top of the fingerprint — they take priority over any defaults.

---

## Step 4: Plan What to Write

### 4a. Map acceptance criteria to layers

For each AC, determine which layers are affected:

| AC type | Layers touched |
|---------|---------------|
| New data stored | Model/entity + migration stub + service + route + test |
| New API endpoint | Route + service + schema/validation + test |
| Modified existing endpoint | MOD route + MOD service + test |
| External service call (email, SMS, payment) | Integration wrapper in `lib/` or `integrations/` + service + env var |
| Frontend screen or UI change | Frontend page/component + API client update + i18n keys |
| Background job or event | Worker/consumer handler + queue config stub |
| Auth / permission change | Middleware or guard + route modifier + test |

### 4b. Produce the write plan

Resolve actual file paths using the detected `folder_style` and `naming` convention from the fingerprint. Use the correct file extension for the runtime.

**Example — Python/FastAPI, snake_case, flat-app:**
```
api-server (python / fastapi):
  NEW  app/schemas/notification.py       — Pydantic request/response models
  NEW  app/services/notification.py      — send_order_email(), queue integration
  NEW  app/routers/notifications.py      — POST /notifications/order-placed
  MOD  app/routers/__init__.py           — register notifications router
  NEW  app/lib/mailer.py                 — SMTP/SendGrid wrapper
  MOD  alembic/versions/<ts>_add_notification_log.py  — migration stub
  NEW  tests/test_notification.py        — 4 tests

web-app (typescript / next.js):
  MOD  src/app/orders/[id]/page.tsx      — toast on order confirm
  MOD  src/lib/api.ts                    — typed notifyOrderPlaced() call
  MOD  src/i18n/locales/en.json          — +2 keys
  MOD  src/i18n/locales/es.json          — +2 keys
  MOD  src/i18n/locales/ar.json          — +2 keys
```

Print this plan to the user before any writes begin. In interactive mode, wait for confirmation. In non-interactive mode, proceed immediately.

### 4c. Conflict check

For every MOD file in the plan:
1. Read the full file.
2. Grep for the `feature_slug` — if already implemented, skip the file and note it as "already present".
3. Identify the exact insertion point (function name, line region, import block). If the insertion point cannot be clearly identified, flag it and describe where the code should go in the summary instead of writing it blindly.

### 4d. Detect affected components not in story tags

If the story has no `component:` tags, infer affected components from the feature description:
- Keywords like "notify", "email", "SMS" → likely touches a backend service + possibly an integration lib
- Keywords like "display", "show", "page", "screen" → likely touches a frontend component
- Keywords like "store", "save", "record" → likely touches a backend + database layer

Cross-reference with `_state.json.components[]` to match inferred types to actual component names.
