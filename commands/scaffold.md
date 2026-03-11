---
description: Create repos and bootstrap projects from a blueprint architecture
---

# /architect:scaffold

## Trigger

`/architect:scaffold`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command creates actual project directories (or GitHub repos) and bootstraps each component with framework-appropriate starter code. Turns architecture specs into real, runnable projects.

## Workflow

### Step 1: Check for Blueprint

**First**, check if the command argument contains a `[blueprint_dir:/path/to/dir]` tag. If it does, read the blueprint artifacts from that local directory:
- Read `blueprint.json` for the full blueprint with all deliverables
- Read `00-manifest/manifest.json` for the system manifest
- Extract all components from the manifest (services, frontends, mobile apps, agents)

**If no local directory tag**, check if a blueprint with a system manifest exists earlier in the conversation. If yes, extract all components from the manifest.

If no blueprint exists (neither local files nor conversation), respond:

> "I need an architecture to scaffold from. Run `/architect:blueprint` first to generate your architecture, then come back here to create the projects."

### Step 2: List Components

Present all identified components in a numbered list:

```
I found these components in your architecture:

1. web-app (Next.js / App Router) — Frontend
2. api-server (Node.js / Express) — REST API
3. worker-service (Node.js / BullMQ) — Background worker
4. mobile-app (React Native / Expo) — iOS + Android
5. support-agent (Python / FastAPI) — AI agent with Claude

Ready to scaffold all 5 projects.
```

Map manifest entries to scaffoldable components:

| Manifest Section | Component Type | Default Framework |
|-----------------|----------------|-------------------|
| `frontends[]` with type `web` | Frontend | Next.js (App Router) |
| `frontends[]` with type `admin` | Admin Dashboard | React (Vite) |
| `frontends[]` with type `mobile-web` | Mobile Web App | Next.js (App Router) |
| `frontends[]` with type `crm` | CRM Frontend | React (Vite) |
| `frontends[]` with type `booking` | Booking Frontend | React (Vite) |
| `frontends[]` with type `ai-chat` | AI Chat Interface | React (Vite) |
| `frontends[]` with type `mobile` + framework `react-native` | Mobile App | React Native (Expo) |
| `frontends[]` with type `mobile` + framework `flutter` | Mobile App | Flutter |
| `frontends[]` with type `mobile` + framework `swift` | Mobile App (iOS) | Swift / Xcode |
| `frontends[]` with type `mobile` + framework `kotlin` | Mobile App (Android) | Kotlin / Android Studio |
| `services[]` with type `rest-api` or `graphql` | Backend API | Node.js/Express |
| `services[]` with type `background-worker` | Worker | Node.js/BullMQ |
| `services[]` with type `websocket` | Real-time Service | Node.js/Socket.io |
| `agents[]` | AI Agent | Python/FastAPI |

### Step 3: Ask Configuration Questions

**If `[non_interactive:true]` is in the command argument**, skip all questions and use these defaults:
- **Parent directory**: current working directory (or the path from `[workspace_dir:...]` if provided)
- **GitHub or local**: Local directories with git init
- **Install dependencies**: Yes

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

Inform the user:

- If design tokens found: `"Design system detected — your scaffolded frontends will use your design tokens."`
- If no design system: `"Tip: Run /architect:design-system first to get a custom design language. Scaffolding will use domain defaults for now."`

### Step 4: Delegate to Scaffolder Agent

Pass the following to the **scaffolder** agent:

- Component list with names, types, and frameworks
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

### Step 5: Print Summary

After the scaffolder agent completes, print a summary:

```
Scaffold complete! Here's what was created:

| # | Component | Framework | Path | Status |
|---|-----------|-----------|------|--------|
| 1 | web-app | Next.js | ./web-app | Created |
| 2 | api-server | Express | ./api-server | Created |
| 3 | worker-service | BullMQ | ./worker-service | Created |
| 4 | mobile-app | Expo | ./mobile-app | Created |
| 5 | support-agent | FastAPI | ./support-agent | Created |

Each project has:
- Framework starter code with folder structure matching the architecture pattern
- Security middleware stubs (CORS, auth, rate limiting)
- Health check endpoints with dependency check TODOs
- Structured logging setup
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
2. Follow the README in each project to start the dev server
3. Open the sample page to see your design system in action
4. Start building features!
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
