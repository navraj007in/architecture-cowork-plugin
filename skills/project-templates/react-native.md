---
name: project-templates-react-native
description: Starter file templates and boilerplate for scaffolding React Native (Expo Managed) mobile apps, including push notifications, auth storage, deep linking, and monitoring stubs
type: skill-extension
parent: project-templates
---

# React Native (Expo) Project Templates

## Mobile — React Native (Expo Managed)

**Initialization (preferred):**
```
npx create-expo-app@latest . --template expo-template-blank-typescript
```

If CLI is unavailable, create these files manually:

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

---

## React Native — API Client

**src/lib/api.ts:**
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

---

## React Native — Auth Storage

**src/lib/auth-storage.ts:**
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

---

## React Native — Push Notifications

**src/lib/push-notifications.ts:**
```ts
import * as Notifications from "expo-notifications";

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

---

## React Native — Monitoring

**src/lib/monitoring.ts:**
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

## React Native — .env.example

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

---

## React Native — CI Workflow

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

      - name: Expo doctor
        run: npx expo-doctor@latest || true
```
