# System Manifest — Field Reference

This document defines every field in the Architect AI System Manifest. The manifest is the structured output that represents a product's full architecture.

---

## `project`

| Field         | Type     | Required | Description                          | Valid Values              |
|---------------|----------|----------|--------------------------------------|---------------------------|
| `name`        | `string` | yes      | Human-readable project name          | free text                 |
| `type`        | `enum`   | yes      | Overall project category             | `app`, `agent`, `hybrid`  |
| `description` | `string` | yes      | One-sentence summary of the product  | free text                 |

## `users[]`

| Field            | Type     | Required | Description                              | Valid Values |
|------------------|----------|----------|------------------------------------------|--------------|
| `role`           | `string` | yes      | Name of the user persona                 | free text    |
| `description`    | `string` | yes      | What this user does within the system    | free text    |
| `count_estimate` | `string` | no       | Rough expected user volume               | free text (e.g. `"1k-10k"`) |

## `frontends[]`

| Field       | Type       | Required | Description                              | Valid Values                                  |
|-------------|------------|----------|------------------------------------------|-----------------------------------------------|
| `name`      | `string`   | yes      | Identifier for this frontend             | free text                                     |
| `type`      | `enum`     | yes      | Platform target                          | `web`, `ios`, `android`, `desktop`, `cli`, `crm`, `booking`, `ai-chat` |
| `framework` | `string`   | yes      | Primary UI framework or toolkit          | free text (e.g. `"Next.js"`, `"SwiftUI"`)     |
| `pages`     | `string[]` | yes      | Key screens or views in this frontend    | list of free text                             |
| `build_tool` | `string`  | no       | Build toolchain                          | free text (e.g. `"Vite"`, `"Webpack"`, `"Expo"`) |
| `rendering` | `enum`     | no       | Rendering strategy (web only)            | `ssr`, `ssg`, `spa`                           |
| `state_management` | `string` | no  | Client-side state library                | free text (e.g. `"Zustand"`, `"Redux"`, `"Riverpod"`) |
| `data_fetching` | `string` | no     | Server-state / data fetching library     | free text (e.g. `"React Query"`, `"SWR"`, `"Apollo"`) |
| `component_library` | `string` | no | UI component library                     | free text (e.g. `"Radix UI"`, `"React Native Paper"`) |
| `form_handling` | `string` | no     | Form management library                  | free text (e.g. `"React Hook Form"`, `"Formik"`) |
| `validation` | `string`  | no       | Schema validation library                | free text (e.g. `"Zod"`, `"Yup"`)            |
| `api_client` | `string`  | no       | HTTP client library                      | free text (e.g. `"Axios"`, `"fetch"`)         |
| `styling`   | `string`   | no       | Styling approach                         | free text (e.g. `"Tailwind CSS"`, `"CSS Modules"`) |
| `routing`   | `string`   | no       | Routing library                          | free text (e.g. `"React Router"`, `"Expo Router"`) |
| `animation` | `string`   | no       | Animation library                        | free text (e.g. `"Framer Motion"`, `"Reanimated"`) |
| `deploy_target` | `string` | no     | Deployment platform for this frontend    | free text (e.g. `"Vercel"`, `"Cloudflare Pages"`) |
| `dev_port`  | `integer`  | no       | Local dev server port                    | integer (e.g. `3000`, `8080`)                 |

### `frontends[].backend_connections[]`

| Field     | Type     | Required | Description                              | Valid Values |
|-----------|----------|----------|------------------------------------------|--------------|
| `service` | `string` | yes      | Backend service this frontend connects to | must reference a defined service |
| `purpose` | `string` | no       | What this connection is used for         | free text |

### `frontends[].client_auth`

| Field            | Type      | Required | Description                              | Valid Values |
|------------------|-----------|----------|------------------------------------------|--------------|
| `token_storage`  | `string`  | no       | Where auth tokens are stored             | `cookie`, `localStorage`, `sessionStorage`, `memory`, `async-storage`, `secure-store`, `keychain` |
| `csrf_protection`| `boolean` | no       | Whether CSRF protection is enabled       | `true`, `false` |
| `token_refresh`  | `boolean` | no       | Whether automatic token refresh is used  | `true`, `false` |
| `device_binding` | `boolean` | no       | Whether device-bound auth is used (mobile) | `true`, `false` |

### `frontends[].realtime`

| Field      | Type     | Required | Description                              | Valid Values |
|------------|----------|----------|------------------------------------------|--------------|
| `protocol` | `enum`   | no       | Real-time protocol used                  | `websocket`, `socket-io`, `sse`, `polling`, `webrtc` |
| `provider` | `string` | no       | Real-time / video provider (mobile)      | free text (e.g. `"Cloudflare RTK"`, `"Dyte"`, `"Twilio"`) |

### `frontends[].monitoring`

| Field            | Type     | Required | Description                              | Valid Values |
|------------------|----------|----------|------------------------------------------|--------------|
| `error_tracking` | `string` | no       | Error tracking service                   | free text (e.g. `"Sentry"`, `"Bugsnag"`) |
| `analytics`      | `string` | no       | Analytics service                        | free text (e.g. `"App Insights"`, `"Mixpanel"`) |

### `frontends[].mobile_config` (for `ios`, `android` types)

| Field              | Type       | Required | Description                              | Valid Values |
|--------------------|------------|----------|------------------------------------------|--------------|
| `bundle_id`        | `string`   | no       | iOS bundle ID or Android package name    | reverse-domain (e.g. `"com.example.myapp"`) |
| `build_platform`   | `string`   | no       | Mobile build toolchain                   | free text (e.g. `"Expo Managed"`, `"React Native CLI"`) |
| `navigation`       | `string`   | no       | Navigation library                       | free text (e.g. `"Expo Router"`, `"React Navigation"`) |
| `push_providers`   | `string[]` | no       | Push notification providers              | list of free text (e.g. `["FCM", "APNS"]`) |
| `deep_link_scheme` | `string`   | no       | Custom URL scheme for deep links         | free text (e.g. `"myapp"`) |
| `associated_domains`| `string[]`| no       | Universal link / app link domains        | list of free text (e.g. `["example.com"]`) |
| `permissions`      | `string[]` | no       | Required device permissions              | list of free text (e.g. `["camera", "microphone", "notifications"]`) |
| `ota_updates`      | `string`   | no       | OTA update provider                      | free text (e.g. `"Expo Updates"`, `"CodePush"`) |

## `services[]`

| Field              | Type       | Required | Description                                  | Valid Values                                                       |
|--------------------|------------|----------|----------------------------------------------|--------------------------------------------------------------------|
| `name`             | `string`   | yes      | Identifier for this service                  | free text                                                          |
| `type`             | `enum`     | yes      | Communication style of the service           | `rest-api`, `graphql`, `websocket`, `worker`, `cron`, `gateway`    |
| `framework`        | `string`   | yes      | Runtime or framework used                    | free text (e.g. `"Express"`, `"FastAPI"`)                          |
| `responsibilities` | `string[]` | yes      | Core duties this service owns                | list of free text                                                  |
| `endpoints`        | `string[]` | no       | Representative routes or operations          | list of free text (e.g. `"POST /orders"`)                          |

## `databases[]`

| Field             | Type       | Required | Description                              | Valid Values                                                                                   |
|-------------------|------------|----------|------------------------------------------|------------------------------------------------------------------------------------------------|
| `name`            | `string`   | yes      | Identifier for this data store           | free text                                                                                      |
| `type`            | `enum`     | yes      | Database engine                          | `postgresql`, `mongodb`, `redis`, `dynamodb`, `elasticsearch`, `mysql`, `sqlite`, `firestore`  |
| `purpose`         | `string`   | yes      | Why this store exists in the system      | free text                                                                                      |
| `key_collections` | `string[]` | no       | Important tables, collections, or keys   | list of free text                                                                              |

## `integrations[]`

| Field         | Type     | Required | Description                                  | Valid Values                                                                                                                          |
|---------------|----------|----------|----------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `name`        | `string` | yes      | Identifier for this integration              | free text                                                                                                                             |
| `category`    | `enum`   | yes      | Domain of the third-party service            | `payments`, `email`, `sms`, `maps`, `auth`, `storage`, `analytics`, `monitoring`, `cdn`, `search`, `messaging`, `notifications`, `ci-cd` |
| `service`     | `string` | yes      | Specific provider or product name            | free text (e.g. `"Stripe"`, `"SendGrid"`)                                                                                            |
| `purpose`     | `string` | yes      | What this integration is used for            | free text                                                                                                                             |
| `credentials` | `string` | no       | Env var name or secret reference             | free text (e.g. `"STRIPE_SECRET_KEY"`)                                                                                                |

## `agents[]`

| Field           | Type       | Required | Description                                    | Valid Values                                                                                                          |
|-----------------|------------|----------|------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `name`          | `string`   | yes      | Identifier for this agent                      | free text                                                                                                             |
| `purpose`       | `string`   | yes      | What task or domain this agent handles         | free text                                                                                                             |
| `llm_provider`  | `enum`     | yes      | LLM vendor                                     | `anthropic`, `openai`, `google`, `mistral`, `groq`, `local`, `multi`                                                 |
| `model`         | `string`   | yes      | Specific model identifier                      | free text (e.g. `"claude-sonnet-4-5-20250929"`)                                                          |
| `orchestration` | `enum`     | yes      | Reasoning or control-flow pattern              | `single-turn`, `react`, `chain-of-thought`, `multi-agent-router`, `multi-agent-parallel`, `plan-and-execute`, `custom`|
| `interface`     | `enum`     | yes      | How users or systems interact with the agent   | `chat-ui`, `api`, `slack-bot`, `discord-bot`, `cli`, `email`, `voice`                                                |
| `tools`         | `object[]` | no       | Capabilities the agent can invoke              | each object: `{ name: string, type: enum }` — type is one of `api-call`, `database-query`, `web-search`, `code-execution`, `file-io`, `browser`, `human-handoff`, `agent-delegate`, `custom` |
| `memory`        | `string`   | no       | Memory or context strategy                     | free text (e.g. `"vector-store"`, `"sliding-window"`)                                                                |
| `guardrails`    | `string[]` | no       | Safety constraints or policies                 | list of free text                                                                                                     |

## `shared`

Shared types, libraries, and contracts that are used across multiple components.

### `shared.types[]`

| Field         | Type       | Required | Description                                    | Valid Values |
|---------------|------------|----------|------------------------------------------------|--------------|
| `name`        | `string`   | yes      | Domain type name (e.g. `"User"`, `"Order"`)    | free text    |
| `description` | `string`   | yes      | What this type represents                      | free text    |
| `used_by`     | `string[]` | yes      | Component names that share this type           | must reference defined components |
| `fields`      | `string[]` | yes      | Key fields or shape of the type                | list of free text (e.g. `["id", "email", "role"]`) |

### `shared.libraries[]`

| Field     | Type       | Required | Description                                    | Valid Values |
|-----------|------------|----------|------------------------------------------------|--------------|
| `name`    | `string`   | yes      | Package name (e.g. `"@project/shared-types"`)  | free text    |
| `purpose` | `string`   | yes      | What this shared library provides              | free text    |
| `used_by` | `string[]` | yes      | Component names that consume this library      | must reference defined components |

### `shared.contracts[]`

| Field         | Type       | Required | Description                                    | Valid Values |
|---------------|------------|----------|------------------------------------------------|--------------|
| `name`        | `string`   | yes      | Contract identifier                            | free text    |
| `type`        | `enum`     | yes      | Contract format                                | `api-schema`, `event-schema`, `proto-definition`, `graphql-schema`, `typescript-types`, `json-schema` |
| `description` | `string`   | yes      | What this contract defines                     | free text    |
| `between`     | `string[]` | yes      | Component names that share this contract       | must reference defined components |

## `application_patterns`

| Field              | Type       | Required | Description                                        | Valid Values |
|--------------------|------------|----------|----------------------------------------------------|--------------|
| `architecture`     | `enum`     | yes      | Primary architecture pattern                       | `clean-architecture`, `hexagonal`, `mvc`, `mvvm`, `modular-monolith`, `microservices`, `serverless`, `event-driven`, `cqrs`, `layered` |
| `principles`       | `string[]` | yes      | Key design principles the codebase follows         | list of free text (e.g. `"dependency inversion"`) |
| `folder_convention`| `enum`     | yes      | How the project organizes its source code          | `feature-based`, `layer-based`, `domain-driven`, `module-based`, `flat` |
| `error_handling`   | `string`   | yes      | Error flow strategy description                    | free text |
| `testing_strategy` | `string`   | yes      | Types of tests and where they add value            | free text |

## `communication[]`

| Field            | Type     | Required | Description                              | Valid Values                                                                          |
|------------------|----------|----------|------------------------------------------|---------------------------------------------------------------------------------------|
| `from`           | `string` | yes      | Source component name                    | must reference a defined frontend, service, or agent                                  |
| `to`             | `string` | yes      | Target component name                    | must reference a defined service, database, or agent                                  |
| `pattern`        | `enum`   | yes      | Protocol or messaging style              | `rest`, `graphql`, `websocket`, `grpc`, `message-queue`, `event-bus`, `sse`           |
| `protocol`       | `string` | yes      | Wire protocol                            | free text (e.g. `"HTTPS"`, `"AMQP"`, `"gRPC/Protobuf"`)                              |
| `auth`           | `string` | yes      | Authentication on this connection        | free text (e.g. `"JWT bearer"`, `"API key"`, `"mTLS"`, `"none (internal)"`)           |
| `data_format`    | `string` | yes      | Serialization format                     | free text (e.g. `"JSON"`, `"Protobuf"`, `"Avro"`)                                    |
| `retry_strategy` | `string` | no       | Retry and failure handling               | free text (e.g. `"exponential backoff, 3 retries"`)                                   |
| `notes`          | `string` | no       | Additional context for this connection   | free text                                                                             |

## `artifacts[]`

| Field     | Type     | Required | Description                              | Valid Values                                            |
|-----------|----------|----------|------------------------------------------|---------------------------------------------------------|
| `name`    | `string` | yes      | Artifact identifier                      | free text                                               |
| `type`    | `enum`   | yes      | Artifact format                          | `openapi`, `postman-collection`, `asyncapi`, `graphql-schema` |
| `service` | `string` | yes      | Which service this artifact documents    | must reference a defined service                        |
| `format`  | `enum`   | yes      | File format                              | `yaml`, `json`, `graphql`                               |

## `security`

| Field               | Type     | Required | Description                                    | Valid Values |
|---------------------|----------|----------|------------------------------------------------|--------------|
| `auth_strategy`     | `string` | yes      | Auth provider and method                       | free text (e.g. `"JWT with refresh tokens via Clerk"`) |
| `secrets_management`| `string` | yes      | How secrets are stored and rotated             | free text |
| `compliance`        | `string[]` | no    | Applicable compliance standards               | list of free text (e.g. `["GDPR", "SOC2"]`) |

### `security.api_security[]`

| Field            | Type       | Required | Description                                    | Valid Values |
|------------------|------------|----------|------------------------------------------------|--------------|
| `name`           | `string`   | yes      | Security measure name                          | free text (e.g. `"rate limiting"`, `"CORS"`) |
| `implementation` | `string`   | yes      | How it is implemented                          | free text |
| `applies_to`     | `string[]` | yes      | Which components this applies to               | must reference defined components |

### `security.data_protection`

| Field                 | Type       | Required | Description                              | Valid Values |
|-----------------------|------------|----------|------------------------------------------|--------------|
| `encryption_at_rest`  | `string`   | yes      | How data is encrypted at rest            | free text |
| `encryption_in_transit`| `string`  | yes      | How data is encrypted in transit         | free text |
| `pii_fields`          | `string[]` | yes      | Fields containing PII                    | list of free text |
| `data_retention`      | `string`   | yes      | Data retention policy                    | free text |

### `security.owasp_considerations[]`

| Field        | Type     | Required | Description                              | Valid Values |
|--------------|----------|----------|------------------------------------------|--------------|
| `threat`     | `string` | yes      | OWASP threat name                        | free text (e.g. `"SQL injection"`, `"XSS"`) |
| `mitigation` | `string` | yes      | How the threat is mitigated              | free text |

## `observability`

### `observability.logging`

| Field        | Type       | Required | Description                              | Valid Values |
|--------------|------------|----------|------------------------------------------|--------------|
| `strategy`   | `string`   | yes      | Logging approach                         | free text (e.g. `"structured JSON logs"`) |
| `provider`   | `string`   | yes      | Logging service or tool                  | free text (e.g. `"Axiom"`, `"Datadog"`) |
| `log_levels` | `string[]` | yes      | Log levels used                          | list of free text (e.g. `["error", "warn", "info"]`) |

### `observability.tracing`

| Field                   | Type       | Required | Description                              | Valid Values |
|-------------------------|------------|----------|------------------------------------------|--------------|
| `enabled`               | `boolean`  | yes      | Whether distributed tracing is used      | `true`, `false` |
| `provider`              | `string`   | yes      | Tracing tool or rationale for skipping   | free text |
| `instrumented_services` | `string[]` | no       | Which services have tracing enabled      | must reference defined services |

### `observability.metrics`

| Field         | Type       | Required | Description                              | Valid Values |
|---------------|------------|----------|------------------------------------------|--------------|
| `provider`    | `string`   | yes      | Metrics collection tool                  | free text (e.g. `"Prometheus + Grafana"`) |
| `key_metrics` | `string[]` | yes      | Important metrics to track               | list of free text |

### `observability.alerting`

| Field             | Type       | Required | Description                              | Valid Values |
|-------------------|------------|----------|------------------------------------------|--------------|
| `provider`        | `string`   | yes      | Alerting tool                            | free text (e.g. `"PagerDuty"`, `"Slack webhooks"`) |
| `critical_alerts` | `string[]` | yes      | Alert conditions                         | list of free text (e.g. `["error rate > 5%"]`) |

### `observability.health_checks[]`

| Field       | Type       | Required | Description                              | Valid Values |
|-------------|------------|----------|------------------------------------------|--------------|
| `component` | `string`   | yes      | Which service has this health check      | must reference a defined service |
| `endpoint`  | `string`   | yes      | Health check URL path                    | free text (e.g. `"/health"`) |
| `checks`    | `string[]` | yes      | What the health check verifies           | list of free text |

## `devops`

### `devops.cicd`

| Field              | Type       | Required | Description                              | Valid Values |
|--------------------|------------|----------|------------------------------------------|--------------|
| `provider`         | `string`   | yes      | CI/CD platform                           | free text (e.g. `"GitHub Actions"`) |
| `branch_strategy`  | `enum`     | yes      | Branching model                          | `github-flow`, `gitflow`, `trunk-based`, `release-branching` |
| `pipeline_stages`  | `string[]` | yes      | Pipeline stages in order                 | list of free text (e.g. `["lint", "test", "build", "deploy"]`) |

### `devops.cicd.environments[]`

| Field         | Type      | Required | Description                              | Valid Values |
|---------------|-----------|----------|------------------------------------------|--------------|
| `name`        | `string`  | yes      | Environment name                         | free text (e.g. `"staging"`, `"production"`) |
| `branch`      | `string`  | yes      | Git branch for this environment          | free text |
| `auto_deploy` | `boolean` | yes      | Whether deploys are automatic            | `true`, `false` |
| `url_pattern` | `string`  | no       | URL template for deployed services       | free text |

### `devops.database_migrations`

| Field           | Type     | Required | Description                              | Valid Values |
|-----------------|----------|----------|------------------------------------------|--------------|
| `tool`          | `string` | yes      | Migration tool                           | free text (e.g. `"Prisma Migrate"`, `"Alembic"`) |
| `strategy`      | `string` | yes      | Migration approach                       | free text |
| `seed_data`     | `string` | yes      | Seed data strategy                       | free text |
| `rollback_plan` | `string` | yes      | How to roll back failed migrations       | free text |

### `devops.environment_config`

| Field              | Type     | Required | Description                              | Valid Values |
|--------------------|----------|----------|------------------------------------------|--------------|
| `strategy`         | `enum`   | yes      | Config management approach               | `env-vars`, `config-service`, `file-based`, `hybrid` |
| `feature_flags`    | `string` | no       | Feature flag tooling                     | free text |
| `config_validation`| `string` | no       | How config is validated on startup       | free text |

## `deployment[]`

| Field       | Type     | Required | Description                              | Valid Values |
|-------------|----------|----------|------------------------------------------|--------------|
| `component` | `string` | yes      | Name of the component being deployed     | must reference a defined frontend, service, database, or agent |
| `target`    | `string` | yes      | Infrastructure target                    | free text (e.g. `"Vercel"`, `"AWS ECS"`, `"Fly.io"`) |

---

## Enumerated Types Reference

### Architecture Pattern

| Value | When to Use |
|-------|-------------|
| `clean-architecture` | Layered with strict dependency inversion. Best for complex business logic. |
| `hexagonal` | Ports and adapters. Emphasizes interchangeable external integrations. |
| `mvc` | Model-View-Controller. Simple apps, server-rendered, CRUD-heavy. |
| `mvvm` | Model-View-ViewModel. Mobile apps, reactive UIs with data binding. |
| `modular-monolith` | Monolith organized into self-contained modules. Good pre-microservices starting point. |
| `microservices` | Independent deployable services with own databases. Only when team/scale justifies overhead. |
| `serverless` | Functions as compute units. Event-driven, low-traffic, or bursty workloads. |
| `event-driven` | Components communicate through events/messages. Decoupled, async-first. |
| `cqrs` | Separate read/write models. Complex domains with different read/write patterns. |
| `layered` | Simple horizontal layers. Straightforward CRUD apps. |

### Folder Convention

| Value | Structure | Best For |
|-------|-----------|----------|
| `feature-based` | `src/features/auth/`, `src/features/orders/` | Most apps |
| `layer-based` | `src/controllers/`, `src/services/`, `src/models/` | Simple CRUD apps |
| `domain-driven` | `src/domain/`, `src/application/`, `src/infrastructure/` | Clean/hexagonal architecture |
| `module-based` | `src/modules/auth/`, `src/modules/billing/` | Modular monoliths |
| `flat` | `src/` with files grouped loosely | Small services, workers |

### Shared Contract Type

| Value | Description |
|-------|-------------|
| `api-schema` | OpenAPI / JSON Schema for REST API contracts |
| `event-schema` | Event payload schema (CloudEvents, AsyncAPI) |
| `proto-definition` | Protocol Buffer definition for gRPC |
| `graphql-schema` | Shared GraphQL type definitions |
| `typescript-types` | Shared TypeScript type/interface package |
| `json-schema` | Generic JSON Schema for cross-service validation |

### Branch Strategy

| Value | When to Use |
|-------|-------------|
| `github-flow` | Single main + feature branches. Best for most startups. |
| `gitflow` | develop + main + feature/release/hotfix. Best for scheduled releases. |
| `trunk-based` | Everyone commits to main with short-lived branches. Best for CI/CD-mature teams. |
| `release-branching` | Main + release branches. Best for multiple supported versions. |

### Config Strategy

| Value | Description |
|-------|-------------|
| `env-vars` | Environment variables (.env locally, platform env vars in production). Simplest. |
| `config-service` | Centralized config (Doppler, AWS Parameter Store). Best for multi-service. |
| `file-based` | Config files per environment. Best for simple apps. |
| `hybrid` | Secrets in config service, non-sensitive in env vars. Best balance. |

### Communication Pattern

| Value | When to Use |
|-------|-------------|
| `rest` | Standard request-response between services |
| `graphql` | Flexible queries from frontend to backend |
| `websocket` | Real-time bidirectional (chat, live updates) |
| `grpc` | High-performance service-to-service |
| `message-queue` | Async processing (SQS, RabbitMQ, BullMQ) |
| `event-bus` | Event-driven decoupled services (EventBridge, Kafka) |
| `sse` | Server-to-client streaming (AI responses, live feeds) |

---

## Example Manifest — SaaS Marketplace

```yaml
project:
  name: CraftBazaar
  type: app
  description: A two-sided marketplace where artisans list handmade goods and buyers purchase them.

users:
  - role: seller
    description: Lists products, manages inventory, fulfills orders
    count_estimate: "5k-20k"
  - role: buyer
    description: Browses, searches, and purchases products
    count_estimate: "50k-200k"
  - role: admin
    description: Moderates listings, resolves disputes, views analytics

frontends:
  - name: storefront
    type: web
    framework: Next.js
    pages: [home, search-results, product-detail, cart, checkout, order-history]
    build_tool: Webpack
    rendering: ssr
    state_management: Zustand
    data_fetching: React Query
    component_library: Radix UI
    form_handling: React Hook Form
    validation: Zod
    api_client: fetch
    styling: Tailwind CSS
    routing: Next.js App Router
    deploy_target: Vercel
    dev_port: 3000
    backend_connections:
      - { service: api-gateway, purpose: "All API requests" }
    client_auth:
      token_storage: cookie
      csrf_protection: false
      token_refresh: true
    monitoring:
      error_tracking: Sentry
      analytics: PostHog
  - name: seller-dashboard
    type: web
    framework: Next.js
    pages: [listings, add-listing, orders, payouts, analytics]
    build_tool: Webpack
    rendering: ssr
    data_fetching: React Query
    component_library: Radix UI
    styling: Tailwind CSS
    deploy_target: Vercel
    backend_connections:
      - { service: api-gateway, purpose: "Seller CRUD and analytics" }

services:
  - name: api-gateway
    type: gateway
    framework: Express
    responsibilities: [routing, rate-limiting, auth-verification]
  - name: product-service
    type: rest-api
    framework: FastAPI
    responsibilities: [listing CRUD, search indexing, inventory tracking]
    endpoints: [GET /products, POST /products, PUT /products/:id]
  - name: order-service
    type: rest-api
    framework: Express
    responsibilities: [order lifecycle, payment orchestration, refunds]
    endpoints: [POST /orders, GET /orders/:id, POST /orders/:id/refund]
  - name: notification-worker
    type: worker
    framework: BullMQ
    responsibilities: [email dispatch, push notifications]

databases:
  - name: main-db
    type: postgresql
    purpose: Primary relational store for users, products, and orders
    key_collections: [users, products, orders, reviews]
  - name: search-index
    type: elasticsearch
    purpose: Full-text product search and filtering
  - name: cache
    type: redis
    purpose: Session store, rate-limit counters, hot product cache

integrations:
  - name: payments
    category: payments
    service: Stripe
    purpose: Process buyer payments and seller payouts
    credentials: STRIPE_SECRET_KEY
  - name: email
    category: email
    service: SendGrid
    purpose: Transactional emails for orders, verification, and marketing
    credentials: SENDGRID_API_KEY
  - name: file-storage
    category: storage
    service: AWS S3
    purpose: Product images and seller documents
    credentials: AWS_ACCESS_KEY_ID
  - name: monitoring
    category: monitoring
    service: Datadog
    purpose: APM, logs, and infrastructure metrics

shared:
  types:
    - name: User
      description: "Core user type across all services"
      used_by: [api-gateway, product-service, order-service]
      fields: [id, email, role, displayName, createdAt]
    - name: Product
      description: "Product listing shared by product service and order service"
      used_by: [product-service, order-service, storefront]
      fields: [id, sellerId, title, description, price, images, status]
    - name: Order
      description: "Order entity used by order service and notifications"
      used_by: [order-service, notification-worker, seller-dashboard]
      fields: [id, buyerId, sellerId, items, total, status, createdAt]
  libraries:
    - name: "@craftbazaar/shared-types"
      purpose: "TypeScript type definitions shared across all Node.js services"
      used_by: [api-gateway, product-service, order-service, storefront, seller-dashboard]
  contracts:
    - name: product-api-contract
      type: api-schema
      description: "OpenAPI spec for product service REST endpoints"
      between: [api-gateway, product-service]
    - name: order-events
      type: event-schema
      description: "Event payloads for order lifecycle (created, paid, shipped, delivered)"
      between: [order-service, notification-worker]

application_patterns:
  architecture: modular-monolith
  principles:
    - "Single responsibility — each service owns one bounded context"
    - "Fail fast — validate inputs at API boundaries"
    - "Dependency inversion — business logic has no framework dependencies"
  folder_convention: feature-based
  error_handling: "Structured error codes {code, message, details}. Gateway maps service errors to HTTP status codes."
  testing_strategy: "Unit tests for business logic, integration tests for API endpoints, contract tests between gateway and services"

communication:
  - from: storefront
    to: api-gateway
    pattern: rest
    protocol: HTTPS
    auth: JWT bearer
    data_format: JSON
  - from: seller-dashboard
    to: api-gateway
    pattern: rest
    protocol: HTTPS
    auth: JWT bearer
    data_format: JSON
  - from: api-gateway
    to: product-service
    pattern: rest
    protocol: HTTP (internal)
    auth: API key
    data_format: JSON
  - from: api-gateway
    to: order-service
    pattern: rest
    protocol: HTTP (internal)
    auth: API key
    data_format: JSON
  - from: order-service
    to: notification-worker
    pattern: message-queue
    protocol: Redis/BullMQ
    auth: none (internal)
    data_format: JSON
    retry_strategy: "exponential backoff, 3 retries"
    notes: "Async notification dispatch after order state changes"

artifacts:
  - name: product-service-openapi
    type: openapi
    service: product-service
    format: yaml
  - name: order-service-openapi
    type: openapi
    service: order-service
    format: yaml
  - name: order-events-asyncapi
    type: asyncapi
    service: notification-worker
    format: yaml

security:
  auth_strategy: "JWT with refresh tokens via Clerk"
  api_security:
    - name: rate-limiting
      implementation: "Upstash Ratelimit — 100 req/min per user, 1000 req/min per IP"
      applies_to: [api-gateway]
    - name: input-validation
      implementation: "Zod schemas on all request bodies"
      applies_to: [product-service, order-service]
    - name: cors
      implementation: "Whitelist storefront and seller-dashboard origins"
      applies_to: [api-gateway]
    - name: helmet-headers
      implementation: "helmet middleware for CSP, HSTS, X-Frame-Options"
      applies_to: [api-gateway]
  data_protection:
    encryption_at_rest: "AES-256 via AWS RDS default encryption"
    encryption_in_transit: "TLS 1.3 on all external endpoints"
    pii_fields: [email, displayName, phone, shippingAddress]
    data_retention: "User data retained while account active, deleted 30 days after deletion request"
  secrets_management: "Vercel environment variables for production, .env files for local dev"
  compliance: [GDPR, PCI-DSS-via-Stripe]
  owasp_considerations:
    - threat: "Broken access control"
      mitigation: "Role-based middleware. Sellers can only edit own listings."
    - threat: "Injection"
      mitigation: "Prisma parameterized queries. Zod validation on all inputs."
    - threat: "SSRF"
      mitigation: "No user-provided URLs fetched server-side."

observability:
  logging:
    strategy: "Structured JSON logs via pino"
    provider: "Datadog"
    log_levels: [error, warn, info, debug]
  tracing:
    enabled: true
    provider: "Datadog APM"
    instrumented_services: [api-gateway, product-service, order-service]
  metrics:
    provider: "Datadog"
    key_metrics: ["request latency p99", "error rate", "queue depth", "order conversion rate"]
  alerting:
    provider: "PagerDuty + Slack webhook"
    critical_alerts: ["error rate > 5%", "latency p99 > 2s", "payment webhook failures > 3 in 5min"]
  health_checks:
    - component: api-gateway
      endpoint: "/health"
      checks: ["product-service reachability", "order-service reachability", "Redis connectivity"]
    - component: product-service
      endpoint: "/health"
      checks: ["PostgreSQL connectivity", "Elasticsearch connectivity"]
    - component: order-service
      endpoint: "/health"
      checks: ["PostgreSQL connectivity", "Redis connectivity", "Stripe API reachability"]

devops:
  cicd:
    provider: "GitHub Actions"
    branch_strategy: github-flow
    pipeline_stages: [lint, test, build, security-scan, deploy]
    environments:
      - name: staging
        branch: develop
        auto_deploy: true
        url_pattern: "{{service}}-staging.craftbazaar.dev"
      - name: production
        branch: main
        auto_deploy: true
        url_pattern: "{{service}}.craftbazaar.com"
  database_migrations:
    tool: "Prisma Migrate"
    strategy: "Versioned migrations committed to git. Run automatically in CI before deploy."
    seed_data: "Dev seeds with faker.js, staging seeds from anonymized prod subset"
    rollback_plan: "Prisma migrate rollback for failed migrations. Manual SQL for data fixes."
  environment_config:
    strategy: env-vars
    feature_flags: "Environment variables for MVP, LaunchDarkly when traffic warrants"
    config_validation: "Zod schema validates all env vars on service startup"

deployment:
  - { component: storefront,          target: Vercel }
  - { component: seller-dashboard,    target: Vercel }
  - { component: api-gateway,         target: AWS ECS }
  - { component: product-service,     target: AWS ECS }
  - { component: order-service,       target: AWS ECS }
  - { component: notification-worker, target: AWS ECS }
  - { component: main-db,             target: AWS RDS }
  - { component: search-index,        target: Elastic Cloud }
  - { component: cache,               target: AWS ElastiCache }
```
