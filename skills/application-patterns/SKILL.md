---
name: application-patterns
description: Architecture pattern selection, folder structures, coding conventions, error handling, testing strategies, and platform-specific patterns for structuring application code
---

# Application Patterns

Authoritative reference for selecting and applying the `application_patterns` manifest block during blueprint generation. Covers architecture pattern selection, folder structures, coding conventions, error handling, testing strategies, and platform-specific patterns.

For security architecture (auth, OWASP, API security), see `operational-patterns`. For infrastructure and tooling decisions (cloud, database, hosting), see `prescriptive-decision-framework`.

---

## Architecture Pattern Selection

### Decision Inputs

| Input | How to Determine |
|-------|-----------------|
| **Team size** | Gating question 5 or tech constraints section |
| **Domain complexity** | Simple CRUD (< 10 entities) vs complex business rules vs event-heavy workflows |
| **Deployment model** | Single deployable vs multiple services (from scale/team gating) |
| **Platform** | Backend API, frontend web app, mobile app, or full-stack |

### Architecture Pattern Decision Tree

```
IF simple CRUD app with < 10 entities AND team <= 3:
  -> RECOMMEND: layered
  -> REASONING: "Simplest to build and hire for. Controllers -> services -> data access. No abstraction overhead."
  -> ALTERNATIVE: "mvc if server-rendered pages are needed (admin panels, forms)"
  -> DON'T USE: "clean-architecture or hexagonal — overkill for simple CRUD"

ELSE IF server-rendered pages with forms (admin panels, CRM, dashboards):
  -> RECOMMEND: mvc
  -> REASONING: "Natural fit for request/response with views. Well-understood by most developers."
  -> ALTERNATIVE: "layered if API-only with separate frontend"
  -> DON'T USE: "cqrs, event-driven — wrong paradigm for form-based apps"

ELSE IF mobile or reactive UI with data-binding (React Native, Flutter):
  -> RECOMMEND: mvvm
  -> REASONING: "ViewModel decouples business logic from UI. Natural fit for reactive/declarative frameworks."
  -> ALTERNATIVE: "clean-architecture if domain logic is complex beyond UI state"
  -> DON'T USE: "mvc — poor fit for reactive/declarative UI frameworks"

ELSE IF complex business logic with many domain rules AND high testability needed:
  -> RECOMMEND: clean-architecture
  -> REASONING: "Domain at center, dependencies point inward. Business logic testable without framework/DB. Best for long-lived codebases."
  -> ALTERNATIVE: "hexagonal if swappable external integrations matter more than layered use-case organization"
  -> DON'T USE: "For MVPs or simple CRUD — the abstraction overhead slows early development"

ELSE IF many external integrations that may change (payment providers, notification services, AI providers):
  -> RECOMMEND: hexagonal
  -> REASONING: "Ports and adapters. Swap Stripe for Adyen, swap OpenAI for Anthropic — without touching business logic."
  -> ALTERNATIVE: "clean-architecture if the domain rules are more complex than the integration surface"

ELSE IF single deployable AND team 3-10 AND multiple bounded contexts:
  -> RECOMMEND: modular-monolith
  -> REASONING: "Module isolation without deployment complexity. Each module owns its data/logic. Can extract to microservices later."
  -> ALTERNATIVE: "clean-architecture if there's one dominant domain, not multiple contexts"
  -> DON'T USE: "microservices — same organizational benefit, 5x more operational complexity at this team size"

ELSE IF team > 10 backend engineers AND services need independent deployment and scaling:
  -> RECOMMEND: microservices
  -> REASONING: "Independent deploys, independent scaling, independent tech choices per service. Required at this team size for velocity."
  -> DON'T USE: "At MVP stage or with < 5 engineers — operational overhead destroys velocity"

ELSE IF low-traffic bursty workloads AND no persistent connections:
  -> RECOMMEND: serverless
  -> REASONING: "Pay per invocation. Auto-scales to zero. Ideal for webhooks, cron jobs, event processors."
  -> ALTERNATIVE: "layered on Railway/Render if you need persistent connections (WebSockets)"
  -> DON'T USE: "For real-time features, long-running jobs, or latency-sensitive APIs (cold starts)"

ELSE IF components react to events asynchronously (order placed -> email + inventory + analytics):
  -> RECOMMEND: event-driven
  -> REASONING: "Decouples producers from consumers. New consumers don't require changes to producers. Natural for async workflows."
  -> ALTERNATIVE: "cqrs if read/write asymmetry is the primary concern rather than event flow"
  -> DON'T USE: "Simple request/response CRUD — adds unnecessary complexity"

ELSE IF read and write patterns are fundamentally different (high-read dashboards + low-write mutations):
  -> RECOMMEND: cqrs
  -> REASONING: "Separate read models (optimized for queries) from write models (optimized for business rules). Scale reads independently."
  -> ALTERNATIVE: "event-driven if the asymmetry is about workflow rather than read/write patterns"
  -> DON'T USE: "Simple CRUD where reads and writes use the same model"

ELSE (default):
  -> RECOMMEND: layered
  -> REASONING: "Safe default. Easiest to hire for. Can evolve to modular-monolith or clean-architecture when complexity justifies it."
```

### Pattern Compatibility Matrix

| Primary Pattern | Combines Well With | Avoid Combining With |
|----------------|-------------------|---------------------|
| clean-architecture | domain-driven folders, cqrs | flat folders |
| hexagonal | domain-driven folders, event-driven | layer-based folders |
| mvc | layer-based folders | cqrs, event-driven |
| mvvm | feature-based folders | microservices |
| modular-monolith | module-based folders, event-driven | flat folders |
| microservices | event-driven, cqrs | mvc, flat folders |
| serverless | flat or feature-based folders | modular-monolith |
| event-driven | cqrs, microservices, feature-based | mvc |
| cqrs | event-driven, clean-architecture | flat folders, mvc |
| layered | layer-based or feature-based folders | cqrs (overkill) |

---

## Folder Structure Examples

### Backend: feature-based

```
src/
  features/
    auth/
      auth.controller.ts
      auth.service.ts
      auth.repository.ts
      auth.routes.ts
      auth.types.ts
      __tests__/
        auth.service.test.ts
    orders/
      orders.controller.ts
      orders.service.ts
      orders.repository.ts
      orders.routes.ts
      orders.types.ts
      __tests__/
        orders.service.test.ts
  shared/
    middleware/
      auth.middleware.ts
      error.middleware.ts
    utils/
    types/
  config/
    env.ts
  index.ts
```

### Backend: layer-based

```
src/
  controllers/
    auth.controller.ts
    orders.controller.ts
  services/
    auth.service.ts
    orders.service.ts
  repositories/
    auth.repository.ts
    orders.repository.ts
  models/
    user.model.ts
    order.model.ts
  routes/
    auth.routes.ts
    orders.routes.ts
  middleware/
    auth.middleware.ts
    error.middleware.ts
  config/
    env.ts
  index.ts
```

### Backend: domain-driven (clean-architecture / hexagonal)

```
src/
  domain/
    entities/
      user.ts
      order.ts
    value-objects/
      email.ts
      money.ts
    repositories/
      user.repository.ts      # Interface only
      order.repository.ts     # Interface only
    errors/
      not-found.error.ts
      validation.error.ts
  application/
    use-cases/
      create-order.use-case.ts
      get-user.use-case.ts
    dto/
      create-order.dto.ts
  infrastructure/
    persistence/
      prisma-user.repository.ts   # Implements domain interface
      prisma-order.repository.ts
    external/
      stripe.adapter.ts
      email.adapter.ts
  presentation/
    controllers/
      orders.controller.ts
    middleware/
      auth.middleware.ts
      error.middleware.ts
    routes/
      orders.routes.ts
  config/
    env.ts
  index.ts
```

### Backend: module-based (modular-monolith)

```
src/
  modules/
    auth/
      index.ts            # Public API (barrel export)
      auth.service.ts
      auth.repository.ts
      auth.routes.ts
      __tests__/
    billing/
      index.ts
      billing.service.ts
      billing.repository.ts
      billing.routes.ts
      __tests__/
    orders/
      index.ts
      orders.service.ts
      orders.repository.ts
      orders.routes.ts
      __tests__/
  shared/
    middleware/
    utils/
  config/
  index.ts
```

Cross-module imports go through `index.ts` only. Direct imports of internal files across modules are a violation.

### Backend: flat

```
src/
  auth.ts
  orders.ts
  billing.ts
  db.ts
  middleware.ts
  types.ts
  index.ts
```

Suitable only for serverless functions, small CLIs, or prototypes with < 5 files.

### Frontend: Next.js App Router (feature-based)

```
src/
  app/
    (auth)/
      login/page.tsx
      register/page.tsx
    (dashboard)/
      layout.tsx
      page.tsx
      orders/page.tsx
  features/
    auth/
      hooks/use-auth.ts
      components/login-form.tsx
      api/auth.api.ts
    orders/
      hooks/use-orders.ts
      components/order-list.tsx
      api/orders.api.ts
  components/
    ui/
      button.tsx
      input.tsx
  lib/
    api-client.ts
    utils.ts
  store/
    auth.store.ts
```

### Frontend: React SPA (Vite, feature-based)

```
src/
  features/
    auth/
      pages/login.tsx
      hooks/use-auth.ts
      components/login-form.tsx
      api/auth.api.ts
    orders/
      pages/order-list.tsx
      hooks/use-orders.ts
      components/order-card.tsx
      api/orders.api.ts
  components/
    ui/
    layout/
  lib/
    api-client.ts
    router.tsx
  store/
  App.tsx
  main.tsx
```

### Mobile: React Native / Expo (feature-based)

```
src/
  features/
    auth/
      screens/login-screen.tsx
      hooks/use-auth.ts
      components/login-form.tsx
      api/auth.api.ts
    orders/
      screens/order-list-screen.tsx
      hooks/use-orders.ts
      components/order-card.tsx
      api/orders.api.ts
  components/
    ui/
  navigation/
    root-navigator.tsx
    auth-navigator.tsx
  services/
    storage.ts
    notifications.ts
    biometrics.ts
  lib/
    api-client.ts
  store/
    auth.store.ts
  App.tsx
```

---

## Coding Conventions

### Naming Conventions by Folder Convention

| Convention | File Naming | Class / Function | Exports |
|-----------|-------------|-----------------|---------|
| feature-based | `{feature}.{layer}.ts` (e.g., `orders.service.ts`) | `OrdersService`, `createOrder` | Named exports per file |
| layer-based | `{entity}.{layer}.ts` (e.g., `order.controller.ts`) | `OrderController`, `OrderService` | Named exports per file |
| domain-driven | `{concept}.ts` in layer directory | `Order` (entity), `CreateOrderUseCase` | Named exports per file |
| module-based | `{module}/{layer}.ts` | `AuthService`, `BillingService` | Barrel exports via `index.ts` |
| flat | `{feature}.ts` | `createOrder`, `authenticateUser` | Named exports per file |

### Dependency Rules by Architecture Pattern

| Pattern | Allowed Import Direction | Violation Example |
|---------|------------------------|-------------------|
| **clean-architecture** | presentation -> application -> domain (never reverse) | Domain importing Express types |
| **hexagonal** | adapters -> ports -> domain (never reverse) | Domain importing Prisma client |
| **layered** | controllers -> services -> repositories (never reverse) | Repository importing controller |
| **modular-monolith** | Within module: any direction. Cross-module: public API (`index.ts`) only | Module A importing Module B's internal service |
| **mvc** | views -> controllers -> models (never reverse) | Model importing view logic |
| **mvvm** | view -> viewmodel -> model (never reverse) | Model importing view state |

---

## Error Handling Patterns

Application-level error handling for structuring, propagating, and responding to errors. For security error mitigations (OWASP, rate limiting, input sanitization), see `operational-patterns`.

### Standard Error Response Shape

```typescript
interface AppError {
  code: string;        // Machine-readable: "ORDER_NOT_FOUND", "VALIDATION_FAILED"
  message: string;     // Human-readable: "Order not found"
  details?: unknown;   // Validation errors array, debug context
  requestId: string;   // For support correlation
}
```

### Error Handling Strategy by Pattern

| Pattern | Strategy | Implementation |
|---------|----------|---------------|
| **layered / mvc** | Try-catch in controllers, centralized error middleware | Express `app.use((err, req, res, next) => ...)` catches all |
| **clean-architecture** | Domain errors as typed classes, use-case catches and maps to application errors | `OrderNotFoundError extends DomainError`, use-case returns `Result<T, E>` |
| **hexagonal** | Port defines error types, adapter catches infrastructure errors and maps to port errors | Database timeout -> `RepositoryUnavailableError` |
| **event-driven** | Dead letter queue for unprocessable events, structured error events | Failed event -> DLQ, log for replay. See `architecture-methodology` invariant on at-least-once processing. |
| **serverless** | Return structured error response, let platform handle retries | `{ statusCode: 500, body: JSON.stringify(appError) }` |
| **microservices** | Each service returns domain error codes, API gateway maps to HTTP | gRPC status codes -> HTTP status codes at gateway |

### Domain Error to HTTP Status Mapping

| Domain Error Type | HTTP Status | When |
|------------------|-------------|------|
| `ValidationError` | 400 | Input fails schema or business rule validation |
| `AuthenticationError` | 401 | Missing, expired, or invalid credentials |
| `ForbiddenError` | 403 | Valid auth but insufficient permissions |
| `NotFoundError` | 404 | Entity does not exist or is not accessible |
| `ConflictError` | 409 | Duplicate resource, idempotency key collision |
| `RateLimitError` | 429 | Too many requests |
| `ExternalServiceError` | 502 | Upstream dependency failed |
| `UnexpectedError` | 500 | Unhandled exception (log full stack, return generic message) |

### Error Propagation Rules

- Never expose stack traces or internal error details in production responses
- Log the full error server-side (with `requestId`), return sanitized `AppError` to the client
- Distinguish client errors (4xx — don't retry) from server errors (5xx — may retry with backoff)
- Use `requestId` for cross-service correlation. See `operational-patterns` structured logging for format.
- For async errors, route to dead letter queue. See `architecture-methodology` invariant on at-least-once processing with DLQ.
- Frontend: use error boundaries (React) or global error handlers to catch rendering errors without crashing the app

---

## Testing Strategy Patterns

### Testing Pyramid by Architecture Pattern

| Pattern | Unit Tests | Integration Tests | E2E Tests | Contract Tests | Ratio |
|---------|-----------|------------------|----------|---------------|-------|
| **layered / mvc** | Service logic, validators | API endpoints (supertest) | Critical user flows | N/A | 70 / 20 / 10 |
| **clean-architecture** | Use cases, domain entities | Adapters against real DB | Critical user flows | N/A | 60 / 30 / 10 |
| **modular-monolith** | Per-module service logic | Per-module API + cross-module | Critical cross-module flows | Between modules | 50 / 25 / 10 / 15 |
| **microservices** | Per-service logic | Intra-service with test DB | Cross-service critical paths | Between services (Pact) | 50 / 20 / 10 / 20 |
| **event-driven** | Event handlers, validators | Event processing pipeline | End-to-end event flows | Event schema validation | 50 / 20 / 10 / 20 |
| **serverless** | Function logic | With local emulator (SAM) | Deployed endpoint smoke tests | N/A | 60 / 30 / 10 |

### What to Test Where

| Layer | What to Test | What NOT to Test | Tooling |
|-------|-------------|-----------------|---------|
| **Domain / business logic** | Rules, calculations, state transitions, edge cases | Framework code, database queries | Jest, Vitest, pytest |
| **API endpoints** | Request/response contracts, auth, validation, status codes | Internal service implementation | Supertest, httpx, Playwright API |
| **Database** | Migrations, complex queries, indexes, constraints | Simple CRUD operations | Testcontainers, in-memory SQLite |
| **External integrations** | Contract compliance, error handling for failures | Third-party uptime or correctness | MSW (mocks), Pact (contracts) |
| **Frontend components** | User interactions, conditional rendering, form validation | Styling, pixel-level layout | Testing Library, Storybook |
| **E2E flows** | Critical user journeys (signup, checkout, payment) | Every possible path | Playwright, Cypress |

### Testing Strategy Templates

Use these templates when populating the `testing_strategy` manifest field:

**MVP / simple app:**
> Unit tests for business logic (Jest/Vitest). Integration tests for API endpoints (supertest). No E2E yet. Coverage target: 60%. Run in CI on every PR.

**Multi-service production:**
> Unit tests for domain logic per service. Integration tests per service with test database. Contract tests between services (Pact). E2E for critical user flows (Playwright). Coverage target: 80%. Run in CI, E2E on staging deploy.

**Event-driven / async:**
> Unit tests for event handlers and validators. Integration tests for event processing pipeline. Schema validation tests for event contracts. DLQ monitoring as implicit regression detection. Coverage target: 70%.

---

## Frontend-Specific Patterns

### State Management Selection

```
IF app has < 5 pages AND minimal shared state:
  -> RECOMMEND: React useState + Context
  -> REASONING: "No extra dependencies. Sufficient for simple apps. Upgrade when state gets complex."
  -> DON'T USE: "Redux, Zustand — overkill at this scale"

ELSE IF primary state is server data (CRUD app, dashboard, admin panel):
  -> RECOMMEND: React Query / TanStack Query (server state) + Zustand (client state)
  -> REASONING: "Server cache is not client state. React Query handles caching, revalidation, loading states. Zustand for UI-only state (modals, sidebar)."

ELSE IF complex client-side state (collaborative editor, form builder, drag-and-drop):
  -> RECOMMEND: Zustand or Redux Toolkit
  -> REASONING: "Need predictable state updates, middleware, devtools, undo/redo support."

ELSE IF Next.js App Router with server components:
  -> RECOMMEND: Server components for data fetching + Zustand for client state
  -> REASONING: "Server components eliminate client state for read data. Zustand handles remaining interactive state."

ELSE IF Vue / Nuxt:
  -> RECOMMEND: Pinia
  -> REASONING: "Official Vue state management. Composable, typed, devtools integrated."
```

### Component Architecture

| Pattern | When to Use | Structure |
|---------|------------|-----------|
| **Feature components** | Feature-scoped, self-contained units | Feature folder with `components/`, `hooks/`, `api/` |
| **Presentational + Container** | Clear data/UI separation needed | Container fetches data, presentational renders props |
| **Compound components** | Complex UI with shared state (Accordion, Tabs, Menu) | Parent provides context, children consume via hooks |
| **Headless hooks** | Reusable logic across different UIs | Logic in custom hooks, no rendered UI (e.g., `useAuth`, `usePagination`) |

### Data Fetching Patterns

| Pattern | When to Use | Implementation |
|---------|------------|---------------|
| **Server Components (RSC)** | Next.js App Router, data needed on initial render | `async function Page()` with direct `fetch` or DB query |
| **Client-side fetching** | Interactive data, user-triggered queries | React Query `useQuery` / `useMutation` |
| **SSR + hydration** | SEO-critical pages with interactivity | Next.js `getServerSideProps` or loader functions |
| **Optimistic updates** | Instant UI feedback (likes, toggles, status changes) | React Query `onMutate` — update cache before server confirms |
| **Infinite scroll / pagination** | Long lists, feeds, search results | React Query `useInfiniteQuery` with cursor-based pagination |

---

## Mobile-Specific Patterns

### Offline-First Architecture

| Requirement | Strategy | Implementation |
|-------------|----------|---------------|
| **Read-only offline** (view cached data) | Cache-first with background sync | MMKV / AsyncStorage + stale-while-revalidate fetch pattern |
| **Write-while-offline** (create/edit offline) | Local-first writes + sync queue | MMKV writes + background sync queue + server reconciliation on reconnect |
| **Full offline capability** | Local database + sync engine | WatermelonDB or Expo SQLite + custom sync protocol with conflict resolution |

Default recommendation: start with read-only offline caching. Add write-offline only when user research confirms the need.

### Navigation Pattern Selection

| App Type | Pattern | Implementation |
|----------|---------|---------------|
| **Tab-based** (social, marketplace, dashboard) | Bottom tabs + stack per tab | Expo Router tabs or React Navigation bottom tabs |
| **Flow-based** (onboarding, checkout, multi-step forms) | Stack navigation with progress indicator | Stack navigator with step-aware header |
| **Drawer-based** (admin panels, settings-heavy apps) | Drawer + nested stacks | Drawer navigator with stack navigators per section |
| **Deep-link driven** (content apps, shared URLs) | URL-based file routing | Expo Router (file-based routing with deep link support) |

### Platform Abstraction Layer

Create a `services/` directory with platform-agnostic interfaces for capabilities that differ across platforms:

| Service | What It Abstracts | Example Implementations |
|---------|------------------|------------------------|
| `storage.ts` | Secure key-value storage | Expo SecureStore, MMKV, AsyncStorage |
| `notifications.ts` | Push notification registration and handling | Expo Notifications, Firebase Cloud Messaging |
| `biometrics.ts` | Biometric authentication | Expo LocalAuthentication |
| `camera.ts` | Camera and image capture | Expo Camera, react-native-image-picker |

Same principle as hexagonal architecture ports/adapters: feature code depends on the interface, not the platform implementation. Swap implementations without changing feature code.

---

## Choosing Patterns for a Blueprint

Quick-reference table for selecting the full `application_patterns` block based on project profile:

| Project Profile | Architecture | Folder Convention | Error Handling | Testing Strategy |
|----------------|-------------|-------------------|---------------|-----------------|
| **Simple CRUD API** | layered | layer-based | Centralized error middleware + status code mapping | Unit + integration (70/30) |
| **SaaS with complex domain** | clean-architecture | domain-driven | Typed domain errors + use-case mapping + error middleware | Unit + integration + contract (60/30/10) |
| **Modular product (pre-microservices)** | modular-monolith | module-based | Per-module error codes + shared error middleware | Unit + integration per module + cross-module contract |
| **Event-driven system** | event-driven | feature-based | DLQ + structured error events + retry with backoff | Handler unit + schema validation + pipeline integration |
| **Serverless API** | serverless | flat | Structured error responses per function | Function unit + emulator integration (60/40) |
| **Mobile app** | mvvm | feature-based | Error boundaries + retry on network failure | Component unit + integration + E2E critical flows |
| **Full-stack Next.js** | layered | feature-based | Server action errors + error.tsx boundaries + API error middleware | RSC + API + Playwright E2E |

For security architecture decisions, see `operational-patterns`. For infrastructure and tooling decisions (cloud, database, auth, hosting), see `prescriptive-decision-framework`. For domain-specific depth (multi-tenant isolation, payment flows, AI orchestration), see `product-type-detector` templates. To evaluate your chosen patterns against quality standards, see `well-architected`.
