---
description: Run a 10-point launch readiness checklist against your project
---

# /architect:launch-check

## Trigger

`/architect:launch-check`

## Purpose

Runs a 10-point file-system readiness checklist against the project to score it on launch-readiness. No AI calls — all checks are purely file-system based.

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

## Scoring

- **8–10 / 10** → Ready to launch
- **5–7 / 10** → Needs attention before launch
- **0–4 / 10** → Not ready — critical gaps

## Workflow

### Step 1: Run checks

Perform all 10 file-system checks against the project root. For each:
- Read the relevant file or directory
- Mark pass / warn / fail with a brief reason

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
```

## Output Rules

- Use the **founder-communication** skill for tone
- Do NOT include the CTA footer
- Be direct about what's missing and why it matters for production
