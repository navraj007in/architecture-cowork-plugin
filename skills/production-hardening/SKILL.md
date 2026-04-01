---
name: production-hardening
description: Core Node.js patterns + cross-runtime reference. For Python see python.md, for .NET see dotnet.md, for Go see go.md.
---

# Production Hardening Patterns

Nine patterns applied to every scaffolded backend service and frontend web app. Each section contains the canonical implementation — copy this code exactly when scaffolding. Do not invent variations. Apply the section for the component's runtime — Node.js, Python, .NET, or Go.

Reference: `skills/operational-patterns/SKILL.md` covers security architecture, OWASP, and observability stack selection. This file covers the concrete implementation patterns used at scaffold time.

For runtime-specific implementations, read `skills/production-hardening/{runtime}.md` (Python: `python.md`, .NET: `dotnet.md`, Go: `go.md`). Claude CLI loads these automatically via --plugin-dir.

---

## scaffold_depth Gating

Before applying patterns, resolve `scaffold_depth` from `solution.stage` in the SDL. Check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module (typically `sdl/core.yaml` or `sdl/solution.yaml`):

| `solution.stage` | `scaffold_depth` |
|---|---|
| `concept` or `mvp` | `mvp` |
| `growth` | `growth` |
| `enterprise` | `enterprise` |

Apply each pattern according to depth:

| Pattern | MVP | Growth | Enterprise |
|---|---|---|---|
| 1 — Correlation ID | Required | Required | Required |
| 2 — Graceful Shutdown | Required | Required | Required |
| 3 — Auth Token Interceptor | Required | Required | Required |
| 4 — Zod Validation | Required | Required | Required |
| 5 — Deep Health Check | Required | Required | Required |
| 6 — Structured Logger | Required | Required | Required |
| 7 — Retry + Timeout | Timeout-only stub (TODO comment for backoff) | Full exponential backoff | Full exponential backoff + circuit breaker |
| 8 — Soft Delete | Recommended — apply if entities exist, add TODO if skipping | Required on all models | Required on all models |
| 9 — CSP | Required | Required | Required |

**MVP stub pattern for Pattern 7** — when `scaffold_depth = mvp`, replace full backoff implementation with:
```typescript
// TODO: upgrade to exponential backoff at Growth stage
const controller = new AbortController();
const timeout = setTimeout(() => controller.abort(), options.timeoutMs ?? 10_000);
try {
  const res = await fetch(url, { ...options, signal: controller.signal });
  return res;
} finally {
  clearTimeout(timeout);
}
```

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
  app.locals.isShuttingDown = true;

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
When shutdown begins, `app.locals.isShuttingDown = true` is set before `server.close()`. The health endpoint reads this flag and returns 503 immediately to signal load balancers to stop routing traffic.

---

## Pattern 3 — Auth Token Interceptor (Frontend)

### What it does
`src/lib/api.ts` injects the Bearer token on every request, detects 401, refreshes the token transparently, retries the original request once, and redirects to the login page if the refresh also fails.

### Auth-provider matrix

| SDL `auth.identityProvider` | Token storage | Refresh mechanism |
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

// ── Retry wrapper ───────────────────────────────────────────────────────────

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

      // Don't retry on abort (timeout) — caller should know
      if (err instanceof DOMException && err.name === 'AbortError') throw err;

      await new Promise((resolve) => setTimeout(resolve, RETRY_DELAYS_MS[attempt]));
    }
  }

  throw lastError;
}

// ── Public API client methods ───────────────────────────────────────────────

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
  // Add fields from domain.entities[] in solution.sdl.yaml
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
  // Add provider-specific vars here based on SDL auth.identityProvider
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

The `requestWithRetry()` wrapper and `AbortController` timeout are both included in Pattern 3's full `api.ts` implementation above. Use that implementation — it already integrates both patterns.

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
SERVICE_NAME=api
SERVICE_VERSION=0.1.0
```

---

## Cross-Pattern Interaction Notes

These interaction rules are load-bearing — violate them and the patterns break:

### Startup order in `src/index.ts` (must be exact)

```
1. src/config/index.ts          ← imported FIRST by src/index.ts
   - validates all env vars via Zod (Pattern 4 - env)
   - process.exit(1) if invalid BEFORE any other module loads

2. src/lib/logger.ts            ← reads config.LOG_LEVEL, config.SERVICE_NAME
   - pino instance created (Pattern 6)
   - MUST load after config

3. src/config/database.ts       ← creates PrismaClient
   - calls applySoftDeleteMiddleware(prisma) (Pattern 8)

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

Pattern 9 (CSP) ─────────────────────► ALLOWED_ORIGINS used by BOTH:
   Backend: cors() origin whitelist
   Backend: helmet CSP connectSrc directive
   Frontend Next.js: next.config.ts CSP connect-src directive
```

### Files created by multiple patterns (coordination points)

| File | Patterns that contribute | How they compose |
|---|---|---|
| `src/index.ts` | 1, 2, 4, 6, 9 | Config first import; cors+helmet; correlationId middleware; request logger; shutdown handlers |
| `src/lib/api.ts` (frontend) | 1, 3, 7 | Single file: correlationId header (1), token interceptor (3), retry+timeout (7) |
| `src/config/index.ts` | 4, 9 | Zod schema validates ALLOWED_ORIGINS (used by Pattern 9) along with all other vars |
| `src/config/database.ts` | 8 | Applies soft-delete middleware to the Prisma client after creation |
| `.env.example` | 4, 9 | Both add required env vars — `ALLOWED_ORIGINS`, `SERVICE_NAME`, `SERVICE_VERSION` |
| `next.config.ts` (frontend) | 9 | CSP headers block; reads `ALLOWED_ORIGINS` from process.env |
| `prisma/schema.prisma` | 8 | `deletedAt DateTime?` + index added to every model |

---

## Runtime Selection Quick Reference

When scaffolding, determine the runtime from the SDL component's `runtime` or `framework` field, then read the matching file for full implementations:

| SDL `runtime` / `framework` value | Apply section | Implementation file |
|---|---|---|
| `node`, `nodejs`, `express`, `fastify`, `nestjs` | Patterns 1–9 above (this file) | `skills/production-hardening/SKILL.md` |
| `python`, `python-fastapi`, `fastapi`, `django` | Runtime Reference — Python | `skills/production-hardening/python.md` |
| `dotnet`, `aspnet`, `csharp` | Runtime Reference — .NET | `skills/production-hardening/dotnet.md` |
| `go`, `golang` | Runtime Reference — Go | `skills/production-hardening/go.md` |
| `java-spring`, `spring` | Use Spring equivalents: Micrometer (logging), Spring Retry (retry), Spring Boot Actuator (health), Hibernate soft delete, Spring Security headers | — |
| `ruby-rails` | Use Rails equivalents: Lograge (logging), ActiveRecord `discarded` gem (soft delete), Rack::Attack (rate limit), SecureHeaders gem (CSP) | — |

For runtimes not listed above, use the **Node.js patterns as a template** and translate library names to the closest ecosystem equivalent.
