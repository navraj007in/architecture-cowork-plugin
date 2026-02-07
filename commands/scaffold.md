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

Check if a blueprint with a system manifest exists earlier in the conversation.

If yes, extract all components from the manifest (services, frontends, mobile apps, agents).

If no blueprint exists, respond:

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
| `frontend` with type `web` | Frontend | Next.js (App Router) |
| `frontend` with type `mobile` | Mobile App | React Native (Expo) |
| `services[]` with type `rest-api` or `graphql` | Backend API | Node.js/Express |
| `services[]` with type `background-worker` | Worker | Node.js/BullMQ |
| `services[]` with type `websocket` | Real-time Service | Node.js/Socket.io |
| `agents[]` | AI Agent | Python/FastAPI |

### Step 3: Ask Configuration Questions

Ask the user these questions before proceeding:

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
- CI/CD workflow (.github/workflows/ci.yml)
- .env.example with credential placeholders
- .gitignore
- README.md with setup instructions
- Git initialized with initial commit
- Shared type packages (if applicable)

Next steps:
1. Copy .env.example to .env in each project and fill in your credentials
2. Follow the README in each project to start the dev server
3. Start building features!
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
