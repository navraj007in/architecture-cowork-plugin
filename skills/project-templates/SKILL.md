---
name: project-templates
description: Starter file templates and boilerplate for scaffolding projects across frontend, backend, mobile, and AI agent frameworks
---

# Project Templates

Starter templates for each supported framework. Used by the scaffolder agent to create real, working project scaffolds.

> **Framework coverage:** This skill provides predefined templates for the most common frameworks (Next.js, React, Express, FastAPI, Expo, etc.). For frameworks not listed here (Angular, .NET, Spring Boot, Django, Go, Flutter, SvelteKit, Rails, Laravel, etc.), the scaffolder agent generates appropriate starter files dynamically using its LLM capabilities. The predefined templates below serve as the quality benchmark — dynamically generated scaffolds should match the same structure and completeness.

## Frontend Templates

### Next.js (App Router)

When `npx create-next-app` is available, use CLI initialization with flags:
```
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --no-import-alias
```

If CLI is unavailable, create these files manually:

**package.json:**
```json
{
  "name": "{{component-name}}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "typescript": "^5.7.0",
    "tailwindcss": "^4.0.0",
    "@tailwindcss/postcss": "^4.0.0",
    "postcss": "^8.0.0",
    "eslint": "^9.0.0",
    "eslint-config-next": "^15.0.0"
  }
}
```

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

**src/app/layout.tsx:**
```tsx
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "{{component-name}}",
  description: "{{component-description}}",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

**src/app/page.tsx:**
```tsx
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold">{{component-name}}</h1>
      <p className="mt-4 text-lg text-gray-600">{{component-description}}</p>
    </main>
  );
}
```

**src/app/globals.css:**
```css
@import "tailwindcss";
```

---

### React (Vite)

Use CLI when available:
```
npm create vite@latest . -- --template react-ts
```

Fallback files:

**package.json:**
```json
{
  "name": "{{component-name}}",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.7.0",
    "vite": "^6.0.0"
  }
}
```

**vite.config.ts:**
```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
});
```

**src/App.tsx:**
```tsx
function App() {
  return (
    <div>
      <h1>{{component-name}}</h1>
      <p>{{component-description}}</p>
    </div>
  );
}

export default App;
```

**src/main.tsx:**
```tsx
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
```

**index.html:**
```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{{component-name}}</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

---

## Frontend Configuration Templates

These files are generated for **all web frontend projects** based on the manifest's frontend-specific fields. Add them after the base framework scaffold.

### API Client (src/lib/api.ts)

Generated when `api_client` is specified. Adapt the base client to the configured library:

**axios (default):**
```ts
import axios from "axios";

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:{{dev-port}}",
  withCredentials: {{client-auth-uses-cookies}}, // true if token_storage is "cookie"
  timeout: 15000,
});

// Auth token injection (for non-cookie auth)
api.interceptors.request.use((config) => {
  // TODO: Read token from configured storage (localStorage, sessionStorage, memory)
  // const token = {{token-storage-get}};
  // if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// CSRF token injection (if client_auth.csrf_protection is true)
// api.interceptors.request.use((config) => {
//   const csrfToken = document.cookie.match(/csrf_token=([^;]+)/)?.[1];
//   if (csrfToken) config.headers["X-CSRF-Token"] = csrfToken;
//   return config;
// });
```

### Backend Connection Stubs (src/services/*.ts)

Generate one file per `backend_connections[]` entry:

**src/services/{{service-name}}.ts:**
```ts
import { api } from "@/lib/api";

/**
 * {{service-name}} service client
 * Purpose: {{connection-purpose}}
 */
export const {{serviceCamelCase}}Service = {
  // TODO: Add typed API methods matching the backend service's endpoints
  // Example:
  // getAll: () => api.get("/{{service-prefix}}/items"),
  // getById: (id: string) => api.get(`/{{service-prefix}}/items/${id}`),
  // create: (data: unknown) => api.post("/{{service-prefix}}/items", data),
};
```

### Client Auth Setup (src/lib/auth.ts)

Generated based on `client_auth` config:

```ts
// Token storage: {{token-storage}}
// CSRF protection: {{csrf-protection}}
// Token refresh: {{token-refresh}}

// TODO: Implement auth helpers based on the configured strategy
// - Cookie-based: withCredentials + CSRF token handling (already in api.ts)
// - localStorage: token get/set/clear + interceptor
// - sessionStorage: same as localStorage but session-scoped
// - memory: in-memory store with refresh flow

export function isAuthenticated(): boolean {
  // TODO: Check if valid token exists
  return false;
}

export function logout(): void {
  // TODO: Clear tokens from configured storage and redirect
}
```

### Monitoring Init (src/lib/monitoring.ts)

Generated when `monitoring` is configured:

```ts
// Error tracking: {{error-tracking}}
// Analytics: {{analytics}}

// TODO: Initialize error tracking SDK
// Example for Sentry:
// import * as Sentry from "@sentry/react";
// Sentry.init({ dsn: import.meta.env.VITE_SENTRY_DSN });

// TODO: Initialize analytics SDK
// Example for App Insights:
// import { ApplicationInsights } from "@microsoft/applicationinsights-web";
// const appInsights = new ApplicationInsights({
//   config: { instrumentationKey: import.meta.env.VITE_APP_INSIGHTS_KEY },
// });
// appInsights.loadAppInsights();

export function captureException(error: Error): void {
  console.error("[Monitoring]", error);
}

export function trackEvent(name: string, properties?: Record<string, unknown>): void {
  console.log("[Analytics]", name, properties);
}
```

### Realtime Setup (src/lib/realtime.ts)

Generated when `realtime` is configured:

**websocket:**
```ts
const WS_URL = import.meta.env.VITE_WS_URL || "ws://localhost:{{dev-port}}";

export function createWebSocket(path: string): WebSocket {
  const ws = new WebSocket(`${WS_URL}${path}`);
  // TODO: Add reconnection logic, heartbeat, auth token
  return ws;
}
```

**socket-io:**
```ts
// import { io } from "socket.io-client";
// const socket = io(import.meta.env.VITE_WS_URL, { withCredentials: true });
// export { socket };
```

**sse:**
```ts
export function createEventSource(path: string): EventSource {
  const url = `${import.meta.env.VITE_API_URL}${path}`;
  return new EventSource(url, { withCredentials: true });
}
```

### State Management (src/store/)

Generated when `state_management` is specified:

**zustand (src/store/index.ts):**
```ts
import { create } from "zustand";

interface AppState {
  // TODO: Add app-level state from manifest responsibilities
}

export const useAppStore = create<AppState>()((set) => ({
  // TODO: Add initial state and actions
}));
```

---

## Backend Templates

### Node.js / Express

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
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/cors": "^2.8.0",
    "@types/node": "^22.0.0",
    "typescript": "^5.7.0",
    "tsx": "^4.0.0"
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

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use("/health", healthRouter);

app.listen(port, () => {
  console.log(`{{component-name}} listening on port ${port}`);
});
```

**src/routes/health.ts:**
```ts
import { Router } from "express";

export const healthRouter = Router();

healthRouter.get("/", (_req, res) => {
  res.json({ status: "ok", service: "{{component-name}}" });
});
```

---

### Python / FastAPI

**pyproject.toml:**
```toml
[project]
name = "{{component-name}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.34.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "httpx>=0.28.0",
]
```

**requirements.txt:**
```
fastapi>=0.115.0
uvicorn[standard]>=0.34.0
python-dotenv>=1.0.0
```

**main.py:**
```python
from fastapi import FastAPI
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="{{component-name}}")


@app.get("/health")
async def health():
    return {"status": "ok", "service": "{{component-name}}"}
```

**app/routes/__init__.py:**
```python
# Route modules
```

Run with: `uvicorn main:app --reload`

---

### Node.js Worker (BullMQ)

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
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "typescript": "^5.7.0",
    "tsx": "^4.0.0"
  }
}
```

**src/worker.ts:**
```ts
import "dotenv/config";
import { Worker } from "bullmq";
import IORedis from "ioredis";

const connection = new IORedis(process.env.REDIS_URL || "redis://localhost:6379");

const worker = new Worker(
  "{{component-name}}",
  async (job) => {
    console.log(`Processing job ${job.id}: ${job.name}`);
    // Add job processing logic here
  },
  { connection }
);

worker.on("completed", (job) => {
  console.log(`Job ${job.id} completed`);
});

worker.on("failed", (job, err) => {
  console.error(`Job ${job?.id} failed:`, err);
});

console.log(`{{component-name}} worker started`);
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

## Mobile Templates

### React Native (Expo Managed)

Use CLI when available:
```
npx create-expo-app@latest . --template expo-template-blank-typescript
```

Fallback files:

**package.json:**
```json
{
  "name": "{{component-name}}",
  "version": "0.1.0",
  "main": "expo-router/entry",
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "ios": "expo run:ios",
    "web": "expo start --web",
    "lint": "expo lint"
  },
  "dependencies": {
    "expo": "~54.0.0",
    "expo-router": "~6.0.0",
    "expo-status-bar": "~3.0.0",
    "expo-secure-store": "~15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-native": "^0.81.0",
    "react-native-safe-area-context": "~5.6.0",
    "react-native-screens": "~4.16.0",
    "react-native-gesture-handler": "~2.28.0",
    "react-native-reanimated": "~4.1.0",
    "@tanstack/react-query": "^5.0.0",
    "axios": "^1.7.0",
    "zustand": "^5.0.0",
    "react-hook-form": "^7.50.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/react": "^19.0.0",
    "typescript": "^5.7.0"
  }
}
```

**app.json:**
```json
{
  "expo": {
    "name": "{{component-name}}",
    "slug": "{{component-name}}",
    "version": "0.1.0",
    "orientation": "portrait",
    "scheme": "{{deep-linking-scheme}}",
    "platforms": ["ios", "android"],
    "ios": {
      "bundleIdentifier": "{{bundle-id-ios}}",
      "supportsTablet": true,
      "associatedDomains": ["{{associated-domains}}"],
      "infoPlist": {
        "NSCameraUsageDescription": "{{camera-usage-description}}",
        "NSMicrophoneUsageDescription": "{{microphone-usage-description}}"
      }
    },
    "android": {
      "package": "{{bundle-id-android}}",
      "permissions": ["{{android-permissions}}"]
    },
    "plugins": [
      "expo-router",
      "expo-secure-store"
    ],
    "updates": {
      "url": "{{ota-update-url}}"
    },
    "runtimeVersion": {
      "policy": "appVersion"
    }
  }
}
```

**app/index.tsx:**
```tsx
import { Text, View, StyleSheet } from "react-native";

export default function Index() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{{component-name}}</Text>
      <Text style={styles.subtitle}>{{component-description}}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center" },
  title: { fontSize: 24, fontWeight: "bold" },
  subtitle: { fontSize: 16, color: "#666", marginTop: 8 },
});
```

**src/lib/api.ts (mobile API client):**
```ts
import axios from "axios";
import { getAuthToken } from "./auth-storage";

const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL || "http://localhost:3000",
  timeout: 30000,
});

api.interceptors.request.use(async (config) => {
  const token = await getAuthToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export { api };
```

**src/lib/auth-storage.ts (mobile auth):**
```ts
import * as SecureStore from "expo-secure-store";

const TOKEN_KEY = "auth_token";
const REFRESH_KEY = "refresh_token";

export async function getAuthToken(): Promise<string | null> {
  return SecureStore.getItemAsync(TOKEN_KEY);
}

export async function setAuthToken(token: string): Promise<void> {
  await SecureStore.setItemAsync(TOKEN_KEY, token);
}

export async function clearAuth(): Promise<void> {
  await SecureStore.deleteItemAsync(TOKEN_KEY);
  await SecureStore.deleteItemAsync(REFRESH_KEY);
}

// TODO: Add biometric unlock if client_auth.biometric is true
// TODO: Add device binding if client_auth.device_binding is true
```

**src/lib/push-notifications.ts (mobile push):**
```ts
import * as Notifications from "expo-notifications";
import { Platform } from "react-native";

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export async function registerForPushNotifications(): Promise<string | null> {
  const { status } = await Notifications.requestPermissionsAsync();
  if (status !== "granted") return null;

  const token = await Notifications.getExpoPushTokenAsync();
  // TODO: Send token to backend for storage
  return token.data;
}

// TODO: Add notification channels from push_notifications.channels
// TODO: Configure provider-specific setup (FCM, APNs) from manifest
```

**src/lib/monitoring.ts (mobile monitoring):**
```ts
// TODO: Initialize crash reporting SDK based on manifest monitoring.crash_reporting
// Example for Sentry:
// import * as Sentry from "@sentry/react-native";
// Sentry.init({ dsn: process.env.EXPO_PUBLIC_SENTRY_DSN });

// TODO: Initialize analytics SDK based on manifest monitoring.analytics

export function captureException(error: Error): void {
  // TODO: Send to crash reporting service
  console.error("[Monitoring]", error);
}

export function trackEvent(name: string, properties?: Record<string, unknown>): void {
  // TODO: Send to analytics service
  console.log("[Analytics]", name, properties);
}
```

---

## Agent Templates

### Python Agent (Claude SDK)

**pyproject.toml:**
```toml
[project]
name = "{{component-name}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "anthropic>=0.42.0",
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.34.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "httpx>=0.28.0",
]
```

**requirements.txt:**
```
anthropic>=0.42.0
fastapi>=0.115.0
uvicorn[standard]>=0.34.0
python-dotenv>=1.0.0
```

**agent.py:**
```python
import anthropic
from dotenv import load_dotenv

load_dotenv()

client = anthropic.Anthropic()

SYSTEM_PROMPT = open("prompts/system.md").read()


def run_agent(user_message: str) -> str:
    """Run a single turn of the agent."""
    response = client.messages.create(
        model="claude-sonnet-4-5-20250929",
        max_tokens=4096,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": user_message}],
    )
    return response.content[0].text
```

**main.py:**
```python
from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
from agent import run_agent

load_dotenv()

app = FastAPI(title="{{component-name}}")


class AgentRequest(BaseModel):
    message: str


@app.post("/chat")
async def chat(request: AgentRequest):
    response = run_agent(request.message)
    return {"response": response}


@app.get("/health")
async def health():
    return {"status": "ok", "service": "{{component-name}}"}
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

**tools/__init__.py:**
```python
# Agent tools
```

---

### Node.js Agent

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
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@types/express": "^5.0.0",
    "@types/cors": "^2.8.0",
    "@types/node": "^22.0.0",
    "typescript": "^5.7.0",
    "tsx": "^4.0.0"
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
    model: "claude-sonnet-4-5-20250929",
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
  console.log(`{{component-name}} agent listening on port ${port}`);
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

## Security Middleware Templates

### Node.js / Express — Auth Middleware

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

### Node.js / Express — Security Middleware

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

### Python / FastAPI — Auth Dependency

**app/middleware/auth.py:**
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()


async def require_auth(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    JWT verification dependency.
    TODO: Replace with actual auth provider SDK based on the architecture's auth_strategy.
    """
    token = credentials.credentials
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token",
        )
    # TODO: Verify JWT with auth provider
    # user = await verify_token(token)
    # return user
    return {"token": token}
```

---

## Observability Templates

### Node.js — Structured Logger

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

Add `pino` and `pino-pretty` to package.json dependencies:
```json
"pino": "^9.0.0",
"pino-pretty": "^11.0.0"
```

### Python — Structured Logger

**app/lib/logger.py:**
```python
import logging
import json
import sys


class JSONFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        log_data = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "service": "{{component-name}}",
        }
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_data)


def get_logger(name: str = "{{component-name}}") -> logging.Logger:
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(JSONFormatter())
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)
    return logger
```

### Enhanced Health Check — Node.js

**src/routes/health.ts (enhanced):**
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

---

## DevOps Templates

### GitHub Actions CI Workflow

**.github/workflows/ci.yml (Node.js):**
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
```

**.github/workflows/ci.yml (Python):**
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

      - uses: actions/setup-python@v5
        with:
          python-version: "3.13"

      - run: pip install -r requirements.txt

      - name: Lint
        run: ruff check .

      - name: Test
        run: pytest
```

### docker-compose.yml (for local development)

```yaml
version: "3.8"

services:
  {{component-name}}:
    build: .
    ports:
      - "${PORT:-3000}:3000"
    env_file: .env
    depends_on:
      - db
      - redis

  # TODO: Add/remove services based on manifest databases
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: {{component-name}}
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

---

## Shared Package Templates

### TypeScript Shared Types Package

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

### Python Shared Types Package

**packages/shared-types/pyproject.toml:**
```toml
[project]
name = "{{shared-library-name}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "pydantic>=2.0.0",
]
```

**packages/shared-types/src/types.py:**
```python
from pydantic import BaseModel


# Generated from manifest shared.types[]

class User(BaseModel):
    """Core user type. TODO: Add proper field types."""
    id: str
    email: str
    # TODO: Add remaining fields from manifest
```

---

## Common Files

These files are added to every project regardless of framework.

### .gitignore (Node.js / TypeScript)

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

### .gitignore (Python)

```
__pycache__/
*.pyc
.env
.venv/
venv/
dist/
*.egg-info/
.DS_Store
```

### .env.example

Generate from the manifest's integrations and environments. Format:

**Backend service:**
```bash
# Server
PORT={{dev-port}}
NODE_ENV=development

# {{service-name}} — {{category}}
# Get credentials at: {{signup-url}}
{{ENV_VAR_NAME}}=
```

**Web frontend (Vite):**
```bash
# API URLs — update per environment
# DEV:     http://localhost:{{backend-dev-port}}
# STAGING: {{staging-url}}
# PROD:    {{prod-url}}
VITE_API_URL=http://localhost:{{backend-dev-port}}

# WebSocket URL (if realtime is configured)
# VITE_WS_URL=ws://localhost:{{backend-dev-port}}

# Monitoring
# VITE_SENTRY_DSN=
# VITE_APP_INSIGHTS_KEY=
```

**Mobile app (Expo):**
```bash
# API URLs — update per environment
# DEV:     http://localhost:{{backend-dev-port}}
# STAGING: {{staging-url}}
# PROD:    {{prod-url}}
EXPO_PUBLIC_API_URL=http://localhost:{{backend-dev-port}}

# Push Notifications
# EXPO_PUBLIC_PUSH_PROJECT_ID=

# Monitoring
# EXPO_PUBLIC_SENTRY_DSN=

# OTA Updates
# EXPO_PUBLIC_UPDATE_URL=
```

Include a comment with the signup URL for each integration service so the user knows where to get credentials. Use environment URLs from the manifest's `environments` section.

### README.md

Auto-generate for each component:

```markdown
# {{component-name}}

{{component-description}}

## Tech Stack

- **Framework:** {{framework}}
- **Language:** {{language}}

## Setup

1. Clone the repository
2. Copy environment variables: `cp .env.example .env`
3. Fill in your credentials in `.env`
4. Install dependencies: `{{install-command}}`
5. Start development server: `{{dev-command}}`

## Scripts

| Command | Description |
|---------|-------------|
| `{{dev-command}}` | Start development server |
| `{{build-command}}` | Build for production |
| `{{start-command}}` | Start production server |

## Architecture

This component is part of the **{{project-name}}** architecture.

Other components:
{{#each other-components}}
- **{{name}}** — {{description}}
{{/each}}

---

*Scaffolded by [Architect AI](https://github.com/navraj007in/architecture-cowork-plugin)*
```

### Dockerfile (optional, include if the manifest specifies containerized deployment)

**Node.js:**
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
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Python:**
```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Template Variables

All templates use `{{variable}}` placeholders. The scaffolder agent replaces these with actual values from the architecture manifest:

| Variable | Source |
|----------|--------|
| `{{component-name}}` | Manifest component name (kebab-case) |
| `{{component-description}}` | Manifest component description |
| `{{project-name}}` | Manifest project name |
| `{{framework}}` | Detected framework |
| `{{language}}` | TypeScript, Python, etc. |
| `{{install-command}}` | `npm install` or `pip install -r requirements.txt` |
| `{{dev-command}}` | `npm run dev` or `uvicorn main:app --reload` |
| `{{build-command}}` | `npm run build` or `N/A` |
| `{{start-command}}` | `npm start` or `uvicorn main:app` |
| `{{ENV_VAR_NAME}}` | Derived from manifest integrations |
| `{{service-name}}` | Integration service name |
| `{{signup-url}}` | From known-services skill |
| `{{dev-port}}` | From manifest frontend `dev_port` or service port |
| `{{backend-dev-port}}` | Port of the primary backend service |
| `{{staging-url}}` | From manifest `environments[name=staging].domain` |
| `{{prod-url}}` | From manifest `environments[name=production].domain` |
| `{{bundle-id-ios}}` | From manifest mobile `bundle_id.ios` |
| `{{bundle-id-android}}` | From manifest mobile `bundle_id.android` |
| `{{deep-linking-scheme}}` | From manifest mobile `deep_linking.scheme` |
| `{{associated-domains}}` | From manifest mobile `deep_linking.associated_domains[]` |
| `{{token-storage}}` | From manifest `client_auth.token_storage` |
| `{{error-tracking}}` | From manifest `monitoring.error_tracking` |
| `{{analytics}}` | From manifest `monitoring.analytics` |
| `{{service-prefix}}` | API path prefix for backend connection |
| `{{connection-purpose}}` | From manifest `backend_connections[].purpose` |
