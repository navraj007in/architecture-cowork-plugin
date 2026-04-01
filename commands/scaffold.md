---
description: Create repos and bootstrap projects from a blueprint architecture
---

# /architect:scaffold

## Trigger

`/architect:scaffold`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command creates actual project directories (or GitHub repos) and bootstraps each component with framework-appropriate starter code. Turns architecture specs into real, runnable projects.

## Workflow

### Step 0.5: Load Prior Activity Context

Before anything else, load two levels of activity context.

**Project level** — check if `architecture-output/_activity.jsonl` exists. If it does, read the last 3 entries. Use them to understand:
- Which components have already been scaffolded and their overall outcome
- Whether a previous scaffold run was partial or failed
- What phase of work the project is in (blueprint done, scaffold done, active coding)

**Component level** — for any component that will be **augmented** (EXISTS), also read `<component-name>/_activity.jsonl` if it exists. Extract the last 3 entries to understand:
- What was scaffolded previously and which files were created
- What code changes have been made since scaffold
- Which files are likely to need updating vs which are safe to leave alone

Use both levels silently to inform decisions — do not print logs to the user unless asked. For example: if a component's log shows it was already scaffolded completely last run, skip its scaffold unless the user asks to re-run it.

If neither file exists, this is a fresh project — proceed normally.

### Step 1: Check for Blueprint

**First**, check if the command argument contains a `[blueprint_dir:/path/to/dir]` tag. If it does, read the blueprint artifacts from that local directory:
- Read `blueprint.json` for the full blueprint with all deliverables
- Read `00-manifest/manifest.json` for the system manifest
- Extract all components from the manifest (services, frontends, mobile apps, agents)

**If no local directory tag**, check if a blueprint with a system manifest exists earlier in the conversation. If yes, extract all components from the manifest.

If no blueprint exists (neither local files nor conversation), respond:

> "I need an architecture to scaffold from. Run `/architect:blueprint` first to generate your architecture, then come back here to create the projects."

### Step 2: List Components and Detect Existing Code

For each component, check whether `<parent-dir>/<component-name>` already exists on disk:
- If it exists and contains source files (package.json, requirements.txt, go.mod, pubspec.yaml, .csproj, or any `src/` / `app/` / `lib/` directory), mark it **EXISTS**.
- If it contains a `.git` directory, it is an independent repository — always mark **EXISTS** regardless of what other files are present, and treat it as an existing codebase to augment rather than scaffold from scratch.
- If it does not exist or is empty, mark it **NEW**.

**Also scan for unmatched sub-repos:** After processing components from the manifest, check if the parent directory has any subdirectory with a `.git` folder that is NOT listed as a component in the manifest. If found, alert the user:

```
⚠ Found independent git repos not in the manifest:
  - ./legacy-admin (Git repo, React — not in blueprint)
  - ./shared-utils (Git repo, TypeScript — not in blueprint)

These will not be scaffolded. If they should be components, add them to your SDL and re-run /architect:blueprint first.
```

Present the components with status:

```
I found these components in your architecture:

1. web-app (Next.js) — Frontend               [NEW]
2. api-server (.NET Clean Architecture) — API  [EXISTS — will augment]
3. worker-service (Python/FastAPI) — Worker    [NEW]

New components will be scaffolded from scratch.
Existing components will be augmented — missing files added, nothing overwritten.
```

**Framework resolution — always follow this precedence:**
1. SDL `framework` field on the component — authoritative, always use it if present
2. ADRs in `architecture-output/adrs/` — if an ADR selects a technology for this component, follow it
3. Table default below — only when neither SDL nor ADR specifies a framework

**Failing to respect a framework declared in the SDL is a scaffolding error. If the SDL says `.NET`, scaffold .NET.**

| Manifest Section | Component Type | SDL `framework` values recognised | Default (SDL silent) |
|-----------------|----------------|------------------------------------|----------------------|
| `frontends[]` with type `web` | Frontend | `nextjs`, `react-vite`, `vue`, `nuxt`, `svelte`, `angular` | Next.js (App Router) |
| `frontends[]` with type `admin` | Admin Dashboard | `react-vite`, `nextjs`, `angular` | React (Vite) |
| `frontends[]` with type `mobile-web` | Mobile Web App | `nextjs`, `react-vite` | Next.js (App Router) |
| `frontends[]` with type `crm` | CRM Frontend | `react-vite`, `nextjs`, `angular` | React (Vite) |
| `frontends[]` with type `booking` | Booking Frontend | `react-vite`, `nextjs` | React (Vite) |
| `frontends[]` with type `ai-chat` | AI Chat Interface | `react-vite`, `nextjs` | React (Vite) |
| `frontends[]` with type `mobile` | Mobile App | `react-native`, `expo`, `flutter`, `swift`, `kotlin` | React Native (Expo) |
| `services[]` with type `rest-api` or `graphql` | Backend API | `nodejs`, `nestjs`, `fastify`, `dotnet`, `python-fastapi`, `go`, `java-spring`, `ruby-rails`, `django` | Node.js/Express |
| `services[]` with type `background-worker` | Worker | `nodejs`, `dotnet`, `python`, `go` | Node.js/BullMQ |
| `services[]` with type `websocket` | Real-time Service | `nodejs`, `nestjs`, `dotnet`, `go` | Node.js/Socket.io |
| `agents[]` | AI Agent | `python-fastapi`, `nodejs` | Python/FastAPI |

Always show the resolved framework next to each component name so the user can verify before scaffolding proceeds.

### Step 3: Ask Configuration Questions

**If `[non_interactive:true]` is in the command argument OR if the execution mode constraints say non-interactive**, skip all questions and use these defaults:
- **Parent directory**: current working directory (or the path from `[workspace_dir:...]` if provided)
- **GitHub or local**: Local directories with git init
- **Install dependencies**: Yes
- **Structure / auth / framework choices**: Derive ALL decisions from SDL and existing ADRs in architecture-output/adrs/. Check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Follow the SDL exactly — do NOT ask the user to choose between options. If the SDL specifies a monorepo structure, use it. If the SDL specifies auth strategy, implement it. If there's a conflict between existing code and SDL, follow the SDL (the SDL is the source of truth).

**Otherwise**, ask the user these questions before proceeding:

**1. Parent directory**

> "Where should I create the projects? (default: current directory)"

**2. GitHub or local**

> "Should I create GitHub repos or just local directories?"
>
> - **Local directories** (default) — just creates folders with git init
> - **GitHub repos** — creates repos using `gh` CLI, pushes initial commit

If GitHub:

> "What GitHub org or username? And public or private repos?"

**3. Install dependencies**

> "Should I run `npm install` / `pip install` after scaffolding? This takes a few minutes but means projects are ready to run immediately."

### Step 3.5: Check for Design System

Check if the design-system phase has been completed:

1. Look for `architecture-output/design-system/design-tokens.json` in the blueprint directory
2. Look for a `design` section in `solution.sdl.yaml` (or `sdl/design.yaml` if using multi-file SDL)

**If design tokens exist**, load them — the scaffolder will use these to configure frontend projects with the correct palette, typography, shape, and motion settings.

**If no design tokens exist but SDL has a `design` section**, use the SDL design fields directly and load the **design-systems.md** reference for implementation patterns.

**If neither exists**, note this in the scaffolder handoff — the scaffolder should infer domain-appropriate defaults from `design-systems.md` (NEVER default to indigo/purple).

Also load `skills/production-hardening/SKILL.md` — the scaffolder applies production hardening patterns to every Node.js backend and React/Next.js frontend during scaffold generation. Which patterns are required vs deferred depends on `solution.stage` (resolved in Step 3.6 below).

Inform the user:

- If design tokens found: `"Design system detected — your scaffolded frontends will use your design tokens."`
- If no design system: `"Tip: Run /architect:design-system first to get a custom design language. Scaffolding will use domain defaults for now."`

### Step 3.6: Stage-Aware Depth Resolution

Read `solution.stage` from `architecture-output/_state.json` (field `project.stage`) or directly from SDL if `_state.json` is absent (check `solution.sdl.yaml` first; if absent, check `sdl/core.yaml` or `sdl/solution.yaml`).

Map stage to `scaffold_depth`:

| `solution.stage` | `scaffold_depth` |
|-----------------|-----------------|
| `concept` | `mvp` |
| `mvp` | `mvp` |
| `growth` | `growth` |
| `enterprise` | `enterprise` |

**Hardening pattern depth by stage:**

| Pattern | MVP | Growth | Enterprise |
|---------|-----|--------|------------|
| Correlation ID propagation | ✓ Required | ✓ Required | ✓ Required |
| Graceful shutdown | ✓ Required | ✓ Required | ✓ Required |
| Structured logging (pino/zerolog/serilog) | ✓ Required | ✓ Required | ✓ Required |
| Health check endpoint (with real DB probe) | ✓ Required | ✓ Required | ✓ Required |
| CORS + Helmet/security headers | ✓ Required | ✓ Required | ✓ Required |
| Input validation (Zod/FluentValidation) | ✓ Required | ✓ Required | ✓ Required |
| Auth token interceptor (frontend) | ✓ Required | ✓ Required | ✓ Required |
| Rate limiting | `// TODO: configure rate limits` stub only | ✓ Required | ✓ Required |
| Retry + timeout on outbound HTTP | Timeout only (AbortController, no backoff) | ✓ Full (timeout + 3-attempt exponential backoff) | ✓ Full |
| Soft delete (`deletedAt` + ORM middleware) | Recommended — generate only if SDL has `softDelete: true` | ✓ Required | ✓ Required |
| Queue consumers (BullMQ/Celery) | Generate only if SDL explicitly declares `data.queues` | ✓ Required if SDL has queues | ✓ Required |
| Prometheus metrics endpoint | Omit | Recommended — generate `/metrics` stub | ✓ Required |
| CI/CD pipeline | Single environment (dev → build → test) | Two environments (+ staging deploy) | Full matrix (dev → staging → production, matrix runners) |
| Docker Compose | Dev databases + services only | Dev stack + monitoring (Prometheus/Grafana) | Full stack including load balancer stub |
| Error tracking (Sentry SDK) | Optional — add `SENTRY_DSN` to `.env.example` with comment | ✓ Required — wire SDK at app startup | ✓ Required |

**Rules:**
- Pass `scaffold_depth` to the scaffolder agent in Step 4
- For MVP, wherever a pattern is deferred, leave a `// TODO (growth): add X` comment at the exact location where it would be wired in
- Never omit patterns 1–7 regardless of stage — these are always required
- If `solution.stage` is absent, default to `mvp`

Print one line to the user:
```
Stage: MVP → using lean scaffold (patterns 1–7 required, rate limiting and retry stubbed for later)
```

### Step 3.7: Contract Generation (Pre-Scaffold)

Before scaffolding any code, generate an OpenAPI 3.1 contract for every backend service. These contracts become the source of truth for route definitions and cross-service clients — the scaffolder generates code FROM these specs, not the other way around.

**For each service with `type: rest-api` or `type: graphql`:**

1. Extract from SDL / manifest:
   - `interfaces[]` — endpoint definitions (method, path, auth, request/response shapes)
   - `product.personas[]` — to infer access levels (public / authenticated / admin)
   - `dependsOn[]` — which other services call this one (affects security scheme)
   - Entity names from `domain.entities[]` — to build schema objects

2. Generate an OpenAPI 3.1 YAML spec with:
   - `info`: service name, description, version `"0.1.0"`, contact from SDL
   - `servers`: `[{ url: "http://localhost:{port}", description: "Local" }]`
   - `security`: bearer JWT if auth is enabled; API key if `serviceTokenModel: api-key`
   - `paths`: one entry per interface endpoint — include request body schema (JSON Schema inlined), response schemas (200, 400, 401, 404, 500), and `operationId`
   - `components.schemas`: one schema per domain entity owned by this service — fields inferred from entity name and context (not detailed ORM schemas; those come from generate-data-model)
   - `components.securitySchemes`: based on `auth.serviceTokenModel`

3. Write to `architecture-output/contracts/<service-name>.openapi.yaml`

4. For each inter-service dependency in `dependsOn[]`:
   - Read the dependency's generated OpenAPI spec
   - Generate a typed client interface file: `architecture-output/contracts/<caller>-calls-<dependency>.client.ts` (TypeScript) or equivalent for the caller's language
   - Client interface contains one typed function per endpoint the caller actually needs (based on SDL flow analysis)
   - These client files are passed to the scaffolder and placed at `src/lib/clients/<dependency>-client.ts` in the caller's scaffold

5. Write `architecture-output/contracts/_index.md` listing all generated contracts:
   ```markdown
   # Service Contracts
   | Service | Contract File | Endpoints | Callers |
   |---------|--------------|-----------|---------|
   | api-server | contracts/api-server.openapi.yaml | 12 | web-app, worker-service |
   ```

**Rules:**
- If a service has no `interfaces[]` defined in SDL: generate a minimal OpenAPI with a single `GET /health` path and a `// TODO: add endpoints` comment in the paths section
- For GraphQL services: generate a GraphQL SDL schema file instead (`<service>.graphql`) — not OpenAPI
- Do NOT generate contracts for non-API services (workers, agents, databases, mobile apps)
- If contracts already exist in `architecture-output/contracts/` from a prior run, diff them against what would be generated — only overwrite if SDL has changed since last generation; otherwise skip and reuse

Inform the user:
```
Contracts generated:
  ✓ api-server.openapi.yaml — 12 endpoints
  ✓ worker-service.openapi.yaml — 3 endpoints (health + 2 worker triggers)
  ✓ web-app-calls-api-server.client.ts — typed client (8 operations)
```

### Step 4: Delegate to Scaffolder Agent

Before delegating, build an `existing_state` map for every **EXISTS** component. For each, read:
1. Package manifest (`package.json`, `requirements.txt`, `go.mod`, `*.csproj`, etc.) — installed deps and scripts
2. Entry point (`src/index.ts`, `main.py`, `Program.cs`, etc.) — what is already wired up
3. `.env.example` if present — to avoid duplicating variable definitions
4. Directory listing of `src/` (or equivalent) — which folders/files already exist

Summarise into the `existing_state` map:
```json
{
  "api-server": {
    "mode": "augment",
    "installed_deps": ["express", "helmet"],
    "has_dockerfile": false,
    "has_env_example": true,
    "existing_src_dirs": ["controllers", "routes"],
    "missing": ["Dockerfile", "docker-compose.yml", ".github/workflows/ci.yml"]
  }
}
```

Pass the following to the **scaffolder** agent:

- Component list with names, types, frameworks, and `mode` (`"new"` or `"augment"`)
- `existing_state` map (populated for augment-mode components)
- Parent directory path
- GitHub config (if applicable): org name, visibility
- Whether to install dependencies
- Relevant integrations from the manifest (for `.env.example` files)
- `shared` section from the manifest (types, libraries, contracts) — for creating shared packages
- `application_patterns` section (architecture, folder_convention, principles) — for folder structure
- `security` section (auth_strategy, api_security) — for security middleware stubs
- `observability` section (health_checks, logging) — for health endpoints and logger setup
- `devops` section (cicd, environments) — for CI/CD workflow and Docker files
- Per-frontend config: build_tool, rendering, state_management, data_fetching, component_library, form_handling, validation, animation, api_client, backend_connections, client_auth, realtime, monitoring, deploy_target, dev_port
- Per-mobile config: build_platform, navigation, push_notifications, deep_linking, permissions, ota_updates, realtime (protocol + provider), bundle_id, client_auth (token_storage, device_binding, biometric)
- `environments` section — for generating `.env.example` files with per-environment URL placeholders
- **`scaffold_depth`** (`"mvp"` | `"growth"` | `"enterprise"`) — resolved in Step 3.6. The scaffolder MUST consult the depth table to determine which patterns are required, stubbed, or omitted for this stage.
- **Contract files** from Step 3.7:
  - Per-service OpenAPI specs: `architecture-output/contracts/<service>.openapi.yaml` — scaffolder generates route handlers and type definitions FROM these specs (routes declared in the spec are the authoritative list; don't invent additional routes from SDL inference alone)
  - Cross-service client files: `architecture-output/contracts/<caller>-calls-<dependency>.client.ts` — place these at `src/lib/clients/<dependency>-client.ts` in the caller's directory instead of generating ad-hoc clients
  - Contract index: `architecture-output/contracts/_index.md`
- **Design system artifacts** (if available):
  - `design-tokens.json` — full token set for Tailwind config generation
  - `tailwind.config.patch.ts` — ready-to-merge Tailwind extensions
  - SDL `design` section — preset, personality, palette, typography, shape, motion, layout, icons, accessibility
- **Production hardening requirements** — apply patterns from `skills/production-hardening/SKILL.md` at the depth specified by `scaffold_depth`. Patterns 1–7 (correlation ID, graceful shutdown, structured logging, health checks, CORS/Helmet, input validation, auth token interceptor) are always required. Patterns 8–9 and optional features follow the depth table in Step 3.6.

#### Frontend Design Integration (when design tokens are available)

For each **frontend component**, the scaffolder MUST:

1. **Tailwind config** — merge `tailwind.config.patch.ts` into the generated `tailwind.config.ts`. Include palette colors, font families, border radius, box shadows, and any custom extensions from the design tokens.

2. **CSS custom properties** — generate `globals.css` with CSS variables matching the design tokens:
   ```css
   :root {
     --color-primary: ...;
     --color-secondary: ...;
     --font-heading: ...;
     --font-body: ...;
     /* etc. from design-tokens.json */
   }
   ```

3. **Font setup** — configure Google Font imports:
   - Next.js: use `next/font/google` with CSS variable binding
   - Vite/React: add `<link>` tags or use `@fontsource` packages
   - Set `--font-heading` and `--font-body` CSS variables

4. **Component library setup** — if a `preset` is specified:
   - shadcn: generate `components.json` with correct theme, run init
   - Material UI: generate theme with `createTheme()` using design tokens
   - Chakra: generate `extendTheme()` config from tokens
   - DaisyUI: configure `daisyui.themes` in Tailwind config

5. **Layout shell** — generate a base layout matching `design.layout.style`:
   - `dashboard`: sidebar navigation + header + main content area
   - `marketing`: hero section + content sections + footer
   - `editorial`: narrow content column + typographic hierarchy
   - `app-shell`: responsive top navigation + content area
   - `saas`: auth layout (login/signup) + dashboard layout + settings layout

6. **Sample page** — generate one themed sample page (`app/page.tsx` or `src/App.tsx`) that demonstrates:
   - The palette (primary, secondary, accent colors in use)
   - Typography (heading + body fonts at different scales)
   - Shape system (cards with correct radius, shadows, borders)
   - At least 2 styled interactive elements (buttons, inputs)
   - The layout shell in action
   - This page serves as a living reference for the design language

7. **Icon library** — install and configure the icon library from `design.iconLibrary`:
   - Add the correct npm package
   - Include sample imports in the sample page

### Step 5: Log Activity

Before printing the summary, write two levels of activity log.

**1. Project-level** — append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"scaffold","outcome":"completed|partial|failed","components":["api-server","web-app"],"summary":"Scaffolded api-server (.NET Clean Architecture) and web-app (Next.js). 25 files total."}
```

- `components`: just the names (array of strings)
- `summary`: one sentence under 120 chars covering all components and any failures

**2. Component-level** — for each component that was scaffolded or augmented, append one line to `<component-name>/_activity.jsonl` (inside the component directory):

```json
{"ts":"<ISO-8601>","phase":"scaffold","framework":"dotnet","status":"created|augmented","filesCreated":["Domain/User.cs","Application/Users/CreateUserCommand.cs","Infrastructure/Persistence/AppDbContext.cs"],"summary":"Initial scaffold: Clean Architecture with CQRS stubs for User, Product. 14 files created."}
```

- `filesCreated`: list of paths relative to the component root (not full absolute paths) — all files, no cap
- `summary`: one sentence specific to this component — framework, pattern, what was generated
- For failed components: write `{"ts":"...","phase":"scaffold","status":"failed","error":"<reason>","summary":"Scaffold failed: <reason>"}`

Rules for both levels:
- Append — never overwrite
- Single JSON object per line, no pretty-printing
- `outcome` on project entry: `completed` if all succeeded, `partial` if some failed, `failed` if none succeeded

### Step 5.5: Build Verification

After all files are written and activity logs are recorded, run a build verification pass for each scaffolded component. The goal is to surface TypeScript errors, missing imports, and config issues immediately — not after the user tries to run the project.

**Verification command by runtime:**

| Runtime | Verification Command | What it checks |
|---------|---------------------|----------------|
| Node.js / TypeScript | `npx tsc --noEmit` in component root | Type errors, missing imports, tsconfig issues |
| Next.js | `npx next build --dry-run` or `npx tsc --noEmit` | Same as above |
| Python / FastAPI | `python -m py_compile $(find src -name "*.py")` | Syntax errors |
| Go | `go build ./...` in component root | Compilation errors |
| .NET | `dotnet build --no-restore` in component root | Build errors |
| React Native | `npx tsc --noEmit` | Type errors |
| Flutter | `flutter analyze` | Analysis issues |

**For each component:**

1. Check whether the runtime is installed (`node --version`, `python3 --version`, `go version`, `dotnet --version`)
2. If the runtime is available AND dependencies were installed (Step 3 config): run the verification command
3. If the runtime is not available or dependencies were not installed: skip and note it in the report

**Parse the output:**
- 0 errors → ✅ pass
- Errors found → capture the first 5 error lines (truncate the rest with "and N more errors")

**Update the component-level activity log entry** with the verification result — append a new line (don't modify the scaffold entry):

```json
{"ts":"<ISO-8601>","phase":"build-verify","status":"pass|fail|skipped","errors":[],"summary":"tsc --noEmit: 0 errors"}
```

For failures:
```json
{"ts":"<ISO-8601>","phase":"build-verify","status":"fail","errors":["src/index.ts(12,5): error TS2304: Cannot find name 'X'"],"summary":"tsc --noEmit: 3 errors — review src/index.ts"}
```

**Rules:**
- Verification is best-effort — a failure does NOT block the scaffold summary or mark the scaffold as failed
- If verification cannot run (missing runtime, skipped deps install), note it clearly but don't treat it as a failure
- For augment-mode components: only verify files that were ADDED, not the whole project (too slow and would surface pre-existing errors the user owns)

### Step 6: Print Summary

After logging activity, print a summary:

```
Scaffold complete! Here's what was created:

Stage: MVP — lean scaffold applied (patterns 1–7 required; rate limiting and retry stubbed)

| # | Component | Framework | Path | Status | Build |
|---|-----------|-----------|------|--------|-------|
| 1 | web-app | Next.js | ./web-app | Created | ✅ tsc: 0 errors |
| 2 | api-server | .NET | ./api-server | Augmented | ✅ dotnet build: 0 errors |
| 3 | worker-service | BullMQ | ./worker-service | Created | ⚠ tsc: 2 errors (see below) |
| 4 | mobile-app | Expo | ./mobile-app | Created | ⏭ skipped (deps not installed) |
| 5 | support-agent | FastAPI | ./support-agent | Created | ✅ py_compile: 0 errors |

Contracts generated:
  architecture-output/contracts/api-server.openapi.yaml — 12 endpoints
  architecture-output/contracts/worker-service.openapi.yaml — 3 endpoints
  architecture-output/contracts/web-app-calls-api-server.client.ts — typed client (8 operations)

Build errors to fix:
  worker-service/src/jobs/email.ts(14,3): error TS2304: Cannot find name 'EmailPayload'
  worker-service/src/jobs/email.ts(28,7): error TS2345: Argument of type ...

Each project has:
- Framework starter code with folder structure matching the architecture pattern
- Security middleware: CORS from `ALLOWED_ORIGINS` (set to sibling frontend `dev_port` URLs derived from SDL — never hardcoded), helmet with environment-specific CSP directives
- Auth token interceptor in frontend API client: Bearer token injection, 401 → refresh → retry, redirect on refresh failure
- Health check endpoints: actual DB (`SELECT 1`) and cache (`PING`) checks, `{ status, uptime, version, memory, checks }` JSON, 503 on critical failure
- Structured logging: pino JSON in prod, pino-pretty in dev; correlationId on every log line; zero console.log
- Correlation ID propagation: `x-correlation-id` generated/forwarded by backend middleware; sent by frontend API client
- Graceful shutdown: SIGTERM/SIGINT handling, connection draining, clean exit
- Zod validation: env vars validated at startup; request body/params/query validated before every handler
- Rate limiting: stub with TODO comment (add at growth stage) [MVP only]
- Retry + timeout: AbortController timeout only — backoff retry stubbed with TODO [MVP only]
- OpenAPI contracts in `architecture-output/contracts/` — route definitions are the source of truth
- Cross-service clients generated from contracts (not ad-hoc SDL inference)
- Dockerfile (all backends and agents; web frontends where applicable)
- docker-compose.yml (dev databases + services) [expanded at growth stage]
- CI/CD workflow (.github/workflows/ci.yml) — single environment [multi-env at growth stage]
- .env.example with per-environment URL placeholders
- .gitignore
- README.md with setup instructions
- Git initialized with initial commit
- Shared type packages (if applicable)
- Frontend: typed API client from contract, backend connection stubs, client auth setup
- Frontend: Design tokens integrated — custom palette, typography, layout shell, and sample page (when design-system phase was completed)
- Mobile: push notification config, deep linking setup, permission declarations, OTA update config

Next steps:
1. Fix any build errors listed above before writing feature code
2. Copy .env.example to .env in each project and fill in your credentials
3. Review `src/config/index.ts` in each backend service — fill in any auth-provider-specific env vars
4. Update `ALLOWED_ORIGINS` in `.env` for each backend and frontend to match your actual domain(s)
5. Follow the README in each project to start the dev server
6. Open the sample page to see your design system in action
7. Start building features!
```

If GitHub repos were created, include repo URLs in the Path column.

## Output Rules

- Use the **founder-communication** skill for tone
- Always check for a blueprint first — don't scaffold without an architecture
- Always list components and get confirmation before creating anything
- Always ask about GitHub vs local and dependency installation
- Report clear results for each component
- If any component fails, report the failure and continue with the rest
- Do NOT include the CTA footer
