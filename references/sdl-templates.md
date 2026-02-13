# SDL Starter Templates

10 ready-to-use SDL templates for common architecture patterns. Each template is a valid SDL document that can be compiled directly.

## Template Index

| # | ID | Name | Stage | Key Stack |
|---|---|---|---|---|
| 1 | `saas-starter` | SaaS Starter | MVP | Next.js, Node.js, Postgres, Auth0, Vercel, Stripe |
| 2 | `ecommerce` | E-Commerce Platform | Growth | Next.js, React, Node.js (microservices), Postgres, AWS, Cognito, Stripe |
| 3 | `mobile-backend` | Mobile App Backend | MVP | React Native, Node.js, Postgres, Firebase, Railway |
| 4 | `internal-tool` | Internal Tool / Admin Panel | MVP | Vue, Python FastAPI, Postgres, Entra ID, Azure |
| 5 | `api-first` | API-First Platform | Growth | Next.js, Go, DynamoDB, AWS, API key auth |
| 6 | `ai-product` | AI Product / RAG API | MVP | Next.js, Python FastAPI, Postgres, Auth0, AWS |
| 7 | `marketplace` | Two-Sided Marketplace | MVP | Next.js, .NET 8, Postgres, Auth0, AWS, Stripe Connect |
| 8 | `admin-dashboard` | Admin Dashboard | MVP | React, Node.js, Postgres, Auth0, Railway |
| 9 | `saas-subscription` | SaaS with Stripe Billing | MVP | Next.js, Node.js, Postgres, Auth0, Vercel, Stripe |
| 10 | `realtime-collab` | Real-Time Collaboration | MVP | React, Node.js, Postgres, Redis, Clerk, Fly.io |

---

## 1. SaaS Starter

Multi-tenant SaaS application with auth, billing, and a dashboard.

```yaml
sdlVersion: "0.1"

solution:
  name: "MySaaS"
  description: "Multi-tenant SaaS application"
  stage: "MVP"

product:
  personas:
    - name: "User"
      goals:
        - "Sign up and manage account"
        - "Use core features"
    - name: "Admin"
      accessLevel: "admin"
      goals:
        - "Manage users"
        - "View analytics"
  coreFlows:
    - name: "Onboarding"
      priority: "critical"
      steps:
        - "Sign up with email"
        - "Verify email"
        - "Complete profile"
        - "Start trial"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "dashboard"
        framework: "nextjs"
        styling: "tailwind"
    backend:
      - name: "api"
        framework: "nodejs"
        apiStyle: "rest"

auth:
  strategy: "oidc"
  provider: "auth0"
  roles:
    - "user"
    - "admin"
  sessions:
    accessToken: "jwt"
    refreshToken: true

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"
  cache:
    type: "redis"
    useCase:
      - "session"
      - "api"

integrations:
  payments:
    provider: "stripe"
    mode: "subscriptions"
  email:
    provider: "resend"
    useCase:
      - "transactional"
      - "notifications"

deployment:
  cloud: "vercel"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 100
    expectedUsersYear1: 5000
  security:
    pii: true
    encryptionAtRest: true
    encryptionInTransit: true

artifacts:
  generate:
    - "architecture-diagram"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "adr"
    - "cost-estimate"
```

---

## 2. E-Commerce Platform

Multi-vendor marketplace with microservices on AWS.

```yaml
sdlVersion: "0.1"

solution:
  name: "MyShop"
  description: "E-commerce marketplace platform"
  stage: "Growth"

product:
  personas:
    - name: "Shopper"
      goals:
        - "Browse and search products"
        - "Add to cart and checkout"
        - "Track orders"
    - name: "Seller"
      accessLevel: "authenticated"
      goals:
        - "List products"
        - "Manage inventory"
        - "View sales reports"
    - name: "Admin"
      accessLevel: "admin"
      goals:
        - "Manage sellers"
        - "Handle disputes"
  coreFlows:
    - name: "Purchase Flow"
      priority: "critical"
      steps:
        - "Search or browse products"
        - "Add to cart"
        - "Enter shipping details"
        - "Submit payment"
        - "Receive confirmation"
    - name: "Seller Onboarding"
      priority: "high"
      steps:
        - "Register as seller"
        - "Verify identity"
        - "Set up store"
        - "List first product"

architecture:
  style: "microservices"
  projects:
    frontend:
      - name: "storefront"
        framework: "nextjs"
        styling: "tailwind"
      - name: "seller-portal"
        framework: "react"
        type: "admin"
    backend:
      - name: "api-gateway"
        framework: "nodejs"
        apiStyle: "rest"
      - name: "order-worker"
        framework: "nodejs"
        type: "worker"
  services:
    - name: "catalog-service"
      kind: "backend"
      responsibilities:
        - "Product CRUD"
        - "Search indexing"
    - name: "order-service"
      kind: "backend"
      responsibilities:
        - "Order processing"
        - "Payment orchestration"

auth:
  strategy: "oidc"
  provider: "cognito"
  roles:
    - "shopper"
    - "seller"
    - "admin"
  mfa: true
  socialProviders:
    - "google"
    - "apple"

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"
  cache:
    type: "redis"
    useCase:
      - "session"
      - "api"
      - "query"
  search:
    provider: "elasticsearch"

integrations:
  payments:
    provider: "stripe"
    mode: "marketplace"
  email:
    provider: "sendgrid"
    useCase:
      - "transactional"
      - "notifications"
  cdn:
    provider: "cloudfront"
  monitoring:
    provider: "datadog"

deployment:
  cloud: "aws"
  ciCd:
    provider: "github-actions"

nonFunctional:
  availability:
    target: "99.95"
  scaling:
    expectedUsersMonth1: 1000
    expectedUsersYear1: 50000
    peakConcurrentUsers: 500
  security:
    pii: true
    pci: true
    encryptionAtRest: true
    encryptionInTransit: true

artifacts:
  generate:
    - "architecture-diagram"
    - "sequence-diagrams"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "iac-skeleton"
    - "backlog"
    - "adr"
    - "deployment-guide"
    - "cost-estimate"
```

---

## 3. Mobile App Backend

Backend API for a cross-platform mobile app.

```yaml
sdlVersion: "0.1"

solution:
  name: "MyApp"
  description: "Mobile app with backend API"
  stage: "MVP"

product:
  personas:
    - name: "Mobile User"
      goals:
        - "Sign up via social login"
        - "Use core features on the go"
        - "Receive push notifications"
  coreFlows:
    - name: "User Onboarding"
      priority: "critical"
      steps:
        - "Download app"
        - "Sign up with Google/Apple"
        - "Complete profile"
        - "Enable notifications"

architecture:
  style: "modular-monolith"
  projects:
    mobile:
      - name: "app"
        platform: "cross-platform"
        framework: "react-native"
    backend:
      - name: "api"
        framework: "nodejs"
        apiStyle: "rest"

auth:
  strategy: "oidc"
  provider: "firebase"
  socialProviders:
    - "google"
    - "apple"
  sessions:
    accessToken: "jwt"
    refreshToken: true

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"
  cache:
    type: "redis"
    useCase:
      - "session"

integrations:
  monitoring:
    provider: "sentry"

deployment:
  cloud: "railway"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 200
    expectedUsersYear1: 10000
  security:
    pii: true

artifacts:
  generate:
    - "architecture-diagram"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "adr"
    - "cost-estimate"
```

---

## 4. Internal Tool / Admin Panel

Internal business tool with SSO, RBAC, and audit logging.

```yaml
sdlVersion: "0.1"

solution:
  name: "BackOffice"
  description: "Internal admin and operations tool"
  stage: "MVP"

product:
  personas:
    - name: "Operations Staff"
      accessLevel: "authenticated"
      goals:
        - "Process requests"
        - "Update records"
    - name: "Manager"
      accessLevel: "admin"
      goals:
        - "View reports"
        - "Manage team access"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "admin"
        framework: "vue"
        type: "admin"
        styling: "css-modules"
    backend:
      - name: "api"
        framework: "python-fastapi"
        apiStyle: "rest"

auth:
  strategy: "oidc"
  provider: "entra-id"
  roles:
    - "staff"
    - "manager"
    - "admin"

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"

deployment:
  cloud: "azure"
  ciCd:
    provider: "azure-devops"

nonFunctional:
  availability:
    target: "99.5"
  scaling:
    expectedUsersMonth1: 20
    expectedUsersYear1: 100
  security:
    pii: true
    encryptionAtRest: true
    encryptionInTransit: true
    auditLogging: "detailed"

artifacts:
  generate:
    - "architecture-diagram"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "adr"
```

---

## 5. API-First Platform

Developer-facing API platform with rate limiting and OpenAPI docs.

```yaml
sdlVersion: "0.1"

solution:
  name: "DevAPI"
  description: "Developer-facing API platform"
  stage: "Growth"

product:
  personas:
    - name: "Developer"
      goals:
        - "Get API key"
        - "Read documentation"
        - "Integrate API"
    - name: "Platform Admin"
      accessLevel: "admin"
      goals:
        - "Monitor usage"
        - "Manage API keys"
  coreFlows:
    - name: "API Integration"
      priority: "critical"
      steps:
        - "Sign up"
        - "Generate API key"
        - "Read docs"
        - "Make first API call"
        - "Go to production"

architecture:
  style: "serverless"
  projects:
    frontend:
      - name: "docs-portal"
        framework: "nextjs"
        styling: "tailwind"
    backend:
      - name: "api"
        framework: "go"
        apiStyle: "rest"

auth:
  strategy: "api-key"

data:
  primaryDatabase:
    type: "dynamodb"
    hosting: "serverless"
  cache:
    type: "redis"
    useCase:
      - "api"

deployment:
  cloud: "aws"
  ciCd:
    provider: "github-actions"

nonFunctional:
  availability:
    target: "99.95"
  scaling:
    expectedUsersMonth1: 500
    expectedUsersYear1: 25000
  performance:
    apiResponseTime: "<100ms"
  security:
    pii: false
    encryptionInTransit: true

artifacts:
  generate:
    - "architecture-diagram"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "iac-skeleton"
    - "adr"
    - "deployment-guide"
    - "cost-estimate"
```

---

## 6. AI Product / RAG API

AI-powered analysis tool with document processing and semantic search.

```yaml
sdlVersion: "0.1"

solution:
  name: "MyAIProduct"
  description: "AI-powered analysis tool"
  stage: "MVP"

product:
  personas:
    - name: "API Consumer"
      goals:
        - "Upload documents for analysis"
        - "Query processed results"
        - "Manage API keys"
  coreFlows:
    - name: "Document upload + processing"
    - name: "Semantic search query"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "dashboard"
        framework: "nextjs"
    backend:
      - name: "api"
        framework: "python-fastapi"

auth:
  strategy: "oidc"
  provider: "auth0"
  roles:
    - "developer"
    - "admin"

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"

integrations:
  email:
    provider: "resend"

deployment:
  cloud: "aws"

constraints:
  budget: "scaleup"
  team:
    developers: 2
  timeline: "12-weeks"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 50
    expectedUsersYear1: 1000

artifacts:
  generate:
    - "architecture-diagram"
    - "adr"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "cost-estimate"
    - "backlog"
```

---

## 7. Two-Sided Marketplace

Buyer/seller marketplace with Stripe Connect split payments.

```yaml
sdlVersion: "0.1"

solution:
  name: "MyMarketplace"
  description: "A marketplace connecting buyers and sellers"
  stage: "MVP"

product:
  personas:
    - name: "Buyer"
      goals:
        - "Browse and search listings"
        - "Place orders"
        - "Leave reviews"
    - name: "Seller"
      goals:
        - "Create and manage listings"
        - "Process orders"
        - "View earnings"
    - name: "Admin"
      goals:
        - "Moderate listings"
        - "Manage disputes"
        - "View platform analytics"
  coreFlows:
    - name: "Buyer purchases from seller"
    - name: "Seller creates listing"
    - name: "Payout to seller"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "web"
        framework: "nextjs"
    backend:
      - name: "api"
        framework: "dotnet-8"

auth:
  strategy: "oidc"
  provider: "auth0"
  roles:
    - "buyer"
    - "seller"
    - "admin"

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"

integrations:
  payments:
    provider: "stripe"
    mode: "marketplace"
  email:
    provider: "sendgrid"

deployment:
  cloud: "aws"

constraints:
  budget: "scaleup"
  team:
    developers: 3
  timeline: "12-weeks"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 500
    expectedUsersYear1: 10000

artifacts:
  generate:
    - "architecture-diagram"
    - "adr"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "cost-estimate"
    - "backlog"
```

---

## 8. Admin Dashboard

Lightweight internal CRUD tool with record management and reporting.

```yaml
sdlVersion: "0.1"

solution:
  name: "MyInternalTool"
  description: "Internal tool for operations team"
  stage: "MVP"

product:
  personas:
    - name: "Operator"
      goals:
        - "View and manage records"
        - "Generate reports"
        - "Process approvals"
    - name: "Manager"
      goals:
        - "Review team activity"
        - "Configure workflows"
  coreFlows:
    - name: "Record management"
    - name: "Report generation"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "admin"
        framework: "react"
    backend:
      - name: "api"
        framework: "nodejs"

auth:
  strategy: "oidc"
  provider: "auth0"
  roles:
    - "operator"
    - "manager"

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"

integrations:
  email:
    provider: "resend"

deployment:
  cloud: "railway"

constraints:
  budget: "startup"
  team:
    developers: 1
  timeline: "6-weeks"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 20
    expectedUsersYear1: 100

artifacts:
  generate:
    - "architecture-diagram"
    - "adr"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "cost-estimate"
```

---

## 9. SaaS with Stripe Billing

Subscription SaaS app with team management and usage analytics.

```yaml
sdlVersion: "0.1"

solution:
  name: "MyApp"
  description: "A SaaS tool for teams"
  stage: "MVP"

product:
  personas:
    - name: "User"
      goals:
        - "Sign up and onboard"
        - "Use core feature"
    - name: "Admin"
      goals:
        - "Manage team members"
        - "View usage analytics"
  coreFlows:
    - name: "User onboarding"
    - name: "Core workflow"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "web"
        framework: "nextjs"
    backend:
      - name: "api"
        framework: "nodejs"

auth:
  strategy: "oidc"
  provider: "auth0"
  roles:
    - "user"
    - "admin"

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"

integrations:
  payments:
    provider: "stripe"
    mode: "subscriptions"
  email:
    provider: "resend"

deployment:
  cloud: "vercel"

constraints:
  budget: "startup"
  team:
    developers: 2
  timeline: "8-weeks"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 100
    expectedUsersYear1: 5000

artifacts:
  generate:
    - "architecture-diagram"
    - "adr"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "cost-estimate"
    - "backlog"
```

---

## 10. Real-Time Collaboration

Real-time collaborative app with WebSocket backend and event streaming.

```yaml
sdlVersion: "0.1"

solution:
  name: "CollabSpace"
  description: "Real-time collaboration platform"
  stage: "MVP"

product:
  personas:
    - name: "Collaborator"
      goals:
        - "Create and edit documents"
        - "See changes in real-time"
        - "Comment and discuss"
    - name: "Workspace Admin"
      accessLevel: "admin"
      goals:
        - "Manage workspace members"
        - "Configure permissions"
  coreFlows:
    - name: "Real-Time Editing"
      priority: "critical"
      steps:
        - "Open document"
        - "Connect to session"
        - "Edit collaboratively"
        - "Auto-save changes"

architecture:
  style: "modular-monolith"
  projects:
    frontend:
      - name: "editor"
        framework: "react"
        stateManagement: "zustand"
        styling: "tailwind"
    backend:
      - name: "api"
        framework: "nodejs"
        apiStyle: "rest"
      - name: "realtime"
        framework: "nodejs"
        type: "worker"

auth:
  strategy: "oidc"
  provider: "clerk"
  roles:
    - "viewer"
    - "editor"
    - "admin"
  sessions:
    accessToken: "jwt"
    refreshToken: true

data:
  primaryDatabase:
    type: "postgres"
    hosting: "managed"
  cache:
    type: "redis"
    useCase:
      - "session"
      - "api"
  queues:
    provider: "redis"
    useCase:
      - "event-streaming"
      - "notifications"

deployment:
  cloud: "fly-io"

nonFunctional:
  availability:
    target: "99.9"
  scaling:
    expectedUsersMonth1: 50
    expectedUsersYear1: 5000
    peakConcurrentUsers: 100
  performance:
    apiResponseTime: "<50ms"
  security:
    pii: false
    encryptionInTransit: true

artifacts:
  generate:
    - "architecture-diagram"
    - "sequence-diagrams"
    - "openapi"
    - "data-model"
    - "repo-scaffold"
    - "adr"
    - "cost-estimate"
```
