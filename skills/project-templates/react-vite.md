---
name: project-templates-react-vite
description: Starter file templates and boilerplate for scaffolding React (Vite) web frontends
type: skill-extension
parent: project-templates
---

# React (Vite) Project Templates

## Frontend — React (Vite)

**Initialization (preferred):**
```
npm create vite@latest . -- --template react-ts
```

If CLI is unavailable, create these files manually:

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

## React (Vite) — Dockerfile (static build + nginx)

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

**nginx.conf** (place in repo root alongside Dockerfile):
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

> Same Dockerfile pattern applies to Vue (Nuxt static), SvelteKit (adapter-static), and Angular builds — all produce a `dist/` directory served by nginx.

---

## React (Vite) — CI Workflow

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

      - name: Type check
        run: npx tsc --noEmit

      - name: Build
        run: npm run build
```
