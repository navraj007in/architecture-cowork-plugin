---
description: Scaffold a single named component from the architecture blueprint
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

### Step 3: Scaffold the Component

Create the directory and all starter files appropriate for the component's type and runtime.

**Directory:** Create `{name}/` (or the path specified in the SDL). Use the folder convention from `application_patterns` if available.

Generate files based on the component type. Use the SDL configuration to determine exactly what to produce:

**For backend services** (rest-api, graphql, websocket, background-worker):
- Package manifest (package.json, go.mod, requirements.txt, etc.)
- Entry point with placeholder routes/handlers matching declared endpoints
- Dockerfile (multi-stage build)
- docker-compose.yml with data dependencies
- Health check endpoint (/health)
- Auth middleware stub if SDL declares auth
- CORS and rate limiting config
- Structured logging setup
- .env.example, .gitignore, README.md, CI workflow

**For frontend web apps** (web, admin, dashboard, crm, booking, ai-chat):
- Framework project structure (Next.js App Router, React/Vite, etc.)
- API client stub pointing to backend services
- Component library setup if specified
- State management boilerplate if specified
- Auth client (token storage, protected routes)
- .env.example with API URLs, .gitignore, README.md, CI workflow

**For mobile apps** (mobile, react-native, flutter, swift, kotlin):
- Mobile project structure (Expo, Flutter, Xcode, Android Studio)
- Navigation setup (stack/tab)
- API client stub
- Push notification, deep linking, permission stubs
- OTA update config if applicable
- .env.example, .gitignore, README.md

**For AI agents** (agent, ai-agent):
- Agent framework setup (FastAPI, LangChain, etc.)
- Tool definition stubs
- .env.example with API keys and model config
- Dockerfile, README.md

**For shared libraries** (shared-lib, shared, common):
- Library manifest and build config
- Type definitions / interfaces from SDL `shared` section
- README.md with usage instructions

**For databases / data stores** (database, db, cache, queue):
- Migration files or schema definitions based on SDL dataModels
- docker-compose.yml with the database container
- Seed script placeholder
- Connection config and README.md

**For cloud resources / infrastructure** (cloud-resource, infrastructure, cdn, storage):
- IaC templates (Terraform, Pulumi, CloudFormation as appropriate)
- Resource configuration files
- README.md with provisioning instructions

**Port assignment:**
- Use the port from the SDL if declared
- If no port, leave a `PORT` env var placeholder — do NOT invent ports

### Step 4: Print Summary

```
Scaffold complete for "{name}" ({type}, {runtime}):

Files created:
- {name}/...
- {name}/...

Port: {port or "PORT env var"}
```

## Output Rules

- Scaffold ONLY the named component — do NOT create or modify other component directories
- Use `[non_interactive:true]` mode — no questions, no confirmations
- Make reasonable assumptions for anything not specified in the SDL
- If the component depends on shared types, create import stubs but do NOT scaffold the shared package (another agent handles that)
- Match framework and runtime conventions exactly (e.g., App Router for Next.js, Expo for React Native)
- Do NOT include the CTA footer
