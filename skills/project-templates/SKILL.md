---
name: project-templates
description: Starter file templates and boilerplate for scaffolding projects across frontend, backend, mobile, and AI agent frameworks. Sub-files: nextjs.md, react-vite.md, react-native.md, ios-swift.md, android-kotlin.md, frontend-config.md, nodejs.md, python.md, go.md, dotnet.md, nestjs.md, spring-boot.md
---

# Project Templates

Starter templates for each supported framework. Used by the scaffolder agent to create real, working project scaffolds.

> **All framework templates are in dedicated sub-files — load the relevant sub-file for the target framework:**
>
> | Sub-file | Covers |
> |----------|--------|
> | `skills/project-templates/nextjs.md` | Next.js (App Router) |
> | `skills/project-templates/react-vite.md` | React (Vite), Vue/static builds |
> | `skills/project-templates/react-native.md` | React Native (Expo Managed) |
> | `skills/project-templates/ios-swift.md` | Swift / SwiftUI (native iOS) |
> | `skills/project-templates/android-kotlin.md` | Kotlin / Jetpack Compose (native Android) |
> | `skills/project-templates/frontend-config.md` | API client, auth, monitoring, realtime, state (all web frontends) |
> | `skills/project-templates/nodejs.md` | Node.js / Express, BullMQ worker, Node.js agent |
> | `skills/project-templates/python.md` | Python / FastAPI, Python agent |
> | `skills/project-templates/go.md` | Go / Gin |
> | `skills/project-templates/dotnet.md` | .NET / ASP.NET Core (Clean Architecture) |
> | `skills/project-templates/nestjs.md` | NestJS |
> | `skills/project-templates/spring-boot.md` | Java / Spring Boot (Maven) |
>
> For unlisted runtimes (Django, Rails, Laravel, Ionic, Angular, Hono, Remix, Astro, Flutter, Swift, Kotlin), the scaffolder generates starter files dynamically — the predefined templates serve as the quality benchmark.

## Frontend Templates

> All frontend framework templates are in dedicated sub-files:
> - **Next.js (App Router):** `skills/project-templates/nextjs.md`
> - **React (Vite):** `skills/project-templates/react-vite.md` (also covers Vue/Svelte/Angular static builds for Dockerfile)
> - **Frontend config** (API client, auth, monitoring, realtime, state — applied after any framework): `skills/project-templates/frontend-config.md`

---

## Backend Templates

> All backend framework templates are in dedicated sub-files:
> - **Node.js / Express, BullMQ worker, Node.js agent:** `skills/project-templates/nodejs.md`
> - **Python / FastAPI, Python agent:** `skills/project-templates/python.md`
> - **Go / Gin:** `skills/project-templates/go.md`
> - **.NET / ASP.NET Core (Clean Architecture):** `skills/project-templates/dotnet.md`
> - **NestJS:** `skills/project-templates/nestjs.md`
> - **Java / Spring Boot:** `skills/project-templates/spring-boot.md`

---

## Mobile Templates

> All mobile framework templates are in dedicated sub-files:
> - **React Native (Expo Managed):** `skills/project-templates/react-native.md`
> - **Swift / SwiftUI (native iOS):** `skills/project-templates/ios-swift.md`
> - **Kotlin / Jetpack Compose (native Android):** `skills/project-templates/android-kotlin.md`
> - **Flutter:** LLM-generated — use `flutter create .` CLI, then apply manifest config

---

## Agent Templates

> Agent templates are included in the runtime sub-files:
> - **Node.js agent:** `skills/project-templates/nodejs.md`
> - **Python agent:** `skills/project-templates/python.md`

---

## Security Middleware Templates

> Security middleware templates are included in the runtime sub-files:
> - **Node.js** (auth, security headers, correlation ID): `skills/project-templates/nodejs.md`
> - **Python** (FastAPI auth dependency, correlation middleware): `skills/project-templates/python.md`
> - **Go** (Gin auth + correlation middleware): `skills/project-templates/go.md`
> - **.NET** (auth middleware, correlation ID middleware): `skills/project-templates/dotnet.md`

---

## Observability Templates

> Structured logger, health check, and observability templates are included in the runtime sub-files:
> - **Node.js** (pino logger, `/health` + `/health/ready`): `skills/project-templates/nodejs.md`
> - **Python** (structlog): `skills/project-templates/python.md`
> - **Go** (slog, health handlers): `skills/project-templates/go.md`
> - **.NET** (Serilog, health endpoint): `skills/project-templates/dotnet.md`

---

## DevOps Templates

### GitHub Actions CI Workflow

> Runtime-specific CI workflows are in the runtime sub-files (nodejs.md, python.md, go.md, dotnet.md).

### docker-compose.yml — MANDATORY for all backend services

Every backend service MUST include a `docker-compose.yml` for local development. Web frontends SHOULD also include one if they have backend dependencies.

**IMPORTANT — Port collision prevention:** Each service in the architecture MUST use a unique host port. Assign ports sequentially starting from the manifest's `dev_port` for each component. Never use the same host port for two different services. Use the `${PORT:-{{dev-port}}}` pattern so ports can be overridden via `.env`.

```yaml
services:
  {{component-name}}:
    build: .
    ports:
      - "${PORT:-{{dev-port}}}:{{dev-port}}"
    env_file: .env
    depends_on:
      - db
      - redis

  # Add/remove services based on manifest databases.
  # Use unique host ports per component to avoid collisions across services.
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: {{component-name}}
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "{{db-host-port}}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "{{redis-host-port}}:6379"

volumes:
  pgdata:
```

**Port assignment strategy for multi-service architectures:**
When scaffolding multiple services, assign non-overlapping host ports for infrastructure containers:
- Service 1 DB: 5432, Redis: 6379
- Service 2 DB: 5433, Redis: 6380
- Service 3 DB: 5434, Redis: 6381
- And so on...

This prevents port collisions when running multiple services locally at the same time.

---

## Shared Package Templates

### Shared Types Package

> Runtime-specific shared types packages are in the runtime sub-files:
> - **TypeScript** (package.json, tsconfig, index.ts): `skills/project-templates/nodejs.md`
> - **Python** (pyproject.toml, pydantic models): `skills/project-templates/python.md`

---

## Common Files

These files are added to every project regardless of framework.

### .editorconfig

Add to the repo root — enforces consistent formatting across editors and runtimes:

```ini
root = true

[*]
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.{ts,tsx,js,jsx,json,yaml,yml,css,html}]
indent_style = space
indent_size = 2

[*.{py}]
indent_style = space
indent_size = 4

[*.{cs}]
indent_style = space
indent_size = 4

[*.go]
indent_style = tab
indent_size = 4

[Makefile]
indent_style = tab
```

### dependabot.yml

Add to `.github/dependabot.yml` in the repo root:

```yaml
version: 2
updates:
  # Node.js / npm
  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5
    groups:
      dev-dependencies:
        dependency-type: development

  # Python / pip
  - package-ecosystem: pip
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  # Go modules
  - package-ecosystem: gomod
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  # .NET / NuGet
  - package-ecosystem: nuget
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 5

  # GitHub Actions
  - package-ecosystem: github-actions
    directory: "/"
    schedule:
      interval: weekly
```

> Generate one block per package ecosystem present in the project. Always include the `github-actions` block.

### Security Scanning Workflow

Add `.github/workflows/security.yml` — language-agnostic, works for all runtimes:

```yaml
name: Security

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1"   # weekly Monday 06:00 UTC

permissions:
  contents: read
  security-events: write   # required for CodeQL to upload SARIF results

jobs:
  secret-scan:
    name: Secret scanning (Gitleaks)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0   # full history so Gitleaks can scan all commits

      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  codeql:
    name: SAST (CodeQL)
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Add only the languages present in this repo
        language: [javascript-typescript]
        # Other supported values: python, go, csharp, java, ruby, swift
    steps:
      - uses: actions/checkout@v4

      - uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-and-quality

      - uses: github/codeql-action/autobuild@v3

      - uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
```

**Language matrix values by runtime:**

| Runtime | `language` value |
|---|---|
| Node.js / TypeScript | `javascript-typescript` |
| Python | `python` |
| Go | `go` |
| .NET / C# | `csharp` |
| Multiple runtimes in monorepo | list all: `[javascript-typescript, python]` |

> CodeQL results appear in the GitHub Security tab → Code scanning alerts. No external accounts needed — it's built into GitHub.

**.gitleaks.toml (optional — add to repo root to suppress false positives):**
```toml
[allowlist]
description = "Global allowlist"
paths = [
  ".env.example",      # example files intentionally contain placeholder keys
]
regexes = [
  "EXAMPLE_",          # suppress vars named *_EXAMPLE_*
  "your-.*-here",      # suppress placeholder strings
]
```

### .gitignore

> Runtime-specific .gitignore files are in the runtime sub-files (nodejs.md, python.md, go.md, dotnet.md). Always add one per component.

### .env.example

Generate from the manifest's integrations and environments. Format:

**Backend service:**
```bash
# Server
PORT={{dev-port}}
NODE_ENV=development

# {{service-name}} — {{category}}
# Get credentials at: {{signup-url}}
{{ENV_VAR_NAME}}=
```

**Web frontend (Vite):**
```bash
# API URLs — update per environment
# DEV:     http://localhost:{{backend-dev-port}}
# STAGING: {{staging-url}}
# PROD:    {{prod-url}}
VITE_API_URL=http://localhost:{{backend-dev-port}}

# WebSocket URL (if realtime is configured)
# VITE_WS_URL=ws://localhost:{{backend-dev-port}}

# Monitoring
# VITE_SENTRY_DSN=
# VITE_APP_INSIGHTS_KEY=
```

**Mobile app (Expo):**
```bash
# API URLs — update per environment
# DEV:     http://localhost:{{backend-dev-port}}
# STAGING: {{staging-url}}
# PROD:    {{prod-url}}
EXPO_PUBLIC_API_URL=http://localhost:{{backend-dev-port}}

# Push Notifications
# EXPO_PUBLIC_PUSH_PROJECT_ID=

# Monitoring
# EXPO_PUBLIC_SENTRY_DSN=

# OTA Updates
# EXPO_PUBLIC_UPDATE_URL=
```

Include a comment with the signup URL for each integration service so the user knows where to get credentials. Use environment URLs from the manifest's `environments` section.

### README.md

Auto-generate for each component:

```markdown
# {{component-name}}

{{component-description}}

## Tech Stack

- **Framework:** {{framework}}
- **Language:** {{language}}

## Setup

1. Clone the repository
2. Copy environment variables: `cp .env.example .env`
3. Fill in your credentials in `.env`
4. Install dependencies: `{{install-command}}`
5. Start development server: `{{dev-command}}`

## Scripts

| Command | Description |
|---------|-------------|
| `{{dev-command}}` | Start development server |
| `{{build-command}}` | Build for production |
| `{{start-command}}` | Start production server |

## Architecture

This component is part of the **{{project-name}}** architecture.

Other components:
{{#each other-components}}
- **{{name}}** — {{description}}
{{/each}}

---

*Scaffolded by [Architect AI](https://github.com/navraj007in/architecture-cowork-plugin)*
```

### Dockerfile — MANDATORY for all backends and agents

Every backend service, worker, and agent MUST include a Dockerfile. This is not optional.

> Runtime-specific Dockerfiles are in the runtime sub-files:
> - **Node.js:** `skills/project-templates/nodejs.md`
> - **Python:** `skills/project-templates/python.md`
> - **Go:** `skills/project-templates/go.md` (distroless static image)
> - **.NET:** `skills/project-templates/dotnet.md` (Alpine + aspnet runtime)
> - **NestJS:** `skills/project-templates/nestjs.md`
> - **Spring Boot:** `skills/project-templates/spring-boot.md` (Maven multi-stage)

### Dockerfile — for web frontends (include where applicable)

Web frontends that produce a build artifact SHOULD include a Dockerfile. Skip only for mobile-only targets (Expo, Flutter).

> Frontend Dockerfiles are in the framework sub-files:
> - **Next.js (SSR):** `skills/project-templates/nextjs.md`
> - **React/Vue/Svelte/Angular (static + nginx):** `skills/project-templates/react-vite.md`

## Template Variables

All templates use `{{variable}}` placeholders. The scaffolder agent replaces these with actual values from the architecture manifest:

| Variable | Source |
|----------|--------|
| `{{component-name}}` | Manifest component name (kebab-case) |
| `{{component-description}}` | Manifest component description |
| `{{project-name}}` | Manifest project name |
| `{{framework}}` | Detected framework |
| `{{language}}` | TypeScript, Python, etc. |
| `{{install-command}}` | `npm install` or `pip install -r requirements.txt` |
| `{{dev-command}}` | `npm run dev` or `uvicorn main:app --reload` |
| `{{build-command}}` | `npm run build` or `N/A` |
| `{{start-command}}` | `npm start` or `uvicorn main:app` |
| `{{ENV_VAR_NAME}}` | Derived from manifest integrations |
| `{{service-name}}` | Integration service name |
| `{{signup-url}}` | From known-services skill |
| `{{dev-port}}` | From manifest frontend `dev_port` or service port |
| `{{backend-dev-port}}` | Port of the primary backend service |
| `{{staging-url}}` | From manifest `environments[name=staging].domain` |
| `{{prod-url}}` | From manifest `environments[name=production].domain` |
| `{{bundle-id-ios}}` | From manifest mobile `bundle_id.ios` |
| `{{bundle-id-android}}` | From manifest mobile `bundle_id.android` |
| `{{deep-linking-scheme}}` | From manifest mobile `deep_linking.scheme` |
| `{{associated-domains}}` | From manifest mobile `deep_linking.associated_domains[]` |
| `{{token-storage}}` | From manifest `client_auth.token_storage` |
| `{{error-tracking}}` | From manifest `monitoring.error_tracking` |
| `{{analytics}}` | From manifest `monitoring.analytics` |
| `{{service-prefix}}` | API path prefix for backend connection |
| `{{connection-purpose}}` | From manifest `backend_connections[].purpose` |
