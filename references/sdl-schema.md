# SDL v0.1 Schema Reference

Solution Design Language (SDL) is a YAML-based specification for capturing complete software architecture decisions. This document defines every field, type, and validation rule.

## Required Root Fields

| Field | Type | Description |
|-------|------|-------------|
| `sdlVersion` | `"0.1"` | Always `"0.1"` |
| `solution` | object | Project metadata |
| `product` | object | User context and flows |
| `architecture` | object | System structure |
| `data` | object | Data layer |
| `nonFunctional` | object | Quality attributes |
| `deployment` | object | Hosting and infrastructure |
| `artifacts` | object | What to generate |

## Optional Root Fields

| Field | Type | Description |
|-------|------|-------------|
| `auth` | object | Authentication strategy |
| `integrations` | object | Third-party services |
| `constraints` | object | Budget, team, timeline |
| `technicalDebt` | array | Known tech debt items |
| `evolution` | object | Roadmap and cost projections |
| `testing` | object | Test framework config |
| `observability` | object | Logging, tracing, metrics |

---

## solution (required)

```yaml
solution:
  name: string              # Required. Project name
  description: string        # Required. What it does
  stage: enum                # Required. MVP | Growth | Enterprise
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
  style: enum                # Required. modular-monolith | microservices | serverless
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
```

## auth (optional)

```yaml
auth:
  strategy: enum             # Required. oidc | passwordless | magic-link | api-key | none
  provider: enum             # Optional. cognito | auth0 | entra-id | entra-id-b2c | firebase | supabase | clerk | custom
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
    - stage: enum            # MVP | Growth | Enterprise
      targetDate: string
      architectureChanges: string[]
      newCapabilities: string[]
  costProjection:
    currentMonthly: string
    atMVP: string
    atGrowth: string
    atEnterprise: string
```

## artifacts (required)

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
  formats:
    diagrams: enum           # mermaid | plantuml | structurizr
    adr: enum                # markdown | asciidoc
```

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
| 2 | `auth.strategy = "oidc"` | `auth.provider` must be set | `OIDC_REQUIRES_PROVIDER` |
| 3 | `nonFunctional.security.pii = true` | `encryptionAtRest` must be `true` | `PII_REQUIRES_ENCRYPTION` |
| 4 | `deployment.infrastructure.iac = "cloudformation"` | `deployment.cloud` must be `"aws"` | `INCOMPATIBLE_CLOUD_IAC` |
| 5 | `data.primaryDatabase.type = "mongodb"` | No backend may have `orm = "ef-core"` | `INCOMPATIBLE_DATABASE_ORM` |
