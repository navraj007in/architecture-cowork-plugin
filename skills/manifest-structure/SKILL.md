---
name: manifest-structure
description: Canonical system manifest format with all enumerated types for project, frontend, service, database, integration, LLM, agent, and communication components. Use when structuring architecture output.
---

# System Manifest Structure

The System Manifest is the canonical structured representation of a product's architecture. Every deliverable (diagrams, cost estimates, complexity scores, specs) derives from this manifest. When building a manifest, use the types and structure defined below.

---

## Manifest Top-Level Structure

```
project:
  name: string
  type: app | agent | hybrid
  description: string (one sentence)

users:
  - role: string
    description: string
    count_estimate: string (range, e.g. "100-1,000 MAU")

frontends:
  - name: string
    type: <frontend_type>
    framework: string
    pages: [string]
    build_tool: string (optional, e.g. "Vite", "Webpack", "Expo")
    rendering: ssr | ssg | spa (optional, web only)
    state_management: string (optional, e.g. "Zustand", "Redux")
    data_fetching: string (optional, e.g. "React Query", "SWR")
    component_library: string (optional, e.g. "Radix UI", "React Native Paper")
    form_handling: string (optional, e.g. "React Hook Form")
    validation: string (optional, e.g. "Zod", "Yup")
    api_client: string (optional, e.g. "Axios", "fetch")
    styling: string (optional, e.g. "Tailwind CSS")
    routing: string (optional, e.g. "React Router", "Expo Router")
    animation: string (optional, e.g. "Framer Motion")
    deploy_target: string (optional, e.g. "Vercel", "Cloudflare Pages")
    dev_port: integer (optional, e.g. 3000)
    backend_connections: (optional)
      - service: string (references a defined service)
        purpose: string
    client_auth: (optional)
      token_storage: string (e.g. "cookie", "async-storage", "keychain")
      csrf_protection: boolean
      token_refresh: boolean
      device_binding: boolean (mobile only)
    realtime: (optional)
      protocol: websocket | socket-io | sse | polling | webrtc
      provider: string (optional, e.g. "Cloudflare RTK", "Dyte")
    monitoring: (optional)
      error_tracking: string (e.g. "Sentry", "Crashlytics")
      analytics: string (e.g. "PostHog", "Mixpanel")
    mobile_config: (optional, for ios/android types)
      bundle_id: string (e.g. "com.example.myapp")
      build_platform: string (e.g. "Expo Managed")
      navigation: string (e.g. "Expo Router", "React Navigation")
      push_providers: [string] (e.g. ["FCM", "APNS"])
      deep_link_scheme: string (e.g. "myapp")
      associated_domains: [string]
      permissions: [string] (e.g. ["camera", "microphone"])
      ota_updates: string (e.g. "Expo Updates")

services:
  - name: string
    type: <service_type>
    framework: string
    responsibilities: [string]
    endpoints: [string] (key endpoints only)

databases:
  - name: string
    type: <database_type>
    purpose: string (primary | cache | search | analytics | vector-store)
    key_collections: [string]

integrations:
  - name: string
    category: <integration_category>
    service: string (specific provider)
    purpose: string
    credentials: [string]

agents: (only for agent or hybrid projects)
  - name: string
    purpose: string
    llm_provider: <llm_provider>
    model: string
    orchestration: <agent_orchestration>
    interface: <agent_interface>
    tools:
      - name: string
        type: <agent_tool_type>
        description: string
    memory: session | persistent | vector-store
    guardrails: [string]

shared:
  types:
    - name: string
      description: string
      used_by: [string] (component names that share this type)
      fields: [string] (key fields or shape)
  libraries:
    - name: string
      purpose: string
      used_by: [string]
  contracts:
    - name: string
      type: api-schema | event-schema | proto-definition
      description: string
      between: [string] (component names)

application_patterns:
  architecture: <architecture_pattern>
  principles: [string] (e.g. "dependency inversion", "single responsibility")
  folder_convention: <folder_convention>
  error_handling: string (strategy description)
  testing_strategy: string (e.g. "unit + integration", "contract tests between services")

communication:
  - from: string (component name)
    to: string (component name)
    pattern: <communication_pattern>
    protocol: string (e.g. "HTTPS", "AMQP", "gRPC/Protobuf")
    auth: string (e.g. "JWT bearer", "API key", "mTLS", "none (internal)")
    data_format: string (e.g. "JSON", "Protobuf", "Avro")
    retry_strategy: string (optional, e.g. "exponential backoff, 3 retries")
    notes: string (optional, context for this connection)

artifacts:
  - name: string
    type: openapi | postman-collection | asyncapi | graphql-schema
    service: string (which service this artifact documents)
    format: yaml | json | graphql

security:
  auth_strategy: string (e.g. "JWT with refresh tokens via Clerk")
  api_security:
    - name: string (e.g. "rate limiting", "input validation", "CORS")
      implementation: string
      applies_to: [string] (component names)
  data_protection:
    encryption_at_rest: string (e.g. "AES-256 via database provider")
    encryption_in_transit: string (e.g. "TLS 1.3 on all endpoints")
    pii_fields: [string] (fields that contain personally identifiable information)
    data_retention: string (policy)
  secrets_management: string (e.g. "environment variables via Doppler / Vercel env")
  compliance: [string] (e.g. ["GDPR", "SOC2", "HIPAA"] — only if applicable)
  owasp_considerations:
    - threat: string (e.g. "SQL injection", "XSS", "CSRF")
      mitigation: string

observability:
  logging:
    strategy: string (e.g. "structured JSON logs")
    provider: string (e.g. "Axiom", "Datadog", "CloudWatch")
    log_levels: [string] (e.g. ["error", "warn", "info", "debug"])
  tracing:
    enabled: boolean
    provider: string (e.g. "OpenTelemetry → Jaeger" or "Datadog APM")
    instrumented_services: [string]
  metrics:
    provider: string (e.g. "Prometheus + Grafana", "Datadog")
    key_metrics: [string] (e.g. ["request latency p99", "error rate", "queue depth"])
  alerting:
    provider: string (e.g. "PagerDuty", "Opsgenie", "Slack webhooks")
    critical_alerts: [string] (e.g. ["error rate > 5%", "latency p99 > 2s", "queue backlog > 1000"])
  health_checks:
    - component: string
      endpoint: string (e.g. "/health")
      checks: [string] (e.g. ["database connectivity", "redis connectivity", "external API reachability"])

devops:
  cicd:
    provider: string (e.g. "GitHub Actions", "GitLab CI", "CircleCI")
    branch_strategy: <branch_strategy>
    pipeline_stages: [string] (e.g. ["lint", "test", "build", "deploy"])
    environments:
      - name: string (e.g. "development", "staging", "production")
        branch: string (e.g. "develop", "staging", "main")
        auto_deploy: boolean
        url_pattern: string (e.g. "{{service}}-dev.{{domain}}")
  database_migrations:
    tool: string (e.g. "Prisma Migrate", "Alembic", "Knex", "TypeORM")
    strategy: string (e.g. "versioned migrations with rollback scripts")
    seed_data: string (e.g. "dev seeds with faker data, staging seeds from anonymized prod")
    rollback_plan: string
  environment_config:
    strategy: <config_strategy>
    feature_flags: string (optional, e.g. "LaunchDarkly", "Unleash", "environment variables")
    config_validation: string (e.g. "Zod schema validation on startup")

deployment:
  - component: string
    target: string (e.g. "Vercel", "AWS ECS", "Railway")
```

---

## Enumerated Types

### Project Type
| Value | When to Use |
|-------|-------------|
| `app` | Traditional application — web, mobile, desktop, CLI. No AI agents. |
| `agent` | AI agent system — no traditional application UI beyond the agent interface. |
| `hybrid` | Application with embedded AI agents. Most common for modern products. |

### Frontend Type
| Value | Description |
|-------|-------------|
| `web` | Browser-based (React, Next.js, Vue, Svelte, etc.) |
| `ios` | Native iOS (Swift/SwiftUI) or cross-platform targeting iOS |
| `android` | Native Android (Kotlin) or cross-platform targeting Android |
| `desktop` | Desktop app (Electron, Tauri, native) |
| `cli` | Command-line interface |
| `crm` | CRM / back-office management interface |
| `booking` | Booking / scheduling application |
| `ai-chat` | AI chat / conversational interface |

### Frontend Rendering (Web Only)
| Value | When to Use |
|-------|-------------|
| `ssr` | Server-side rendering. Best for SEO, dynamic content. |
| `ssg` | Static site generation. Best for content-heavy, infrequently changing pages. |
| `spa` | Single-page application. Best for app-like UX, no SEO needs. |

### Client-Side Token Storage
| Value | Platform | Description |
|-------|----------|-------------|
| `cookie` | Web | HTTP-only cookies. Most secure for web. |
| `localStorage` | Web | Browser localStorage. Persistent but XSS-vulnerable. |
| `sessionStorage` | Web | Browser sessionStorage. Cleared on tab close. |
| `memory` | Web | In-memory only. Most secure but lost on refresh. |
| `async-storage` | Mobile (RN) | React Native AsyncStorage. Unencrypted. |
| `secure-store` | Mobile (RN) | Expo SecureStore. Uses Keychain/Keystore. |
| `keychain` | Mobile (iOS) | iOS Keychain. Survives reinstalls. |
| `encrypted-shared-prefs` | Mobile (Android) | Android EncryptedSharedPreferences. |

### Real-Time Protocol
| Value | When to Use |
|-------|-------------|
| `websocket` | Raw WebSocket for bidirectional communication |
| `socket-io` | Socket.IO with auto-reconnect, rooms, namespaces |
| `sse` | Server-Sent Events for one-way streaming (AI responses, live feeds) |
| `polling` | HTTP polling when WebSocket not available |
| `webrtc` | Peer-to-peer audio/video communication |

### Mobile Permissions
| Value | Description |
|-------|-------------|
| `camera` | Camera access for photos/video |
| `microphone` | Microphone access for audio/calls |
| `contacts` | Address book access |
| `location` | GPS / location services |
| `notifications` | Push notification permission |
| `photos` | Photo library access |
| `calendar` | Calendar access |
| `bluetooth` | Bluetooth device communication |
| `background-audio` | Background audio playback/recording |

### Service Type
| Value | Description |
|-------|-------------|
| `rest-api` | RESTful HTTP API |
| `graphql` | GraphQL API |
| `websocket` | Real-time bidirectional communication |
| `worker` | Background job processor |
| `cron` | Scheduled task runner |
| `gateway` | API gateway or reverse proxy |

### Database Type
| Value | Typical Use Case |
|-------|------------------|
| `postgresql` | Relational data, complex queries, transactions |
| `mongodb` | Document storage, flexible schemas |
| `redis` | Caching, sessions, rate limiting, pub/sub |
| `dynamodb` | Key-value at scale, serverless workloads |
| `elasticsearch` | Full-text search, log analytics |
| `mysql` | Relational data, legacy systems |
| `sqlite` | Local/embedded, development, mobile |
| `firestore` | Real-time sync, mobile-first, serverless |

### Integration Category
| Value | Examples |
|-------|----------|
| `payments` | Stripe, PayPal, Paddle, LemonSqueezy |
| `email` | SendGrid, Resend, AWS SES, Postmark |
| `sms` | Twilio, MessageBird, Vonage |
| `maps` | Google Maps, Mapbox, HERE |
| `auth` | Auth0, Clerk, Firebase Auth, Supabase Auth |
| `storage` | AWS S3, Cloudflare R2, Google Cloud Storage |
| `analytics` | PostHog, Mixpanel, Amplitude, Google Analytics |
| `monitoring` | Sentry, Datadog, Grafana, New Relic |
| `cdn` | Cloudflare, CloudFront, Fastly |
| `search` | Algolia, Typesense, Meilisearch |
| `messaging` | Slack API, Discord API, Telegram Bot API |
| `notifications` | OneSignal, Firebase Cloud Messaging, Novu |
| `ci-cd` | GitHub Actions, GitLab CI, CircleCI |

### LLM Provider
| Value | Models |
|-------|--------|
| `anthropic` | Claude Haiku, Sonnet, Opus |
| `openai` | GPT-4o, GPT-4o-mini, o1, o3 |
| `google` | Gemini Flash, Gemini Pro |
| `mistral` | Mistral Large, Mistral Small, Codestral |
| `groq` | LLaMA, Mixtral (fast inference) |
| `local` | Ollama, llama.cpp, vLLM |
| `multi` | Multiple providers with fallback/routing |

### Agent Orchestration
| Value | When to Use |
|-------|-------------|
| `single-turn` | Simple request-response, no reasoning chain needed |
| `react` | Tool-using agent that reasons then acts in a loop |
| `chain-of-thought` | Multi-step reasoning without tool use |
| `multi-agent-router` | Router dispatches to specialist agents sequentially |
| `multi-agent-parallel` | Multiple agents work simultaneously, results merged |
| `plan-and-execute` | Planner creates steps, executor runs them |
| `custom` | Novel orchestration pattern — describe in detail |

### Agent Tool Type
| Value | Description |
|-------|-------------|
| `api-call` | Calls an external HTTP API |
| `database-query` | Reads from or writes to a database |
| `web-search` | Searches the web for information |
| `code-execution` | Runs code in a sandbox |
| `file-io` | Reads or writes files |
| `browser` | Navigates web pages, scrapes content |
| `human-handoff` | Escalates to a human operator |
| `agent-delegate` | Delegates to another agent |
| `custom` | Custom tool — describe in detail |

### Agent Interface
| Value | Description |
|-------|-------------|
| `chat-ui` | Web-based chat interface |
| `api` | Programmatic API (no UI) |
| `slack-bot` | Slack workspace bot |
| `discord-bot` | Discord server bot |
| `cli` | Command-line interface |
| `email` | Email-based interaction |
| `voice` | Voice interface (phone, smart speaker) |

### Architecture Pattern
| Value | When to Use |
|-------|-------------|
| `clean-architecture` | Layered with strict dependency inversion (domain → use cases → adapters → frameworks). Best for complex business logic. |
| `hexagonal` | Ports and adapters. Similar to clean architecture but emphasizes interchangeable external integrations. |
| `mvc` | Model-View-Controller. Simple apps, server-rendered pages, CRUD-heavy products. |
| `mvvm` | Model-View-ViewModel. Mobile apps, reactive UIs with data binding. |
| `modular-monolith` | Monolith organized into self-contained modules with clear boundaries. Good starting point before microservices. |
| `microservices` | Independent deployable services with own databases. Only when team/scale justifies the overhead. |
| `serverless` | Functions as compute units (Lambda, Cloud Functions). Event-driven, low-traffic, or bursty workloads. |
| `event-driven` | Components communicate through events/messages. Decoupled, async-first. |
| `cqrs` | Command Query Responsibility Segregation. Separate read/write models. Complex domains with different read/write patterns. |
| `layered` | Simple horizontal layers (presentation → business → data). Straightforward CRUD apps. |

### Folder Convention
| Value | Structure | Best For |
|-------|-----------|----------|
| `feature-based` | `src/features/auth/`, `src/features/orders/`, `src/features/payments/` | Most apps. Groups related code (routes, services, models) by feature. |
| `layer-based` | `src/controllers/`, `src/services/`, `src/models/`, `src/repositories/` | Simple CRUD apps. Groups by technical layer. |
| `domain-driven` | `src/domain/`, `src/application/`, `src/infrastructure/`, `src/presentation/` | Clean/hexagonal architecture. Enforces dependency direction. |
| `module-based` | `src/modules/auth/`, `src/modules/billing/` with internal layers per module | Modular monoliths. Each module is self-contained. |
| `flat` | `src/` with files grouped loosely | Small services, workers, single-purpose microservices. |

### Shared Contract Type
| Value | Description |
|-------|-------------|
| `api-schema` | OpenAPI / JSON Schema defining REST API contracts between services |
| `event-schema` | Event payload schema (e.g. CloudEvents, AsyncAPI) for message queues / event bus |
| `proto-definition` | Protocol Buffer definition for gRPC services |
| `graphql-schema` | Shared GraphQL type definitions |
| `typescript-types` | Shared TypeScript type/interface package |
| `json-schema` | Generic JSON Schema used for validation across services |

### Branch Strategy
| Value | When to Use |
|-------|-------------|
| `github-flow` | Single main branch + feature branches. Simple. Best for most startups and small teams. |
| `gitflow` | develop + main + feature/release/hotfix branches. Best for products with scheduled releases. |
| `trunk-based` | Everyone commits to main with short-lived feature branches (<1 day). Best for CI/CD-mature teams. |
| `release-branching` | Main + release branches (release/1.0, release/1.1). Best for products with multiple supported versions. |

### Config Strategy
| Value | Description |
|-------|-------------|
| `env-vars` | Environment variables (.env files locally, platform env vars in production). Simplest approach. |
| `config-service` | Centralized config management (Doppler, AWS Parameter Store, HashiCorp Vault). Best for multi-service architectures. |
| `file-based` | Config files per environment (config.dev.json, config.prod.json). Best for simple apps. |
| `hybrid` | Secrets in a config service, non-sensitive config in env vars or files. Best balance of security and simplicity. |

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

## Example Manifest Snippet

```yaml
project:
  name: "SupportBot Pro"
  type: hybrid
  description: "AI-powered customer support platform with human escalation"

users:
  - role: customer
    description: "End users seeking support"
    count_estimate: "1,000-10,000 MAU"
  - role: support-agent
    description: "Human support staff handling escalations"
    count_estimate: "5-20"
  - role: admin
    description: "Manages knowledge base, views analytics"
    count_estimate: "1-3"

frontends:
  - name: customer-widget
    type: web
    framework: React
    pages: [chat-widget, ticket-history]
    build_tool: Vite
    rendering: spa
    state_management: Zustand
    data_fetching: React Query
    api_client: fetch
    styling: Tailwind CSS
    deploy_target: Vercel
    dev_port: 3001
    backend_connections:
      - { service: api-server, purpose: "Ticket CRUD and history" }
      - { service: agent-service, purpose: "Real-time AI chat" }
    client_auth:
      token_storage: cookie
      csrf_protection: true
      token_refresh: true
    realtime:
      protocol: websocket
    monitoring:
      error_tracking: Sentry
  - name: agent-dashboard
    type: web
    framework: Next.js
    pages: [inbox, conversation-view, knowledge-base, analytics]
    build_tool: Webpack
    rendering: ssr
    state_management: Zustand
    data_fetching: React Query
    component_library: Radix UI
    form_handling: React Hook Form
    validation: Zod
    styling: Tailwind CSS
    routing: Next.js App Router
    deploy_target: Vercel
    dev_port: 3000
    backend_connections:
      - { service: api-server, purpose: "All admin and agent operations" }
    client_auth:
      token_storage: cookie
      token_refresh: true
    monitoring:
      error_tracking: Sentry
      analytics: PostHog

services:
  - name: api-server
    type: rest-api
    framework: Node.js/Express
    responsibilities: [auth, ticket-management, knowledge-base-crud]
  - name: agent-service
    type: websocket
    framework: Node.js
    responsibilities: [ai-agent-orchestration, streaming-responses]

databases:
  - name: primary-db
    type: postgresql
    purpose: primary
    key_collections: [users, tickets, conversations, knowledge_articles]
  - name: vector-db
    type: postgresql
    purpose: vector-store
    key_collections: [knowledge_embeddings]
  - name: cache
    type: redis
    purpose: cache
    key_collections: [sessions, rate_limits]

agents:
  - name: support-agent
    purpose: "Answer customer questions using knowledge base, escalate complex issues"
    llm_provider: anthropic
    model: claude-sonnet
    orchestration: react
    interface: chat-ui
    tools:
      - name: search-knowledge-base
        type: database-query
        description: "Vector search over knowledge articles"
      - name: create-ticket
        type: api-call
        description: "Create support ticket for human follow-up"
      - name: human-handoff
        type: human-handoff
        description: "Transfer conversation to human agent"
    memory: persistent
    guardrails:
      - "Never make promises about refunds or policy changes"
      - "Always disclose that you are an AI when asked"
      - "Escalate to human if confidence is low or customer is upset"

shared:
  types:
    - name: User
      description: "Core user type shared across API and dashboard"
      used_by: [api-server, agent-dashboard]
      fields: [id, email, role, displayName, createdAt]
    - name: Ticket
      description: "Support ticket shared between API, agent, and dashboard"
      used_by: [api-server, agent-service, agent-dashboard]
      fields: [id, customerId, subject, status, priority, messages[], assignedTo]
    - name: KnowledgeArticle
      description: "Knowledge base article used by API and AI agent"
      used_by: [api-server, support-agent]
      fields: [id, title, content, embedding, category, updatedAt]
  libraries:
    - name: shared-types
      purpose: "TypeScript type definitions shared across all Node.js services"
      used_by: [api-server, agent-service, agent-dashboard, customer-widget]
    - name: shared-validators
      purpose: "Zod schemas for request/response validation"
      used_by: [api-server, agent-service]
  contracts:
    - name: ticket-events
      type: event-schema
      description: "Event payloads for ticket lifecycle (created, assigned, resolved, escalated)"
      between: [api-server, agent-service]
    - name: api-contract
      type: api-schema
      description: "OpenAPI spec for the REST API consumed by frontends"
      between: [api-server, customer-widget, agent-dashboard]

application_patterns:
  architecture: clean-architecture
  principles:
    - "Dependency inversion — domain layer has zero external dependencies"
    - "Single responsibility — each service owns one bounded context"
    - "Interface segregation — clients depend only on the methods they use"
    - "Fail fast — validate at boundaries, trust internal data"
  folder_convention: feature-based
  error_handling: "Structured error codes with user-friendly messages. Services return {code, message, details}. Frontend maps codes to UI text."
  testing_strategy: "Unit tests for business logic, integration tests for API endpoints, contract tests between api-server and agent-service"

communication:
  - from: customer-widget
    to: api-server
    pattern: rest
    protocol: HTTPS
    auth: JWT bearer
    data_format: JSON
  - from: customer-widget
    to: agent-service
    pattern: websocket
    protocol: WSS
    auth: JWT bearer
    data_format: JSON
  - from: agent-dashboard
    to: api-server
    pattern: rest
    protocol: HTTPS
    auth: JWT bearer
    data_format: JSON
  - from: agent-service
    to: api-server
    pattern: rest
    protocol: HTTP (internal)
    auth: API key
    data_format: JSON
    notes: "Internal service-to-service call for ticket operations"
  - from: api-server
    to: agent-service
    pattern: message-queue
    protocol: Redis/BullMQ
    auth: none (internal)
    data_format: JSON
    retry_strategy: "exponential backoff, 3 retries"
    notes: "Async ticket assignment and AI processing"

security:
  auth_strategy: "JWT with refresh tokens via Clerk"
  api_security:
    - name: rate-limiting
      implementation: "Upstash Ratelimit — 100 requests/min per user"
      applies_to: [api-server]
    - name: input-validation
      implementation: "Zod schemas on all request bodies"
      applies_to: [api-server, agent-service]
    - name: cors
      implementation: "Whitelist customer-widget and agent-dashboard origins only"
      applies_to: [api-server]
    - name: helmet-headers
      implementation: "helmet middleware for CSP, HSTS, X-Frame-Options"
      applies_to: [api-server]
  data_protection:
    encryption_at_rest: "AES-256 via Supabase (PostgreSQL) default encryption"
    encryption_in_transit: "TLS 1.3 on all external endpoints"
    pii_fields: [email, displayName, phone]
    data_retention: "User data retained while account active, deleted 30 days after account deletion"
  secrets_management: "Vercel environment variables for production, .env files for local development"
  owasp_considerations:
    - threat: "Broken access control"
      mitigation: "Role-based middleware on every route. Support agents can't access admin endpoints."
    - threat: "Injection"
      mitigation: "Prisma parameterized queries. Zod validation on all inputs."
    - threat: "SSRF"
      mitigation: "Agent tool URLs whitelisted. No user-provided URLs fetched server-side."

observability:
  logging:
    strategy: "Structured JSON logs via pino"
    provider: "Axiom (free tier)"
    log_levels: [error, warn, info, debug]
  tracing:
    enabled: false
    provider: "Not needed at MVP stage"
    instrumented_services: []
  metrics:
    provider: "Vercel Analytics + Sentry performance"
    key_metrics: ["request latency p99", "error rate", "queue depth", "AI response time"]
  alerting:
    provider: "Sentry + Slack webhook"
    critical_alerts: ["error rate > 5%", "api-server down", "agent-service queue backlog > 500"]
  health_checks:
    - component: api-server
      endpoint: "/health"
      checks: ["PostgreSQL connectivity", "Redis connectivity"]
    - component: agent-service
      endpoint: "/health"
      checks: ["Redis connectivity", "Anthropic API reachability"]

devops:
  cicd:
    provider: "GitHub Actions"
    branch_strategy: github-flow
    pipeline_stages: [lint, test, build, deploy]
    environments:
      - name: staging
        branch: develop
        auto_deploy: true
        url_pattern: "{{service}}-staging.vercel.app"
      - name: production
        branch: main
        auto_deploy: true
        url_pattern: "{{service}}.vercel.app"
  database_migrations:
    tool: "Prisma Migrate"
    strategy: "Versioned migrations committed to git. Run automatically in CI before deploy."
    seed_data: "Dev seeds with faker.js for local development"
    rollback_plan: "Prisma migrate rollback for failed migrations. Manual SQL for data fixes."
  environment_config:
    strategy: env-vars
    feature_flags: "Environment variables (ENABLE_AI_AGENT=true/false) for MVP"
    config_validation: "Zod schema validates all env vars on service startup"
```
