---
description: Reverse-engineer architecture from an existing codebase — generates SDL and analysis
---

# /architect:import

## Trigger

`/architect:import [scan context JSON]`

## Purpose

Analyze an existing codebase folder. Using the static scan results (detected
tech stack, frameworks, databases, etc.) as a starting point, perform a deep
analysis of the actual source code to understand the architecture, then
generate:

1. `solution.sdl.yaml` — A complete SDL capturing the inferred architecture
2. `architecture-output/import-analysis.md` — Detailed findings report
3. `intent.json` — Derived project intent for lifecycle continuity

## Workflow

### Step 1: Load Scan Context

The command argument may contain a JSON object with static scan results
from a codebase scanner. Parse it to understand what technologies,
frameworks, databases, and infrastructure are already in use.

If no scan context is provided, perform your own analysis by reading directory
listings and key config files (package.json, requirements.txt, go.mod, etc.).

### Step 2: Deep Source Analysis

Using the scan results as a guide, read the actual source code to understand
the system architecture. Read a **representative sample** of source files —
do not attempt to read every file. Focus on architecturally significant code:

**Priority reads:**
- Entry points (index.ts, main.ts, app.ts, server.ts, manage.py, main.go)
- Route/controller definitions (routes/, controllers/, api/)
- Database models/schemas/migrations (models/, prisma/schema.prisma, migrations/)
- Middleware and auth setup (middleware/, auth/)
- Configuration files (config/, .env.example)
- Docker and deployment configs (Dockerfile, docker-compose.yml, terraform/)
- README.md for project context and purpose
- CI/CD pipeline definitions (.github/workflows/)

**Determine:**
- **Architecture style**: monolith, modular monolith, microservices, serverless, or hybrid
- **Service boundaries**: distinct services/modules and their responsibilities
- **Data flow**: how data flows between components, key API contracts
- **Database schema**: entities, relationships, indexes from migration files or ORM schemas
- **Auth flow**: authentication and authorization implementation
- **API surface**: endpoints, REST/GraphQL/gRPC/WebSocket
- **Component structure**: for frontends — page/component structure, state management
- **Testing patterns**: test structure, coverage approach, frameworks in use
- **Deployment model**: how the app is deployed, environments, CI/CD

### Step 3: Generate SDL

Using the **sdl-knowledge** skill, build a **v0.1-compliant** SDL document.

**CRITICAL: The output MUST use the SDL v0.1 schema structure. Do NOT invent custom
top-level sections.** The only allowed root keys are:

**Required:** `sdlVersion`, `solution`, `product`, `architecture`, `data`, `nonFunctional`, `deployment`, `artifacts`
**Optional:** `auth`, `integrations`, `constraints`, `technicalDebt`, `evolution`, `testing`, `observability`, `environments`, `interServiceCommunication`, `configuration`, `errorHandling`
**Extension:** Any key prefixed with `x-` (e.g., `x-confidence`, `x-evidence`)

**DO NOT** use these non-standard keys: `tech_stack`, `cross_cutting`, `infrastructure`,
`services` (top-level), `shared_libraries`, `metadata`, `project`.

#### 3.1 — Mapping Rules (codebase analysis → SDL v0.1)

| Discovered | SDL Location |
|---|---|
| Project name (README, package.json) | `solution.name` |
| Project description | `solution.description` |
| Maturity signals (CI/CD, monitoring, tests) | `solution.stage` (MVP/Growth/Enterprise) |
| Frontend apps (React, Vue, Angular, etc.) | `architecture.projects.frontend[]` |
| Backend services/APIs | `architecture.projects.backend[]` |
| Mobile apps | `architecture.projects.mobile[]` |
| Microservice boundaries | `architecture.services[]` (with kind + responsibilities) |
| Shared libraries / common packages | `architecture.sharedLibraries[]` |
| Architecture pattern | `architecture.style` (modular-monolith/microservices/serverless) |
| Primary database (first/main) | `data.primaryDatabase` (type + hosting) |
| Additional databases | `data.secondaryDatabases[]` |
| Redis/Memcached | `data.cache` (type + useCase) |
| Blob/file storage (S3, Azure Blob) | `data.storage` (blobs/files + provider) |
| Message queues (RabbitMQ, SQS, Kafka) | `data.queues` (provider + useCase) |
| Search engines (Elasticsearch, Algolia) | `data.search` (provider) |
| Auth strategy (JWT, OAuth, session) | `auth.strategy` + `auth.provider` |
| User roles from RBAC code | `auth.roles[]` and `product.personas[]` |
| Routes/pages/flows | `product.coreFlows[]` |
| Payment provider (Stripe, etc.) | `integrations.payments` |
| Email provider (SendGrid, SES, etc.) | `integrations.email` |
| SMS provider (Twilio, etc.) | `integrations.sms` |
| Analytics (PostHog, Mixpanel) | `integrations.analytics` |
| Monitoring (Datadog, Sentry, AppInsights) | `integrations.monitoring` |
| CDN (Cloudflare, CloudFront) | `integrations.cdn` |
| Other external APIs (Dyte, Twilio, etc.) | `integrations.custom[]` |
| Cloud provider (Azure, AWS, GCP) | `deployment.cloud` |
| CI/CD pipeline (GitHub Actions, etc.) | `deployment.ciCd.provider` |
| Docker/container setup | `deployment.runtime` |
| IaC (Terraform, Bicep) | `deployment.infrastructure.iac` |
| Dev/staging/prod environments | `environments[]` (name, url, services with URLs) |
| Test frameworks (Jest, Pytest, etc.) | `testing` (unit + e2e) |
| Logging library (Winston, Pino, etc.) | `observability.logging` |
| Tracing (OpenTelemetry, Jaeger) | `observability.tracing` |
| Metrics (Prometheus, CloudWatch) | `observability.metrics` |
| Inter-service communication patterns | `interServiceCommunication[]` |
| Configuration management patterns | `configuration` |
| Error handling patterns | `errorHandling` |

#### 3.2 — SDL Output Template

Use this exact structure. Omit optional sections that have no data.

```yaml
sdlVersion: "0.1"

solution:
  name: "{from README or package.json}"
  description: "{one-line description}"
  stage: MVP | Growth | Enterprise
  x-confidence: high | medium | low
  x-evidence: "{why this stage}"

product:
  personas:
    - name: "{inferred from auth roles or UI}"
      goals:
        - "{inferred from features}"
      accessLevel: public | authenticated | admin
  coreFlows:
    - name: "{inferred from routes/pages}"
      priority: critical | high | medium | low

architecture:
  style: modular-monolith | microservices | serverless
  x-confidence: high | medium | low
  x-evidence: "{structural signals}"
  projects:
    frontend:                           # Include if frontend exists
      - name: "{app name}"
        framework: nextjs | react | vue | angular | svelte | solid
        # Add rendering, styling, stateManagement if detected
    backend:                            # Include if backend exists
      - name: "{service name}"
        framework: nodejs | python-fastapi | dotnet-8 | go | java-spring | ruby-rails | php-laravel
        apiStyle: rest | graphql | grpc | mixed
        orm: prisma | typeorm | mongoose | sqlalchemy | ef-core | gorm | sequelize
  services:                             # Required if style=microservices (min 2)
    - name: "{service name}"
      kind: backend | worker | function | api-gateway
      responsibilities:
        - "{what this service does}"
  sharedLibraries:                      # If shared packages exist
    - name: "{package name}"
      language: typescript | javascript | python | go

auth:                                   # If auth detected
  strategy: oidc | passwordless | api-key | none
  provider: cognito | auth0 | entra-id | firebase | supabase | clerk | custom
  roles: ["{role1}", "{role2}"]
  sessions:
    accessToken: jwt | opaque
    refreshToken: true | false
  x-confidence: high | medium | low
  x-evidence: "{auth implementation details}"

data:
  primaryDatabase:
    type: postgres | mysql | mongodb | sqlserver | dynamodb | cockroachdb | planetscale
    hosting: managed | self-hosted | serverless
    x-confidence: high | medium | low
    x-evidence: "{how detected}"
  secondaryDatabases:                   # If additional DBs found
    - type: "{type}"
      hosting: "{hosting}"
      role: primary | read-replica | analytics
  cache:                                # If Redis/Memcached found
    type: redis | memcached
    useCase: [session, api, query]
  storage:                              # If blob/file storage found
    blobs:
      provider: s3 | azure-blob | gcs | cloudflare-r2
  queues:                               # If message queue found
    provider: rabbitmq | azure-service-bus | sqs | kafka | redis
    useCase: [async-jobs, event-streaming, notifications]
  search:                               # If search engine found
    provider: elasticsearch | algolia | typesense | azure-search

integrations:                           # If third-party services found
  payments:
    provider: stripe | paypal
    mode: subscriptions | one-time | marketplace
  email:
    provider: sendgrid | ses | resend | mailgun
    useCase: [transactional, marketing]
  sms:
    provider: twilio | vonage
  monitoring:
    provider: datadog | sentry | azure-monitor | newrelic
  custom:                               # For non-standard external services
    - name: "{service name}"
      apiType: rest | graphql | grpc
      authMethod: api-key | oauth2 | basic
      x-purpose: "{what it does}"
      x-scope: "{which services use it}"

nonFunctional:
  availability:
    target: "99.9"                      # Infer from stage
  scaling:
    expectedUsersMonth1: 100            # Infer from maturity
    expectedUsersYear1: 5000
  security:
    pii: true | false
    encryptionAtRest: true
    encryptionInTransit: true
    auditLogging: none | basic | detailed | compliance

deployment:
  cloud: azure | aws | gcp | vercel | railway | fly-io | render
  x-confidence: high | medium | low
  x-evidence: "{deployment signals}"
  runtime:
    frontend: "{inferred from cloud}"
    backend: "{inferred from cloud}"
  ciCd:
    provider: github-actions | gitlab-ci | azure-devops | circleci | jenkins
  infrastructure:
    iac: terraform | bicep | pulumi | cdk | cloudformation

environments:                           # If dev/staging/prod detected
  - name: development
    url: "http://localhost:{frontend-port}"     # Primary dev URL
    services:                                   # Backend service URLs for this env
      - name: "{backend-service-name}"
        url: "http://localhost:{port}"
    x-features: ["{feature1}", "{feature2}"]
  - name: production
    url: "https://{production-domain}"
    services:
      - name: "{backend-service-name}"
        url: "https://api.{production-domain}"
    x-features: ["{feature1}", "{feature2}"]

testing:                                # If test frameworks detected
  unit:
    framework: jest | vitest | pytest | xunit | go-test | junit
  e2e:
    framework: playwright | cypress | selenium | none

observability:                          # If logging/tracing/metrics detected
  logging:
    provider: winston | pino | serilog | zerolog | structured
    structured: true
  tracing:
    provider: opentelemetry | jaeger | xray | none
  metrics:
    provider: prometheus | datadog | cloudwatch | none

interServiceCommunication:              # If service-to-service patterns found
  - pattern: http | grpc | event-driven | websocket | message-queue
    description: "{how services communicate}"
    from: "{source service}"
    to: "{target service}"
    async: true | false

configuration:                          # If config management patterns found
  strategy: env-vars | config-service | feature-flags | vault | mixed
  provider: "{e.g. AWS SSM, HashiCorp Vault}"
  secretsManagement: "{how secrets are stored}"
  perEnvironment: true | false

errorHandling:                          # If error patterns found
  strategy: centralized | per-service | middleware | boundary
  errorFormat: "{e.g. RFC 7807, custom JSON}"
  globalHandler: true | false
  retryPolicy: "{e.g. exponential backoff}"
  circuitBreaker: true | false

artifacts:
  generate:
    - architecture-diagram
    - data-model
    - adr
    - deployment-guide
```

#### 3.3 — Validation

1. **Check conditional rules** before saving:
   - `microservices` requires 2+ services
   - `oidc` requires provider
   - `pii = true` requires encryptionAtRest
   - CloudFormation requires AWS
   - MongoDB incompatible with ef-core ORM

2. **Apply normalization** — let smart defaults fill gaps

3. **Add confidence markers** using `x-confidence` and `x-evidence` extension fields
   on key decisions (architecture style, database choice, auth, deployment)

4. **Save to project root** as `solution.sdl.yaml` (NOT inside architecture-output/)

### Step 4: Generate Import Analysis

Write a comprehensive analysis to `architecture-output/import-analysis.md`:

```markdown
# Import Analysis: {Project Name}

## 1. Project Overview
What the project is, its purpose, and target users. Derived from README,
code comments, and structural analysis.

## 2. Technology Stack
| Category | Technology | Version | Confidence | Source |
|----------|-----------|---------|------------|--------|
Complete listing of all detected and inferred technologies.

## 3. Architecture Pattern
Identified pattern (e.g., modular monolith, microservices) with evidence:
- What structural signals support this classification
- How the code is organized
- Communication patterns between components

## 4. Service Map
Each service/module with:
- Name and responsibilities
- Key files and entry points
- Dependencies on other services
- API surface (endpoints, event handlers)

## 5. Data Model Summary
Key entities, relationships, and storage:
- Primary entities and their fields
- Relationships (one-to-many, many-to-many)
- Database type and ORM
- Migration strategy in use

## 6. API Surface
Discovered endpoints and contracts:
| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|

## 7. Authentication & Authorization
Current auth implementation:
- Strategy (JWT, session, OAuth, API key)
- Provider (custom, Auth0, Clerk, etc.)
- Role/permission model
- Token storage and refresh

## 8. Infrastructure & Deployment
Current deployment setup:
- Hosting platform and compute
- Container setup (if any)
- CI/CD pipeline stages
- Environment strategy

## 9. Code Quality Signals
| Signal | Status | Details |
|--------|--------|---------|
| Type safety | | TypeScript strict mode, type coverage |
| Test coverage | | Test frameworks, test file ratio |
| Linting | | ESLint/Prettier/Ruff config |
| CI/CD | | Pipeline completeness |
| Documentation | | README, inline docs, API docs |

## 10. Architecture Observations
**Strengths:**
- What the codebase does well architecturally

**Concerns:**
- Potential issues, anti-patterns, or risks

**Technical Debt:**
- Areas that may need attention

## 11. Recommendations
Prioritized suggestions for improvement:
| Priority | Recommendation | Effort | Impact |
|----------|---------------|--------|--------|
```

### Step 5: Generate Intent

Write `intent.json` using the standard intent schema:

```json
{
  "intent": {
    "product_name": "from package.json name, README heading, or directory name",
    "vision": "inferred from README or code comments",
    "problem_statement": "Architecture reverse-engineered from existing codebase.",
    "target_users": [{
      "persona": "inferred from auth roles or UI structure",
      "needs": ["inferred from features"],
      "pain_points": ["inferred from code patterns"]
    }],
    "core_features": [
      {
        "feature": "inferred from routes/pages/handlers",
        "description": "what it does",
        "priority": "P0 or P1",
        "acceptance_criteria": ["derived from existing implementation"]
      }
    ],
    "non_functional_requirements": {
      "performance": { "concurrent_users": "inferred from infra" },
      "security": { "compliance": ["inferred from code patterns"] },
      "availability": { "uptime_sla": "inferred from deployment" }
    },
    "technical_constraints": {
      "preferred_stack": "the detected stack"
    },
    "business_constraints": {
      "timeline": { "mvp": "Already built" },
      "budget": { "initial_development": "N/A — existing codebase" }
    },
    "risks_and_assumptions": {
      "assumptions": ["list what was inferred vs confirmed"]
    }
  }
}
```

## Output Requirements

- Create `architecture-output/` directory if it does not exist
- Write SDL to `solution.sdl.yaml` in the project root (NOT inside architecture-output/)
- Write analysis to `architecture-output/import-analysis.md`
- Write intent to `intent.json` in the project root
- After writing all files, return a brief summary listing every file created
  and key findings
- If the codebase is too large to fully analyze, state assumptions explicitly
  and focus on the most architecturally significant parts

## Output Rules

- Use the **founder-communication** skill for tone — plain English, no jargon
  without explanation
- Use tables and structured sections for scannability
- Include confidence levels for all inferred architecture decisions
- Clearly distinguish between **detected** (from config/code) vs **assumed**
  (inferred/defaulted)
- Do not expose secrets, passwords, or API key values from .env files
- Keep the analysis actionable — every observation should have a recommendation
