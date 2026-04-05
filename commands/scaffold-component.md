---
description: Scaffold a single named component from the architecture blueprint with production-depth code
---

# /architect:scaffold-component

## Trigger

`/architect:scaffold-component <component_name>`

## Purpose

Scaffolds a single component by name from the SDL. This command is invoked by the parallel scaffold orchestrator to scaffold one component at a time, enabling parallel execution across multiple agents.

A component is anything defined in the SDL: backend service, frontend web app, mobile app, AI agent, shared library, database setup, cloud resource, infrastructure config — whatever gets generated as part of the SDL.

Unlike `/architect:scaffold` which scaffolds everything, this command targets exactly one component and is designed for non-interactive, single-focus execution.

## Workflow

## Quick Navigation

[Step 1](#step-1-identify-the-component) · [Step 2](#step-2-extract-component-configuration) · [Step 3](#step-3-scaffold-the-component) · [Step 4](#step-4-cross-component-wiring) · [Step 5](#step-5-verify--install-build-and-fix) · [Step 6](#step-6-print-summary)

### Step 1: Identify the Component

Extract the component name from the command argument. The name corresponds to a component defined in the SDL.

Locate the SDL:
1. Check `solution.sdl.yaml` in the project root — if it exists, read it
2. If absent, check for `sdl/` directory — read `sdl/README.md` first, then the module containing component definitions (typically `sdl/architecture.yaml` or `sdl/projects.yaml`)

Find the component matching the provided name by searching:
- `architecture.projects[]` (array form)
- `architecture.projects.backend[]` and `architecture.projects.frontend[]` (object form)
- Top-level `components[]`, `modules[]`, or `services[]`

If no matching component is found, respond:

> "Component '{name}' not found in SDL. Available components: {list}."

### Step 2: Extract Component Configuration

From the matching SDL entry, extract all available fields:
- **name** — directory name
- **type** — component type (rest-api, graphql, web, admin, mobile, worker, agent, shared-lib, database, cloud-resource, cdn, queue, cache, etc.)
- **runtime** — runtime/platform (node, python, go, java, swift, kotlin, flutter, terraform, etc.)
- **language** — programming language
- **framework** — framework if specified (express, fastapi, next, react, react-native, flutter, django, spring, etc.)
- **purpose** — what the component does
- **interfaces** — endpoints, events, screens, or ports
- **dataOwnership** — data responsibilities (cross-reference with `domain.entities[]` in SDL)
- **port** — assigned port
- **deploy_target** — deployment target
- Any other component-specific fields (build_tool, rendering, state_management, navigation, permissions, etc.)

**First, check for `architecture-output/_state.json`** — if it exists, read it in full. It provides:
- `entities` — pre-extracted entity names + field lists; use these instead of grepping data-model.md for entity schemas
- `tech_stack` — tech stack summary; cross-check with SDL for component-specific config
- `design` — full palette (primary, secondary, accent, surface, text colors), fonts, border-radius, shadow, icon library, component library. If set by `design-system` command, this is the authoritative source — use it instead of SDL's design section or re-deriving from domain. `tokens_file` points to the full `design-tokens.json` if you need the complete spacing scale.
- `personas` — who uses this component; informs mock data generation for frontends

Then read the SDL and cross-cutting sections:

Also read these cross-cutting SDL sections for context:
- `shared` — shared types, libraries, contracts
- `application_patterns` — folder convention, architecture style
- `security` / `auth` — auth strategy
- `observability` — logging, health checks, metrics
- `devops` — CI/CD, Docker, environments
- `environments` — for .env.example generation
- `design` — design system, color palette, typography, shape, personality (see below)
- `data` — database type, ORM, migrations

Also read these deliverables if they exist for richer context:
- `architecture-output/data-model.md` — entity schemas, relationships, indexes. **Only read this if the entity you need is NOT in `_state.json.entities`.** If reading, use Grep to find only the relevant entity/model section rather than reading the entire file. If `architecture-output/data-model.md` does not exist, fall back to `domain.entities[]` from SDL for the entity name list (check `solution.sdl.yaml` first; if absent, check `sdl/data.yaml` or the relevant `sdl/` module). Field details will need to be inferred from context.
- `architecture-output/mvp-scope.md` — prioritized features and user stories (if split, read the index file first)
- `architecture-output/user-journeys.md` — core user flows
- `architecture-output/user-personas.md` — who we're building for

### Step 3: Scaffold the Component

Create the directory and all starter files appropriate for the component's type and runtime.

**Directory:** Create `{name}/` (or the path specified in the SDL). Use the folder convention from `application_patterns` if available.

---

#### DEPTH REQUIREMENTS — ALL COMPONENT TYPES

The scaffold must produce **production-starter** code, not hello-world boilerplate. Every generated file should contain real, working logic — not TODOs or placeholder comments. Specifically:

**Every component MUST include:**
- Complete package manifest with ALL dependencies (not just framework core — include middleware, validation, logging, testing libraries)
- Working entry point that starts without errors
- At least one meaningful test file with 3+ test cases
- `.env.example` with every variable the component needs (derived from SDL `environments` section)
- `.gitignore` appropriate for the runtime
- `Dockerfile` with multi-stage build (dev + production stages)
- `docker-compose.yml` wiring up the component + its data dependencies
- `README.md` with setup instructions, available scripts, API docs or screen list
- CI workflow (`.github/workflows/ci.yml`) with lint, test, build steps

---

#### BACKEND SERVICES (rest-api, graphql, websocket, background-worker)

**Project structure** (adapt to framework conventions):
```
{name}/
├── src/
│   ├── index.ts                 # Entry point — server startup, graceful shutdown
│   ├── config/
│   │   ├── index.ts             # Env vars loaded and validated (zod or joi)
│   │   └── database.ts          # DB connection config
│   ├── routes/                  # Or controllers/ — one file per resource
│   │   ├── index.ts             # Route registration
│   │   ├── health.ts            # GET /health with dependency checks
│   │   └── {resource}.ts        # One per SDL interface endpoint group
│   ├── middleware/
│   │   ├── auth.ts              # JWT/session verification (from SDL auth strategy)
│   │   ├── correlation-id.ts    # Generate/forward x-correlation-id header
│   │   ├── error-handler.ts     # Global error handler with structured responses
│   │   ├── request-logger.ts    # Per-request pino child logger bound to req.log
│   │   ├── validation.ts        # Request validation middleware
│   │   └── rate-limit.ts        # Rate limiting config
│   ├── models/                  # Or entities/ — one per data model
│   │   └── {entity}.ts          # Schema/model definition from domain.entities[] or data-model.md
│   ├── schemas/                 # Zod schemas — one per resource
│   │   └── {resource}.ts        # Create/update/list/params schemas + inferred types
│   ├── services/                # Business logic layer
│   │   └── {resource}.ts        # Service functions (CRUD + domain logic stubs)
│   ├── lib/
│   │   ├── logger.ts            # Pino structured logger (pino-pretty dev, JSON prod)
│   │   ├── http-client.ts       # Outbound service calls with retry + timeout
│   │   └── errors.ts            # Custom error classes (NotFound, Unauthorized, etc.)
│   └── types/
│       └── index.ts             # Shared types, request/response interfaces
├── tests/
│   ├── health.test.ts           # Health endpoint test
│   └── {resource}.test.ts       # CRUD operation tests (at least 3 tests per resource)
├── package.json
├── tsconfig.json
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
└── .github/workflows/ci.yml
```

**Code depth requirements for backends:**
- **Routes/Controllers:** Implement ALL endpoints declared in SDL `interfaces`. Each route handler should: parse request params/body, call service layer, return typed response with correct HTTP status codes. Include input validation using zod or joi schemas.
- **Models/Entities:** Generate complete schema definitions from `domain.entities[]` in the SDL (check `solution.sdl.yaml` first; if absent, use `sdl/data.yaml` or the relevant `sdl/` module) and `architecture-output/data-model.md` (if it exists). Include all columns, types, constraints, relationships, indexes. Use the ORM specified in SDL (Prisma, Drizzle, TypeORM, Sequelize, SQLAlchemy, etc.).
- **Services:** Implement actual CRUD logic (create, read, update, delete, list with pagination) for each resource. Include error handling (not found, duplicate, validation errors).
- **Auth middleware:** Implement the strategy from SDL (JWT verification, API key check, OAuth token validation). Include role-based access control stubs if SDL declares roles. Read `auth.serviceTokenModel` from SDL (jwt | session | api-key) to determine the correct token validation mechanism for backend middleware and the correct injection strategy for the frontend API client.
- **Health check:** Check DB connectivity, cache connectivity, and any external service dependencies. Return structured JSON: `{ status, checks: { db: "ok", cache: "ok" }, uptime, version }`.
- **Production hardening — REQUIRED on all backends:** Apply all 9 patterns for the component's runtime.

  **Runtime-specific implementations:** When scaffolding a non-Node.js component, read the matching file before generating hardening code:
  - Python/FastAPI: `skills/production-hardening/python.md`
  - .NET: `skills/production-hardening/dotnet.md`
  - Go: `skills/production-hardening/go.md`
  - Node.js: patterns in `skills/production-hardening/SKILL.md` (already loaded)

  Specifically:
  - **Correlation ID** (`src/middleware/correlation-id.ts`): generate/forward `x-correlation-id` on every request. Mount BEFORE logger middleware.
  - **Graceful shutdown** (`src/index.ts`): handle SIGTERM/SIGINT, drain HTTP server, disconnect Prisma, quit Redis, force-exit after 10s. Set `app.locals.isShuttingDown = true` on shutdown start.
  - **Validation** (`src/schemas/`, `src/middleware/validate.ts`): Validate all request inputs using the runtime-appropriate schema library: `zod` (Node.js), Pydantic (Python — built into FastAPI), FluentValidation (.NET), `go-playground/validator` (Go). Return 400 with structured error details on failure. Also validate env vars at startup — fail fast with a clear error if required vars are missing.
  - **Deep health check** (`src/routes/health.ts`): run `SELECT 1` against DB, `PING` against Redis. Return `{ status, version, uptime, memory, checks: { db, cache } }`. Return 503 on DB failure, 200 on cache failure. Return 503 immediately when `app.locals.isShuttingDown === true`.
  - **Structured logger** (`src/lib/logger.ts`): Use the runtime-appropriate structured logger from `skills/production-hardening/SKILL.md`: `pino` (Node.js), `structlog` (Python), `Serilog` (.NET), `log/slog` (Go). Dev: human-readable. Prod: JSON. Always include service name, version, env, and correlationId. ZERO `console.log` in any generated file except `src/config/index.ts` startup abort.
  - **Retry + timeout** (`src/lib/http-client.ts`): Wrap all outbound service calls with: 10s timeout, 3 retries with exponential backoff (100ms/200ms/400ms) on 5xx and network errors. Never retry 4xx. Use `AbortController` (Node.js), `tenacity` (Python), `Polly` / `Microsoft.Extensions.Http.Resilience` (.NET), manual retry loop (Go). See `skills/production-hardening/SKILL.md` for full implementations.
  - **Soft delete** (Prisma schema + `src/middleware/soft-delete.ts`): add `deletedAt DateTime?` + `@@index([deletedAt])` to every model. Prisma middleware rewrites delete→update and filters `deletedAt: null` on all reads. Apply in `src/config/database.ts`.
  - **CSP + CORS** (`src/index.ts`): Apply CSP + HSTS using: `helmet` (Node.js/Express), `secure` pip package (Python/FastAPI), `NWebsec` + manual headers (.NET), `unrolled/secure` (Go). Strict CSP in production; relaxed in development (allow `unsafe-eval`). Configure CORS from `ALLOWED_ORIGINS` env var. See `skills/production-hardening/SKILL.md` for full implementations.
- **Request logger middleware** (`src/middleware/request-logger.ts`): log every incoming request with method, URL, and correlationId via a pino child logger bound to `req.log`. Use `req.log` in all route handlers (not the root logger) so correlationId appears on every log line from that request.
- **Config:** Validate ALL env vars at startup using a schema — fail fast with clear error messages if required vars are missing.
- **Error handling:** Global error handler that catches all exceptions, logs them, and returns consistent error response format: `{ error: { code, message, details? } }`.
- **Database setup:** Include migration files or schema sync commands. For Prisma: include `schema.prisma` with all models. For Drizzle: include schema files. For raw SQL: include migration files.

---

#### FRONTEND WEB APPS (web, admin, dashboard, crm, booking, ai-chat)

**Project structure:**
```
{name}/
├── src/
│   ├── app/                     # Or pages/ depending on framework
│   │   ├── layout.tsx           # Root layout with navigation, theme provider
│   │   ├── page.tsx             # Home/dashboard page with real content
│   │   ├── login/page.tsx       # Auth pages (if SDL declares auth)
│   │   └── {feature}/page.tsx   # One page per SDL interface screen/flow
│   ├── components/
│   │   ├── ui/                  # Base UI components (Button, Card, Input, Table, Badge, Modal)
│   │   ├── layout/              # Sidebar, Header, Footer, Navigation
│   │   └── {feature}/           # Feature-specific components
│   ├── lib/
│   │   ├── api.ts               # API client with typed endpoints matching backend SDL interfaces
│   │   ├── auth.ts              # Auth helpers (token storage, login/logout, protected routes)
│   │   └── utils.ts             # Common utilities
│   ├── hooks/                   # Custom React hooks (useAuth, useFetch, useForm)
│   ├── stores/                  # State management (if SDL specifies: zustand, redux, etc.)
│   ├── types/                   # TypeScript interfaces matching backend response types
│   └── data/
│       └── mock.ts              # Realistic mock data for all pages (typed, not lorem ipsum)
├── public/                      # Static assets
├── tests/
│   └── components/              # Component tests
├── package.json
├── tsconfig.json
├── tailwind.config.ts           # Themed with SDL design section
├── Dockerfile
├── .env.example
├── .gitignore
├── README.md
└── .github/workflows/ci.yml
```

**Code depth requirements for frontends:**
- **Pages:** Every page declared in SDL interfaces/screens MUST be created with real content — data tables with mock rows, forms with all fields, dashboards with metric cards. NO empty pages or "Coming soon" placeholders.
- **Navigation:** Working sidebar/topbar navigation that routes between all pages. Active state highlighting. **Mobile responsive** — sidebar hidden on mobile (`hidden md:flex`) with hamburger button + slide-in drawer overlay. Bottom tab bar for mobile-first products.
- **API client** (`src/lib/api.ts`): Typed functions for every backend endpoint. Read `skills/production-hardening/SKILL.md` Pattern 3 (Auth Token Interceptor) and Pattern 7 (Retry + Timeout) and implement both in `api.ts`:
  - Send `x-correlation-id: crypto.randomUUID()` on every request (Pattern 1 frontend integration)
  - Inject Bearer token from the auth provider declared in SDL `auth.identityProvider` (see provider matrix in skill)
  - On 401: attempt token refresh once using the provider-appropriate refresh call, retry original request; redirect to `/login` on refresh failure
  - `AbortController` with 10s timeout on every request
  - 3 retries with exponential backoff (100/200/400ms) on 5xx and network errors; never retry on 4xx
  - Export typed `api.get/post/put/patch/delete` methods
- **Auth flow:** If SDL declares auth: implement login page, signup page, token storage, protected route wrapper, and logout. Use the auth strategy from SDL (JWT, OAuth, etc.).
- **UI components:** Build 6-8 reusable components that the pages actually use (not a separate component library — components created to serve the pages).
- **Mock data:** Realistic, domain-appropriate data in `data/mock.ts`. Typed objects, not random strings. Enough data to fill tables (10+ rows) and populate dashboards.
- **Design system:** Apply SDL `design` section:
  - Tailwind config with SDL palette colors mapped to primary/secondary/accent; set `darkMode: 'class'`
  - CSS variables in `globals.css` for both `:root` (light) and `.dark` (dark) — all palette colors as CSS vars
  - Font setup for declared heading/body/mono fonts
  - Component library installation if specified
  - Icon library installation if specified
  - If NO design section: select a domain-appropriate color palette — NEVER use indigo/purple as default
- **Dark/light mode — REQUIRED on all frontend scaffolds:**
  - `ThemeContext.tsx` with `useTheme()` hook — reads `localStorage`, falls back to `prefers-color-scheme`, toggles `dark` class on `<html>`
  - All components use CSS variable-backed Tailwind classes (`bg-surface`, `text-text-primary`) — never hardcoded colours
  - Theme toggle button (sun/moon icon) in the Header/Navbar
- **Internationalisation & RTL — REQUIRED on all frontend scaffolds:**
  - Install `i18next` + `react-i18next`
  - `src/i18n/index.ts` — initialise with `en` default, `es` as second locale, `ar` as third
  - `src/i18n/locales/en.json`, `es.json`, and `ar.json` — cover all nav labels, page titles, button labels, table headers, form labels, empty states
  - All user-facing strings via `useTranslation()`: `const { t } = useTranslation(); t('nav.dashboard')`
  - Language switcher dropdown (EN / ES / AR) in Header/Navbar
  - RTL support: in i18next `languageChanged` callback, set `document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr'` and `document.documentElement.lang = lang`. Use Tailwind `rtl:` modifier for layout-sensitive classes.
- **Accessibility — REQUIRED on all frontend scaffolds:**
  - Semantic HTML: `<nav>`, `<main>`, `<aside>`, `<header>`, `<section>`, `<button>` (never `<div onClick>`)
  - Visible focus rings on all interactive elements: `focus-visible:ring-2 focus-visible:ring-primary focus-visible:outline-none`
  - `aria-label` or `aria-labelledby` on all icon-only buttons and inputs without visible labels
  - Tables: `<thead>`, `<th scope="col">` headers; list items use `role="listitem"` implicitly via `<li>`
  - Form inputs: every `<input>` has a paired `<label htmlFor>` — no floating-label without aria fallback
  - Modals: trap focus inside while open, close on Escape key, restore focus to trigger element on close
  - WCAG AA contrast: text must meet 4.5:1 against background. Verify colour palette choices against this threshold — if in doubt, darken text or lighten background.
- **State management:** If SDL specifies (zustand, redux, etc.), set up stores for auth state and at least one domain store.
- **CSP headers (Next.js only)** (`next.config.ts`): add security headers block per Pattern 9 in `skills/production-hardening/SKILL.md`. Include `ALLOWED_ORIGINS` in `.env.example`. For Vite-based frontends, document CSP headers to be set at the reverse proxy/CDN layer in the README.

---

#### MOBILE APPS (mobile, react-native, flutter, swift, kotlin)

**Code depth requirements:**
- Mobile project structure matching framework conventions (Expo, Flutter, Xcode, Android Studio)
- Navigation setup (stack + tab navigation) with all screens from SDL
- Theme/design tokens from SDL mapped to platform conventions
- API client stub with typed endpoints matching backend
- At least 3 screens with real UI: auth, main list/dashboard, and detail view
- Push notification setup (stubs for registration + handling)
- Deep linking configuration matching SDL routes
- Permission declarations for camera, location, etc. from SDL
- OTA update config if applicable (Expo Updates, CodePush)
- `.env.example` with API URLs, .gitignore, README.md

---

#### AI AGENTS (agent, ai-agent)

**Code depth requirements:**
- Agent framework setup (FastAPI + LangChain, or as SDL specifies)
- Tool definitions — one file per tool declared in SDL, with input/output schemas
- Prompt templates for agent system prompt and tool descriptions
- Conversation memory setup (in-memory or Redis-backed)
- API endpoint for chat/invoke with streaming support
- Rate limiting and token budget tracking
- `.env.example` with API keys, model config, temperature settings
- Health check with model availability verification
- At least 2 working tool implementations (not just stubs)
- Dockerfile, docker-compose.yml, README.md

---

#### SHARED LIBRARIES (shared-lib, shared, common)

**Code depth requirements:**
- Library manifest with build config (tsup, rollup, or platform-appropriate bundler)
- Type definitions / interfaces from SDL `shared` section — ALL types, not just one
- Utility functions for common patterns (error handling, validation, date formatting)
- Export barrel file (index.ts) with all public exports
- Build script that produces both ESM and CJS (for Node.js libs)
- README.md with usage instructions and API reference

---

#### DATABASES / DATA STORES (database, db, cache, queue)

**Code depth requirements:**
- Migration files with ALL tables/collections from `domain.entities[]` in SDL and `architecture-output/data-model.md` (if it exists)
- Seed script with realistic sample data (10+ records per table)
- docker-compose.yml with the database container + volume + health check
- Connection configuration for each environment
- Backup script stub
- README.md with setup, migration, and seed instructions

---

#### CLOUD RESOURCES / INFRASTRUCTURE (cloud-resource, infrastructure, cdn, storage)

**Code depth requirements:**
- IaC templates (Terraform, Pulumi, CloudFormation as specified in SDL)
- Resource configuration for ALL resources declared in SDL
- Variable definitions with descriptions and defaults
- Output definitions for resource URLs/IDs needed by other components
- Environment separation (dev/staging/prod) using workspaces or separate configs
- README.md with provisioning instructions, prerequisites, and cost estimate

---

### Step 4: Cross-Component Wiring

After generating all files for the component:

Read `architecture.services[].dependsOn[]` from the SDL for the component being scaffolded — this lists the other services and external providers it calls, which directly maps to the API client stubs and environment variables to generate.

1. **API URLs:** If this component consumes another component's API, add the URL to `.env.example` as `{OTHER_SERVICE}_URL=http://localhost:{port}`
2. **CORS / ALLOWED_ORIGINS (backends only):** For every backend/agent component, read the SDL to find all frontend components that list this backend as a dependency. Set `ALLOWED_ORIGINS` in `.env.example` to a comma-separated list of their `dev_port` URLs (e.g. `ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173`). For staging/production, use the frontend's environment domain from the SDL `environments` section. Never hardcode `http://localhost:3000` — always derive from the manifest.
3. **Shared types:** If SDL has a `shared` section, import types from the shared package (use relative paths or package name)
4. **Auth tokens:** If this component authenticates against another service, include token passing in the API client
5. **Docker networking:** In `docker-compose.yml`, reference other services by name for inter-service communication

### Step 5: Verify — Install, Build, and Fix

**This step is MANDATORY. Do NOT skip it.**

After writing all files, run the following verification sequence inside the `{name}/` directory:

#### 5a. Install dependencies
```bash
cd {name} && npm install   # or pip install, go mod download, etc.
```
If install fails (missing packages, version conflicts):
- Read the error output
- Fix `package.json` / `requirements.txt` / `go.mod` (add missing deps, fix version ranges)
- Re-run install until it succeeds

#### 5b. Build / compile
```bash
npm run build   # or tsc --noEmit, go build ./..., python -m py_compile, etc.
```
For TypeScript projects without a build script, run: `npx tsc --noEmit`

If the build fails (type errors, missing imports, syntax errors):
- Read EVERY error message
- Fix the source files — do NOT delete code or add `// @ts-ignore` to make errors go away. Fix them properly:
  - Missing import → add the import
  - Type mismatch → fix the type or the value
  - Missing property → add it to the interface/type
  - Module not found → install the package or fix the import path
- Re-run the build
- **Repeat until the build passes with zero errors**

#### 5c. Run tests (if test files were created)
```bash
npm test   # or pytest, go test ./..., etc.
```
If tests fail:
- Read the failure output
- Fix the test OR the source code (whichever is wrong)
- Re-run tests until they pass

#### 5d. Lint check (if linter is configured)
```bash
npm run lint   # if lint script exists
```
Fix lint errors if any. Do NOT disable lint rules to suppress errors.

**The scaffold is NOT complete until install + build succeed with zero errors.** If you cannot resolve an error after 3 attempts, document the remaining issue in the README under a "Known Issues" section — but this should be rare.

### Step 6: Print Summary

```
Scaffold complete for "{name}" ({type}, {runtime}):

Files created:
- {name}/...
- {name}/...

Verification:
✓ Dependencies installed
✓ Build passed (zero errors)
✓ Tests passed (X/X)

Port: {port or "PORT env var"}
Test: npm test (or equivalent)
Start: npm run dev (or equivalent)
```

### Final Step: Log Activity

After the verification step passes and all files are written, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"scaffold-component","outcome":"completed","files":["<component-name>/src/index.ts","<component-name>/package.json"],"summary":"Scaffolded <component-name> (<type>, <framework>). <N> files created, build and tests pass."}
```

Replace `<component-name>`, `<type>`, `<framework>`, and `<N>` with actual values. List all files created in the `files` array (paths relative to the project root). Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

## Output Rules

- Scaffold ONLY the named component — do NOT create or modify other component directories
- Use `[non_interactive:true]` mode — no questions, no confirmations
- Make reasonable assumptions for anything not specified in the SDL
- For UI styling: ALWAYS use the SDL `design` section colors if present. If absent, choose a domain-appropriate palette. NEVER default to indigo/purple — use teal, emerald, sky, rose, amber, or cyan instead
- **ALL frontend scaffolds MUST be mobile responsive** — sidebar collapses to hamburger drawer on mobile, tables degrade to card layout, all grids use responsive breakpoints (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`), touch targets min 44px, modals full-screen on mobile, no fixed-width containers without `max-w` + `w-full`
- **ALL frontend scaffolds MUST include dark/light mode** (`darkMode: 'class'`, CSS variables, ThemeContext, toggle in header)
- **ALL frontend scaffolds MUST include i18n** (`i18next` + `react-i18next`, `en.json` + `es.json` + `ar.json`, all strings via `t()`, RTL direction on `<html>`)
- **ALL frontend scaffolds MUST include accessibility** (semantic HTML, visible focus rings, ARIA labels, WCAG AA contrast, keyboard navigation, modal focus trapping)
- If the component depends on shared types, create import stubs but do NOT scaffold the shared package (another agent handles that)
- Match framework and runtime conventions exactly (e.g., App Router for Next.js, Expo for React Native)
- **CRITICAL: Generate REAL code with actual logic — not placeholder comments, TODOs, or empty function bodies. Every file should work when the project starts.**
- **CRITICAL: You MUST run install + build and fix all errors before finishing. A scaffold that doesn't compile is a failed scaffold.**
- When reading `architecture-output/data-model.md`, use Grep to extract only the relevant entity — do not read the entire file
- If any generated markdown file exceeds ~15KB, split into numbered parts — always generate complete content
- Use tables instead of prose for structured data (entities, endpoints, config)
- Do NOT include the CTA footer
