---
description: Deep code analysis across all components — produces a scored, categorised go/no-go verdict before launch
---

# /architect:production-readiness

## Trigger

```
/architect:production-readiness
/architect:production-readiness --component <name>   # scope to a single component
```

## Purpose

Analyses actual source code across all components to determine whether the project is safe to launch. Reads route files, middleware, schema, migrations, environment config, test files, and SDL to score 8 categories. Produces a prioritised gap list (P0 blockers / P1 required / P2 recommended) and a single go/no-go verdict.

**Distinct from `/architect:launch-check`** — that command is a 30-second file-presence scan suitable for CI gates. This command reads and analyses source code content. Run it as the final sign-off before going to production.

**Does not re-run other commands.** If `security-scan.md`, `_state.json.test_suite`, or monitoring config already exist, this command reads their outputs rather than repeating the analysis.

## Workflow

### Step 1: Load project context

Follow the [Context Loading Pattern](../CLAUDE.md):

1. Read `architecture-output/_state.json` in full. Extract:
   - `project.name`, `project.type`, `project.stage`
   - `tech_stack` — framework, ORM, auth provider, integrations
   - `components[]` — names, types, ports
   - `test_suite` — coverage target, frameworks (if `generate-tests` was run)
   - `monitoring` — providers configured (if `setup-monitoring` was run)
   - `compliance` — frameworks, critical gaps (if `compliance` was run)

2. Read `solution.sdl.yaml` (or `sdl/` module files). Grep for:
   - `slos:` → `slos.services[].availability` — used to enforce observability threshold
   - `compliance:` → frameworks in scope
   - `testing:` → e2eFramework, coverageTarget
   - `contracts:` → `contracts.apis[]` — used to verify API contract shape
   - `features:` → features with status `done` — used to verify critical paths are tested

3. If `--component <name>` was passed, scope all subsequent steps to that component's directory only.

4. Collect the component directory list:
   - From `_state.json.components[]` — use `name` field to find directories
   - Fall back to Glob for directories containing `package.json`, `pyproject.toml`, `go.mod`, or `*.csproj`

### Step 2: Security analysis

For each component of type `api`, `backend`, `service`, `worker`, or `lambda`:

**2a. Auth guards on routes**

- Grep for route definitions: Express (`router.get|post|put|patch|delete`), Fastify (`fastify.get|post`), NestJS (`@Get|@Post|@Put|@Patch|@Delete`), FastAPI (`@app.get|@router.post`), etc.
- For each route, check whether an auth middleware is present in the handler chain or at the router level
- Routes containing `health`, `ping`, `metrics`, `status`, `webhook` are exempt from auth check
- **P0 blocker** if any non-exempt route has no auth guard and SDL `auth.strategy` is not `none`

**2b. Input validation**

- Grep source files for validation library usage: `zod`, `joi`, `class-validator`, `FluentValidation`, `pydantic`, `cerberus`
- For each POST/PUT/PATCH route, check whether a schema is applied to `req.body` / `request.body` before the handler logic
- **P0 blocker** if mutation routes exist and no validation library is present at all
- **P1** if validation library is present but not applied to all mutation handlers

**2c. Hardcoded secrets**

- Grep all source files (excluding `node_modules`, `dist`, `.git`, test files) for patterns:
  - `= "sk_live_`, `= "pk_live_`, `= "AKIA`, `= "ghp_`, `= "Bearer ey`, `password =`, `secret =`, `api_key =`
  - Followed by a non-empty string literal (not a variable reference)
- Also Grep for common secret file patterns: `credentials.json`, `.pem`, `.p12`, `.pfx` committed to source
- **P0 blocker** if any hardcoded secret is found

**2d. Security headers**

- Grep `package.json` / `requirements.txt` / `go.mod` for: `helmet`, `cors`, `django-cors-headers`, `fastapi-cors`, `gorilla/handlers`
- Grep entry point file for the middleware being applied (not just installed)
- **P0 blocker** if neither security headers library nor equivalent manual header-setting is found in the entry point
- **P1** if library is installed but not applied in entry point

**2e. Rate limiting**

- Grep for rate limiting middleware: `express-rate-limit`, `fastapi-limiter`, `throttler`, `rate_limit`, `RateLimit`, `@nestjs/throttler`
- Check it is applied to auth routes at minimum (`/auth/login`, `/auth/register`, `/api/token`)
- **P0 blocker** if auth routes exist and no rate limiting is applied to them

**2f. No SQL injection risk**

- Grep for raw query patterns with string concatenation: `` `SELECT * FROM ${``, `"SELECT * FROM " +`, `execute(f"SELECT`, `db.query(f"`
- Exclude parameterised variants: `$1`, `?`, `:param`
- **P0 blocker** if raw concatenated SQL queries are found

### Step 3: Production hardening analysis

For each backend/API component:

**3a. Graceful shutdown**

- Grep entry point file for `SIGTERM`, `SIGINT`, `process.on(`, `signal.Notify`
- Check that `server.close()` / connection pool drain is called in the handler
- **P0 blocker** if no signal handler found in the entry point

**3b. Health check endpoint**

- Grep route files for path containing `health`, `ping`, or `readiness`
- **P0 blocker** if no health endpoint found — required for all load balancers and container orchestrators

**3c. Structured logging**

- Grep `package.json` / deps for: `pino`, `winston`, `bunyan`, `zerolog`, `zap`, `structlog`, `logrus`, `serilog`
- Grep source files (excluding tests) for `console.log(`, `console.error(`, `print(`, `fmt.Println(`
  - If a structured logger is present but `console.log` is also used in production paths → **P1**
  - If no structured logger is present → **P0 blocker**

**3d. Error tracking**

- Grep `package.json` / deps for: `@sentry/node`, `@sentry/browser`, `dd-trace`, `newrelic`, `bugsnag`, `rollbar`, `honeybadger`
- Check it is initialised at application entry point (not just installed)
- **P1** if not present — required before any user-facing traffic

**3e. Unhandled rejection/exception handlers**

- Grep entry point for `process.on('unhandledRejection'`, `process.on('uncaughtException'`, `app.exception_handler`, `recover()`
- **P1** if absent — unhandled errors will crash the process without logging context

**3f. Correlation ID**

- Grep backend middleware for `x-correlation-id`, `x-request-id`, `correlationId`, `requestId` header extraction
- Grep frontend API client for the same header being forwarded on outbound requests
- **P2** if absent — non-blocking but degrades incident response

**3g. Retry + timeout on outbound HTTP**

- Grep source files for outbound HTTP call patterns: `axios.get`, `fetch(`, `httpx.get`, `http.Get`
- For each, check for `AbortController` / `timeout:` / `signal:` / `context.WithTimeout`
- Check for retry logic: `axios-retry`, `p-retry`, `tenacity`, `backoff`
- **P2** if absent for non-critical paths; **P1** if missing on payment/critical integration calls

### Step 4: Observability analysis

**4a. Metrics**

- Check SDL `slos.services[].availability` — if any service has availability ≥ 99.9%, require a metrics provider
- Grep for: `prom-client`, `prometheus_client`, `dd-trace`, APM agent init
- Check if `setup-monitoring` output exists at `architecture-output/monitoring-*`
- **P1** if SLO ≥ 99.9% and no metrics provider found

**4b. Log levels via environment variable**

- Grep for `LOG_LEVEL`, `log_level`, `LOG_LEVEL` environment variable reference in logger init
- **P2** if hardcoded log level found

**4c. Request logging**

- Grep for request logging middleware: `morgan`, `pino-http`, `fastapi middleware`, `access_log`
- **P1** if absent on API/backend components

### Step 5: Testing analysis

**5a. Test file presence per component**

- Glob for `**/__tests__/**`, `**/tests/**`, `**/*.test.ts`, `**/*.spec.ts`, `**/*.test.py`, `**/*_test.go` within the component directory
- **P1** if no test files found for any API or backend component

**5b. Critical path coverage**

- Grep test files for references to auth flows: `login`, `register`, `token`, `session`
- If SDL `tech_stack.integrations` contains `Stripe`, `Paddle`, `LemonSqueezy`, `Braintree` — Grep test files for payment-related test cases
- Grep test files for the primary entity CRUD operations (use `_state.json.entities[0].name`)
- **P1** for each critical path that has no corresponding test file references

**5c. Test command**

- Grep `package.json` scripts for `"test":` entry
- Grep `Makefile` for `test:` target
- **P1** if no runnable test command found

**5d. Coverage target**

- If `_state.json.test_suite.coverage_target` exists, check for a coverage configuration file: `.nycrc`, `jest.config.js coverage`, `pytest-cov`, `.coveragerc`
- **P2** if coverage target is defined but no coverage tooling is configured

### Step 6: Deployment readiness analysis

**6a. Dockerfile**

- Check for `Dockerfile` at component root
- Read it — check for multi-stage build (`FROM ... AS builder`, `FROM ... AS runner`)
- Check that final stage does not install dev dependencies (`npm ci --include=dev`, `pip install -r requirements-dev.txt`)
- **P0 blocker** if no Dockerfile found for any deployable component
- **P1** if Dockerfile is single-stage (copies dev deps to production image)

**6b. CI/CD pipeline**

- Glob for `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml`, `bitbucket-pipelines.yml`
- Check that at least one workflow references a build or deploy step
- **P0 blocker** if no CI/CD pipeline found

**6c. Environment variable completeness**

- For each component, Grep source files for `process.env.`, `os.environ[`, `os.getenv(`, `viper.GetString(`, `os.Getenv(` — collect all referenced variable names
- Read `.env.example` if present — collect all defined names
- Report variables referenced in source but absent from `.env.example`
- **P0 blocker** if any variables are missing from `.env.example` (undocumented config = production surprise)

**6d. Database migrations**

- Glob for `migrations/`, `prisma/migrations/`, `db/migrate/`, `alembic/versions/`, `flyway/migrations/`
- **P0 blocker** if SDL `data.primaryDatabase` is present but no migration directory is found

**6e. No dev-only deps in production paths**

- Grep `package.json` for `devDependencies` entries that are also imported in non-test source files
- Common offenders: `ts-node`, `nodemon`, `faker`, `jest`, `vitest`, `supertest`
- **P1** if dev-only packages are imported in production source

### Step 7: Data model analysis

For each component with a schema file (`schema.prisma`, `models.py`, `*.entity.ts`, `*.go` with GORM structs):

**7a. Foreign key indexes**

- Parse schema files for foreign key fields (fields ending in `Id`, `_id`, decorator `@relation`, `ForeignKey`, `db.ForeignKey`)
- Check whether each FK field has a corresponding `@@index`, `db.Index`, `index=True`
- **P1** for each FK field missing an index (causes full table scans on joins)

**7b. Unique constraints on SDL unique fields**

- Grep SDL `domain.entities[].fields` for fields with `unique: true`
- Check schema files for `@unique`, `unique=True`, `UNIQUE` constraint on those fields
- **P1** if SDL declares a field unique but the schema lacks the constraint

**7c. Soft delete**

- If `_state.json.entities` contains any entity that appears in routes with a DELETE handler, check for `deletedAt` field in the schema
- **P2** if hard deletes are used — note it as an architectural consideration, not a blocker

**7d. Migration reversibility**

- Grep latest 3 migration files for `DROP TABLE`, `DROP COLUMN`, `ALTER TABLE ... DROP` without a corresponding `down` migration or reversible comment
- **P2** if destructive migrations lack down migrations

### Step 8: API contract analysis

For each API/backend component:

**8a. OpenAPI spec presence**

- Glob for `architecture-output/contracts/<component>.openapi.yaml`, `openapi.yaml`, `swagger.yaml` in component directory
- **P1** if SDL `contracts.apis[]` is non-empty but no spec file found

**8b. Consistent error shapes**

- Grep route/controller files for error response patterns: `res.status(4`, `res.status(5`, `raise HTTPException`, `c.JSON(http.Status`
- Check whether error responses include both `code` (machine-readable) and `message` (human-readable) fields
- Sample 3–5 error responses across different routes
- **P1** if error shapes are inconsistent (some return `{error: string}`, others return `{message: string}`)

**8c. Pagination on list endpoints**

- Grep route files for GET routes returning arrays: patterns like `findMany`, `list`, `getAll`, `/users`, `/orders`, `/items`
- Check for `limit`, `offset`, `page`, `cursor`, `take`, `skip` parameters
- **P1** if list endpoints return unbounded results (no pagination)

### Step 9: Compliance analysis (conditional)

Only run this step if `_state.json.compliance.frameworks` is non-empty or SDL has a `compliance:` section.

- Read `architecture-output/compliance-*.md` if `compliance` command was run — extract critical gaps
- **If compliance report exists:** re-surface any critical or high severity gaps as P1 items
- **If compliance report does not exist:**
  - For GDPR: Grep for PII logging (logging fields like `email`, `phone`, `ssn`, `dob` in log statements) → **P1** if found
  - For HIPAA: Grep for PHI in unencrypted storage patterns → **P0 blocker** if found
  - For PCI DSS: Grep for card number patterns in source or logs → **P0 blocker** if found
  - Recommend running `/architect:compliance` for a full audit

### Step 10: Produce report

**10a. Aggregate findings**

Collect all findings from Steps 2–9. For each finding:
- Assign severity: `P0` (launch blocker), `P1` (fix within sprint 0), `P2` (post-launch)
- Record: category, component, finding description, file path if applicable

**10b. Determine verdict**

| Condition | Verdict |
|-----------|---------|
| Any P0 blocker | `⛔ NOT READY` |
| 0 P0 blockers, more than 3 P1 items | `⚠️ CONDITIONALLY READY` |
| 0 P0 blockers, 3 or fewer P1 items | `✅ READY TO LAUNCH` |

**10c. Write output file**

Write `architecture-output/production-readiness.md`:

```markdown
# Production Readiness: <project name>

**Verdict: ⛔ NOT READY / ⚠️ CONDITIONALLY READY / ✅ READY TO LAUNCH**
Generated: <ISO date>
Components scanned: <N> (<list>)

---

## Verdict Summary

<1–2 sentences. If NOT READY: "N P0 blockers must be resolved before launch."
If CONDITIONALLY READY: "No launch blockers, but M issues should be addressed before first users."
If READY: "All critical checks pass. Address P1 items before scaling beyond initial users.">

---

## P0 — Launch Blockers

Must be fixed before any production traffic.

| # | Category | Component | Finding | File |
|---|----------|-----------|---------|------|
| 1 | Security | api-server | No rate limiting on /auth/login — brute-force risk | src/routes/auth.ts |
| 2 | Hardening | api-server | No SIGTERM handler — requests dropped mid-deploy | src/index.ts |
| … | … | … | … | … |

---

## P1 — Required Before Scale

Not launch blockers, but should be resolved before onboarding real users.

| # | Category | Component | Finding | File |
|---|----------|-----------|---------|------|
| … | … | … | … | … |

---

## P2 — Post-Launch Improvements

Address after initial launch once stability is confirmed.

| # | Category | Component | Finding | File |
|---|----------|-----------|---------|------|
| … | … | … | … | … |

---

## Score by Category

| Category | Score | P0 | P1 | P2 |
|----------|-------|----|----|-----|
| Security | 5/7 | 1 | 0 | 1 |
| Hardening | 4/7 | 1 | 1 | 1 |
| Observability | 4/6 | 0 | 1 | 1 |
| Testing | 3/6 | 0 | 2 | 1 |
| Deployment | 6/8 | 1 | 1 | 0 |
| Data Model | 7/8 | 0 | 1 | 1 |
| API Contracts | 4/6 | 0 | 1 | 0 |
| Compliance | n/a | — | — | — |

---

## Fix Guide

### P0 — Security: Rate limiting on /auth/login

**Why it matters:** Without rate limiting, an attacker can attempt unlimited password combinations against login endpoints.

**Fix:** Install `express-rate-limit` and apply a limiter to auth routes:

```ts
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 20 });
router.post('/auth/login', authLimiter, loginHandler);
router.post('/auth/register', authLimiter, registerHandler);
```

### P0 — Hardening: SIGTERM handler

**Why it matters:** Without a SIGTERM handler, in-flight requests are dropped when the container shuts down during a deploy.

**Fix:** Add to `src/index.ts`:

```ts
process.on('SIGTERM', () => {
  server.close(() => {
    pool.end();
    process.exit(0);
  });
});
```

<... one Fix Guide entry per P0 and P1 finding ...>
```

**10d. Print in-conversation summary**

After writing the file, print a condensed version in the conversation:

```
Production Readiness: <project name>
Verdict: ⛔ NOT READY (3 P0 blockers)

P0 — Launch Blockers:
  ⛔ Security     · No rate limiting on /auth/login (api-server/src/routes/auth.ts)
  ⛔ Hardening    · No SIGTERM handler (api-server/src/index.ts)
  ⛔ Deployment   · 4 env vars used in source but missing from .env.example

P1 — Fix Before Scale:
  ⚠️  Observability · No Prometheus/APM — SLO target is 99.9%
  ⚠️  Testing      · No tests for Stripe payment flow
  ⚠️  Data Model   · Missing index on orders.userId
  ⚠️  API Contracts · /api/users returns unbounded results (no pagination)

P2 — Post-Launch:
  💡 Correlation ID not forwarded in web-app → api-server client
  💡 Soft delete not implemented on User entity (hard deletes only)

Score:  Security 5/7 · Hardening 4/7 · Observability 4/6 · Testing 3/6
        Deployment 6/8 · Data Model 7/8 · API Contracts 4/6

Full report: architecture-output/production-readiness.md
Fix /auth/login rate limiting, add SIGTERM handler, and complete .env.example to unblock launch.
```

**10e. Append to activity log**

```json
{"ts":"<ISO-8601>","phase":"production-readiness","outcome":"completed","files":["architecture-output/production-readiness.md"],"summary":"<verdict>: N P0 blockers, M P1 items across X components"}
```

## Output Rules

- Do not re-run `security-scan`, `generate-tests`, `setup-monitoring`, or `compliance` — read their output files if they exist
- Do not generate placeholder Fix Guide entries — only write a Fix Guide entry for P0 and P1 findings that were actually found
- If a component directory cannot be found, skip it and note it in the summary line: "web-app not found — skipped"
- If `_state.json` is missing, proceed with SDL only; note reduced accuracy in the verdict summary
- The Fix Guide entries must include the specific file path and a concrete code snippet, not generic advice
- Use the **founder-communication** skill for tone — direct about what breaks in production and why it matters, not academic
- Do NOT add a "Next Steps" footer — the fix guide and verdict are the output

## Relationship to other commands

| Command | How it relates |
|---------|---------------|
| `/architect:launch-check` | File-presence scan, CI gate — run this first for a quick check; `production-readiness` is the thorough pre-launch sign-off |
| `/architect:launch-checklist` | Produces a task list of what to build; `production-readiness` verifies those tasks were completed |
| `/architect:security-scan` | Deep security analysis; if `security-scan.md` exists, `production-readiness` reads it rather than repeating checks |
| `/architect:compliance` | Full compliance audit; if compliance report exists, `production-readiness` re-surfaces critical gaps as P1 items |
| `/architect:generate-tests` | Generates test files; `production-readiness` reads `_state.json.test_suite` to verify coverage targets |
| `/architect:setup-monitoring` | Configures monitoring; `production-readiness` checks whether it is actually wired in |
