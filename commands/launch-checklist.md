---
description: Pre-launch readiness checklist generated from SDL and deployment configuration
---

# /architect:launch-checklist

## Trigger

`/architect:launch-checklist` — run after blueprint and scaffold are complete, before go-live.

## Purpose

Generate a comprehensive pre-launch readiness checklist tailored to the project's architecture, deployment strategy, and compliance requirements. Ensures nothing is missed before the product goes live. Useful for founders, development agencies handing off to clients, and DevOps teams.

## Workflow

### Step 1: Gather Project Context

Read the following project files to understand the architecture:

1. **SDL file** (`solution.sdl.yaml` or `sdl.yaml`) — components, auth strategy, data stores, deployment config, observability settings, non-functional requirements
2. **Architecture output** — read `architecture-output/executive-summary.md` if it exists for high-level context
3. **Deployment config** — check for `docker-compose.yml`, `.github/workflows/`, Dockerfile, `fly.toml`, `vercel.json`, `netlify.toml`, `render.yaml`
4. **Environment files** — check `.env.example` for required secrets and config
5. **Security scan** — read `architecture-output/security-scan.md` if it exists

### Step 2: Load Skills

Load:
- **operational-patterns** skill — for security, observability, and CI/CD best practices
- **security-audit** skill — for security hardening checklist items
- **founder-communication** skill — for plain English descriptions

### Step 3: Generate Checklist

Organize the checklist by category. For each item, include:
- `[ ]` checkbox (unchecked)
- Item description in plain English
- Priority tag: `[Required]`, `[Recommended]`, or `[Optional]`
- One-line "why" explaining the risk if skipped

**Categories:**

#### 1. Infrastructure & Hosting
- Domain name configured and DNS propagated
- SSL/TLS certificates installed (HTTPS enforced)
- CDN configured for static assets (if frontend exists)
- Load balancer configured (if multiple instances)
- Auto-scaling rules set (if applicable)
- Environment variables set in production (compare .env.example)

#### 2. Monitoring & Observability
- Error tracking service configured (Sentry, Bugsnag, etc.)
- Uptime monitoring with alerting (Pingdom, Better Uptime, etc.)
- Application logging to centralized service (not just stdout)
- Performance monitoring / APM (response times, throughput)
- Alert channels configured (Slack, email, PagerDuty)
- Health check endpoints responding

#### 3. Security
- All secrets rotated from development values
- CORS policy restricted to production domains
- Rate limiting enabled on API endpoints
- Input validation on all user-facing endpoints
- SQL injection / XSS protections verified
- Authentication tokens configured with appropriate expiry
- Admin/debug endpoints disabled or protected
- Dependency audit (npm audit / pip audit) clean or acknowledged

#### 4. Data & Backups
- Database backups configured (automated, tested restore)
- Migration scripts tested against production-like data
- Seed data removed or replaced with production defaults
- Data retention policy defined
- Personal data handling documented (if applicable)

#### 5. Legal & Compliance
- Privacy Policy published and linked
- Terms of Service published and linked
- Cookie consent banner (if applicable — EU/GDPR)
- GDPR/CCPA data subject request process documented
- Third-party service DPAs signed (if handling PII)
- Accessibility basics checked (WCAG 2.1 AA — headings, alt text, keyboard nav)

#### 6. Analytics & Metrics
- Product analytics installed (Mixpanel, PostHog, Amplitude, etc.)
- Key funnel events tracked (signup, activation, conversion)
- Error rates dashboarded
- Business KPIs defined and measurable

#### 7. Performance
- Page load time < 3s on 3G connection (tested)
- Images optimized (WebP, lazy loading)
- API response times < 500ms for critical paths
- Database queries optimized (no N+1, indexes added)
- Caching strategy implemented (Redis, CDN, HTTP cache headers)

#### 8. Documentation
- README updated with setup instructions
- API documentation published (Swagger/Redoc if applicable)
- Deployment runbook written (how to deploy, rollback, restart)
- Incident response plan documented (who to contact, escalation)

#### 9. Go-Live Readiness
- Feature flags configured for risky features
- Rollback plan tested (can revert to previous version in < 5 min)
- Support channel set up (email, chat, or ticketing)
- Status page configured (Instatus, Betteruptime, etc.)
- Launch announcement prepared (social, email, product hunt)

### Step 4: Tailor to Project

- If SDL has no `auth` section → skip authentication-related items
- If SDL has no `deployment` section → mark all infrastructure items as `[Required]` with note "deployment not yet configured"
- If SDL has `observability` section → mark monitoring items that are already configured as `[Configured]` instead of checkbox
- If project stage is `mvp` → mark legal/compliance items as `[Recommended]` not `[Required]`
- If project stage is `product` → mark all legal/compliance items as `[Required]`

### Step 5: Output

Write the checklist to `architecture-output/launch-checklist.md`.

Format as a single markdown document with clear category headings (## level) and checkbox items.

Include a summary at the top:
```
# Launch Checklist — [Project Name]
Generated: [date]

**Summary**: X required items, Y recommended, Z optional
**Launch readiness**: [Ready / Needs attention / Not ready]
```

## Output Rules

- Use **founder-communication** skill for all descriptions — plain English, no jargon
- Every item should be actionable — "Configure X" not "X should be configured"
- Include links to recommended services where applicable (e.g., "Configure Sentry (sentry.io) for error tracking")
- Do NOT include a CTA footer
- Do NOT ask questions — make reasonable assumptions based on SDL
