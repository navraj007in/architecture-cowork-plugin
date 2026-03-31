I now have everything I need. Let me produce the full implementation plan.

---

# Production Hardening Implementation Plan for Archon Scaffold Generation

---

## 1. Overview

### Surfaces Changed

| Surface | File | Change Type |
|---|---|---|
| New skill | `skills/production-hardening/SKILL.md` | Create new file |
| Component scaffold command | `commands/scaffold-component.md` | Add bullet points in BACKEND and FRONTEND sections |
| Orchestrator command | `commands/scaffold.md` | Update Step 6 summary table |
| SDK scaffold generator | `packages/sdl/src/generators/scaffold.ts` | Add npm deps to Node.js backend switch case |

### Feature to Surface Mapping

| # | Feature | Skill section | scaffold-component.md | scaffold.ts |
|---|---|---|---|---|
| 1 | Correlation ID propagation | `correlation-id` | Backend middleware + frontend api.ts | no new pkg |
| 2 | Graceful shutdown | `graceful-shutdown` | Backend `index.ts` | no new pkg |
| 3 | Auth token interceptor | `auth-token-interceptor` | Frontend `src/lib/api.ts` | no new pkg |
| 4 | Zod validation | `zod-validation` | Backend `src/schemas/`, `src/middleware/validate.ts`, `src/config/index.ts` | `zod` dep |
| 5 | Deep health check | `deep-health-check` | Backend `src/routes/health.ts` | no new pkg |
| 6 | Structured logger | `structured-logger` | Backend `src/lib/logger.ts` | `pino`, `pino-pretty` (devDep) |
| 7 | Retry + timeout | `retry-timeout` | Frontend `src/lib/api.ts`, backend service clients | `p-retry` (optional) |
| 8 | Soft delete | `soft-delete` | Backend Prisma schema + middleware | no new pkg |
| 9 | CSP configuration | `csp-config` | Backend `helmet` setup, Next.js `next.config.ts` | no new pkg |

---

## 2. New Skill: `skills/production-hardening/SKILL.md`

Create this file at `/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/production-hardening/SKILL.md`.

Full file content:

```markdown
---
name: production-hardening
description: Nine production hardening patterns for Node.js/Express backends and React/Next.js frontends. Used by scaffold-component to generate fully production-ready code.
---

# Production Hardening Patterns

Nine mandatory patterns applied to every scaffolded backend service and frontend web app. Each section contains the canonical implementation — copy this code exactly when scaffolding. Do not invent variations.

Reference: `skills/operational-patterns/SKILL.md` covers security architecture, OWASP, and observability stack selection. This file covers the concrete implementation patterns used at scaffold time.

---

## Pattern 1 — Correlation ID Header Propagation

### What it does
Every HTTP request gets a unique `x-correlation-id` header. Backend generates one if missing, forwards it on all outbound service calls, and includes it in every log line. Frontend API client sends it on every request.

### Backend: `src/middleware/correlation-id.ts`

```typescript
import { randomUUID } from 'crypto';
import type { Request, Response, NextFunction } from 'express';

export const CORRELATION_ID_HEADER = 'x-correlation-id';

declare global {
  namespace Express {
    interface Request {
      correlationId: string;
    }
  }
}

export function correlationIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const id = (req.headers[CORRELATION_ID_HEADER] as string) ?? randomUUID();
  req.correlationId = id;
  res.setHeader(CORRELATION_ID_HEADER, id);
  next();
}
```

### Backend: Mount order in `src/index.ts`

```typescript
// CRITICAL: correlationId MUST be mounted before logger middleware and all routes
app.use(correlationIdMiddleware);
app.use(requestLogger);   // logger reads req.correlationId
app.use(express.json());
```

### Backend: Forwarding in outbound service clients

When calling another service from a route handler or service layer, forward the header:

```typescript
// src/lib/http-client.ts
import { CORRELATION_ID_HEADER } from '../middleware/correlation-id';

export function makeServiceClient(baseUrl: string) {
  return async function request<T>(
    path: string,
    options: RequestInit & { correlationId?: string } = {},
  ): Promise<T> {
    const { correlationId, ...fetchOptions } = options;
    const headers = new Headers(fetchOptions.headers);
    if (correlationId) headers.set(CORRELATION_ID_HEADER, correlationId);

    const res = await fetch(`${baseUrl}${path}`, { ...fetchOptions, headers });
    if (!res.ok) throw new Error(`Service call failed: ${res.status}`);
    return res.json() as T;
  };
}
```

### Frontend: `src/lib/api.ts` — always send correlationId

```typescript
import { randomUUID } from 'crypto'; // or use uuid package in browser context

// In browser: crypto.randomUUID() is available in all modern browsers
const correlationId = () =>
  typeof crypto !== 'undefined' && crypto.randomUUID
    ? crypto.randomUUID()
    : Math.random().toString(36).slice(2);
```

Add `'x-correlation-id': correlationId()` to every request's headers (see Pattern 3 for the full api.ts implementation that includes this).

---

## Pattern 2 — Graceful Shutdown Handler

### What it does
On SIGTERM/SIGINT: stop accepting new connections, wait for in-flight requests to drain, close DB/cache connections, then exit with code 0.

### `src/index.ts` — complete graceful shutdown block

```typescript
import http from 'http';
import { db } from './config/database';   // Prisma client or pg pool
import { redis } from './config/cache';   // ioredis client — omit if no cache
import { logger } from './lib/logger';

const server = http.createServer(app);
const SHUTDOWN_TIMEOUT_MS = 10_000;

server.listen(PORT, () => {
  logger.info({ port: PORT }, 'Server listening');
});

function shutdown(signal: string): void {
  logger.info({ signal }, 'Received shutdown signal — draining connections');

  // Stop accepting new connections
  server.close(async (err) => {
    if (err) {
      logger.error({ err }, 'Error closing HTTP server');
      process.exit(1);
    }

    try {
      // Close database connection
      await db.$disconnect();                  // Prisma
      // await db.end();                       // pg Pool — uncomment if using pg directly

      // Close cache connection
      await redis?.quit();                     // ioredis — omit if no cache

      logger.info('Graceful shutdown complete');
      process.exit(0);
    } catch (shutdownErr) {
      logger.error({ err: shutdownErr }, 'Error during shutdown');
      process.exit(1);
    }
  });

  // Force exit after timeout — prevents hanging on stubborn connections
  setTimeout(() => {
    logger.error('Shutdown timeout exceeded — forcing exit');
    process.exit(1);
  }, SHUTDOWN_TIMEOUT_MS).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Catch unhandled errors — log and exit rather than running in corrupted state
process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'Uncaught exception');
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  logger.fatal({ reason }, 'Unhandled promise rejection');
  process.exit(1);
});
```

### Interaction with health check (Pattern 5)
When shutdown begins, the health endpoint should return 503 immediately to signal load balancers to stop routing traffic. Implement this with a `isShuttingDown` flag:

```typescript
let isShuttingDown = false;

// Add at top of health route handler:
if (isShuttingDown) {
  res.status(503).json({ status: 'shutting_down' });
  return;
}

// Set flag before closing server:
function shutdown(signal: string): void {
  isShuttingDown = true;
  // ... rest of shutdown
}
```

---

## Pattern 3 — Auth Token Interceptor (Frontend)

### What it does
`src/lib/api.ts` injects the Bearer token on every request, detects 401, refreshes the token transparently, retries the original request once, and redirects to the login page if the refresh also fails.

### Auth-provider matrix

| SDL `auth.provider` | Token storage | Refresh mechanism |
|---|---|---|
| `clerk` | Clerk SDK manages internally | `await clerk.session?.getToken({ skipCache: true })` |
| `auth0` | SDK manages in memory | `await auth0.getAccessTokenSilently({ ignoreCache: true })` |
| `supabase` | Supabase SDK auto-refreshes | `await supabase.auth.refreshSession()` then `supabase.auth.getSession()` |
| `firebase` | Firebase SDK manages | `await auth.currentUser?.getIdToken(true)` (force=true) |
| `custom-jwt` | `localStorage` / `httpOnly cookie` | Call `POST /auth/refresh` with refresh token |

### `src/lib/api.ts` — complete implementation

```typescript
import { config } from '../config';

// ── Types ──────────────────────────────────────────────────────────────────

export interface ApiError {
  code: string;
  message: string;
  details?: unknown;
}

export class ApiRequestError extends Error {
  constructor(
    public status: number,
    public error: ApiError,
    public correlationId: string,
  ) {
    super(error.message);
    this.name = 'ApiRequestError';
  }
}

// ── Token provider — swap implementation based on auth provider ─────────────

async function getAccessToken(): Promise<string | null> {
  // IMPLEMENTATION NOTE: replace the body of this function with the correct
  // provider call per the auth-provider matrix above.
  //
  // For custom JWT:
  //   return localStorage.getItem('access_token');
  //
  // For Clerk:
  //   const { session } = await import('@clerk/nextjs/server'); (or useAuth in client component)
  //   return session?.getToken() ?? null;
  //
  // For Auth0 (with @auth0/nextjs-auth0 client-side):
  //   return null; // Auth0 uses cookies — no manual token injection needed
  return localStorage.getItem('access_token');
}

async function refreshAccessToken(): Promise<string | null> {
  // IMPLEMENTATION NOTE: replace with correct provider refresh call.
  //
  // For custom JWT:
  const refreshToken = localStorage.getItem('refresh_token');
  if (!refreshToken) return null;
  const res = await fetch(`${config.apiUrl}/auth/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken }),
  });
  if (!res.ok) return null;
  const data = await res.json() as { accessToken: string; refreshToken: string };
  localStorage.setItem('access_token', data.accessToken);
  localStorage.setItem('refresh_token', data.refreshToken);
  return data.accessToken;
}

function redirectToLogin(): void {
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
  window.location.href = '/login';
}

// ── Core request function ───────────────────────────────────────────────────

let isRefreshing = false;
let refreshQueue: Array<(token: string | null) => void> = [];

async function request<T>(
  path: string,
  options: RequestInit = {},
  _isRetry = false,
): Promise<T> {
  const correlationId = crypto.randomUUID();

  const token = await getAccessToken();
  const headers = new Headers(options.headers);
  headers.set('Content-Type', 'application/json');
  headers.set('x-correlation-id', correlationId);
  if (token) headers.set('Authorization', `Bearer ${token}`);

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 10_000);

  let res: Response;
  try {
    res = await fetch(`${config.apiUrl}${path}`, {
      ...options,
      headers,
      signal: controller.signal,
    });
  } finally {
    clearTimeout(timeoutId);
  }

  // ── 401 handling: refresh and retry once ──────────────────────────────────
  if (res.status === 401 && !_isRetry) {
    if (isRefreshing) {
      // Queue concurrent requests while a refresh is in flight
      const newToken = await new Promise<string | null>((resolve) => {
        refreshQueue.push(resolve);
      });
      if (!newToken) {
        redirectToLogin();
        throw new ApiRequestError(401, { code: 'UNAUTHORIZED', message: 'Session expired' }, correlationId);
      }
      return request<T>(path, options, true);
    }

    isRefreshing = true;
    const newToken = await refreshAccessToken();
    isRefreshing = false;
    refreshQueue.forEach((resolve) => resolve(newToken));
    refreshQueue = [];

    if (!newToken) {
      redirectToLogin();
      throw new ApiRequestError(401, { code: 'UNAUTHORIZED', message: 'Session expired' }, correlationId);
    }

    return request<T>(path, options, true);
  }

  if (!res.ok) {
    const body = await res.json().catch(() => ({ error: { code: 'UNKNOWN', message: res.statusText } })) as { error: ApiError };
    throw new ApiRequestError(res.status, body.error, correlationId);
  }

  return res.json() as T;
}

// ── Public API client methods ───────────────────────────────────────────────

export const api = {
  get: <T>(path: string) => request<T>(path, { method: 'GET' }),
  post: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  put: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'PUT', body: JSON.stringify(body) }),
  patch: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'PATCH', body: JSON.stringify(body) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
```

---

## Pattern 4 — Zod Validation on API Endpoints

### What it does
Every request body, params, and query is validated before reaching the handler. Env vars are validated at startup with a Zod schema. Validation failures return structured 400 errors.

### `src/schemas/{resource}.ts` — per-resource schema file

```typescript
import { z } from 'zod';

// List query params
export const ListQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
});

// Create body
export const CreateResourceSchema = z.object({
  name: z.string().min(1).max(255),
  description: z.string().max(2000).optional(),
  // Add fields from SDL dataModels
});

// Update body — all fields optional
export const UpdateResourceSchema = CreateResourceSchema.partial();

// Path params
export const ResourceParamsSchema = z.object({
  id: z.string().min(1),
});

// Inferred TypeScript types
export type ListQuery = z.infer<typeof ListQuerySchema>;
export type CreateResourceInput = z.infer<typeof CreateResourceSchema>;
export type UpdateResourceInput = z.infer<typeof UpdateResourceSchema>;
export type ResourceParams = z.infer<typeof ResourceParamsSchema>;
```

### `src/middleware/validate.ts` — reusable validation middleware factory

```typescript
import { z } from 'zod';
import type { Request, Response, NextFunction } from 'express';

type RequestPart = 'body' | 'params' | 'query';

export function validate<T extends z.ZodTypeAny>(
  schema: T,
  part: RequestPart = 'body',
) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[part]);
    if (!result.success) {
      res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Request validation failed',
          details: result.error.flatten(),
        },
      });
      return;
    }
    // Replace the request part with the parsed (coerced + defaulted) data
    (req as Record<string, unknown>)[part] = result.data;
    next();
  };
}
```

### Route usage pattern

```typescript
import { validate } from '../middleware/validate';
import { CreateResourceSchema, ListQuerySchema, ResourceParamsSchema } from '../schemas/resource';

router.get(
  '/',
  validate(ListQuerySchema, 'query'),
  async (req: Request, res: Response) => { ... }
);

router.post(
  '/',
  validate(CreateResourceSchema, 'body'),
  async (req: Request, res: Response) => { ... }
);

router.put(
  '/:id',
  validate(ResourceParamsSchema, 'params'),
  validate(UpdateResourceSchema, 'body'),
  async (req: Request, res: Response) => { ... }
);
```

### `src/config/index.ts` — env var validation at startup

```typescript
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_SECRET: z.string().min(32),
  LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),
  SERVICE_NAME: z.string().default('api'),
  SERVICE_VERSION: z.string().default('0.0.0'),
  ALLOWED_ORIGINS: z.string().default('http://localhost:3000'),
  // Add provider-specific vars here based on SDL auth.provider
});

const _env = EnvSchema.safeParse(process.env);
if (!_env.success) {
  console.error('Invalid environment variables:\n', JSON.stringify(_env.error.flatten().fieldErrors, null, 2));
  process.exit(1);
}

export const config = _env.data;
export type Config = typeof config;
```

**Important:** `src/config/index.ts` must be the first import in `src/index.ts` so validation runs before any other module initializes.

---

## Pattern 5 — Deep Health Check

### What it does
`GET /health` actually queries the database and pings the cache. Returns structured JSON. Returns HTTP 503 if any critical dependency is down.

### `src/routes/health.ts`

```typescript
import { Router } from 'express';
import type { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { createClient } from 'ioredis';   // omit if no cache
import { config } from '../config';
import { logger } from '../lib/logger';

interface HealthCheck {
  status: 'ok' | 'degraded' | 'down';
  latencyMs: number;
  error?: string;
}

interface HealthResponse {
  status: 'ok' | 'degraded' | 'down';
  version: string;
  uptime: number;
  memory: {
    heapUsedMb: number;
    heapTotalMb: number;
    rssMb: number;
  };
  checks: {
    db: HealthCheck;
    cache?: HealthCheck;
  };
}

export const healthRouter = Router();

async function checkDatabase(prisma: PrismaClient): Promise<HealthCheck> {
  const start = Date.now();
  try {
    await prisma.$queryRaw`SELECT 1`;
    return { status: 'ok', latencyMs: Date.now() - start };
  } catch (err) {
    return { status: 'down', latencyMs: Date.now() - start, error: String(err) };
  }
}

async function checkCache(redis: ReturnType<typeof createClient>): Promise<HealthCheck> {
  const start = Date.now();
  try {
    await redis.ping();
    return { status: 'ok', latencyMs: Date.now() - start };
  } catch (err) {
    return { status: 'down', latencyMs: Date.now() - start, error: String(err) };
  }
}

export function createHealthRouter(prisma: PrismaClient, redis?: ReturnType<typeof createClient>) {
  healthRouter.get('/', async (req: Request, res: Response) => {
    // Fast-path when shutting down — Pattern 2 integration point
    if ((req.app.locals as { isShuttingDown?: boolean }).isShuttingDown) {
      res.status(503).json({ status: 'shutting_down' });
      return;
    }

    const [db, cache] = await Promise.all([
      checkDatabase(prisma),
      redis ? checkCache(redis) : Promise.resolve(undefined),
    ]);

    const mem = process.memoryUsage();
    const body: HealthResponse = {
      status: db.status === 'down' ? 'down' : cache?.status === 'down' ? 'degraded' : 'ok',
      version: config.SERVICE_VERSION,
      uptime: Math.floor(process.uptime()),
      memory: {
        heapUsedMb: Math.round(mem.heapUsed / 1_048_576),
        heapTotalMb: Math.round(mem.heapTotal / 1_048_576),
        rssMb: Math.round(mem.rss / 1_048_576),
      },
      checks: {
        db,
        ...(cache ? { cache } : {}),
      },
    };

    // 503 only on critical (DB) failure — cache failure is degraded/200
    const httpStatus = db.status === 'down' ? 503 : 200;
    if (httpStatus !== 200) {
      logger.warn({ checks: body.checks }, 'Health check failed');
    }

    res.status(httpStatus).json(body);
  });

  return healthRouter;
}
```

### Mount in `src/index.ts`

```typescript
import { createHealthRouter } from './routes/health';
// Health endpoint bypasses auth middleware — mount before auth
app.use('/health', createHealthRouter(prisma, redis));
```

---

## Pattern 6 — Structured Logger Setup

### What it does
Uses `pino` with `pino-pretty` in development (human-readable) and raw JSON in production. Every log line includes `service`, `version`, `env`, and `correlationId`. All `console.log` replaced.

### `src/lib/logger.ts`

```typescript
import pino, { type Logger } from 'pino';
import { config } from '../config';

const isDev = config.NODE_ENV === 'development';

export const logger: Logger = pino({
  level: config.LOG_LEVEL,
  base: {
    service: config.SERVICE_NAME,
    version: config.SERVICE_VERSION,
    env: config.NODE_ENV,
  },
  ...(isDev
    ? {
        transport: {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'SYS:HH:MM:ss', ignore: 'pid,hostname' },
        },
      }
    : {
        // JSON in production — parsed by log aggregators (Axiom, Datadog, etc.)
        timestamp: pino.stdTimeFunctions.isoTime,
      }),
});

// Per-request child logger with correlationId — used in request middleware
export function childLogger(correlationId: string): Logger {
  return logger.child({ correlationId });
}
```

### Request logging middleware `src/middleware/request-logger.ts`

```typescript
import type { Request, Response, NextFunction } from 'express';
import { childLogger } from '../lib/logger';

export function requestLogger(req: Request, _res: Response, next: NextFunction): void {
  // correlationId is set by correlationIdMiddleware (Pattern 1) before this runs
  req.log = childLogger(req.correlationId);
  req.log.info({ method: req.method, url: req.url }, 'Incoming request');
  next();
}

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      log: import('pino').Logger;
    }
  }
}
```

### Usage in route handlers and services

```typescript
// In route handlers — use req.log (has correlationId bound)
router.get('/:id', async (req, res, next) => {
  req.log.info({ id: req.params.id }, 'Fetching resource');
  // ...
});

// In service layer — pass correlationId down, create child logger
import { childLogger } from '../lib/logger';

export async function findResource(id: string, correlationId: string) {
  const log = childLogger(correlationId);
  log.debug({ id }, 'DB query: find resource');
  // ...
}
```

### Replace ALL `console.log` — rule for scaffold generation

When generating any file in a backend service, NEVER emit `console.log`, `console.error`, or `console.warn`. All logging MUST go through the `logger` or `req.log` instance. The only exception is the `src/config/index.ts` startup validation failure, which uses `console.error` before the logger is initialized.

---

## Pattern 7 — Retry + Timeout on Service Calls

### What it does
All outbound HTTP calls use `AbortController` for a 10-second hard timeout. On 5xx or network errors, retry up to 3 times with exponential backoff (100ms, 200ms, 400ms). Never retry on 4xx responses.

### Frontend: included in `src/lib/api.ts` (Pattern 3 implementation)

The `request()` function in Pattern 3 already has the AbortController timeout. Add the retry wrapper:

```typescript
const RETRY_DELAYS_MS = [100, 200, 400];

async function requestWithRetry<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  let lastError: unknown;

  for (let attempt = 0; attempt <= RETRY_DELAYS_MS.length; attempt++) {
    try {
      return await request<T>(path, options);
    } catch (err) {
      lastError = err;

      // Never retry on explicit 4xx errors
      if (err instanceof ApiRequestError && err.status >= 400 && err.status < 500) {
        throw err;
      }

      // Never retry on the last attempt
      if (attempt === RETRY_DELAYS_MS.length) break;

      // Don't retry on abort (timeout) either — caller should know
      if (err instanceof DOMException && err.name === 'AbortError') throw err;

      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAYS_MS[attempt]));
    }
  }

  throw lastError;
}

// Export the retrying version as the public API
export const api = {
  get: <T>(path: string) => requestWithRetry<T>(path, { method: 'GET' }),
  post: <T>(path: string, body: unknown) =>
    requestWithRetry<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  put: <T>(path: string, body: unknown) =>
    requestWithRetry<T>(path, { method: 'PUT', body: JSON.stringify(body) }),
  patch: <T>(path: string, body: unknown) =>
    requestWithRetry<T>(path, { method: 'PATCH', body: JSON.stringify(body) }),
  delete: <T>(path: string) => requestWithRetry<T>(path, { method: 'DELETE' }),
};
```

### Backend: `src/lib/http-client.ts` — service-to-service calls with retry

```typescript
import { logger } from './logger';
import { CORRELATION_ID_HEADER } from '../middleware/correlation-id';

const RETRY_DELAYS_MS = [100, 200, 400];
const DEFAULT_TIMEOUT_MS = 10_000;

export class ServiceCallError extends Error {
  constructor(public status: number, message: string, public correlationId?: string) {
    super(message);
    this.name = 'ServiceCallError';
  }
}

export async function serviceRequest<T>(
  url: string,
  options: RequestInit & { correlationId?: string; timeoutMs?: number } = {},
): Promise<T> {
  const { correlationId, timeoutMs = DEFAULT_TIMEOUT_MS, ...fetchOptions } = options;
  let lastError: unknown;

  for (let attempt = 0; attempt <= RETRY_DELAYS_MS.length; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const headers = new Headers(fetchOptions.headers);
      if (correlationId) headers.set(CORRELATION_ID_HEADER, correlationId);

      const res = await fetch(url, { ...fetchOptions, headers, signal: controller.signal });
      clearTimeout(timeoutId);

      // Do not retry 4xx — these are caller errors
      if (res.status >= 400 && res.status < 500) {
        throw new ServiceCallError(res.status, `Service returned ${res.status}`, correlationId);
      }

      if (!res.ok) {
        // 5xx — will be retried
        throw new ServiceCallError(res.status, `Service error ${res.status}`, correlationId);
      }

      return res.json() as T;
    } catch (err) {
      clearTimeout(timeoutId);
      lastError = err;

      if (err instanceof ServiceCallError && err.status >= 400 && err.status < 500) throw err;
      if (attempt === RETRY_DELAYS_MS.length) break;

      logger.warn({ url, attempt: attempt + 1, err }, 'Service call failed, retrying');
      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAYS_MS[attempt]));
    }
  }

  throw lastError;
}
```

---

## Pattern 8 — Soft Delete Pattern

### What it does
Entities are never hard-deleted. Every Prisma model gets a `deletedAt DateTime?` field. A Prisma middleware transparently filters deleted records from all queries. DELETE endpoints set `deletedAt` rather than calling `prisma.model.delete()`.

### Prisma schema additions — apply to every model

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  deletedAt DateTime?                        // ← add to every model

  @@index([deletedAt])                       // ← index for filter performance
}

// Where a unique constraint must tolerate soft-deleted duplicates:
// Remove @@unique and replace with a partial unique index in raw SQL migration,
// OR use a compound unique with deletedAt:
model Resource {
  id        String   @id @default(cuid())
  slug      String
  deletedAt DateTime?

  @@unique([slug, deletedAt])               // allows reuse of slug after soft delete
}
```

### `src/middleware/soft-delete.ts` — Prisma middleware

```typescript
import { PrismaClient } from '@prisma/client';

const SOFT_DELETE_MODELS = [
  'User',
  'Resource',
  // Add all model names here — must match Prisma model names exactly
] as const;

type SoftDeleteModel = (typeof SOFT_DELETE_MODELS)[number];

function isSoftDeleteModel(model: string | undefined): model is SoftDeleteModel {
  return SOFT_DELETE_MODELS.includes(model as SoftDeleteModel);
}

export function applySoftDeleteMiddleware(prisma: PrismaClient): void {
  prisma.$use(async (params, next) => {
    if (!isSoftDeleteModel(params.model)) return next(params);

    // Rewrite delete → update with deletedAt
    if (params.action === 'delete') {
      params.action = 'update';
      params.args['data'] = { deletedAt: new Date() };
    }

    // Rewrite deleteMany → updateMany with deletedAt
    if (params.action === 'deleteMany') {
      params.action = 'updateMany';
      params.args['data'] = { deletedAt: new Date() };
    }

    // Auto-filter deleted records from all reads
    if (['findUnique', 'findFirst', 'findMany', 'count', 'aggregate', 'groupBy'].includes(params.action)) {
      params.args.where = {
        ...params.args.where,
        deletedAt: null,
      };
    }

    return next(params);
  });
}
```

### `src/config/database.ts` — apply middleware at startup

```typescript
import { PrismaClient } from '@prisma/client';
import { applySoftDeleteMiddleware } from '../middleware/soft-delete';

export const prisma = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
    { emit: 'event', level: 'error' },
    { emit: 'event', level: 'warn' },
  ],
});

applySoftDeleteMiddleware(prisma);

// Log slow queries in development
prisma.$on('query', (e) => {
  if (e.duration > 200) {
    // Import logger separately to avoid circular dependency
    console.warn(`Slow query (${e.duration}ms): ${e.query}`);
  }
});
```

### DELETE route pattern

```typescript
// src/routes/{resource}.ts
router.delete('/:id', validate(ResourceParamsSchema, 'params'), async (req, res, next) => {
  try {
    const { id } = req.params as ResourceParams;
    // Prisma middleware converts this delete to an update with deletedAt = now()
    const deleted = await prisma.resource.delete({ where: { id } });
    res.status(200).json({ data: deleted, message: 'Resource deleted' });
  } catch (err) {
    next(err);
  }
});
```

---

## Pattern 9 — CSP Configuration

### What it does
Backend: `helmet` with strict CSP in production, relaxed in development. `ALLOWED_ORIGINS` env var controls CORS. Next.js frontends get security headers in `next.config.ts`.

### Backend: `src/index.ts` — helmet with explicit CSP

```typescript
import helmet from 'helmet';
import cors from 'cors';
import { config } from './config';

const isDev = config.NODE_ENV === 'development';
const allowedOrigins = config.ALLOWED_ORIGINS.split(',').map((o) => o.trim());

// CORS — must come before helmet
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error(`CORS: origin ${origin} not allowed`));
      }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-correlation-id'],
  }),
);

// Helmet with environment-specific CSP
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: isDev
          ? ["'self'", "'unsafe-inline'", "'unsafe-eval'"]  // dev: allow hot-reload
          : ["'self'"],
        styleSrc: isDev
          ? ["'self'", "'unsafe-inline'"]
          : ["'self'", "'unsafe-inline'"],  // inline styles often required for UI libs
        imgSrc: ["'self'", 'data:', 'https:'],
        connectSrc: isDev
          ? ["'self'", 'ws:', 'wss:', ...allowedOrigins]
          : ["'self'", ...allowedOrigins],
        fontSrc: ["'self'", 'https://fonts.gstatic.com'],
        objectSrc: ["'none'"],
        mediaSrc: ["'self'"],
        frameSrc: ["'none'"],
        baseUri: ["'self'"],
        formAction: ["'self'"],
        upgradeInsecureRequests: isDev ? null : [],
      },
    },
    hsts: {
      maxAge: 31_536_000, // 1 year
      includeSubDomains: true,
      preload: true,
    },
    crossOriginEmbedderPolicy: false, // set true only if you use SharedArrayBuffer
  }),
);
```

### Frontend (Next.js): `next.config.ts` — security headers

```typescript
import type { NextConfig } from 'next';

const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',').map((o) => o.trim()) ?? [];
const isDev = process.env.NODE_ENV !== 'production';

const securityHeaders = [
  { key: 'X-DNS-Prefetch-Control', value: 'on' },
  { key: 'Strict-Transport-Security', value: 'max-age=31536000; includeSubDomains; preload' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
  {
    key: 'Content-Security-Policy',
    value: [
      "default-src 'self'",
      isDev ? "script-src 'self' 'unsafe-inline' 'unsafe-eval'" : "script-src 'self'",
      "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
      "img-src 'self' data: https:",
      `connect-src 'self' ${allowedOrigins.join(' ')}`,
      "font-src 'self' https://fonts.gstatic.com",
      "object-src 'none'",
      "base-uri 'self'",
      "frame-ancestors 'none'",
      isDev ? '' : 'upgrade-insecure-requests',
    ]
      .filter(Boolean)
      .join('; '),
  },
];

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: securityHeaders,
      },
    ];
  },
};

export default nextConfig;
```

### `.env.example` additions for CSP

Both backends and frontends must declare these env vars:

```bash
# ── Security ──
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

---

## Cross-Pattern Interaction Notes

These interaction rules are load-bearing — violate them and the patterns break:

1. **Startup order in `src/index.ts`:**
   `config/index.ts` import → `logger` init → `correlationIdMiddleware` → `requestLogger` → `cors` → `helmet/CSP` → `express.json()` → routes → error handler

2. **Logger depends on config:** `logger.ts` imports from `config/index.ts`. Config must be validated before the logger module loads.

3. **Health check depends on Pattern 2 flag:** The `isShuttingDown` flag set in Pattern 2 must be accessible to the health route in Pattern 5. Use `app.locals.isShuttingDown` as the shared flag.

4. **Zod schemas are shared:** The same Zod schema defined in `src/schemas/{resource}.ts` is used both by the validate middleware (Pattern 4) and can be used to validate data returned from external services.

5. **Soft delete + Prisma queries:** Pattern 8's middleware intercepts ALL Prisma calls. If you ever need to query deleted records (admin use), call `prisma.resource.findMany({ where: { deletedAt: { not: null } } })` and the middleware will NOT add its filter because you are providing an explicit `deletedAt` condition.

6. **Retry + 401:** Pattern 7's retry logic MUST NOT retry on 401. Pattern 3's token refresh handles 401 before Pattern 7's retry wrapper sees the error.
```

---

## 3. Changes to `commands/scaffold-component.md`

Do not rewrite the file. Add the following bullet points at precisely identified locations.

### 3A. Add to BACKEND SERVICES section — after the "Health check:" bullet (line 144), before "Config:"

Insert this new bullet:

```markdown
- **Production hardening — REQUIRED on all Node.js backends:** Read `skills/production-hardening/SKILL.md` and apply all 9 patterns. Specifically:
  - **Correlation ID** (`src/middleware/correlation-id.ts`): generate/forward `x-correlation-id` on every request. Mount BEFORE logger middleware.
  - **Graceful shutdown** (`src/index.ts`): handle SIGTERM/SIGINT, drain HTTP server, disconnect Prisma, quit Redis, force-exit after 10s. Set `app.locals.isShuttingDown = true` on shutdown start.
  - **Zod validation** (`src/schemas/`, `src/middleware/validate.ts`): one schema file per resource. Validate body, params, query before every handler. Return `{ error: { code: 'VALIDATION_ERROR', details: error.flatten() } }` on 400.
  - **Env validation** (`src/config/index.ts`): Zod schema for ALL env vars. Import config as the FIRST import in `src/index.ts`. `process.exit(1)` with clear field errors on failure.
  - **Deep health check** (`src/routes/health.ts`): run `SELECT 1` against DB, `PING` against Redis. Return `{ status, version, uptime, memory, checks: { db, cache } }`. Return 503 on DB failure, 200 on cache failure. Return 503 immediately when `app.locals.isShuttingDown === true`.
  - **Structured logger** (`src/lib/logger.ts`): pino with pino-pretty in dev, JSON in prod. Base fields: `service`, `version`, `env`. Child logger per-request includes `correlationId`. ZERO `console.log` in any generated file except `src/config/index.ts` startup abort.
  - **Retry + timeout** (`src/lib/http-client.ts`): all outbound `fetch` calls wrapped with AbortController (10s timeout) and 3-attempt exponential backoff (100/200/400ms). Never retry 4xx.
  - **Soft delete** (Prisma schema + `src/middleware/soft-delete.ts`): add `deletedAt DateTime?` + `@@index([deletedAt])` to every model. Prisma middleware rewrites delete→update and filters `deletedAt: null` on all reads. Apply in `src/config/database.ts`.
  - **CSP + CORS** (`src/index.ts`): helmet with explicit CSP directives per environment (strict in prod, relaxed in dev). CORS from `ALLOWED_ORIGINS` env var. Add `ALLOWED_ORIGINS` to `.env.example`.
```

### 3B. Add to BACKEND SERVICES section — after the "Error handling:" bullet (line 148), before "Database setup:"

Insert this new bullet:

```markdown
- **Request logger middleware** (`src/middleware/request-logger.ts`): log every incoming request with method, URL, and correlationId via a pino child logger bound to `req.log`. Use `req.log` in all route handlers (not the root logger) so correlationId appears on every log line from that request.
```

### 3C. Add to FRONTEND WEB APPS section — after the "API client:" bullet (line 191), before "Auth flow:"

Replace the existing "API client:" bullet with this expanded version:

```markdown
- **API client** (`src/lib/api.ts`): Typed functions for every backend endpoint. Read `skills/production-hardening/SKILL.md` Pattern 3 (Auth Token Interceptor) and Pattern 7 (Retry + Timeout) and implement both in `api.ts`:
  - Send `x-correlation-id: crypto.randomUUID()` on every request (Pattern 1 frontend integration)
  - Inject Bearer token from the auth provider declared in SDL `auth.provider` (see provider matrix in skill)
  - On 401: attempt token refresh once using the provider-appropriate refresh call, retry original request; redirect to `/login` on refresh failure
  - `AbortController` with 10s timeout on every request
  - 3 retries with exponential backoff (100/200/400ms) on 5xx and network errors; never retry on 4xx
  - Export typed `api.get/post/put/patch/delete` methods
```

### 3D. Add to FRONTEND WEB APPS section — at the very end of the "Code depth requirements for frontends:" list, after the "State management:" bullet (line 221), before the MOBILE APPS section

Insert this new bullet:

```markdown
- **CSP headers (Next.js only)** (`next.config.ts`): add security headers block per Pattern 9 in `skills/production-hardening/SKILL.md`. Include `ALLOWED_ORIGINS` in `.env.example`. For Vite-based frontends, document CSP headers to be set at the reverse proxy/CDN layer in the README.
```

### 3E. Update the project structure block for BACKEND SERVICES (lines 101–137) — add missing files

The existing structure already lists `src/middleware/validation.ts` and `src/lib/logger.ts`. Add these missing entries in the structure tree:

Under `src/middleware/`:
```
│   │   ├── correlation-id.ts    # Generate/forward x-correlation-id header
│   │   └── request-logger.ts    # Per-request pino child logger bound to req.log
```

Under `src/schemas/` (new directory — add after `src/middleware/`):
```
│   ├── schemas/                 # Zod schemas — one per resource
│   │   └── {resource}.ts        # Create/update/list/params schemas + inferred types
```

The line showing `src/lib/logger.ts` should also list `src/lib/http-client.ts`:
```
│   │   ├── logger.ts            # Pino structured logger (pino-pretty dev, JSON prod)
│   │   └── http-client.ts       # Outbound service calls with retry + timeout
```

---

## 4. Changes to `commands/scaffold.md`

Target: Step 6 "Print Summary" section (lines 255–293). The summary table's "Each project has:" bullet list currently reads:

```
- Security middleware stubs (CORS, auth, rate limiting)
- Health check endpoints with dependency check TODOs
- Structured logging setup
```

Replace those three bullets with:

```markdown
- Security middleware: CORS from `ALLOWED_ORIGINS`, helmet with environment-specific CSP directives, rate limiting
- Auth token interceptor in frontend API client: Bearer token injection, 401 → refresh → retry, redirect on refresh failure
- Health check endpoints: actual DB (`SELECT 1`) and cache (`PING`) checks, `{ status, uptime, version, memory, checks }` JSON, 503 on critical failure
- Structured logging: pino JSON in prod, pino-pretty in dev; correlationId on every log line; zero console.log
- Correlation ID propagation: `x-correlation-id` generated/forwarded by backend middleware; sent by frontend API client
- Graceful shutdown: SIGTERM/SIGINT handling, connection draining, clean exit
- Zod validation: env vars validated at startup; request body/params/query validated before every handler
- Retry + timeout: 10s AbortController timeout + 3-attempt exponential backoff on all outbound HTTP calls
- Soft delete: `deletedAt` on all Prisma models, transparent Prisma middleware, no hard deletes
```

Also update the `Next steps:` list. After the existing step 1, add:

```markdown
2. Review `src/config/index.ts` in each backend service — fill in any auth-provider-specific env vars
3. Update `ALLOWED_ORIGINS` in `.env` for each backend and frontend to match your actual domain(s)
```

(Renumber the existing steps 2–4 to 4–6.)

---

## 5. Changes to `scaffold.ts`

Target file: `/Users/nexper/Code/architecture/backend/architecture/packages/sdl/src/generators/scaffold.ts`

### 5A. Node.js/Express backend dependencies (lines 153–161)

The current `nodejs` case:

```typescript
case 'nodejs':
  deps['express'] = '4.19.0';
  deps['cors'] = '2.8.5';
  deps['helmet'] = '7.1.0';
  devDeps['typescript'] = '5.4.0';
  devDeps['tsx'] = '4.10.0';
  devDeps['@types/express'] = '4.17.0';
  devDeps['@types/cors'] = '2.8.17';
  break;
```

Change to:

```typescript
case 'nodejs':
  deps['express'] = '4.19.0';
  deps['cors'] = '2.8.5';
  deps['helmet'] = '7.1.0';
  deps['pino'] = '9.2.0';
  deps['zod'] = '3.23.0';
  devDeps['typescript'] = '5.4.0';
  devDeps['tsx'] = '4.10.0';
  devDeps['@types/express'] = '4.17.0';
  devDeps['@types/cors'] = '2.8.17';
  devDeps['pino-pretty'] = '11.2.0';
  break;
```

### 5B. Default case (lines 171–175) — same additions for the fallback

```typescript
default:
  deps['express'] = '4.19.0';
  deps['pino'] = '9.2.0';
  deps['zod'] = '3.23.0';
  devDeps['typescript'] = '5.4.0';
  devDeps['tsx'] = '4.10.0';
  devDeps['pino-pretty'] = '11.2.0';
```

### 5C. `nodeServerStub` function (lines 462–494) — update the generated stub

The current `nodeServerStub` generates a minimal Express app with `console.log`. Update the function to emit a production-hardened stub:

The function currently emits this at the end:
```typescript
app.listen(PORT, () => {
  console.log(\`${solutionName} ${projectName} listening on port \${PORT}\`);
});
```

Change to:
```typescript
const server = app.listen(PORT, () => {
  logger.info({ port: PORT }, '${projectName} listening');
});

process.on('SIGTERM', () => {
  app.locals.isShuttingDown = true;
  server.close(async () => {
    await prisma.$disconnect().catch(() => {});
    logger.info('Graceful shutdown complete');
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000).unref();
});

process.on('SIGINT', () => process.emit('SIGTERM' as NodeJS.Signals));
```

Also add the import lines to the generated stub:
```typescript
import { logger } from './lib/logger';
import { correlationIdMiddleware } from './middleware/correlation-id';
import { requestLogger } from './middleware/request-logger';
```

And replace `app.get('/health', ...)` with a reference to the deep health router:
```typescript
import { createHealthRouter } from './routes/health';
app.use('/health', createHealthRouter(prisma));
```

### 5D. `envExample` and `envBackendPerEnv` functions — add ALLOWED_ORIGINS

In `envExample` (lines 353–414), inside the `if (layer === 'backend')` block, add after the CORS section:

```typescript
lines.push('# ── Security ──');
lines.push('ALLOWED_ORIGINS=http://localhost:3000');
lines.push('SERVICE_NAME=' + (be?.name ?? 'api'));
lines.push('SERVICE_VERSION=0.1.0');
lines.push('');
```

In `envBackendPerEnv` (lines 782+), after the `CORS_ORIGINS` line, add:
```typescript
lines.push(`ALLOWED_ORIGINS=${appUrl(frontendName, env)}`);
lines.push(`SERVICE_NAME=${be.name}`);
lines.push(`SERVICE_VERSION=0.1.0`);
```

---

## 6. Interaction Map

This map describes the runtime dependencies between the 9 patterns. It is the ordering and wiring contract.

### Startup sequencing (must be exact)

```
1. src/config/index.ts          ← imported FIRST by src/index.ts
   - validates all env vars via Zod (Pattern 4 - env)
   - process.exit(1) if invalid BEFORE any other module loads
   
2. src/lib/logger.ts            ← reads config.LOG_LEVEL, config.SERVICE_NAME
   - pino instance created (Pattern 6)
   - MUST load after config

3. src/config/database.ts       ← creates PrismaClient
   - calls applySoftDeleteMiddleware(prisma) (Pattern 8)
   - registers pino slow-query listener

4. src/index.ts — middleware chain:
   a. cors()                    (Pattern 9)
   b. helmet({ csp })           (Pattern 9) 
   c. correlationIdMiddleware   (Pattern 1) — sets req.correlationId
   d. requestLogger             (Pattern 6) — creates req.log child with correlationId
                                              MUST come after (c)
   e. express.json()
   f. routes (Pattern 4 — Zod validate on each route)
   
5. app.use('/health', createHealthRouter(prisma, redis))
   - mounted BEFORE auth middleware so it is publicly accessible
   - reads app.locals.isShuttingDown (Pattern 2 integration)

6. SIGTERM/SIGINT handlers registered AFTER server.listen()
   - set app.locals.isShuttingDown = true first (Pattern 5 sees this)
   - then server.close() → prisma.$disconnect() → redis.quit()
```

### Cross-pattern data flows

```
Pattern 1 (correlationId) ──feeds──► Pattern 6 (logger child)
   req.correlationId ──────────────► req.log = logger.child({ correlationId })
   req.correlationId ──────────────► forwarded in Pattern 7 (http-client outbound headers)

Pattern 2 (shutdown flag) ──feeds──► Pattern 5 (health check)
   app.locals.isShuttingDown = true ─► health returns 503 immediately
   app.locals.isShuttingDown = true ─► load balancer stops routing before drain begins

Pattern 4 (Zod schemas) ────────────► shared between:
   src/schemas/{resource}.ts ─────►  validate middleware (runtime validation)
   src/schemas/{resource}.ts ─────►  TypeScript types in service layer (compile-time safety)
   config/index.ts EnvSchema ─────►  process.env validation (startup)

Pattern 8 (soft delete middleware) ──► intercepts ALL Prisma operations
   Must be applied before any route handler can query the DB
   Applied once in database.ts — affects the entire application

Pattern 3 (token interceptor) ──────► intercepts Pattern 7's retry wrapper
   401 is handled by Pattern 3 BEFORE Pattern 7 sees it
   Pattern 7 only retries 5xx and network errors
   Pattern 3's token refresh is a one-time 401 handler, not a retry

Pattern 9 (CSP) ─────────────────────► ALLOWED_ORIGINS used by BOTH:
   Backend: cors() origin whitelist
   Backend: helmet CSP connectSrc directive
   Frontend Next.js: next.config.ts CSP connect-src directive
```

### Package dependency graph

```
pino               ← Pattern 6, imported by src/lib/logger.ts
pino-pretty        ← devDep, used by logger in development only
zod                ← Pattern 4, imported by src/schemas/* and src/config/index.ts
@prisma/client     ← Pattern 5 (health), Pattern 8 (soft delete)
helmet             ← Pattern 9
cors               ← Pattern 9
```

### Files that are created by multiple patterns (coordination points)

| File | Patterns that contribute | How they compose |
|---|---|---|
| `src/index.ts` | 1, 2, 4, 6, 9 | Pattern 4 provides config first import; Pattern 9 sets up cors+helmet; Pattern 1 adds middleware; Pattern 6 adds request logger; Pattern 2 adds shutdown handlers |
| `src/lib/api.ts` (frontend) | 1, 3, 7 | Single file implements all three: correlationId header (1), token interceptor (3), retry+timeout (7) |
| `src/config/index.ts` | 4, 9 | Zod schema validates ALLOWED_ORIGINS (used by Pattern 9) along with all other vars |
| `src/config/database.ts` | 8 | Applies soft-delete middleware to the Prisma client after creation |
| `.env.example` | 4, 9 | Both add required env vars — `ALLOWED_ORIGINS`, `SERVICE_NAME`, `SERVICE_VERSION` |
| `next.config.ts` (frontend) | 9 | CSP headers block; reads `ALLOWED_ORIGINS` from process.env |
| `prisma/schema.prisma` | 8 | `deletedAt DateTime?` + index added to every model |

---

### Critical Files for Implementation

- `/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/production-hardening/SKILL.md`
- `/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/scaffold-component.md`
- `/Users/nexper/Code/architecture/backend/architecture/packages/sdl/src/generators/scaffold.ts`
- `/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/commands/scaffold.md`
- `/Users/nexper/Code/architecture/backend/architecture-cowork-plugin/skills/operational-patterns/SKILL.md`
