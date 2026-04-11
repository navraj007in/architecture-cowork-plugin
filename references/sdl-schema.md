# SDL v1.1 Plugin Reference

Solution Design Language (SDL) is a YAML-based specification for capturing complete software architecture decisions. This local reference is the plugin's v1.1-oriented guide, aligned to the upstream `spec/SDL-v1.1.md` while preserving plugin-specific generation conventions.

## Version Notes

- `v1.1` is the active SDL version for this plugin.
- `v0.1` should be treated as obsolete reference material, not as a target for new generation.
- When updating or regenerating SDL in this repo, always write `sdlVersion: "1.1"`.

## Required Root Fields (v1.1)

| Field | Type | Description |
|-------|------|-------------|
| `sdlVersion` | `"1.1"` | Always `"1.1"` for newly generated SDL |
| `solution` | object | Project metadata |
| `architecture` | object | System structure |
| `data` | object | Data layer |

## Core and Optional Root Fields

| Field | Type | Description |
|-------|------|-------------|
| `product` | object | Core section carried forward into v1.1 |
| `auth` | object | Authentication strategy |
| `deployment` | object | Core deployment section carried forward into v1.1 |
| `environments` | array | Runtime environment definitions |
| `nonFunctional` | object | Core quality section carried forward into v1.1 |
| `observability` | object | Logging, tracing, metrics |
| `integrations` | object | Third-party services |
| `constraints` | object | Budget, team, timeline |
| `testing` | object | Test framework config |
| `technicalDebt` | array | Known tech debt items |
| `contracts` | object/array | v1.1 API contract definitions |
| `domain` | object | v1.1 entity definitions |
| `features` | object | v1.1 feature planning |
| `compliance` | object | v1.1 regulatory requirements |
| `slos` | array | v1.1 service objectives |
| `resilience` | object | v1.1 fault tolerance patterns |
| `costs` | object | v1.1 cost model |
| `backupDr` | object | v1.1 backup and disaster recovery |
| `design` | object | v1.1 design system definition |

Alignment note:
- This mirrors the upstream `spec/SDL-v1.1.md` document structure.
- In upstream v1.1, only `solution`, `architecture`, and `data` remain universally required beyond `sdlVersion`.
- Additional sections are optional but recommended when their domain applies.

---

## solution (required)

```yaml
solution:
  name: string              # Required. Project name
  description: string        # Required. What it does
  stage: enum                # Required. concept | mvp | growth | enterprise (lowercase; uppercase variants MVP/Growth/Enterprise also accepted)
  domain: string             # Optional. Custom domain
  regions:                   # Optional
    primary: string          # Default: "us-east-1"
    secondary: string[]      # Optional
  repository:                # Optional
    org: string
    naming: string
```

## product (required)

```yaml
product:
  personas:                  # Required. Min 1
    - name: string           # Required
      goals: string[]        # Required. Min 1
      accessLevel: enum      # Optional. public | authenticated | admin
  coreFlows:                 # Optional
    - name: string           # Required
      priority: enum         # Optional. critical | high | medium | low
      steps: string[]        # Optional
  valueProposition: string   # Optional
```

## architecture (required)

```yaml
architecture:
  style: enum                # Required. modular-monolith | microservices | serverless | hybrid
  projects:                  # Required
    frontend:                # Optional
      - name: string         # Required
        type: enum           # Optional. web | mobile-web | admin
        framework: enum      # Required. nextjs | react | vue | angular | svelte | solid
        rendering: enum      # Optional. ssr | ssg | spa
        stateManagement: enum # Optional. context | redux | zustand | mobx | none
        styling: enum        # Optional. tailwind | css-modules | styled-components | sass | emotion
    backend:                 # Optional
      - name: string         # Required
        type: enum           # Optional. backend | worker | function
        framework: enum      # Required. dotnet-8 | nodejs | python-fastapi | go | java-spring | ruby-rails | php-laravel
        apiStyle: enum       # Optional. rest | graphql | grpc | mixed
        orm: enum            # Optional. ef-core | prisma | typeorm | sqlalchemy | gorm | sequelize | mongoose
        apiVersioning: enum  # Optional. url-prefix | header | query-param | none
    mobile:                  # Optional
      - name: string         # Required
        platform: enum       # Required. ios | android | cross-platform
        framework: enum      # Required. react-native | flutter | swift | kotlin | ionic
  services:                  # Optional. Required if style=microservices (min 2)
    - name: string
      kind: enum             # backend | worker | function | api-gateway
      responsibilities: string[]
  sharedLibraries:           # Optional
    - name: string
      language: string

# Plugin extensions on architecture.projects entries (not in upstream spec):
#   deployable: boolean      # true for services/frontends, false for shared libs/type packages
#   dependsOn: string[]      # Names of other components this component calls, plus external integrations
#                            # Every component must have this field; shared libs use dependsOn: []
```

## auth (optional)

```yaml
auth:
  strategy: enum             # Required. oidc | passwordless | magic-link | api-key | none
  identityProvider: enum     # Optional. cognito | auth0 | entra-id | entra-id-b2c | firebase | supabase | clerk | custom
  roles: string[]            # Optional
  sessions:                  # Optional
    accessToken: enum        # Optional. jwt | opaque
    refreshToken: boolean    # Optional
    ttl:                     # Optional
      access: string
      refresh: string
  mfa: boolean               # Optional
  socialProviders: enum[]    # Optional. google | github | microsoft | apple | facebook | twitter
```

## data (required)

```yaml
data:
  primaryDatabase:           # Required
    type: enum               # Required. postgres | mysql | sqlserver | mongodb | dynamodb | cockroachdb | planetscale
    hosting: enum            # Required. managed | self-hosted | serverless
    name: string             # Optional. Default: "{solutionName}_db"
    size: enum               # Optional. small | medium | large
    role: enum               # Optional. primary | read-replica | analytics
  secondaryDatabases:        # Optional
    - (same shape as primaryDatabase)
  storage:                   # Optional
    blobs:
      provider: enum         # azure-blob | s3 | gcs | cloudflare-r2
      public: boolean
    files:
      provider: enum         # azure-blob | s3 | gcs | cloudflare-r2
  cache:                     # Optional
    type: enum               # redis | memcached | none
    useCase: enum[]          # session | api | query
  queues:                    # Optional
    provider: enum           # rabbitmq | azure-service-bus | sqs | kafka | redis
    useCase: enum[]          # async-jobs | event-streaming | notifications
  search:                    # Optional
    provider: enum           # elasticsearch | algolia | typesense | azure-search | meilisearch | pinecone | qdrant | weaviate
```

## integrations (optional)

```yaml
integrations:
  payments:
    provider: enum           # stripe | paypal | square | adyen | braintree
    mode: enum               # subscriptions | one-time | marketplace
    currency: string
  email:
    provider: enum           # sendgrid | mailgun | ses | postmark | resend | smtp
    useCase: enum[]          # transactional | marketing | notifications
  sms:
    provider: enum           # twilio | vonage | aws-sns | messagebird
  analytics:
    provider: enum           # posthog | mixpanel | amplitude | google-analytics | plausible
  monitoring:
    provider: enum           # datadog | newrelic | azure-monitor | sentry | cloudwatch
  cdn:
    provider: enum           # cloudflare | fastly | azure-cdn | cloudfront
  custom:                    # Optional array
    - name: string           # Required
      apiType: enum          # rest | graphql | soap | grpc
      authMethod: enum       # api-key | oauth2 | basic | none
      rateLimit: string
```

## nonFunctional (required)

```yaml
nonFunctional:
  availability:
    target: string           # Required. e.g. "99.9"
    maintenanceWindow: string
  scaling:
    expectedUsersMonth1: number
    expectedUsersYear1: number
    peakConcurrentUsers: number
    dataGrowthPerMonth: string
  performance:
    apiResponseTime: string  # e.g. "<200ms"
    pageLoadTime: string
    targetRps: number        # Target requests per second (for load testing)
    p95LatencyMs: number     # p95 latency target in milliseconds
    p99LatencyMs: number     # p99 latency target in milliseconds
  caching:
    enabled: boolean         # Use caching (Redis, CDN)? Default: false if MVP, true if Growth+
  security:
    pii: boolean             # Required within security section
    phi: boolean
    pci: boolean
    encryptionAtRest: boolean # Default: true if pii=true
    encryptionInTransit: boolean # Default: true
    auditLogging: enum       # none | basic | detailed | compliance
    penetrationTesting: boolean
  compliance:
    frameworks: enum[]       # gdpr | hipaa | sox | pci-dss | iso27001 | soc2
  multiTenancy:
    enabled: boolean         # Is this a multi-tenant SaaS? Default: false
    isolationModel: enum     # row-level-security | schema-per-tenant | db-per-tenant
    tenantIdField: string    # Column name for tenant identifier. Default: "tenant_id"
    tenantOnboarding: enum   # self-service | manual. Default: self-service
    customizationsPerTenant: boolean # Can tenants customize schema? Default: false
  backup:
    frequency: enum          # hourly | daily | weekly
    retention: string
    pointInTimeRecovery: boolean
```

## deployment (required)

```yaml
deployment:
  cloud: enum                # Required. azure | aws | gcp | cloudflare | vercel | railway | render | fly-io
  runtime:                   # Optional. Auto-inferred from cloud
    frontend: string
    backend: string
    worker: string
  networking:
    publicApi: boolean       # Default: true
    waf: boolean
    ddos: boolean
    privateEndpoints: boolean
    customDomain: boolean
  ciCd:
    provider: enum           # github-actions | gitlab-ci | azure-devops | circleci | jenkins
    environments:
      - name: string
        autoApproval: boolean
        requiresTests: boolean
        secrets: string[]
  infrastructure:
    iac: enum                # terraform | bicep | pulumi | cdk | cloudformation
    stateBacking: string
```

## constraints (optional)

```yaml
constraints:
  budget: enum               # startup | scaleup | enterprise | custom
  budgetAmount: string
  team:
    backend: number
    frontend: number
    fullstack: number
    devops: number
    designer: number
    developers: number       # Shorthand for total devs
  timeline: string           # e.g. "12-weeks", "3-months"
  compliance: enum[]         # gdpr | hipaa | sox | pci-dss | iso27001 | soc2
  existingInfra:
    description: string
    mustReuse: boolean
  skills:
    languages: string[]
    cloudExperience: enum[]  # azure | aws | gcp
```

## testing (optional)

```yaml
testing:
  unit:
    framework: enum          # jest | vitest | pytest | xunit | go-test | junit | rspec | phpunit
  e2e:
    framework: enum          # playwright | cypress | selenium | none
  coverage:
    target: number           # e.g. 80
    enforce: boolean
```

## observability (optional)

```yaml
observability:
  logging:
    provider: enum           # pino | winston | serilog | zerolog | log4j | structured
    structured: boolean      # Default: true
    level: enum              # debug | info | warn | error
  tracing:
    provider: enum           # opentelemetry | jaeger | zipkin | xray | none
    samplingRate: number     # Default: 0.1
  metrics:
    provider: enum           # prometheus | datadog | cloudwatch | grafana | none
```

## environments (optional)

```yaml
environments:
  - name: string               # Required. e.g. "development", "staging", "production"
    url: string                # Optional. Primary environment URL (e.g. "https://app.example.com")
    cloud: string              # Optional. Override deployment cloud for this env
    services:                  # Optional. Services in this env with their base URLs
      - name: string           # Service name (matches architecture.services[] or projects.backend[])
        url: string            # Base URL for this service in this environment
    variables:                 # Optional. Non-secret env config
      - key: string
        value: string
    x-features: string[]      # Optional. Feature flags or capabilities enabled
```

## interServiceCommunication (plugin extension — not in upstream spec)

```yaml
interServiceCommunication:
  - pattern: enum              # Required. http | grpc | event-driven | websocket | message-queue
    description: string        # Required. How services communicate
    from: string               # Optional. Source service name
    to: string                 # Optional. Target service name
    protocol: string           # Optional. Specific protocol details (e.g. "REST over HTTPS", "protobuf")
    async: boolean             # Optional. Whether communication is async. Default: false
```

## configuration (plugin extension — not in upstream spec)

```yaml
configuration:
  strategy: enum               # Required. env-vars | config-service | feature-flags | vault | mixed
  provider: string             # Optional. e.g. "AWS SSM", "HashiCorp Vault", "LaunchDarkly"
  secretsManagement: string    # Optional. How secrets are stored/rotated
  perEnvironment: boolean      # Optional. Whether config varies per environment. Default: true
```

## errorHandling (plugin extension — not in upstream spec)

```yaml
errorHandling:
  strategy: enum               # Required. centralized | per-service | middleware | boundary
  errorFormat: string          # Optional. e.g. "RFC 7807 Problem Details", "custom JSON"
  globalHandler: boolean       # Optional. Whether a global error handler exists
  retryPolicy: string          # Optional. e.g. "exponential backoff with 3 retries"
  circuitBreaker: boolean      # Optional. Whether circuit breaker pattern is used
```

## technicalDebt (optional)

```yaml
technicalDebt:
  - id: string
    decision: string
    reason: string
    impact: string
    effort: string
    priority: enum           # low | medium | high | critical
    triggerCondition: string
    mitigationPlan: string
```

## evolution (optional)

```yaml
evolution:
  triggers:
    - condition: string
      action: string
      estimatedEffort: string
      blockers: string[]
  roadmap:
    - stage: enum            # mvp | growth | enterprise
      targetDate: string
      architectureChanges: string[]
      newCapabilities: string[]
  costProjection:
    currentMonthly: string
    atMVP: string
    atGrowth: string
    atEnterprise: string
```

## artifacts (plugin extension)

The upstream `spec/SDL-v1.1.md` focuses on architecture sections and does not define `artifacts` as a required root section. This plugin still supports `artifacts` as generation metadata for local workflows that need explicit artifact selection.

```yaml
artifacts:
  generate:                  # Required. Min 1
    - architecture-diagram
    - sequence-diagrams
    - openapi
    - data-model
    - repo-scaffold
    - iac-skeleton
    - backlog
    - adr
    - deployment-guide
    - cost-estimate
    - coding-rules
    - coding-rules-enforcement
  formats:
    diagrams: enum           # mermaid | plantuml | structurizr
    adr: enum                # markdown | asciidoc
```

---

## contracts (optional, v1.1)

API contract definitions for REST, GraphQL, and gRPC services. Contract files themselves live in `sdl/contracts/`.

```yaml
contracts:
  - name: api-server
    type: enum               # Required. openapi | graphql | grpc
    version: string          # Optional. e.g. "3.1.0"
    path: string             # Required. Path to contract file. e.g. sdl/contracts/api-server.openapi.yaml
    endpoints:               # Optional
      count: number
      baseUrl: string
```

---

## domain (optional, v1.1)

Entity definitions with fields, types, relationships, indexes, and constraints. Drives ORM schema generation.

```yaml
domain:
  entities:
    - name: string           # Required. PascalCase entity name
      description: string    # Optional
      table: string          # Optional. DB table name (snake_case default)
      fields:                # Optional
        - name: string       # Required
          type: enum         # Required. uuid | string | int | bigint | decimal | boolean | timestamp | json | enum | text
          primaryKey: boolean
          generated: boolean # Auto-generated (sequences, UUID defaults)
          unique: boolean
          nullable: boolean  # Default: false
          default: string
          maxLength: number
          precision: number
          scale: number
          enum: string[]     # If type: enum
          foreignKey: string # e.g. "Users.id"
          onUpdate: string   # e.g. "NOW()"
          description: string
      relationships:         # Optional
        - name: string
          type: enum         # one-to-one | one-to-many | many-to-one | many-to-many
          target: string     # Target entity name
          foreignKey: string
      indexes:               # Optional
        - name: string       # Optional
          fields: string[]   # Required
          unique: boolean
      constraints:           # Optional
        - type: enum         # check | unique | foreign-key
          fields: string[]
          expression: string # For check constraints
```

---

## features (optional, v1.1)

Feature planning, MVP phasing, feature flags. Import: only list features that EXIST in the codebase. Blueprint: list planned features.

```yaml
features:
  phase1:                    # Phase key — use phase1/phase2/phase3 or named phases
    name: string             # Optional. e.g. "MVP"
    deadline: string         # Optional. ISO date
    features:
      - id: string           # Required. kebab-case
        name: string         # Required
        description: string
        priority: enum       # critical | high | medium | low
        estimatedDays: number
        dependsOn: string[]  # IDs of features this depends on
        status: enum         # planned | in-progress | completed
  featureFlags:              # Optional
    - name: string           # Required
      rollout: string        # e.g. "50%", "0%", "100%"
      targetAudience: string
      phase: string          # Phase key this flag belongs to
```

---

## compliance (optional, v1.1)

Regulatory requirements, data retention policies, and certifications.

```yaml
compliance:
  frameworks:
    - name: enum             # Required. GDPR | HIPAA | SOC2-Type2 | PCI-DSS | CCPA | ISO27001
      applicable: boolean    # Required
      requirements:          # Optional
        - requirement: string
          description: string
          implementation: string
      notes: string          # Optional. Reason if not applicable
  certifications:            # Optional
    - name: string
      targetDate: string
      auditor: string
  dataResidency:             # Optional
    - region: string
      dataTypes: string[]
      compliance: string[]
  dataRetention:             # Optional
    - dataType: string
      retentionDays: number
      reason: string
```

---

## slos (optional, v1.1)

Service level objectives and SLIs per component. Generated when: production stage OR 2+ services OR explicit targets defined.

```yaml
slos:
  - componentId: string      # Required. Must match a component name in architecture.projects
    name: string             # Optional
    availability:
      target: string         # Required. e.g. "99.9%"
      window: enum           # Optional. monthly | weekly | daily
      errorBudget: string    # Optional. e.g. "43 minutes/month"
    latency:
      p50: string            # e.g. "50ms"
      p95: string
      p99: string
      p999: string
    throughput:
      rps: number
      concurrentUsers: number
    errorRate:
      target: string         # e.g. "0.1%"
    slis:                    # Optional
      - metric: string
        description: string
        query: string        # Prometheus/PromQL expression
        threshold: string
    alerts:                  # Optional
      - name: string
        condition: string
        severity: enum       # critical | warning | info
        action: string
```

---

## resilience (optional, v1.1)

Fault tolerance patterns: circuit breakers, retries, timeouts, bulkheads, fallbacks.

```yaml
resilience:
  circuitBreaker:            # Optional
    - name: string
      target: enum           # external | internal
      failureThreshold: number
      successThreshold: number
      timeout: string        # e.g. "30s"
      backoffMultiplier: number
      maxBackoff: string
      fallback: string
  retryPolicy:               # Optional
    - name: string
      maxAttempts: number
      backoff:
        type: enum           # exponential | linear | fixed
        initialDelayMs: number
        maxDelayMs: number
        multiplier: number
      retryableErrors: string[] # e.g. [500, 502, 503, "timeout"]
  timeout:                   # Optional
    - name: string
      ms: number             # Required
      description: string
  bulkhead:                  # Optional
    - name: string
      threads: number
      queue: number
      description: string
  rateLimit:                 # Optional
    - name: string
      rps: number
      burstSize: number
      perUser: number
      window: string
  fallback:                  # Optional
    - service: string
      failureMode: enum      # timeout | error | slow-response
      fallbackStrategy: string
```

---

## costs (optional, v1.1)

Infrastructure and third-party cost model. Always generated; import: from Terraform/compose only; blueprint: estimated projections.

```yaml
costs:
  model: enum                # Optional. usage-based | flat-rate | hybrid
  infrastructure:
    compute:                 # Optional
      - component: string    # Component name
        platform: string     # e.g. "aws-ec2", "vercel", "railway"
        instanceType: string
        instances: number
        costPerMonth: number
    database:                # Optional
      - name: string
        provider: string
        instanceType: string
        storage: string
        costPerMonth: number
    storage:                 # Optional
      - name: string
        provider: string
        storage: string
        costPerMonth: number
    cdn:                     # Optional
      - name: string
        provider: string
        bandwidth: string
        costPerMonth: number
  thirdParty:                # Optional
    - name: string
      category: string
      fee: string
      expectedVolume: string
      monthlyCost: number
  total:                     # Optional
    infrastructure: number
    thirdParty: number
    monthly: number
    annual: number
  scaling:                   # Optional
    - milestone: string
      estimatedCost: number
```

---

## backupDr (optional, v1.1)

Backup strategy, RTO/RPO, replication, and disaster recovery procedures. Generated when primary database exists.

```yaml
backupDr:
  strategy: enum             # Optional. active-passive | active-active | pilot-light | warm-standby
  databases:                 # Optional
    - name: string
      rto: string            # Recovery Time Objective. e.g. "15m"
      rpo: string            # Recovery Point Objective. e.g. "5m"
      backup:
        frequency: enum      # hourly | daily | weekly
        retention: string
        type: string         # e.g. "continuous-backup", "snapshot"
      replication:           # Optional
        target: string
        lag: string
      failover:
        automatic: boolean
        manual: boolean
        switchoverTime: string
  storage:                   # Optional
    - name: string
      rto: string
      rpo: string
      backup:
        type: string
        target: string
        retention: string
  siteFailover:              # Optional
    primary: string          # Primary region
    secondary: string        # Failover region
    healthCheck: string
    automaticFailover: boolean
    switchoverTime: string
    testSchedule: string
    lastTestDate: string
  recoveryProcedures:        # Optional
    - scenario: string
      rto: string
      steps: string[]
```

---

## design (optional, v1.1)

Defines the visual design language for frontend components. When present, scaffold prompts MUST follow these constraints instead of defaulting to generic styles.

**Structure note:** The upstream spec (SDL-v1.1.md) stores font families under `design.tokens.typography.headingFont/bodyFont/monoFont` (camelCase, nested under `tokens`). This plugin simplifies to `design.typography.heading/body/mono` for SDL generation. The `_state.json` flattens further to `heading_font/body_font/mono_font`. Both representations are valid; use the plugin form when generating.

```yaml
design:
  personality: string        # Optional. e.g. "professional-structured", "bold-commercial", "soft-minimal"
  preset: enum               # Optional. shadcn | material | ant | chakra | daisyui | bootstrap | custom
  
  # Simplified palette (plugin form — flat fields):
  palette:                   # Optional
    primary: string          # CSS hex. e.g. "#0066cc"
    secondary: string
    accent: string
    neutral: enum            # slate | gray | zinc | neutral | stone
    surface: enum            # light | dark | auto
    semantic:
      success: string
      warning: string
      error: string
      info: string
  
  # Full token set (upstream spec form — use when capturing detailed design systems):
  tokens:                    # Optional. Preferred over flat fields when full token scale is available
    colors:                  # Named color tokens
      primary: string        # e.g. "#0066cc"
      primary-dark: string
      secondary: string
      success: string
      warning: string
      error: string
      neutral-50: string
      neutral-900: string
    typography:              # Upstream spec uses camelCase here
      headingFont: string    # e.g. "Figtree"
      bodyFont: string       # e.g. "Inter"
      monoFont: string       # e.g. "JetBrains Mono"
      scale:                 # Pixel sizes
        h1: string           # e.g. "32px"
        h2: string
        h3: string
        body: string
        small: string
    spacing:
      xs: string
      sm: string
      md: string
      lg: string
      xl: string
    radius:
      sm: string             # e.g. "4px"
      md: string
      lg: string
      full: string           # e.g. "9999px"
    shadows:
      sm: string             # CSS shadow value
      md: string
      lg: string
  
  # Plugin simplified typography (use when tokens not available):
  typography:                # Optional. Simplified font-family-only form
    heading: string          # Font family. e.g. "DM Sans"
    body: string             # e.g. "Inter"
    mono: string             # e.g. "JetBrains Mono"
    scale: enum              # compact | default | spacious

  shape:                     # Optional
    radius: enum             # none | sm | md | lg | full
    density: enum            # compact | default | relaxed
    shadows: enum            # flat | subtle | elevated | dramatic
    borders: enum            # none | subtle | visible | bold
  motion:                    # Optional
    transitions: enum        # none | snappy | smooth | expressive
    pageTransitions: boolean # Default: false
  layout:                    # Optional
    maxWidth: number         # Max content width in px. e.g. 1280
    style: enum              # dashboard | marketing | editorial | app-shell | saas
  iconLibrary: string        # Optional. e.g. "lucide-react", "heroicons", "phosphor"
  componentLibrary: string   # Optional. e.g. "shadcn/ui", "Radix UI", "Chakra UI"
  
  # Multi-theme support (v1.1 spec):
  themes:                    # Optional. Define light/dark/custom themes
    - name: string           # Required. e.g. "light", "dark", "high-contrast"
      colors:                # Theme-specific color overrides
        background: string
        text: string
        [key]: string
  
  # Layout variants (v1.1 spec):
  layouts:                   # Optional. Named layout shells available in the app
    - name: string           # Required. e.g. "dashboard", "marketing", "app-shell"
      description: string
  
  accessibility:             # Optional
    wcag: enum               # A | AA | AAA
    reducedMotion: boolean   # Default: true
    highContrast: boolean    # Default: false
```

**Behavior rules:**
- When `preset` is set, scaffold should install/configure that design system and follow its conventions.
- When `palette` is set, ALL generated UI code MUST use these colors — never fall back to default Tailwind indigo/purple.
- When `personality` is set, it constrains layout density, whitespace, border treatment, and animation choices.
- When `design` is absent entirely, the scaffolder should select a diverse, project-appropriate palette (NOT default indigo).

---

## Extension Fields

Any field prefixed with `x-` is allowed at any level:

```yaml
solution:
  name: "MyApp"
  x-internal-id: "PRJ-123"
  x-team-slack: "#architecture"
```

---

## Conditional Validation Rules

These are hard errors — SDL will not compile if violated:

| # | Condition | Requirement | Error Code |
|---|-----------|-------------|------------|
| 1 | `architecture.style = "microservices"` | `services[]` must have 2+ items | `MICROSERVICES_REQUIRES_SERVICES` |
| 2 | `auth.strategy = "oidc"` | `auth.identityProvider` must be set | `OIDC_REQUIRES_PROVIDER` |
| 3 | `nonFunctional.security.pii = true` | `encryptionAtRest` must be `true` | `PII_REQUIRES_ENCRYPTION` |
| 4 | `deployment.infrastructure.iac = "cloudformation"` | `deployment.cloud` must be `"aws"` | `INCOMPATIBLE_CLOUD_IAC` |
| 5 | `data.primaryDatabase.type = "mongodb"` | No backend may have `orm = "ef-core"` | `INCOMPATIBLE_DATABASE_ORM` |
