---
name: sdl-knowledge
description: Solution Design Language (SDL) specification — schema, validation, normalization, and generation rules
---

# SDL Knowledge

## Identity

You understand the Solution Design Language (SDL) — a YAML-based architecture specification format used by arch0 to capture complete system designs. SDL transforms raw requirements into a validated, normalized intermediate representation that drives deterministic artifact generation.

## Core Principle

SDL sits between requirements gathering and artifact generation. The manifest captures *what the user said*. SDL transforms that into *what the system will build* — with smart defaults filled in, incompatibilities caught, and warnings surfaced.

---

## What SDL Is

SDL is a machine-readable YAML specification. This plugin uses the `v1.1` path for architecture workflows. Older `v0.1` material should be treated as obsolete and upgraded rather than reused for new generation.

- Solution metadata and stage (MVP / Growth / Enterprise)
- Product personas and core user flows
- Architecture style and project structure (frontend, backend, mobile)
- Authentication strategy and provider
- Data layer (databases, cache, queues, search, storage)
- Third-party integrations (payments, email, SMS, analytics, monitoring, CDN)
- Non-functional requirements (availability, scaling, security, compliance)
- Deployment configuration (cloud, runtime, networking, CI/CD, IaC)
- Constraints (budget, team, timeline, compliance, existing infrastructure)
- Inter-service communication patterns, configuration strategy, and error handling
- Testing, observability, technical debt, and evolution roadmap
- Artifact generation preferences

## When to Generate SDL

Generate SDL **after** requirements gathering and manifest building (Step 3), **before** deliverable generation (Step 4). SDL is Step 3.5 in the blueprint lifecycle.

## SDL Version

Version policy:
- Use `v1.1` for all new SDL generation in this plugin.
- Treat `v0.1` as obsolete input that should be upgraded before use.

---

## SDL Schema

See `references/sdl-schema.md` for the complete field-by-field schema reference with all enum values.

### Required Root Sections

| Section | Key Required Fields |
|---------|-------------------|
| `sdlVersion` | Must be `"1.1"` |
| `solution` | `name`, `description`, `stage` |
| `architecture` | `style`, `projects` |
| `data` | `primaryDatabase.type`, `primaryDatabase.hosting` |
| `product` | Core section carried forward into v1.1, include when user/persona context is known |
| `auth` | Retained core auth section, include when identity/access details are known |
| `deployment` | Core deployment section carried forward into v1.1, include when hosting/runtime is known |
| `nonFunctional` | Core quality section carried forward into v1.1, include when targets or constraints are known |
| `contracts` | v1.1 API contracts, include for formal interfaces |
| `domain` | v1.1 entity definitions, include when domain objects can be named |
| `features` | v1.1 feature planning, include when phase planning is needed |
| `compliance` | v1.1 regulatory requirements, include when applicable |
| `slos` | v1.1 service objectives, include when operational targets are defined |
| `resilience` | v1.1 fault tolerance patterns, include when reliability design is specified |
| `costs` | v1.1 cost model, include when financial planning is needed |
| `backupDr` | v1.1 backup and DR strategy, include when recovery planning is needed |
| `design` | v1.1 design system section, include for frontend/design-aware projects |

Alignment note:
- Follow `spec/SDL-v1.1.md` as the authority for v1.1 structure.
- In v1.1, `solution`, `architecture`, and `data` are the universally required root sections beyond `sdlVersion`.
- Other sections are added when the architecture actually needs them.

### Artifact Types

```
architecture-diagram | sequence-diagrams | openapi | data-model
repo-scaffold | iac-skeleton | backlog | adr | deployment-guide | cost-estimate
coding-rules | coding-rules-enforcement
```

---

## Conditional Validation Rules

These are hard errors — SDL will not compile if violated:

| # | Condition | Requirement | Error Code | Fix |
|---|-----------|-------------|------------|-----|
| 1 | `architecture.style = "microservices"` | `services[]` must have 2+ items | `MICROSERVICES_REQUIRES_SERVICES` | Add services array with 2+ entries, or use `modular-monolith` |
| 2 | `auth.strategy = "oidc"` | `auth.identityProvider` must be set | `OIDC_REQUIRES_PROVIDER` | Add identityProvider (auth0, cognito, entra-id, etc.) |
| 3 | `nonFunctional.security.pii = true` | `encryptionAtRest` must be `true` | `PII_REQUIRES_ENCRYPTION` | Set `encryptionAtRest: true` |
| 4 | `deployment.infrastructure.iac = "cloudformation"` | `deployment.cloud` must be `"aws"` | `INCOMPATIBLE_CLOUD_IAC` | Change iac to terraform/cdk, or cloud to aws |
| 5 | `data.primaryDatabase.type = "mongodb"` | No backend may have `orm = "ef-core"` | `INCOMPATIBLE_DATABASE_ORM` | Use mongoose for MongoDB, or postgres for EF Core |

---

## Normalization Rules

The normalizer applies 15 auto-inference defaults. **Do not manually set these** — let the normalizer handle them:

| # | Field | Default | Condition |
|---|-------|---------|-----------|
| 1 | `solution.regions.primary` | `"us-east-1"` | If regions missing |
| 2 | `data.primaryDatabase.name` | `"{name}_db"` | Lowercased, non-alphanumeric → `_` |
| 3 | `frontend[].type` | `"web"` | If type not set |
| 4 | `backend[].type` | `"backend"` | If type not set |
| 5 | `deployment.runtime.frontend` | From cloud mapping | See table below |
| 6 | `deployment.runtime.backend` | From cloud mapping | See table below |
| 7 | `deployment.networking.publicApi` | `true` | If undefined |
| 8 | `deployment.ciCd.provider` | `"github-actions"` | If ciCd missing |
| 9 | `nonFunctional.availability.target` | Stage-based | concept/mvp→99%, growth→99.9%, enterprise→99.99% |
| 10 | `security.encryptionAtRest` | `true` | If pii=true |
| 11 | `security.encryptionInTransit` | `true` | If undefined |
| 12 | (reserved) | — | — |
| 13 | `backend[].orm` | Framework+DB based | See ORM mapping below |
| 14 | `testing.unit.framework` | Backend framework based | See test mapping below |
| 15 | `observability.logging.provider` | Backend framework based | See logging mapping below |

### Cloud → Runtime Mapping

| Cloud | Frontend Runtime | Backend Runtime |
|-------|-----------------|-----------------|
| `vercel` | `vercel` | `vercel` |
| `aws` | `s3+cloudfront` | `ecs` |
| `railway` | `railway` | `railway` |
| `gcp` | `cloudflare-pages` | `cloud-run` |
| `azure` | `static-web-apps` | `container-apps` |

### Framework → ORM Mapping

| Framework | postgres | mysql | mongodb |
|-----------|---------|-------|---------|
| `nodejs` | `prisma` | `prisma` | `mongoose` |
| `python-fastapi` | `sqlalchemy` | `sqlalchemy` | — |
| `dotnet-8` | `ef-core` | `ef-core` | — |
| `go` | `gorm` | `gorm` | — |
| `java-spring` | `hibernate` | `hibernate` | — |

### Framework → Test Framework Mapping

| Framework | Test Framework |
|-----------|---------------|
| `nodejs` | `vitest` |
| `python-fastapi` | `pytest` |
| `dotnet-8` | `xunit` |
| `go` | `go-test` |
| `java-spring` | `junit` |
| `ruby-rails` | `rspec` |
| `php-laravel` | `phpunit` |

### Framework → Logging Provider Mapping

| Framework | Logging Provider |
|-----------|-----------------|
| `nodejs` | `pino` |
| `python-fastapi` | `structured` |
| `dotnet-8` | `serilog` |
| `go` | `zerolog` |
| `java-spring` | `log4j` |

---

## Warning Detection

Warnings are non-fatal checks applied after validation passes:

### Warning 1: Complexity vs Team

```
TRIGGER: architecture.style = "microservices" AND (totalDevs < 3 OR devops = 0)
CODE:    COMPLEXITY_EXCEEDS_TEAM_CAPACITY
MESSAGE: "Microservices with {N} service(s) may be too complex for {D} developer(s)"
FIX:     "Consider modular-monolith for MVP — plan microservices migration when team grows"
```

### Warning 2: Timeline vs Scope

```
TRIGGER: (projectCount × flowCount × 1.5) / totalDevs > timelineWeeks
CODE:    TIMELINE_TOO_AGGRESSIVE
MESSAGE: "{P} project(s) with {F} core flow(s) may not fit in {W} weeks"
FIX:     "Reduce scope, extend timeline, or add developers"
```

### Warning 3: Multi-Persona without Auth

```
TRIGGER: auth section missing AND personas > 1 AND (any has admin role OR count > 2)
CODE:    MISSING_RECOMMENDED_FIELD
MESSAGE: "{N} personas defined but no auth configuration"
FIX:     "Add an auth section with strategy and roles"
```

### Warning 4: Budget vs Infrastructure

```
TRIGGER: estimated monthly cost > budget ceiling
         (startup=$500, scaleup=$2000, enterprise=$10000)
CODE:    BUDGET_INFRASTRUCTURE_MISMATCH
MESSAGE: "Estimated cost (~${X}/mo) may exceed {budget} ceiling (${Y}/mo)"
FIX:     "Consider managed/serverless options or upgrade budget tier"
```

---

## Error Codes

### Parse Errors

| Code | Trigger | Fix |
|------|---------|-----|
| `EMPTY_INPUT` | Empty YAML string | Provide valid YAML |
| `INVALID_YAML` | Result is not an object | Start with key-value pairs |
| `YAML_PARSE_ERROR` | Syntax error | Fix indentation, colons, special characters |

### Schema Errors

| Code | Trigger | Fix |
|------|---------|-----|
| `MISSING_REQUIRED` | Required field absent | Add the field |
| `INVALID_ENUM` | Value not in allowed list | Use allowed value |
| `INVALID_TYPE` | Wrong data type | Provide correct type |
| `UNKNOWN_FIELD` | Unknown field without `x-` prefix | Remove or prefix with `x-` |
| `INVALID_FORMAT` | Pattern mismatch | Follow required format |
| `VALUE_TOO_SHORT` | Below min length | Provide longer value |
| `ARRAY_TOO_SHORT` | Below min items | Add more items |

### Conditional Rule Errors

| Code | Trigger | Fix |
|------|---------|-----|
| `MICROSERVICES_REQUIRES_SERVICES` | Microservices without 2+ services | Add services or use modular-monolith |
| `OIDC_REQUIRES_PROVIDER` | OIDC without provider | Add provider field |
| `PII_REQUIRES_ENCRYPTION` | PII without encryption | Set encryptionAtRest: true |
| `INCOMPATIBLE_CLOUD_IAC` | CloudFormation on non-AWS | Use terraform or change to AWS |
| `INCOMPATIBLE_DATABASE_ORM` | MongoDB with EF Core | Use mongoose or change database |

---

## Manifest-to-SDL Mapping

When converting a system manifest to SDL:

| Manifest Field | SDL Field |
|---|---|
| `project.name` | `solution.name` |
| `project.description` | `solution.description` |
| `project.type` (app/agent/hybrid) | `solution.stage` — infer: new idea → MVP, scaling → Growth |
| `users[].role` | `product.personas[].name` |
| `users[].description` | `product.personas[].goals` (split into goal statements) |
| `users[].count` (sum) | `nonFunctional.scaling.expectedUsersYear1` |
| `frontends[]` | `architecture.projects.frontend[]` |
| `services[]` | `architecture.projects.backend[]` |
| `databases[0]` | `data.primaryDatabase` |
| `databases[1+]` | `data.secondaryDatabases[]` |
| `integrations[category=payments]` | `integrations.payments` |
| `integrations[category=email]` | `integrations.email` |
| `integrations[category=auth]` | `auth` section |
| `integrations[category=storage]` | `data.storage` |
| `integrations[category=cache]` | `data.cache` |
| `application_patterns.style` | `architecture.style` |
| `security.auth` | `auth` section |
| `security.api_security` | `nonFunctional.security` |
| `devops.ci_cd.provider` | `deployment.ciCd.provider` |
| `deployment.targets[0]` | `deployment.cloud` |
| `communication_patterns[]` | `interServiceCommunication[]` |
| `application_patterns.error_handling` | `errorHandling` |
| `devops.config_management` | `configuration` |
| `services[].name` + `frontends[].name` (cross-referenced with communication patterns) | `architecture.projects.*[].dependsOn[]` — **required on every component**. Array of names of other components and external providers this component calls. Rules: frontend lists every backend it calls; backend lists downstream services + external integrations (e.g. `["stripe", "sendgrid"]`); lambda/worker lists its trigger source + any downstream service; shared lib gets `[]`. Always emit the field even when empty. Use the component's SDL `name` as identifier. External providers in lowercase (e.g. `"razorpay"`, `"anthropic"`). |
| Detected domain objects (entity names from models/schemas) | `domain.entities[]` — list of core domain object names |
| Identity provider (Cognito, Auth0, etc.) | `auth.identityProvider` |
| Service-level token validation mechanism (JWT, session) | `auth.serviceTokenModel: jwt \| session \| api-key` |

> **Auth note:** Use `auth.identityProvider` for the external IdP (cognito, auth0, clerk) and `auth.serviceTokenModel` for how services validate tokens (jwt, session, api-key). These are often different — e.g. Cognito issues tokens, services validate them as JWT.

### Integration Provider Mapping

| Manifest Service | SDL Path |
|---|---|
| Stripe | `integrations.payments.provider: stripe` |
| SendGrid | `integrations.email.provider: sendgrid` |
| Resend | `integrations.email.provider: resend` |
| Twilio | `integrations.sms.provider: twilio` |
| PostHog | `integrations.analytics.provider: posthog` |
| Datadog | `integrations.monitoring.provider: datadog` |
| Sentry | `integrations.monitoring.provider: sentry` |
| Cloudflare | `integrations.cdn.provider: cloudflare` |
| Auth0 | `auth.identityProvider: auth0` |
| Firebase Auth | `auth.identityProvider: firebase` |
| Clerk | `auth.identityProvider: clerk` |
| Cognito | `auth.identityProvider: cognito` |
| S3 | `data.storage.blobs.provider: s3` |
| GCS | `data.storage.blobs.provider: gcs` |
| Azure Blob | `data.storage.blobs.provider: azure-blob` |
| Cloudflare R2 | `data.storage.blobs.provider: cloudflare-r2` |
| Redis | `data.cache.type: redis` |
| RabbitMQ | `data.queues.provider: rabbitmq` |
| SQS | `data.queues.provider: sqs` |
| Kafka | `data.queues.provider: kafka` |
| Azure Service Bus | `data.queues.provider: azure-service-bus` |
| Elasticsearch | `data.search.provider: elasticsearch` |
| Algolia | `data.search.provider: algolia` |
| Typesense | `data.search.provider: typesense` |
| Meilisearch | `data.search.provider: meilisearch` |
| Azure Search | `data.search.provider: azure-search` |
| Pinecone | `data.search.provider: pinecone` |
| Qdrant | `data.search.provider: qdrant` |
| Weaviate | `data.search.provider: weaviate` |

---

## Domain Entities

The `domain` section captures the core business objects of the system. It is optional but strongly recommended for any system with 3+ services or a complex data model.

```yaml
domain:
  entities:
    - Expert
    - Client
    - Appointment
    - Payment
    - Notification
```

Domain entities are used by:
- `generate-data-model` — to enumerate all entities that need ORM schemas
- `blueprint` — to drive the data model section and ERD generation
- `prototype` — to generate typed mock data and CRUD pages

Rules:
- List entity names only (PascalCase) — no fields, no relationships here. Those belong in the data model deliverable.
- Include any object that has its own lifecycle, identity, and persistence
- Do NOT include value objects (Money, Address) or enums

---

## SDL Generation Rules

When generating SDL from a conversation or manifest:

0. **Save to project root** — always write the SDL file as `solution.sdl.yaml` in the project root directory (current working directory). Never place it inside `architecture/`, `artifacts/`, `output/`, or any other subfolder.
1. **Always set** `sdlVersion: "1.1"`
2. **Infer architecture style**:
   - Single backend → `modular-monolith`
   - 2+ backends with separate concerns → `microservices`
   - All functions/lambdas → `serverless`
3. **Include only sections with data** — omit empty optional sections
4. **Let normalizer handle defaults** — do not manually set fields covered by the 15 normalization rules
5. **Check the applicable v1.1 conditional rules mentally** before outputting:
   - Cross-reference the rules from `spec/SDL-v1.1.md` when using v1.1 sections
   - At minimum, check service references, feature dependencies, component references, and compatibility constraints
6. **If plugin workflows need explicit generation metadata, set `artifacts.generate`** based on what the user needs. This is plugin metadata, not a universally required upstream v1.1 root section. For a full blueprint:
   ```yaml
   artifacts:
     generate:
       - "architecture-diagram"
       - "sequence-diagrams"
       - "openapi"
       - "data-model"
       - "repo-scaffold"
       - "adr"
       - "backlog"
       - "deployment-guide"
       - "cost-estimate"
   ```
7. **Use comments sparingly** — only for non-obvious choices
8. **Validate the output** — ensure all required fields are present and enums are valid
9. **Quote YAML-unsafe string values** — any scalar value that starts with or contains a YAML special character MUST be wrapped in double quotes. Failure to quote these causes parse errors. Apply this rule to every string value you write:

   | Character / pattern | Why it breaks YAML | Example fix |
   |--------------------|--------------------|-------------|
   | Value starts with `>` | Interpreted as block scalar folding indicator | `condition: ">5 failures in 5 min"` |
   | Value starts with `\|` | Interpreted as block scalar literal indicator | `format: "\| pipe-delimited"` |
   | Value starts with `{` or `[` | Interpreted as inline mapping/sequence | `config: "{key: val}"` |
   | Value starts with `*` or `&` | Interpreted as alias/anchor | `ref: "*base"` |
   | Value starts with `!` | Interpreted as tag | `type: "!important"` |
   | Value contains `: ` (colon-space) anywhere | Parsed as a nested mapping key | `trigger: "EventBridge Schedule (rate: 1 day)"` |
   | Value contains ` #` (space-hash) | Everything after is treated as a comment | `desc: "retry # times"` |
   | Value contains `'` or `"` | May terminate the string early | Use double quotes and escape inner doubles as `\"` |
   | Value is a bare `true`, `false`, `yes`, `no`, `on`, `off`, `null` | Coerced to boolean/null | `flag: "true"` |
   | Value is a bare number that should be a string | Coerced to number | `version: "1.0"` |

   **Practical checklist — before writing any string value, ask:**
   - Does it start with `>`, `|`, `{`, `[`, `*`, `&`, `!`, `-`, `?`, `:`, `@`, `` ` ``? → quote it.
   - Does it contain `: ` anywhere (including inside parentheses)? → quote it.
   - Does it contain ` #` anywhere? → quote it.
   - Is it a comparison expression like `>5`, `>=10`, `<100ms`? → quote it.
   - Is it `true`, `false`, `yes`, `no`, `null`, or a plain number that must stay a string? → quote it.

## SDL Output Format

Output SDL as a YAML code block with triple-backtick yaml fencing. After the SDL, report the validation summary:

```
**Validation Summary**
| Field | Value |
|-------|-------|
| Architecture | {style} |
| Projects | {frontend + backend + mobile count} |
| Estimated Cost | {range} |
| Artifacts | {count} |
| Warnings | {count} |
```

If warnings exist, list each with code, message, and recommendation.

---

## SDL Diffing

SDL documents can be compared structurally. The diff engine:

1. Recursively compares both document trees
2. Uses **named array matching** — arrays of objects with `name` field are matched by name, not index
3. Reports changes as `added`, `removed`, or `changed`
4. Groups summary by top-level section

Diff entry format: `{path, type, oldValue?, newValue?}`

Example paths:
- `architecture.style` → scalar change
- `product.personas[name=Admin]` → named array item
- `data.cache` → section added/removed

---

## Templates

10 starter templates are available at `references/sdl-templates.md`:

| ID | Name | Stage | Key Stack |
|---|---|---|---|
| `saas-starter` | SaaS Starter | MVP | Next.js, Node.js, Postgres, Auth0, Vercel |
| `ecommerce` | E-Commerce Platform | Growth | Microservices, Postgres, AWS, Cognito |
| `mobile-backend` | Mobile App Backend | MVP | React Native, Node.js, Firebase, Railway |
| `internal-tool` | Internal Tool | MVP | Vue, Python FastAPI, Entra ID, Azure |
| `api-first` | API-First Platform | Growth | Go, DynamoDB, AWS, API key auth |
| `ai-product` | AI Product / RAG API | MVP | Python FastAPI, Postgres, Auth0, AWS |
| `marketplace` | Two-Sided Marketplace | MVP | .NET 8, Stripe Connect, AWS |
| `admin-dashboard` | Admin Dashboard | MVP | React, Node.js, Railway |
| `saas-subscription` | SaaS with Stripe Billing | MVP | Next.js, Vercel, Stripe |
| `realtime-collab` | Real-Time Collaboration | MVP | React, Node.js, Redis, Clerk, Fly.io |

---

## Artifact Generators

Each generator takes a compiled SDL document and produces deterministic output — same input always produces identical artifacts.

| Generator | Output | SDL Sections Used |
|-----------|--------|-------------------|
| Architecture Diagram | Mermaid C4 container diagram | `architecture`, `data`, `auth`, `integrations` |
| Repo Scaffold | Per-project package.json, configs, starter code | `architecture.projects`, `data`, `auth` |
| CI/CD Pipeline | GitHub Actions / GitLab CI / Azure DevOps YAML | `deployment.ciCd`, `deployment.cloud`, `architecture.projects` |
| ADRs | MADR-format decision records | All major sections |
| OpenAPI Spec | OpenAPI 3.1 YAML | `architecture.projects.backend`, `auth`, `product.personas` |
| Data Model | Mermaid ERD + ORM schema | `data.primaryDatabase`, backend ORM, `product.personas` |
| Sequence Diagrams | Mermaid sequence diagrams | `auth`, `product.coreFlows`, `product.personas` |
| Backlog | User stories grouped by epic | `product.personas`, `product.coreFlows`, `architecture` |
| Deployment Guide | Step-by-step runbook | `deployment`, `data`, `auth`, `integrations` |
| Cost Estimate | Monthly cost breakdown | `deployment.cloud`, `data`, `integrations`, `nonFunctional.scaling` |
| Docker Compose | docker-compose.yml for local dev | `architecture.projects`, `data`, `integrations` |
| Kubernetes | K8s manifests (Deployment, Service, HPA, Ingress) | `architecture.projects`, `deployment`, `data` |
| Monitoring | Prometheus config, alert rules, Grafana dashboard | `architecture.projects`, `nonFunctional`, `data` |
| Nginx | Reverse proxy config with SSL, gzip, rate limiting | `architecture.projects`, `deployment` |
| Coding Rules | CLAUDE.md, .cursorrules, copilot-instructions.md | `architecture`, `data`, `auth`, `testing`, `observability`, all projects |
| Coding Rules Enforcement | ESLint, dependency-cruiser, pre-commit, arch tests | `architecture`, all projects |

### How SDL drives blueprint deliverables

**Deterministic** (SDL → artifact directly):
- 4b: Architecture Diagram
- 4e: API Artifacts (OpenAPI, Postman, AsyncAPI)
- 4i: Cost Estimate
- 4o: Sprint Backlog

**Structured input** (SDL provides context for LLM-enhanced output):
- 4a: Executive Summary
- 4c: Application Architecture & Patterns
- 4d: Shared Types & Contracts
- 4f: Security Architecture
- 4g: Observability & Monitoring
- 4h: DevOps Blueprint
- 4j: Complexity Assessment
- 4k: Well-Architected Review
- 4l: Plain English Specs
- 4m: Required Accounts
- 4n: Next Steps Guide

---

## SDL API Routes

All SDL operations are exposed via REST endpoints at `/api/sdl/*`. All routes require authentication.

| Method | Path | Input | Description |
|--------|------|-------|-------------|
| POST | `/api/sdl/validate` | `{ yaml, modules? }` | Validate SDL YAML (supports multi-module with imports) |
| POST | `/api/sdl/generate` | `{ yaml, artifactType? }` | Generate all artifacts or a single type |
| POST | `/api/sdl/docker-compose` | `{ yaml }` | Generate Docker Compose for local dev |
| POST | `/api/sdl/kubernetes` | `{ yaml }` | Generate Kubernetes manifests |
| POST | `/api/sdl/monitoring` | `{ yaml }` | Generate Prometheus + Grafana configs |
| POST | `/api/sdl/nginx` | `{ yaml }` | Generate Nginx reverse proxy config |
| POST | `/api/sdl/coding-rules` | `{ yaml }` | Generate AI coding rules (CLAUDE.md, .cursorrules) |
| POST | `/api/sdl/diff` | `{ yamlA, yamlB }` | Diff two SDL documents |
| GET | `/api/sdl/templates` | — | List available SDL templates |
| GET | `/api/sdl/templates/:id` | — | Get specific template with YAML |

**Notes:**
- `coding-rules-enforcement` has no dedicated route — use `/api/sdl/generate` with `artifactType: "coding-rules-enforcement"`
- `deploy-diagram` is not exposed via API — used programmatically by the deploy planner module
- Routes with `sdlGate` middleware also check billing capabilities (`sdlEdit` capability required)

---

## Constants

### Budget Monthly Ceilings

| Budget Tier | Monthly Ceiling |
|---|---|
| `startup` | $500 |
| `scaleup` | $2,000 |
| `enterprise` | $10,000 |

### Availability by Stage

| Stage | Default Availability Target |
|---|---|
| `concept` | 99% |
| `mvp` | 99% |
| `growth` | 99.9% |
| `enterprise` | 99.99% |
