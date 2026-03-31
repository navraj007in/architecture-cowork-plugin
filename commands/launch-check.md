---
description: Run a 10-point launch readiness checklist against your project
---

# /architect:launch-check

## Trigger

`/architect:launch-check`

## Purpose

Runs a 10-point file-system readiness checklist against the project to score it on launch-readiness. No AI calls — all checks are purely file-system based. Also runs a 9-point production hardening sub-check.

## Checklist (10 points)

| # | Check | How it's verified |
|---|-------|-------------------|
| 1 | Tests present | `tests/`, `__tests__/`, or `npm test` script exists |
| 2 | Health check endpoint | Any file containing "health" in path or name |
| 3 | Environment variables complete | `.env.example` vars all set in `.env` |
| 4 | Monitoring / error tracking | Sentry, Datadog, or similar in package.json / requirements.txt |
| 5 | Security headers | helmet, cors, or security middleware in deps |
| 6 | README.md | README.md exists at project root |
| 7 | Dockerfile | Dockerfile exists at project root |
| 8 | CI/CD pipeline | `.github/workflows/`, `.gitlab-ci.yml`, or Jenkinsfile exists |
| 9 | Database migrations | `migrations/` or `prisma/migrations/` directory exists |
| 10 | API specification | `openapi.yaml`, `swagger.yaml`, or equivalent in `architecture-output/` |

## Production Hardening Sub-Check (9 patterns)

Run all 9 production hardening pattern checks against the project's backend entry point and source files:

| # | Pattern | How it's verified |
|---|---------|-------------------|
| 1 | Security headers (helmet/CORS) | helmet and cors middleware present in backend deps and applied in entry point |
| 2 | Health check endpoint | Route file or handler containing "health" exists in backend |
| 3 | Correlation ID propagation | `x-correlation-id` middleware exists in backend entry point and API client forwards the header |
| 4 | Graceful shutdown | SIGTERM/SIGINT handlers exist in backend entry point with `server.close()` |
| 5 | Structured logging | A logging library (pino, winston, serilog, zerolog) is present and `console.log` is absent from production code paths |
| 6 | Auth token interceptor | Frontend API client has Bearer token injection, 401 retry, and redirect on refresh failure |
| 7 | Rate limiting | Rate limiting middleware is applied to API routes |
| 8 | Input validation | Zod/Joi/FluentValidation schemas are applied to request body/params/query before handlers |
| 9 | Retry + timeout | Outbound HTTP calls use AbortController timeout and exponential backoff retry |
| 10 | Soft delete | ORM models have `deletedAt` field and transparent query filter middleware |

Wait — patterns 3–10 are the 8 new checks; together with the existing helmet/CORS (pattern 1) and health check (pattern 2), the hardening score is **x/9** (patterns 1–9 above; soft delete is pattern 10 and counts as an optional bonus check outside the 9-point score).

The 9 scored hardening patterns are:

| # | Pattern |
|---|---------|
| 1 | Security headers (helmet/CORS) |
| 2 | Health check endpoint |
| 3 | Correlation ID propagation |
| 4 | Graceful shutdown |
| 5 | Structured logging |
| 6 | Auth token interceptor |
| 7 | Rate limiting |
| 8 | Input validation |
| 9 | Retry + timeout |

Soft delete (`deletedAt` + query filter) is checked and reported separately as a bonus pattern.

### Hardening Score

- **7–9 / 9** → Production-hardened
- **4–6 / 9** → Partially hardened — address gaps before go-live
- **0–3 / 9** → Not hardened — significant production risk

## Scoring

- **8–10 / 10** → Ready to launch
- **5–7 / 10** → Needs attention before launch
- **0–4 / 10** → Not ready — critical gaps

## Workflow

### Step 1: Run checks

Perform all 10 file-system checks against the project root. For each:
- Read the relevant file or directory
- Mark pass / warn / fail with a brief reason

Then run the 9-point production hardening sub-check against the backend entry point and source files. Also check for the soft delete bonus pattern.

### Step 2: Report

Print a checklist table:

```
Launch Readiness: 7/10

✅ Tests present — __tests__/ found
✅ Health check — /health route in src/routes/health.ts
✅ Env vars complete — .env matches .env.example
⚠️  Monitoring — No Sentry or Datadog dependency found
⚠️  Security headers — helmet not in package.json
✅ README.md — present
✅ Dockerfile — present
⚠️  CI/CD — No .github/workflows found
✅ Migrations — prisma/migrations/ present
✅ API spec — architecture-output/openapi.yaml found

Status: Needs attention (7/10)
Fix monitoring, security headers, and CI/CD before launching to production.

---

Production Hardening: 4/9

✅ Security headers — helmet + cors in deps
✅ Health check — /health route found
⚠️  Correlation ID propagation — no x-correlation-id middleware found
⚠️  Graceful shutdown — no SIGTERM/SIGINT handler in entry point
⚠️  Structured logging — console.log found in production paths; no pino/winston
✅ Auth token interceptor — Bearer injection + 401 retry found in API client
⚠️  Rate limiting — no rate limiting middleware on API routes
✅ Input validation — Zod schemas applied to request handlers
⚠️  Retry + timeout — no AbortController or backoff retry on outbound HTTP

Bonus: Soft delete — ❌ no deletedAt field found in ORM models

Hardening status: Partially hardened (4/9)
Add correlation ID, graceful shutdown, structured logging, rate limiting, and retry/timeout before go-live.
```

## Output Rules

- Use the **founder-communication** skill for tone
- Do NOT include the CTA footer
- Be direct about what's missing and why it matters for production
