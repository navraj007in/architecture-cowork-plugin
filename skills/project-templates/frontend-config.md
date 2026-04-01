---
name: project-templates-frontend-config
description: Frontend configuration file templates — API client, auth storage, monitoring, realtime, and state management. Applied to all web frontends after base framework scaffold.
type: skill-extension
parent: project-templates
---

# Frontend Configuration Templates

These files are generated for **all web frontend projects** based on the manifest's frontend-specific fields. Apply them after the base framework scaffold (Next.js, React/Vite, Vue, SvelteKit, Angular).

## API Client (src/lib/api.ts)

Generated when `api_client` is specified. Adapt to the configured library:

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

**Next.js note:** Replace `import.meta.env.VITE_*` with `process.env.NEXT_PUBLIC_*` for Next.js projects.

---

## Backend Connection Stubs (src/services/*.ts)

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

> If a pre-generated contract client exists at `architecture-output/contracts/<frontend>-calls-<service>.client.ts`, copy that file to `src/lib/clients/<service>-client.ts` instead of creating a stub.

---

## Client Auth Setup (src/lib/auth.ts)

Generated based on `client_auth` config:

```ts
// Token storage: {{token-storage}}
// CSRF protection: {{csrf-protection}}
// Token refresh: {{token-refresh}}

// TODO: Implement auth helpers based on the configured strategy:
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

---

## Monitoring Init (src/lib/monitoring.ts)

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

---

## Realtime Setup (src/lib/realtime.ts)

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

---

## State Management (src/store/)

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
