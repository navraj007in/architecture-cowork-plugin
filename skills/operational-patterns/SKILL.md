---
name: operational-patterns
description: Security architecture, observability, CI/CD pipelines, database migrations, and environment strategy patterns for production-ready systems
---

# Operational Patterns

Patterns and recommendations for security, observability, CI/CD, database migrations, and environment management. Use when generating the Security Architecture, Observability, and DevOps Blueprint deliverables.

---

## Security Architecture

### Auth Strategy Selection

| Project Type | Recommended Auth | Rationale |
|-------------|-----------------|-----------|
| Simple app, few roles | Clerk or Supabase Auth | Managed service, minimal setup, built-in UI components |
| Multi-tenant SaaS | Auth0 or Clerk (organizations) | Organization-level isolation, role management, SSO |
| API-only / B2B | API keys + JWT | Simple machine-to-machine auth |
| Enterprise / compliance-heavy | Auth0 or Keycloak (self-hosted) | Fine-grained control, audit logs, compliance certifications |
| Mobile app | Firebase Auth or Clerk | Native SDK support, social login, biometrics |

### API Security Checklist

Every REST API service should implement these protections:

| Protection | Implementation | Priority |
|-----------|---------------|----------|
| **Rate limiting** | Express-rate-limit, Upstash Ratelimit, or API gateway rate limits | Must-have |
| **Input validation** | Zod schemas on all request bodies and query params. Reject unknown fields. | Must-have |
| **CORS** | Whitelist specific origins. Never use `*` in production. | Must-have |
| **Helmet headers** | `helmet` middleware for security headers (CSP, X-Frame-Options, HSTS) | Must-have |
| **SQL/NoSQL injection** | Parameterized queries only. Never interpolate user input into queries. | Must-have |
| **XSS prevention** | Sanitize HTML output. Use frameworks with built-in escaping (React, Next.js). | Must-have |
| **CSRF protection** | SameSite cookies + CSRF tokens for cookie-based auth. Not needed for bearer-only APIs. | Conditional |
| **Request size limits** | Limit body size (e.g. 1MB default, higher for file uploads) | Should-have |
| **Authentication** | Verify JWT/session on every protected route. Middleware, not per-route. | Must-have |
| **Authorization** | Check user roles/permissions after authentication. Separate middleware. | Must-have |

### Data Protection

| Concern | Recommendation |
|---------|---------------|
| **Encryption at rest** | Use database provider's built-in encryption (RDS, Supabase, MongoDB Atlas all encrypt by default) |
| **Encryption in transit** | TLS 1.3 on all endpoints. Enforce HTTPS redirects. Internal service-to-service can use HTTP if within VPC. |
| **PII handling** | Identify PII fields (email, name, phone, address, IP). Log them only when necessary. Mask in non-prod environments. |
| **Secrets management** | Never hardcode secrets. Use platform env vars (Vercel, Railway) or a secrets manager (Doppler, AWS SSM). Rotate API keys periodically. |
| **Data retention** | Define retention periods per data type. Implement soft deletes for user data. Support data export/deletion for GDPR. |
| **Backups** | Automated daily database backups with point-in-time recovery. Test restores quarterly. |

### OWASP Top 10 Quick Reference

When assessing security, check against these common threats:

1. **Broken Access Control** — Ensure authorization checks on every endpoint, not just authentication
2. **Cryptographic Failures** — Don't store passwords in plaintext (use bcrypt/argon2 via auth provider), don't log tokens
3. **Injection** — Parameterized queries, input validation, no eval/exec of user input
4. **Insecure Design** — Rate limit auth endpoints, implement account lockout, use CAPTCHA on public forms
5. **Security Misconfiguration** — Remove default credentials, disable debug mode in production, review CORS
6. **Vulnerable Components** — Keep dependencies updated, run `npm audit` / `pip audit` in CI
7. **Authentication Failures** — Use a managed auth provider, implement MFA for admin roles
8. **Data Integrity Failures** — Verify webhook signatures, validate JWT signatures, use CSP headers
9. **Logging Failures** — Log auth events, access denials, and input validation failures
10. **SSRF** — Validate and whitelist URLs before making server-side requests

---

## Observability

### Observability Stack Recommendations

| Project Size | Logging | Tracing | Metrics | Alerting | Monthly Cost |
|-------------|---------|---------|---------|----------|-------------|
| **MVP / startup** | Axiom (free tier) or console + Vercel logs | Not needed yet | Vercel/Railway built-in | Sentry (free tier) | $0 |
| **Growing (1K-10K users)** | Axiom or Betterstack | Sentry performance | PostHog + Sentry | Sentry + Slack webhooks | $20-50/mo |
| **Production (10K+ users)** | Datadog or Grafana Cloud | OpenTelemetry → Jaeger/Datadog | Prometheus + Grafana or Datadog | PagerDuty + Datadog | $100-500/mo |
| **Enterprise** | Datadog or Splunk | Datadog APM or Honeycomb | Datadog or custom Prometheus | PagerDuty + Datadog | $500+/mo |

### Structured Logging

All services should use structured JSON logging:

```json
{
  "level": "info",
  "timestamp": "2026-02-07T10:30:00.000Z",
  "service": "api-server",
  "requestId": "req_abc123",
  "userId": "usr_xyz",
  "action": "create_order",
  "duration_ms": 145,
  "message": "Order created successfully"
}
```

**Logging rules:**
- Use log levels consistently: `error` (broken), `warn` (degraded), `info` (business events), `debug` (dev only)
- Include `requestId` for request correlation across services
- Include `userId` for audit trail (mask in logs if compliance requires)
- Never log: passwords, tokens, full credit card numbers, API keys
- Always log: auth failures, permission denials, input validation errors, external API errors

### Key Metrics to Track

| Category | Metric | Alert Threshold |
|----------|--------|----------------|
| **Availability** | Uptime percentage | < 99.5% over 24h |
| **Latency** | Request duration p50, p95, p99 | p99 > 2s |
| **Error rate** | 5xx errors / total requests | > 1% over 5 minutes |
| **Throughput** | Requests per second | Unusual spike or drop (>3x baseline) |
| **Queue depth** | Jobs waiting in queue | > 1000 for > 5 minutes |
| **Database** | Connection pool usage, query duration | Pool > 80%, queries > 500ms |
| **AI/LLM** | Token usage, response time, failure rate | Failure rate > 5%, response > 30s |
| **Business** | Signups, conversions, active users | Unusual drops (context-dependent) |

### Health Check Pattern

Every service exposes `/health` with tiered checks:

```json
{
  "status": "healthy",
  "service": "api-server",
  "version": "1.2.3",
  "uptime_seconds": 86400,
  "checks": {
    "database": { "status": "healthy", "latency_ms": 5 },
    "redis": { "status": "healthy", "latency_ms": 2 },
    "external_api": { "status": "degraded", "latency_ms": 1500, "note": "slow but responding" }
  }
}
```

- `/health` — quick liveness check (returns 200 if process is running)
- `/health/ready` — readiness check (returns 200 only if all dependencies are reachable)
- Used by load balancers, container orchestrators, and monitoring

---

## CI/CD Pipeline

### Pipeline Templates by Provider

**GitHub Actions (recommended for most projects):**

```
Stages: lint → test → build → deploy

Triggers:
  - Push to main → deploy to production
  - Push to develop → deploy to staging
  - Pull request → run lint + test only
  - Manual dispatch → deploy to any environment
```

**Pipeline stages:**

| Stage | What It Does | Tools |
|-------|-------------|-------|
| **Lint** | Code style, formatting, type checking | ESLint, Prettier, tsc --noEmit / Ruff, mypy |
| **Test** | Unit tests, integration tests | Jest, Vitest, pytest |
| **Build** | Compile, bundle, Docker image | tsc, next build, docker build |
| **Security** | Dependency audit, secret scanning | npm audit, pip audit, Trivy, GitGuardian |
| **Deploy** | Push to hosting provider | Vercel CLI, Railway CLI, AWS CDK, Docker push |

### Branch Strategy Selection

| Team Size | Recommended Strategy | Workflow |
|-----------|---------------------|----------|
| Solo / 1-2 devs | github-flow | `main` + feature branches. Merge via PR. Deploy on merge to main. |
| 3-5 devs | github-flow | Same, but require PR reviews. Use staging environment for pre-prod testing. |
| 5-10 devs | gitflow or trunk-based | Gitflow if you need scheduled releases. Trunk-based if you deploy continuously. |
| 10+ devs | trunk-based with feature flags | Short-lived branches (<1 day). Feature flags for incomplete features. |

### Environment Promotion

```
Feature branch → PR review → merge to develop → auto-deploy to staging →
manual promote to production (merge develop → main) → auto-deploy to production
```

For simpler projects:
```
Feature branch → PR review → merge to main → auto-deploy to production
```

---

## Database Migrations

### Migration Tool Selection

| Stack | Recommended Tool | Alternatives |
|-------|-----------------|-------------|
| Node.js + PostgreSQL | Prisma Migrate | Knex, TypeORM, Drizzle Kit |
| Node.js + MongoDB | Mongoose (schema-on-read) | migrate-mongo |
| Python + PostgreSQL | Alembic | Django migrations, SQLAlchemy-migrate |
| Python + MongoDB | No formal migrations needed | mongomock for testing |

### Migration Strategy

| Concern | Recommendation |
|---------|---------------|
| **Versioning** | Sequential numbered migrations (001_create_users.sql, 002_add_orders.sql). Never edit applied migrations. |
| **Rollback** | Every migration has an up and a down. Test rollbacks before deploying. |
| **CI integration** | Run pending migrations automatically in CI before tests. Run in staging before production. |
| **Zero-downtime** | Avoid breaking changes in one step. Add column → backfill → make required → remove old. |
| **Seed data** | Dev seeds: faker/factory data for local development. Staging seeds: anonymized subset of production data. |
| **Production** | Run migrations before deploying new code. Use advisory locks to prevent concurrent migrations. |

### Common Migration Patterns

| Pattern | When | Example |
|---------|------|---------|
| **Add nullable column** | Safe, no downtime | `ALTER TABLE users ADD COLUMN phone TEXT;` |
| **Rename column** | Requires migration in 2 steps | Step 1: Add new column + backfill. Step 2: Drop old column. |
| **Add index** | Can lock table on large datasets | Use `CREATE INDEX CONCURRENTLY` on PostgreSQL |
| **Change column type** | Risky — may lose data | Create new column, migrate data, drop old column |

---

## Environment Strategy

### Environment Definitions

| Environment | Purpose | Data | Access | Deploy Trigger |
|------------|---------|------|--------|---------------|
| **Local** | Developer machine | Seed data / Docker Compose | Developer only | Manual |
| **Development** | Shared dev environment | Seed data | Dev team | Push to `develop` |
| **Staging** | Pre-production testing | Anonymized prod data or rich seeds | Dev team + QA | Push to `staging` or manual promote |
| **Production** | Live users | Real data | Restricted access | Push to `main` or manual promote |

### Config Management

**Environment variable categories:**

| Category | Examples | Where Stored |
|----------|---------|-------------|
| **Service config** | PORT, NODE_ENV, LOG_LEVEL | .env file (local), platform env vars (deployed) |
| **Database** | DATABASE_URL, REDIS_URL | Platform env vars, secrets manager |
| **Third-party API keys** | STRIPE_SECRET_KEY, SENDGRID_API_KEY | Secrets manager (Doppler, AWS SSM) |
| **Feature flags** | ENABLE_AI_AGENT, ENABLE_BETA_FEATURES | Feature flag service or env vars |
| **Internal service URLs** | API_SERVER_URL, AGENT_SERVICE_URL | Platform env vars, service discovery |

**Config validation:**
- Validate all environment variables on service startup using Zod, envalid, or pydantic-settings
- Fail fast with clear error messages if required vars are missing
- Log which environment the service is running in (but never log secret values)

### Feature Flags

| Approach | When to Use | Tool |
|----------|------------|------|
| **Environment variables** | Simple on/off for 1-2 features | `ENABLE_FEATURE_X=true` |
| **Config file** | Multiple flags, no runtime changes needed | `features.json` loaded on startup |
| **Feature flag service** | Runtime toggling, gradual rollouts, A/B testing | LaunchDarkly ($10/mo), Unleash (open source), PostHog (free tier) |

---

## Choosing What to Include

Not every project needs all operational patterns. Use this guide:

| Project Stage | Include | Skip |
|-------------|---------|------|
| **MVP / proof of concept** | Basic auth, console logging, simple CI (lint + test + deploy), env vars | Tracing, alerting, feature flags, multi-environment |
| **Early startup (pre-product-market fit)** | Managed auth, structured logging, Sentry, GitHub Actions CI/CD, staging env | APM, custom metrics, PagerDuty, complex migration strategy |
| **Growing product (1K+ users)** | All security checklist items, observability stack, full CI/CD pipeline, migration tooling, staging + production | Enterprise compliance, self-hosted tooling |
| **Production / enterprise** | Everything above + compliance audits, APM, distributed tracing, PagerDuty, feature flags, multi-region | Nothing — you need it all |

When generating blueprints, match the depth to the project's stage and complexity. Don't overwhelm an MVP with enterprise patterns.
