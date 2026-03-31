---
name: project-templates
description: Starter file templates and boilerplate for scaffolding projects across frontend, backend, mobile, and AI agent frameworks. Runtime sub-files: go.md (Go/Gin), dotnet.md (.NET/ASP.NET Core)
---

# Project Templates

Starter templates for each supported framework. Used by the scaffolder agent to create real, working project scaffolds.

> **Runtime-specific sub-files:** Full predefined templates for Go and .NET are in separate files loaded automatically:
> - **Go / Gin:** `skills/project-templates/go.md`
> - **.NET / ASP.NET Core:** `skills/project-templates/dotnet.md`
>
> **Framework coverage:** This skill (plus the runtime sub-files above) covers: Next.js, React, Express, FastAPI, Go/Gin, ASP.NET Core, Expo, and AI agents. For other runtimes (Angular, Spring Boot, Django, Flutter, Rails, Laravel, etc.), the scaffolder generates appropriate starter files dynamically using its LLM capabilities — the predefined templates serve as the quality benchmark.

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

> **Runtime-specific backend templates** are in dedicated sub-files loaded automatically:
> - **Node.js / Express, BullMQ worker, Node.js agent:** `skills/project-templates/nodejs.md`
> - **Python / FastAPI, Python agent:** `skills/project-templates/python.md`
> - **Go / Gin:** `skills/project-templates/go.md`
> - **.NET / ASP.NET Core:** `skills/project-templates/dotnet.md`

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

> Agent templates are included in the runtime sub-files:
> - **Node.js agent:** `skills/project-templates/nodejs.md`
> - **Python agent:** `skills/project-templates/python.md`

---

## Security Middleware Templates

> Security middleware templates are included in the runtime sub-files:
> - **Node.js** (auth, security headers, correlation ID): `skills/project-templates/nodejs.md`
> - **Python** (FastAPI auth dependency, correlation middleware): `skills/project-templates/python.md`
> - **Go** (Gin auth + correlation middleware): `skills/project-templates/go.md`
> - **.NET** (auth middleware, correlation ID middleware): `skills/project-templates/dotnet.md`

---

## Observability Templates

> Structured logger, health check, and observability templates are included in the runtime sub-files:
> - **Node.js** (pino logger, `/health` + `/health/ready`): `skills/project-templates/nodejs.md`
> - **Python** (structlog): `skills/project-templates/python.md`
> - **Go** (slog, health handlers): `skills/project-templates/go.md`
> - **.NET** (Serilog, health endpoint): `skills/project-templates/dotnet.md`

---

## DevOps Templates

### GitHub Actions CI Workflow

> Runtime-specific CI workflows are in the runtime sub-files (nodejs.md, python.md, go.md, dotnet.md).

### docker-compose.yml — MANDATORY for all backend services

Every backend service MUST include a `docker-compose.yml` for local development. Web frontends SHOULD also include one if they have backend dependencies.

**IMPORTANT — Port collision prevention:** Each service in the architecture MUST use a unique host port. Assign ports sequentially starting from the manifest's `dev_port` for each component. Never use the same host port for two different services. Use the `${PORT:-{{dev-port}}}` pattern so ports can be overridden via `.env`.

```yaml
services:
  {{component-name}}:
    build: .
    ports:
      - "${PORT:-{{dev-port}}}:{{dev-port}}"
    env_file: .env
    depends_on:
      - db
      - redis

  # Add/remove services based on manifest databases.
  # Use unique host ports per component to avoid collisions across services.
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: {{component-name}}
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "{{db-host-port}}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "{{redis-host-port}}:6379"

volumes:
  pgdata:
```

**Port assignment strategy for multi-service architectures:**
When scaffolding multiple services, assign non-overlapping host ports for infrastructure containers:
- Service 1 DB: 5432, Redis: 6379
- Service 2 DB: 5433, Redis: 6380
- Service 3 DB: 5434, Redis: 6381
- And so on...

This prevents port collisions when running multiple services locally at the same time.

---

## Shared Package Templates

### Shared Types Package

> Runtime-specific shared types packages are in the runtime sub-files:
> - **TypeScript** (package.json, tsconfig, index.ts): `skills/project-templates/nodejs.md`
> - **Python** (pyproject.toml, pydantic models): `skills/project-templates/python.md`

---

## Common Files

These files are added to every project regardless of framework.

### .gitignore

> Runtime-specific .gitignore files are in the runtime sub-files (nodejs.md, python.md, go.md, dotnet.md). Always add one per component.

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

### Dockerfile — MANDATORY for all backends and agents

Every backend service, worker, and agent MUST include a Dockerfile. This is not optional.

> Runtime-specific Dockerfiles are in the runtime sub-files:
> - **Node.js:** `skills/project-templates/nodejs.md`
> - **Python:** `skills/project-templates/python.md`
> - **Go:** `skills/project-templates/go.md` (distroless static image)
> - **.NET:** `skills/project-templates/dotnet.md` (Alpine + aspnet runtime)

### Dockerfile — for web frontends (include where applicable)

Web frontends that produce a build artifact SHOULD include a Dockerfile. Skip only for mobile-only targets (Expo, Flutter).

**Next.js (SSR):**
```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE {{dev-port}}
ENV PORT={{dev-port}}
CMD ["node", "server.js"]
```

**React / Vue / Svelte (static build + nginx):**
```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE {{dev-port}}
```

When generating a static-frontend Dockerfile, also create a `nginx.conf`:
```nginx
server {
    listen {{dev-port}};
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
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
