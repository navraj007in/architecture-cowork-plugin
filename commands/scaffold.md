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
- If it does not exist or is empty, mark it **NEW**.

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
| `frontends[]` with type `mobile` | Mobile App | `react-native`, `flutter`, `swift`, `kotlin` | React Native (Expo) |
| `services[]` with type `rest-api` or `graphql` | Backend API | `nodejs`, `dotnet`, `python-fastapi`, `go`, `java-spring`, `ruby-rails`, `django` | Node.js/Express |
| `services[]` with type `background-worker` | Worker | `nodejs`, `dotnet`, `python`, `go` | Node.js/BullMQ |
| `services[]` with type `websocket` | Real-time Service | `nodejs`, `dotnet`, `go` | Node.js/Socket.io |
| `agents[]` | AI Agent | `python-fastapi`, `nodejs` | Python/FastAPI |

Always show the resolved framework next to each component name so the user can verify before scaffolding proceeds.

### Step 3: Ask Configuration Questions

**If `[non_interactive:true]` is in the command argument OR if the execution mode constraints say non-interactive**, skip all questions and use these defaults:
- **Parent directory**: current working directory (or the path from `[workspace_dir:...]` if provided)
- **GitHub or local**: Local directories with git init
- **Install dependencies**: Yes
- **Structure / auth / framework choices**: Derive ALL decisions from solution.sdl.yaml and existing ADRs in architecture-output/adrs/. Follow the SDL exactly — do NOT ask the user to choose between options. If the SDL specifies a monorepo structure, use it. If the SDL specifies auth strategy, implement it. If there's a conflict between existing code and SDL, follow the SDL (the SDL is the source of truth).

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
2. Look for a `design` section in `sdl.yaml`

**If design tokens exist**, load them — the scaffolder will use these to configure frontend projects with the correct palette, typography, shape, and motion settings.

**If no design tokens exist but SDL has a `design` section**, use the SDL design fields directly and load the **design-systems.md** reference for implementation patterns.

**If neither exists**, note this in the scaffolder handoff — the scaffolder should infer domain-appropriate defaults from `design-systems.md` (NEVER default to indigo/purple).

Also load `skills/production-hardening/SKILL.md` — the scaffolder applies all 9 production hardening patterns to every Node.js backend and React/Next.js frontend during scaffold generation.

Inform the user:

- If design tokens found: `"Design system detected — your scaffolded frontends will use your design tokens."`
- If no design system: `"Tip: Run /architect:design-system first to get a custom design language. Scaffolding will use domain defaults for now."`

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
- **Design system artifacts** (if available):
  - `design-tokens.json` — full token set for Tailwind config generation
  - `tailwind.config.patch.ts` — ready-to-merge Tailwind extensions
  - SDL `design` section — preset, personality, palette, typography, shape, motion, layout, icons, accessibility

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

### Step 6: Print Summary

After logging activity, print a summary:

```
Scaffold complete! Here's what was created:

| # | Component | Framework | Path | Status |
|---|-----------|-----------|------|--------|
| 1 | web-app | Next.js | ./web-app | Created |
| 2 | api-server | .NET | ./api-server | Augmented (existing code preserved) |
| 3 | worker-service | BullMQ | ./worker-service | Created |
| 4 | mobile-app | Expo | ./mobile-app | Created |
| 5 | support-agent | FastAPI | ./support-agent | Created |

Each project has:
- Framework starter code with folder structure matching the architecture pattern
- Security middleware: CORS from `ALLOWED_ORIGINS`, helmet with environment-specific CSP directives, rate limiting
- Auth token interceptor in frontend API client: Bearer token injection, 401 → refresh → retry, redirect on refresh failure
- Health check endpoints: actual DB (`SELECT 1`) and cache (`PING`) checks, `{ status, uptime, version, memory, checks }` JSON, 503 on critical failure
- Structured logging: pino JSON in prod, pino-pretty in dev; correlationId on every log line; zero console.log
- Correlation ID propagation: `x-correlation-id` generated/forwarded by backend middleware; sent by frontend API client
- Graceful shutdown: SIGTERM/SIGINT handling, connection draining, clean exit
- Zod validation: env vars validated at startup; request body/params/query validated before every handler
- Retry + timeout: 10s AbortController timeout + 3-attempt exponential backoff on all outbound HTTP calls
- Soft delete: `deletedAt` on all Prisma models, transparent Prisma middleware, no hard deletes
- Dockerfile (all backends and agents; web frontends where applicable)
- docker-compose.yml (all backends with data dependencies; web frontends where applicable)
- CI/CD workflow (.github/workflows/ci.yml)
- .env.example with per-environment URL placeholders
- .gitignore
- README.md with setup instructions
- Git initialized with initial commit
- Shared type packages (if applicable)
- Frontend: API client config, backend connection stubs, client auth setup, monitoring SDK init
- Frontend: Design tokens integrated — custom palette, typography, layout shell, and sample page (when design-system phase was completed)
- Mobile: push notification config, deep linking setup, permission declarations, OTA update config

Next steps:
1. Copy .env.example to .env in each project and fill in your credentials
2. Review `src/config/index.ts` in each backend service — fill in any auth-provider-specific env vars
3. Update `ALLOWED_ORIGINS` in `.env` for each backend and frontend to match your actual domain(s)
4. Follow the README in each project to start the dev server
5. Open the sample page to see your design system in action
6. Start building features!
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
