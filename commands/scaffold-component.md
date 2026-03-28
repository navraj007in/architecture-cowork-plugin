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

### Step 1: Identify the Component

Extract the component name from the command argument. The name corresponds to a component defined in `solution.sdl.yaml`.

Read `solution.sdl.yaml` from the project root. Find the component matching the provided name by searching:
- `architecture.projects[]` (array form)
- `architecture.projects.backend[]` and `architecture.projects.frontend[]` (object form)
- Top-level `components[]`, `modules[]`, or `services[]`

If no matching component is found, respond:

> "Component '{name}' not found in solution.sdl.yaml. Available components: {list}."

### Step 2: Extract Component Configuration

From the matching SDL entry, extract all available fields:
- **name** — directory name
- **type** — component type (rest-api, graphql, web, admin, mobile, worker, agent, shared-lib, database, cloud-resource, cdn, queue, cache, etc.)
- **runtime** — runtime/platform (node, python, go, java, swift, kotlin, flutter, terraform, etc.)
- **language** — programming language
- **framework** — framework if specified (express, fastapi, next, react, react-native, flutter, django, spring, etc.)
- **purpose** — what the component does
- **interfaces** — endpoints, events, screens, or ports
- **dataModels** / **dataOwnership** — data responsibilities
- **port** — assigned port
- **deploy_target** — deployment target
- Any other component-specific fields (build_tool, rendering, state_management, navigation, permissions, etc.)

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
- `architecture-output/data-model.md` — entity schemas, relationships, indexes
- `architecture-output/mvp-scope.md` — prioritized features and user stories
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
│   │   ├── error-handler.ts     # Global error handler with structured responses
│   │   ├── validation.ts        # Request validation middleware
│   │   └── rate-limit.ts        # Rate limiting config
│   ├── models/                  # Or entities/ — one per data model
│   │   └── {entity}.ts          # Schema/model definition from SDL dataModels
│   ├── services/                # Business logic layer
│   │   └── {resource}.ts        # Service functions (CRUD + domain logic stubs)
│   ├── lib/
│   │   ├── logger.ts            # Structured logger (pino/winston)
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
- **Models/Entities:** Generate complete schema definitions from SDL `dataModels` and `architecture-output/data-model.md`. Include all columns, types, constraints, relationships, indexes. Use the ORM specified in SDL (Prisma, Drizzle, TypeORM, Sequelize, SQLAlchemy, etc.).
- **Services:** Implement actual CRUD logic (create, read, update, delete, list with pagination) for each resource. Include error handling (not found, duplicate, validation errors).
- **Auth middleware:** Implement the strategy from SDL (JWT verification, API key check, OAuth token validation). Include role-based access control stubs if SDL declares roles.
- **Health check:** Check DB connectivity, cache connectivity, and any external service dependencies. Return structured JSON: `{ status, checks: { db: "ok", cache: "ok" }, uptime, version }`.
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
- **Navigation:** Working sidebar/topbar navigation that routes between all pages. Active state highlighting. Responsive — collapses on mobile.
- **API client:** Typed functions for every backend endpoint. Include request/response type definitions. Handle loading, error, and empty states.
- **Auth flow:** If SDL declares auth: implement login page, signup page, token storage, protected route wrapper, and logout. Use the auth strategy from SDL (JWT, OAuth, etc.).
- **UI components:** Build 6-8 reusable components that the pages actually use (not a separate component library — components created to serve the pages).
- **Mock data:** Realistic, domain-appropriate data in `data/mock.ts`. Typed objects, not random strings. Enough data to fill tables (10+ rows) and populate dashboards.
- **Design system:** Apply SDL `design` section:
  - Tailwind config with SDL palette colors mapped to primary/secondary/accent
  - Font setup for declared heading/body/mono fonts
  - Component library installation if specified
  - Icon library installation if specified
  - If NO design section: select a domain-appropriate color palette — NEVER use indigo/purple as default
- **State management:** If SDL specifies (zustand, redux, etc.), set up stores for auth state and at least one domain store.

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
- Migration files with ALL tables/collections from SDL `dataModels` and `data-model.md`
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

1. **API URLs:** If this component consumes another component's API, add the URL to `.env.example` as `{OTHER_SERVICE}_URL=http://localhost:{port}`
2. **Shared types:** If SDL has a `shared` section, import types from the shared package (use relative paths or package name)
3. **Auth tokens:** If this component authenticates against another service, include token passing in the API client
4. **Docker networking:** In `docker-compose.yml`, reference other services by name for inter-service communication

### Step 5: Print Summary

```
Scaffold complete for "{name}" ({type}, {runtime}):

Files created:
- {name}/...
- {name}/...

Port: {port or "PORT env var"}
Test: npm test (or equivalent)
Start: npm run dev (or equivalent)
```

## Output Rules

- Scaffold ONLY the named component — do NOT create or modify other component directories
- Use `[non_interactive:true]` mode — no questions, no confirmations
- Make reasonable assumptions for anything not specified in the SDL
- For UI styling: ALWAYS use the SDL `design` section colors if present. If absent, choose a domain-appropriate palette. NEVER default to indigo/purple — use teal, emerald, sky, rose, amber, or cyan instead
- If the component depends on shared types, create import stubs but do NOT scaffold the shared package (another agent handles that)
- Match framework and runtime conventions exactly (e.g., App Router for Next.js, Expo for React Native)
- **CRITICAL: Generate REAL code with actual logic — not placeholder comments, TODOs, or empty function bodies. Every file should work when the project starts.**
- Do NOT include the CTA footer
