---
name: production-hardening
description: Nine production hardening patterns for all supported runtimes: Node.js/Express, Python/FastAPI, .NET/ASP.NET Core, and Go. Used by scaffold-component to generate fully production-ready code.
---

# Production Hardening Patterns

Nine mandatory patterns applied to every scaffolded backend service and frontend web app. Each section contains the canonical implementation — copy this code exactly when scaffolding. Do not invent variations. Apply the section for the component's runtime — Node.js, Python, .NET, or Go.

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

## Runtime Reference — Python / FastAPI

Apply these patterns when the SDL specifies `runtime: python` or `framework: python-fastapi` / `django`.

### Pattern 1 — Correlation ID (Python)

**Dependency:** `pip install starlette-correlation-id` or implement manually.

```python
# app/middleware/correlation_id.py
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

CORRELATION_ID_HEADER = "x-correlation-id"

class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        correlation_id = request.headers.get(CORRELATION_ID_HEADER) or str(uuid.uuid4())
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers[CORRELATION_ID_HEADER] = correlation_id
        return response
```

Mount in `app/main.py`:
```python
app.add_middleware(CorrelationIdMiddleware)
```

In structured log calls, include `correlation_id=request.state.correlation_id`.

### Pattern 2 — Graceful Shutdown (Python / FastAPI)

```python
# app/main.py
import signal
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.db import engine  # SQLAlchemy async engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    yield
    # Shutdown — runs when SIGTERM received (uvicorn handles signal forwarding)
    await engine.dispose()
    # Close Redis if used:
    # await redis_client.aclose()

app = FastAPI(lifespan=lifespan)
```

Run with: `uvicorn app.main:app --host 0.0.0.0 --port 8000 --timeout-graceful-shutdown 10`

### Pattern 3 — Auth Token Interceptor (Python — outbound service calls)

For backend-to-backend calls using `httpx`:

```python
# app/lib/http_client.py
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception

class ServiceClient:
    def __init__(self, base_url: str, token_fn=None):
        self.base_url = base_url
        self.token_fn = token_fn  # callable that returns a Bearer token

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=0.1, max=1),
        retry=retry_if_exception(lambda e: isinstance(e, httpx.HTTPStatusError) and e.response.status_code >= 500),
    )
    async def request(self, method: str, path: str, correlation_id: str = None, **kwargs):
        headers = kwargs.pop("headers", {})
        if correlation_id:
            headers["x-correlation-id"] = correlation_id
        if self.token_fn:
            headers["Authorization"] = f"Bearer {await self.token_fn()}"
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.request(method, f"{self.base_url}{path}", headers=headers, **kwargs)
            resp.raise_for_status()
            return resp.json()
```

### Pattern 4 — Validation (Python / FastAPI)

FastAPI uses **Pydantic** natively — no extra dependency needed. Define request models as Pydantic schemas:

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    role: str = Field(default="user")

class UpdateUserRequest(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=100)
```

FastAPI auto-validates and returns 422 on failure. For env var validation:

```python
# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    redis_url: str = "redis://localhost:6379"
    allowed_origins: str = "http://localhost:3000"
    service_name: str = "api"
    service_version: str = "0.1.0"

    class Config:
        env_file = ".env"

settings = Settings()  # raises ValidationError on startup if required vars missing
```

**Dependency:** `pip install pydantic-settings`

### Pattern 5 — Deep Health Check (Python / FastAPI)

```python
# app/routes/health.py
import time
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db import AsyncSessionLocal
from app.config import settings
import redis.asyncio as aioredis

router = APIRouter()

@router.get("/health")
async def health_check():
    checks = {}
    overall = "ok"

    # Database check
    try:
        start = time.monotonic()
        async with AsyncSessionLocal() as session:
            await session.execute(text("SELECT 1"))
        checks["db"] = {"status": "ok", "response_ms": round((time.monotonic() - start) * 1000)}
    except Exception as e:
        checks["db"] = {"status": "fail", "error": str(e)}
        overall = "unhealthy"

    # Redis check
    try:
        r = aioredis.from_url(settings.redis_url)
        await r.ping()
        await r.aclose()
        checks["cache"] = {"status": "ok"}
    except Exception as e:
        checks["cache"] = {"status": "fail", "error": str(e)}
        if overall == "ok":
            overall = "degraded"

    status_code = 503 if overall == "unhealthy" else 200
    from fastapi.responses import JSONResponse
    return JSONResponse(
        content={"status": overall, "checks": checks, "service": settings.service_name},
        status_code=status_code,
    )
```

### Pattern 6 — Structured Logger (Python)

**Dependency:** `pip install structlog`

```python
# app/lib/logger.py
import logging
import structlog
from app.config import settings

def configure_logging():
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer() if settings.service_name != "local" else structlog.dev.ConsoleRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
    )

logger = structlog.get_logger()
```

In middleware, bind correlation ID to context:
```python
import structlog
structlog.contextvars.bind_contextvars(correlation_id=request.state.correlation_id)
```

### Pattern 7 — Retry + Timeout (Python)

**Dependency:** `pip install tenacity httpx`

Already shown in Pattern 3's `ServiceClient`. For standalone use:

```python
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
import httpx

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=0.1, max=1),
    retry=retry_if_exception_type(httpx.HTTPStatusError),
)
async def call_with_retry(url: str) -> dict:
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url)
        if resp.status_code >= 500:
            resp.raise_for_status()  # triggers retry
        return resp.json()
```

### Pattern 8 — Soft Delete (Python / SQLAlchemy)

```python
# In SQLAlchemy models
from sqlalchemy import Column, DateTime, func
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass

class SoftDeleteMixin:
    deleted_at = Column(DateTime, nullable=True, index=True)

    def soft_delete(self):
        self.deleted_at = func.now()

# Usage: all models inherit SoftDeleteMixin
class User(Base, SoftDeleteMixin):
    __tablename__ = "users"
    # ...

# In queries, always filter:
session.query(User).filter(User.deleted_at.is_(None)).all()

# Or use a custom query class to enforce globally:
from sqlalchemy.orm import Query
class SoftDeleteQuery(Query):
    def __new__(cls, *args, **kwargs):
        obj = super().__new__(cls)
        return obj
    def __iter__(self):
        return super().__iter__()
```

For FastAPI with Alembic: add `deleted_at TIMESTAMP NULL` to migration files for all entity tables.

### Pattern 9 — CSP / Security Headers (Python / FastAPI)

**Dependency:** `pip install secure`

```python
# app/middleware/security.py
import secure
from starlette.middleware.base import BaseHTTPMiddleware

secure_headers = secure.Secure(
    csp=secure.ContentSecurityPolicy()
        .default_src("'self'")
        .script_src("'self'")
        .style_src("'self'", "'unsafe-inline'")
        .img_src("'self'", "data:", "blob:")
        .connect_src("'self'")
        .font_src("'self'", "https://fonts.gstatic.com")
        .object_src("'none'"),
    hsts=secure.StrictTransportSecurity().max_age(31536000).include_subdomains().preload(),
    referrer=secure.ReferrerPolicy().no_referrer_when_downgrade(),
    xfo=secure.XFrameOptions().deny(),
)

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        secure_headers.framework.fastapi(response)
        return response
```

CORS configuration:
```python
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## Runtime Reference — .NET / ASP.NET Core

Apply these patterns when the SDL specifies `runtime: dotnet` or `framework: dotnet`.

### Pattern 1 — Correlation ID (.NET)

**NuGet:** `CorrelationId` package or implement via middleware.

```csharp
// Middleware/CorrelationIdMiddleware.cs
public class CorrelationIdMiddleware
{
    private const string HeaderName = "x-correlation-id";
    private readonly RequestDelegate _next;

    public CorrelationIdMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers[HeaderName].FirstOrDefault()
            ?? Guid.NewGuid().ToString();

        context.Items["CorrelationId"] = correlationId;
        context.Response.Headers[HeaderName] = correlationId;

        using (LogContext.PushProperty("CorrelationId", correlationId))
        {
            await _next(context);
        }
    }
}
```

Register in `Program.cs`:
```csharp
app.UseMiddleware<CorrelationIdMiddleware>();
```

### Pattern 2 — Graceful Shutdown (.NET)

ASP.NET Core handles SIGTERM natively via `IHostApplicationLifetime`:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<IHostedService, GracefulShutdownService>();

// In appsettings.json
// "ShutdownTimeout": "00:00:10"

// GracefulShutdownService.cs
public class GracefulShutdownService : IHostedService
{
    private readonly IHostApplicationLifetime _lifetime;
    private readonly ILogger<GracefulShutdownService> _logger;

    public GracefulShutdownService(IHostApplicationLifetime lifetime, ILogger<GracefulShutdownService> logger)
    {
        _lifetime = lifetime;
        _logger = logger;
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        _lifetime.ApplicationStopping.Register(() =>
            _logger.LogInformation("Application stopping — draining requests..."));
        _lifetime.ApplicationStopped.Register(() =>
            _logger.LogInformation("Application stopped."));
        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
```

Set shutdown timeout in `Program.cs`:
```csharp
builder.Services.Configure<HostOptions>(opts => opts.ShutdownTimeout = TimeSpan.FromSeconds(10));
```

### Pattern 3 — Auth Token Interceptor (.NET — outbound HTTP)

Use `IHttpClientFactory` with a `DelegatingHandler`:

```csharp
// Infrastructure/TokenDelegatingHandler.cs
public class TokenDelegatingHandler : DelegatingHandler
{
    private readonly ITokenProvider _tokenProvider;

    public TokenDelegatingHandler(ITokenProvider tokenProvider)
        => _tokenProvider = tokenProvider;

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await _tokenProvider.GetTokenAsync();
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await base.SendAsync(request, cancellationToken);

        if (response.StatusCode == HttpStatusCode.Unauthorized)
        {
            await _tokenProvider.RefreshAsync();
            token = await _tokenProvider.GetTokenAsync();
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            response = await base.SendAsync(request, cancellationToken);
        }

        return response;
    }
}
```

Register:
```csharp
builder.Services.AddTransient<TokenDelegatingHandler>();
builder.Services.AddHttpClient("ServiceClient")
    .AddHttpMessageHandler<TokenDelegatingHandler>();
```

### Pattern 4 — Validation (.NET)

Use **FluentValidation** or Data Annotations. FluentValidation preferred:

**NuGet:** `FluentValidation.AspNetCore`

```csharp
// Validators/CreateUserRequestValidator.cs
using FluentValidation;

public class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Role).IsInEnum();
    }
}
```

Register in `Program.cs`:
```csharp
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserRequestValidator>();
```

ASP.NET Core returns 400 automatically when validation fails.

For env/config validation at startup:
```csharp
// Configuration/AppSettings.cs
public class AppSettings
{
    public string DatabaseUrl { get; set; } = null!;
    public string RedisUrl { get; set; } = "redis://localhost:6379";
    public string AllowedOrigins { get; set; } = "http://localhost:3000";
}

// Program.cs
builder.Services.AddOptions<AppSettings>()
    .Bind(builder.Configuration.GetSection("App"))
    .ValidateDataAnnotations()
    .ValidateOnStart();
```

### Pattern 5 — Deep Health Check (.NET)

**NuGet:** `AspNetCore.HealthChecks.NpgSql` + `AspNetCore.HealthChecks.Redis`

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "database", tags: new[] { "db" })
    .AddRedis(redisConnectionString, name: "cache", tags: new[] { "cache" })
    .AddCheck<CustomHealthCheck>("custom");

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
    ResultStatusCodes =
    {
        [HealthStatus.Healthy]   = StatusCodes.Status200OK,
        [HealthStatus.Degraded]  = StatusCodes.Status200OK,
        [HealthStatus.Unhealthy] = StatusCodes.Status503ServiceUnavailable,
    }
});
```

### Pattern 6 — Structured Logger (.NET)

**NuGet:** `Serilog.AspNetCore` + `Serilog.Sinks.Console` + `Serilog.Formatting.Compact`

```csharp
// Program.cs
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithProperty("ServiceName", builder.Configuration["App:ServiceName"])
    .WriteTo.Console(
        builder.Environment.IsDevelopment()
            ? new ExpressionTemplate("[{@t:HH:mm:ss} {@l:u3}] {@m}\n{@x}")
            : (ITextFormatter)new CompactJsonFormatter()
    )
    .CreateLogger();

builder.Host.UseSerilog();
```

`appsettings.json`:
```json
{
  "Serilog": { "MinimumLevel": { "Default": "Information" } }
}
```

### Pattern 7 — Retry + Timeout (.NET)

**NuGet:** `Microsoft.Extensions.Http.Resilience` (Polly v8 built-in)

```csharp
// Program.cs
builder.Services.AddHttpClient("ServiceClient")
    .AddStandardResilienceHandler(options =>
    {
        options.Retry.MaxRetryAttempts = 3;
        options.Retry.Delay = TimeSpan.FromMilliseconds(100);
        options.Retry.BackoffType = DelayBackoffType.Exponential;
        options.AttemptTimeout.Timeout = TimeSpan.FromSeconds(10);
        options.TotalRequestTimeout.Timeout = TimeSpan.FromSeconds(30);
    });
```

### Pattern 8 — Soft Delete (.NET / EF Core)

```csharp
// Models/SoftDeleteEntity.cs
public abstract class SoftDeleteEntity
{
    public DateTime? DeletedAt { get; set; }
    public bool IsDeleted => DeletedAt.HasValue;
}

// Data/AppDbContext.cs — global query filter
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    foreach (var entityType in modelBuilder.Model.GetEntityTypes())
    {
        if (typeof(SoftDeleteEntity).IsAssignableFrom(entityType.ClrType))
        {
            modelBuilder.Entity(entityType.ClrType)
                .HasQueryFilter(e => EF.Property<DateTime?>(e, "DeletedAt") == null);
        }
    }
}

// In DELETE endpoints:
entity.DeletedAt = DateTime.UtcNow;
await dbContext.SaveChangesAsync();
```

### Pattern 9 — CSP / Security Headers (.NET)

**NuGet:** `NWebsec.AspNetCore.Middleware`

```csharp
// Program.cs
app.UseHsts();
app.UseHttpsRedirection();

app.Use(async (context, next) =>
{
    context.Response.Headers["Content-Security-Policy"] =
        "default-src 'self'; " +
        "script-src 'self'; " +
        "style-src 'self' 'unsafe-inline'; " +
        "img-src 'self' data: blob:; " +
        "connect-src 'self'; " +
        "font-src 'self' https://fonts.gstatic.com; " +
        "object-src 'none'";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["Referrer-Policy"] = "no-referrer-when-downgrade";
    await next();
});

// CORS
app.UseCors(policy => policy
    .WithOrigins(builder.Configuration["App:AllowedOrigins"]!.Split(","))
    .AllowAnyMethod()
    .AllowAnyHeader()
    .AllowCredentials());
```

---

## Runtime Reference — Go

Apply these patterns when the SDL specifies `runtime: go` or `framework: go`.

### Pattern 1 — Correlation ID (Go)

```go
// middleware/correlation_id.go
package middleware

import (
    "context"
    "github.com/google/uuid"
    "net/http"
)

type contextKey string
const CorrelationIDKey contextKey = "correlationID"
const CorrelationIDHeader = "X-Correlation-ID"

func CorrelationID(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        id := r.Header.Get(CorrelationIDHeader)
        if id == "" {
            id = uuid.NewString()
        }
        ctx := context.WithValue(r.Context(), CorrelationIDKey, id)
        w.Header().Set(CorrelationIDHeader, id)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

func GetCorrelationID(ctx context.Context) string {
    if id, ok := ctx.Value(CorrelationIDKey).(string); ok {
        return id
    }
    return ""
}
```

### Pattern 2 — Graceful Shutdown (Go)

```go
// main.go
package main

import (
    "context"
    "log/slog"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
)

func main() {
    srv := &http.Server{Addr: ":8080", Handler: router}

    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            slog.Error("server error", "err", err)
            os.Exit(1)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)
    <-quit

    slog.Info("shutting down gracefully")
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        slog.Error("forced shutdown", "err", err)
    }

    db.Close()   // close DB pool
    slog.Info("server stopped")
}
```

### Pattern 3 — Auth Token Interceptor (Go — outbound HTTP)

```go
// lib/http_client.go
package lib

import (
    "context"
    "fmt"
    "net/http"
    "time"
)

type TokenProvider interface {
    GetToken(ctx context.Context) (string, error)
}

type ServiceClient struct {
    base     string
    client   *http.Client
    tokens   TokenProvider
}

func NewServiceClient(base string, tokens TokenProvider) *ServiceClient {
    return &ServiceClient{
        base:   base,
        client: &http.Client{Timeout: 10 * time.Second},
        tokens: tokens,
    }
}

func (c *ServiceClient) Get(ctx context.Context, path string) (*http.Response, error) {
    token, err := c.tokens.GetToken(ctx)
    if err != nil {
        return nil, err
    }
    req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.base+path, nil)
    if err != nil {
        return nil, err
    }
    req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))
    req.Header.Set("X-Correlation-ID", middleware.GetCorrelationID(ctx))
    return c.client.Do(req)
}
```

### Pattern 4 — Validation (Go)

**Module:** `github.com/go-playground/validator/v10`

```go
// schemas/user.go
package schemas

type CreateUserRequest struct {
    Email string `json:"email" validate:"required,email"`
    Name  string `json:"name"  validate:"required,min=1,max=100"`
    Role  string `json:"role"  validate:"omitempty,oneof=user admin"`
}

// middleware/validate.go
package middleware

import (
    "encoding/json"
    "net/http"
    "github.com/go-playground/validator/v10"
)

var validate = validator.New()

func ValidateBody[T any](next func(http.ResponseWriter, *http.Request, T)) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var body T
        if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
            http.Error(w, `{"error":"invalid JSON"}`, http.StatusBadRequest)
            return
        }
        if err := validate.Struct(body); err != nil {
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusBadRequest)
            json.NewEncoder(w).Encode(map[string]any{"error": err.Error()})
            return
        }
        next(w, r, body)
    }
}
```

Env var validation using `envconfig` or `github.com/caarlos0/env`:
```go
// config/config.go
package config

import "github.com/caarlos0/env/v11"

type Config struct {
    DatabaseURL    string `env:"DATABASE_URL,required"`
    RedisURL       string `env:"REDIS_URL" envDefault:"redis://localhost:6379"`
    AllowedOrigins string `env:"ALLOWED_ORIGINS" envDefault:"http://localhost:3000"`
    ServiceName    string `env:"SERVICE_NAME" envDefault:"api"`
}

func Load() (*Config, error) {
    cfg := &Config{}
    return cfg, env.Parse(cfg)
}
```

### Pattern 5 — Deep Health Check (Go)

```go
// handlers/health.go
package handlers

import (
    "database/sql"
    "encoding/json"
    "net/http"
    "runtime"
    "time"
)

type HealthStatus struct {
    Status  string            `json:"status"`
    Checks  map[string]Check  `json:"checks"`
    Uptime  float64           `json:"uptime_seconds"`
    Memory  uint64            `json:"heap_alloc_bytes"`
}

type Check struct {
    Status     string `json:"status"`
    ResponseMs int64  `json:"response_ms,omitempty"`
    Error      string `json:"error,omitempty"`
}

var startTime = time.Now()

func HealthCheck(db *sql.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        checks := map[string]Check{}
        overall := "ok"

        // DB check
        start := time.Now()
        if err := db.PingContext(r.Context()); err != nil {
            checks["db"] = Check{Status: "fail", Error: err.Error()}
            overall = "unhealthy"
        } else {
            checks["db"] = Check{Status: "ok", ResponseMs: time.Since(start).Milliseconds()}
        }

        var m runtime.MemStats
        runtime.ReadMemStats(&m)

        resp := HealthStatus{
            Status: overall,
            Checks: checks,
            Uptime: time.Since(startTime).Seconds(),
            Memory: m.HeapAlloc,
        }

        w.Header().Set("Content-Type", "application/json")
        if overall == "unhealthy" {
            w.WriteHeader(http.StatusServiceUnavailable)
        }
        json.NewEncoder(w).Encode(resp)
    }
}
```

### Pattern 6 — Structured Logger (Go)

Go 1.21+ includes `log/slog` natively — no extra dependency:

```go
// lib/logger.go
package lib

import (
    "log/slog"
    "os"
)

func NewLogger(env string) *slog.Logger {
    if env == "production" || env == "staging" {
        return slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
            Level: slog.LevelInfo,
        }))
    }
    return slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelDebug,
    }))
}
```

Usage:
```go
logger.InfoContext(ctx, "request received",
    slog.String("correlation_id", middleware.GetCorrelationID(ctx)),
    slog.String("method", r.Method),
    slog.String("path", r.URL.Path),
)
```

### Pattern 7 — Retry + Timeout (Go)

**Module:** `github.com/avast/retry-go` or manual:

```go
// lib/retry.go
package lib

import (
    "context"
    "errors"
    "net/http"
    "time"
)

func WithRetry(ctx context.Context, maxAttempts int, fn func() (*http.Response, error)) (*http.Response, error) {
    delays := []time.Duration{100 * time.Millisecond, 200 * time.Millisecond, 400 * time.Millisecond}
    var lastErr error
    for i := 0; i < maxAttempts; i++ {
        resp, err := fn()
        if err == nil && resp.StatusCode < 500 {
            return resp, nil
        }
        if err == nil {
            lastErr = errors.New("server error: " + resp.Status)
        } else {
            lastErr = err
        }
        if i < len(delays) {
            select {
            case <-ctx.Done():
                return nil, ctx.Err()
            case <-time.After(delays[i]):
            }
        }
    }
    return nil, lastErr
}
```

### Pattern 8 — Soft Delete (Go / GORM)

```go
// models/base.go
package models

import (
    "gorm.io/gorm"
    "time"
)

type Base struct {
    ID        uint           `gorm:"primarykey"`
    CreatedAt time.Time
    UpdatedAt time.Time
    DeletedAt gorm.DeletedAt `gorm:"index"`  // GORM soft-delete built-in
}

// Usage — all models embedding Base get soft delete for free:
type User struct {
    Base
    Email string `gorm:"uniqueIndex"`
    Name  string
}

// GORM automatically filters deleted_at IS NULL on all queries
// db.Delete(&user) sets deleted_at instead of DELETE FROM
// db.Unscoped().Find(&users) bypasses the filter (admin use)
```

### Pattern 9 — CSP / Security Headers (Go)

**Module:** `github.com/unrolled/secure`

```go
// middleware/security.go
package middleware

import (
    "net/http"
    "os"
    "strings"
    "github.com/unrolled/secure"
    "github.com/rs/cors"
)

func SecurityHeaders() func(http.Handler) http.Handler {
    isDev := os.Getenv("APP_ENV") == "local"
    scriptSrc := "'self'"
    if isDev {
        scriptSrc = "'self' 'unsafe-eval'"
    }

    sm := secure.New(secure.Options{
        ContentSecurityPolicy: strings.Join([]string{
            "default-src 'self'",
            "script-src " + scriptSrc,
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: blob:",
            "connect-src 'self'",
            "font-src 'self' https://fonts.gstatic.com",
            "object-src 'none'",
        }, "; "),
        STSSeconds:            31536000,
        STSIncludeSubdomains:  true,
        STSPreload:            true,
        FrameDeny:             true,
        ContentTypeNosniff:    true,
        IsDevelopment:         isDev,
    })

    return sm.Handler
}

func CORS() func(http.Handler) http.Handler {
    origins := strings.Split(os.Getenv("ALLOWED_ORIGINS"), ",")
    return cors.New(cors.Options{
        AllowedOrigins:   origins,
        AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowedHeaders:   []string{"*"},
        AllowCredentials: true,
    }).Handler
}
```

---

## Runtime Selection Quick Reference

When scaffolding, determine the runtime from the SDL component's `runtime` or `framework` field, then apply the matching section:

| SDL `runtime` / `framework` value | Apply section |
|---|---|
| `node`, `nodejs`, `express`, `fastify`, `nestjs` | Patterns 1–9 (main body above) |
| `python`, `python-fastapi`, `fastapi`, `django` | Runtime Reference — Python |
| `dotnet`, `aspnet`, `csharp` | Runtime Reference — .NET |
| `go`, `golang` | Runtime Reference — Go |
| `java-spring`, `spring` | Use Spring equivalents: Micrometer (logging), Spring Retry (retry), Spring Boot Actuator (health), Hibernate soft delete, Spring Security headers |
| `ruby-rails` | Use Rails equivalents: Lograge (logging), ActiveRecord `discarded` gem (soft delete), Rack::Attack (rate limit), SecureHeaders gem (CSP) |

For runtimes not listed above, use the **Node.js patterns as a template** and translate library names to the closest ecosystem equivalent.
