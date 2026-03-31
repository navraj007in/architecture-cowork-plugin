---
name: project-templates-nodejs
description: Starter file templates and boilerplate for scaffolding Node.js/TypeScript backends (Express, BullMQ workers, Node.js AI agents)
type: skill-extension
parent: project-templates
---

# Node.js / TypeScript Project Templates

## Backend — Node.js / Express

**package.json:**
```json
{
  "name": "{{component-name}}",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "express": "^5.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "pino": "^9.2.0",
    "zod": "^3.23.0",
    "uuid": "^10.0.0"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/cors": "^2.8.0",
    "@types/node": "^22.0.0",
    "@types/uuid": "^10.0.0",
    "typescript": "^5.7.0",
    "tsx": "^4.0.0",
    "pino-pretty": "^11.2.0"
  }
}
```

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**src/index.ts:**
```ts
import "dotenv/config";
import express from "express";
import cors from "cors";
import { healthRouter } from "./routes/health.js";
import { logger } from "./lib/logger.js";
import { applySecurityMiddleware } from "./middleware/security.js";

const app = express();
const port = process.env.PORT || 3000;

applySecurityMiddleware(app);
app.use(express.json());

app.use("/health", healthRouter);

// Global error handler — must be last middleware
app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  logger.error({ err }, "Unhandled error");
  res.status(500).json({ code: "INTERNAL_ERROR", message: "An unexpected error occurred" });
});

const server = app.listen(port, () => {
  logger.info({ port }, "{{component-name}} started");
});

// Graceful shutdown
process.on("SIGTERM", () => {
  logger.info("SIGTERM received — shutting down");
  server.close(() => {
    logger.info("Server closed");
    process.exit(0);
  });
});
```

**src/routes/health.ts:**
```ts
import { Router } from "express";

export const healthRouter = Router();

healthRouter.get("/", (_req, res) => {
  res.json({
    status: "ok",
    service: "{{component-name}}",
    timestamp: new Date().toISOString(),
  });
});

healthRouter.get("/ready", async (_req, res) => {
  const checks: Record<string, string> = {};

  // TODO: Add dependency checks from manifest observability.health_checks
  // try {
  //   await db.query("SELECT 1");
  //   checks.database = "ok";
  // } catch {
  //   checks.database = "fail";
  // }

  const allOk = Object.values(checks).every((v) => v === "ok");
  res.status(allOk ? 200 : 503).json({
    status: allOk ? "ok" : "degraded",
    service: "{{component-name}}",
    checks,
    timestamp: new Date().toISOString(),
  });
});
```

**Directory structure:**
```
{{component-name}}/
├── package.json
├── tsconfig.json
├── .env.example
├── Dockerfile
├── docker-compose.yml
├── src/
│   ├── index.ts
│   ├── lib/
│   │   └── logger.ts
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── security.ts
│   │   └── correlation.ts
│   └── routes/
│       └── health.ts
└── .github/
    └── workflows/
        └── ci.yml
```

Run with: `npm run dev`

---

## Node.js Worker (BullMQ)

**package.json:**
```json
{
  "name": "{{component-name}}",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/worker.ts",
    "build": "tsc",
    "start": "node dist/worker.js"
  },
  "dependencies": {
    "bullmq": "^5.0.0",
    "ioredis": "^5.0.0",
    "dotenv": "^16.0.0",
    "pino": "^9.2.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "typescript": "^5.7.0",
    "tsx": "^4.0.0",
    "pino-pretty": "^11.2.0"
  }
}
```

**src/worker.ts:**
```ts
import "dotenv/config";
import { Worker } from "bullmq";
import IORedis from "ioredis";
import { logger } from "./lib/logger.js";

const connection = new IORedis(process.env.REDIS_URL || "redis://localhost:6379");

const worker = new Worker(
  "{{component-name}}",
  async (job) => {
    logger.info({ jobId: job.id, jobName: job.name }, "Processing job");
    // Add job processing logic here
  },
  { connection }
);

worker.on("completed", (job) => {
  logger.info({ jobId: job.id }, "Job completed");
});

worker.on("failed", (job, err) => {
  logger.error({ jobId: job?.id, err }, "Job failed");
});

// Graceful shutdown
process.on("SIGTERM", async () => {
  logger.info("SIGTERM received — closing worker");
  await worker.close();
  process.exit(0);
});

logger.info("{{component-name}} worker started");
```

**src/jobs/example.ts:**
```ts
import { Queue } from "bullmq";
import IORedis from "ioredis";

const connection = new IORedis(process.env.REDIS_URL || "redis://localhost:6379");

export const exampleQueue = new Queue("{{component-name}}", { connection });

export async function addExampleJob(data: Record<string, unknown>) {
  return exampleQueue.add("example", data);
}
```

---

## Node.js Agent (Claude SDK)

**package.json:**
```json
{
  "name": "{{component-name}}",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.37.0",
    "express": "^5.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "pino": "^9.2.0"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/cors": "^2.8.0",
    "@types/node": "^22.0.0",
    "typescript": "^5.7.0",
    "tsx": "^4.0.0",
    "pino-pretty": "^11.2.0"
  }
}
```

**src/agent.ts:**
```ts
import Anthropic from "@anthropic-ai/sdk";
import { readFileSync } from "fs";

const client = new Anthropic();

const systemPrompt = readFileSync("prompts/system.md", "utf-8");

export async function runAgent(userMessage: string): Promise<string> {
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    system: systemPrompt,
    messages: [{ role: "user", content: userMessage }],
  });

  const block = response.content[0];
  if (block.type === "text") return block.text;
  return JSON.stringify(block);
}
```

**src/server.ts:**
```ts
import "dotenv/config";
import express from "express";
import cors from "cors";
import { runAgent } from "./agent.js";
import { logger } from "./lib/logger.js";

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.post("/chat", async (req, res) => {
  const { message } = req.body;
  const response = await runAgent(message);
  res.json({ response });
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "{{component-name}}" });
});

app.listen(port, () => {
  logger.info({ port }, "{{component-name}} agent started");
});
```

**prompts/system.md:**
```markdown
You are {{component-name}}, an AI assistant that {{component-description}}.

## What You Do
- [Capability 1]
- [Capability 2]

## What You Don't Do
- [Limitation 1]
- [Limitation 2]

## Communication Style
Be helpful, concise, and professional.
```

**src/tools/index.ts:**
```ts
// Agent tools
export {};
```

---

## Security Middleware

**src/middleware/auth.ts:**
```ts
import { Request, Response, NextFunction } from "express";

/**
 * JWT verification middleware.
 * TODO: Replace with actual auth provider SDK (Clerk, Auth0, etc.)
 * based on the architecture's auth_strategy.
 */
export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ code: "UNAUTHORIZED", message: "Missing authentication token" });
  }
  // TODO: Verify JWT with auth provider
  // const user = await verifyToken(token);
  // req.user = user;
  next();
}
```

**src/middleware/security.ts:**
```ts
import helmet from "helmet";
import cors from "cors";
import { Express } from "express";

export function applySecurityMiddleware(app: Express) {
  // Security headers (CSP, HSTS, X-Frame-Options)
  app.use(helmet());

  // CORS — update origins from .env or manifest
  app.use(cors({
    origin: process.env.CORS_ORIGINS?.split(",") || ["http://localhost:3000"],
    credentials: true,
  }));

  // TODO: Add rate limiting per manifest security.api_security
  // import rateLimit from "express-rate-limit";
  // app.use(rateLimit({ windowMs: 60000, max: 100 }));
}
```

**src/middleware/correlation.ts:**
```ts
import { Request, Response, NextFunction } from "express";
import { randomUUID } from "crypto";

export function correlationId(req: Request, res: Response, next: NextFunction) {
  const id = (req.headers["x-correlation-id"] as string) || randomUUID();
  req.headers["x-correlation-id"] = id;
  res.setHeader("x-correlation-id", id);
  next();
}
```

---

## Observability

**src/lib/logger.ts:**
```ts
import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL || "info",
  transport:
    process.env.NODE_ENV === "development"
      ? { target: "pino-pretty", options: { colorize: true } }
      : undefined,
});
```

---

## Linting & Formatting

**eslint.config.js:**
```js
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/no-explicit-any": "warn",
    },
  }
);
```

**.prettierrc:**
```json
{
  "semi": true,
  "singleQuote": false,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
```

Add to `package.json` scripts:
```json
"lint": "eslint src --ext .ts",
"format": "prettier --write src"
```

Add to `package.json` devDependencies:
```json
"eslint": "^9.0.0",
"@eslint/js": "^9.0.0",
"typescript-eslint": "^8.0.0",
"prettier": "^3.0.0"
```

---

## Testing

**vitest.config.ts:**
```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov"],
    },
  },
});
```

Add to `package.json`:
```json
"test": "vitest run",
"test:watch": "vitest",
"test:coverage": "vitest run --coverage"
```

Add to devDependencies:
```json
"vitest": "^2.0.0",
"@vitest/coverage-v8": "^2.0.0",
"supertest": "^7.0.0",
"@types/supertest": "^6.0.0"
```

**src/__tests__/health.test.ts:**
```ts
import { describe, it, expect } from "vitest";
import request from "supertest";
import express from "express";
import { healthRouter } from "../routes/health.js";

const app = express();
app.use("/health", healthRouter);

describe("GET /health", () => {
  it("returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ok");
  });
});
```

---

## CI Workflow

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm

      - run: npm ci

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm test

      - name: Build
        run: npm run build

      - name: Audit dependencies
        run: npm audit --audit-level=high
```

---

## Dockerfile

```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE {{dev-port}}
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:{{dev-port}}/health || exit 1
CMD ["node", "dist/index.js"]
```

---

## .gitignore

```
node_modules/
dist/
.env
.env.local
.DS_Store
*.log
.next/
.expo/
```

---

## Shared Types Package

**packages/shared-types/package.json:**
```json
{
  "name": "{{shared-library-name}}",
  "version": "0.1.0",
  "private": true,
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch"
  },
  "devDependencies": {
    "typescript": "^5.7.0"
  }
}
```

**packages/shared-types/tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**packages/shared-types/src/index.ts:**
```ts
// Re-export all shared types
// Generated from manifest shared.types[]

{{#each shared-types}}
export type { {{name}} } from "./types/{{kebab-name}}.js";
{{/each}}
```

**packages/shared-types/src/types/[type-name].ts (per type):**
```ts
/**
 * {{description}}
 * Used by: {{used_by}}
 */
export interface {{Name}} {
  {{#each fields}}
  {{field}}: string; // TODO: Set correct type
  {{/each}}
}
```
