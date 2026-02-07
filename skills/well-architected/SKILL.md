---
name: well-architected
description: Six-pillar well-architected framework for evaluating architecture quality — operational excellence, security, reliability, performance, cost optimization, and developer experience
---

# Well-Architected Framework

A structured framework for evaluating architecture quality across six pillars. Inspired by the AWS Well-Architected Framework, adapted for startups and modern product development. Technology-agnostic — applies to any stack.

Use this skill when generating the Well-Architected Review deliverable in `/architect:blueprint` or when running `/architect:well-architected` as a standalone evaluation.

---

## The Six Pillars

### 1. Operational Excellence

**Question:** Can you deploy, monitor, and improve the system with confidence?

| Criteria | What Good Looks Like | Score Guide |
|----------|---------------------|-------------|
| **CI/CD pipeline** | Automated lint → test → build → deploy on every push | 1 = manual deploys, 5 = full CI/CD with rollback |
| **Infrastructure as Code** | Deployment config in repo (Vercel config, Dockerfile, Terraform) | 1 = manual setup, 5 = fully reproducible |
| **Observability** | Structured logs + error tracking + health checks | 1 = console.log only, 5 = full observability stack |
| **Incident response** | Alerts → runbook → mitigation → post-mortem process | 1 = no plan, 5 = documented runbooks and on-call |
| **Change management** | Feature flags, staged rollouts, database migrations versioned | 1 = YOLO deploys, 5 = staged rollouts with flags |

**Key questions to ask:**
- How do you deploy a change today? How long does it take?
- When something breaks at 2am, how do you find out? How do you fix it?
- Can a new developer deploy to staging on their first day?

---

### 2. Security

**Question:** Is user data protected, and are attack surfaces minimized?

| Criteria | What Good Looks Like | Score Guide |
|----------|---------------------|-------------|
| **Authentication** | Managed auth provider, MFA for admin, token rotation | 1 = DIY password hashing, 5 = managed auth + MFA |
| **Authorization** | Role-based or attribute-based access control on every endpoint | 1 = no authorization checks, 5 = RBAC/ABAC middleware |
| **Data protection** | Encryption at rest and in transit, PII identified and handled | 1 = plaintext everywhere, 5 = encrypted + PII policies |
| **API security** | Rate limiting, input validation, CORS, security headers | 1 = none, 5 = all OWASP top 10 mitigated |
| **Secrets management** | No hardcoded secrets, env vars or secrets manager, rotation policy | 1 = secrets in code, 5 = secrets manager + rotation |
| **Dependency security** | Automated vulnerability scanning in CI | 1 = never audited, 5 = automated audit + auto-fix |

**Key questions to ask:**
- What happens if an API key leaks? How fast can you rotate it?
- Can a regular user access admin endpoints by guessing the URL?
- Are you storing anything you shouldn't be? (passwords, full card numbers, unnecessary PII)

---

### 3. Reliability

**Question:** Does the system keep working when things go wrong?

| Criteria | What Good Looks Like | Score Guide |
|----------|---------------------|-------------|
| **Fault isolation** | One service failing doesn't cascade to others | 1 = monolith with no error boundaries, 5 = circuit breakers + fallbacks |
| **Recovery** | Automated restarts, health checks, self-healing | 1 = manual restart, 5 = auto-restart + health checks + failover |
| **Data durability** | Automated backups, point-in-time recovery, tested restores | 1 = no backups, 5 = automated backups + tested restores |
| **Retry & timeout** | Retries with exponential backoff, timeouts on all external calls | 1 = no retries/timeouts, 5 = retry policies on all external calls |
| **Graceful degradation** | System works (reduced functionality) when a dependency is down | 1 = hard crash, 5 = graceful fallback for each dependency |
| **Scaling** | Handles 10x current load without architecture changes | 1 = breaks at 2x, 5 = auto-scaling with no code changes |

**Key questions to ask:**
- What happens when the database goes down for 5 minutes?
- What happens when a third-party API (Stripe, SendGrid) is slow or down?
- Can the system handle a sudden traffic spike (e.g., HackerNews front page)?

---

### 4. Performance Efficiency

**Question:** Are resources used efficiently, and is the user experience fast?

| Criteria | What Good Looks Like | Score Guide |
|----------|---------------------|-------------|
| **Response time** | API p95 < 500ms, page load < 2s, AI response < 5s | 1 = > 3s average, 5 = p95 < 200ms |
| **Right-sizing** | Resources match actual load (not over/under-provisioned) | 1 = fixed large instances, 5 = auto-scaled to demand |
| **Caching** | Appropriate caching at each layer (CDN, API, database) | 1 = no caching, 5 = multi-layer caching strategy |
| **Async processing** | Heavy work offloaded to background jobs / queues | 1 = everything synchronous, 5 = async where appropriate |
| **Database efficiency** | Indexed queries, connection pooling, no N+1 problems | 1 = unoptimized queries, 5 = optimized + monitored |
| **Frontend performance** | Code splitting, lazy loading, optimized images, CDN | 1 = single bundle, no CDN, 5 = optimized + CDN + edge |

**Key questions to ask:**
- What's the slowest user-facing operation? Can it be made async?
- Are you paying for compute that's idle 90% of the time?
- Is there a caching layer, or does every request hit the database?

---

### 5. Cost Optimization

**Question:** Are you spending the minimum needed for the current scale?

| Criteria | What Good Looks Like | Score Guide |
|----------|---------------------|-------------|
| **Free tier usage** | Maximizing free tiers before paying | 1 = paying for everything, 5 = optimized free tier usage |
| **Right-sizing** | Resources match actual usage, not theoretical maximum | 1 = over-provisioned, 5 = auto-scaled or right-sized |
| **Cost awareness** | Team knows monthly cost breakdown, alerts on overspend | 1 = no idea of costs, 5 = cost dashboards + budget alerts |
| **Service selection** | Chosen services fit the scale (not enterprise tools for MVP) | 1 = enterprise tools for 10 users, 5 = appropriate for scale |
| **LLM cost control** | Token optimization, caching, model selection, rate limits | 1 = GPT-4 for everything, 5 = tiered models + prompt caching |
| **Scaling economics** | Costs scale sub-linearly with users | 1 = linear cost scaling, 5 = strong economies of scale |

**Key questions to ask:**
- What's your monthly cloud bill? Do you know what each line item is?
- Are you using the cheapest option that meets your requirements?
- When you 10x users, does cost 10x too, or less?

---

### 6. Developer Experience

**Question:** Can developers build, test, and ship features quickly and confidently?

| Criteria | What Good Looks Like | Score Guide |
|----------|---------------------|-------------|
| **Onboarding** | New dev productive in < 1 day (README, setup scripts, seed data) | 1 = tribal knowledge, 5 = automated setup + docs |
| **Local development** | `docker compose up` or `npm run dev` and everything works | 1 = complex manual setup, 5 = one-command startup |
| **Type safety** | TypeScript/Python type hints throughout, shared types across services | 1 = untyped, 5 = strict types + shared type packages |
| **Testing** | Fast unit tests, meaningful integration tests, CI runs all tests | 1 = no tests, 5 = comprehensive test suite < 5 min |
| **Code organization** | Clear folder structure, consistent patterns, separation of concerns | 1 = spaghetti code, 5 = clear architecture + conventions |
| **Documentation** | API docs (OpenAPI), architecture docs, runbooks | 1 = no docs, 5 = auto-generated API docs + architecture docs |

**Key questions to ask:**
- How long does it take a new developer to submit their first PR?
- Can you run the entire system locally without cloud credentials?
- Is there a style guide or do code reviews catch inconsistencies?

---

## Scoring Methodology

### Per-Pillar Scoring

Each pillar is scored 1-5 based on the average of its criteria:

| Score | Label | Meaning |
|-------|-------|---------|
| 1 | **Critical** | Fundamental gaps. Address immediately before building further. |
| 2 | **Needs Work** | Significant gaps. Plan to address in next sprint/milestone. |
| 3 | **Adequate** | Meets minimum bar. Acceptable for MVP, improve for production. |
| 4 | **Good** | Solid implementation. Minor improvements possible. |
| 5 | **Excellent** | Best practices followed. Ready for production scale. |

### Overall Architecture Rating

Average of all 6 pillar scores:

| Overall | Rating | Interpretation |
|---------|--------|---------------|
| 1.0 - 2.0 | **Fragile** | Architecture has critical gaps. Not production-ready. |
| 2.1 - 3.0 | **Developing** | Functional but risky. Acceptable for early MVP with a plan to improve. |
| 3.1 - 3.5 | **Solid** | Good foundation. Typical for well-planned MVP or early startup. |
| 3.6 - 4.0 | **Strong** | Production-quality. Ready for real users and growth. |
| 4.1 - 5.0 | **Exemplary** | Mature architecture. Enterprise-ready. Rare for early-stage products. |

### Stage-Appropriate Expectations

Not every project needs a 5/5 on every pillar. Set expectations by stage:

| Stage | Target Score | Acceptable Lows |
|-------|-------------|----------------|
| **Proof of concept** | 2.0 overall | Security 2, Reliability 1, DevEx 2 |
| **MVP** | 2.5 - 3.0 | Reliability 2, Performance 2 |
| **Early product (paying users)** | 3.0 - 3.5 | Performance 3, Cost 2 |
| **Growth stage** | 3.5 - 4.0 | None below 3 |
| **Production / enterprise** | 4.0+ | None below 4 |

---

## Output Format

**IMPORTANT: Be comprehensive and thorough in all sections.**

### 1. Visual Score Summary (REQUIRED)

Visualize pillar scores as a horizontal bar table:

```
Operational Excellence  ████░  4/5 — Good
Security               ███░░  3/5 — Adequate
Reliability            ██░░░  2/5 — Needs Work
Performance Efficiency ████░  4/5 — Good
Cost Optimization      █████  5/5 — Excellent
Developer Experience   ███░░  3/5 — Adequate

Overall: 3.5/5 — Solid
```

**Score table (also provide as markdown table):**

| Pillar | Score | Label | Key Strength | Critical Gap |
|--------|:-----:|-------|--------------|--------------|
| Operational Excellence | X/5 | [Label] | [1 sentence] | [1 sentence or "None"] |
| Security | X/5 | [Label] | [1 sentence] | [1 sentence or "None"] |
| Reliability | X/5 | [Label] | [1 sentence] | [1 sentence or "None"] |
| Performance Efficiency | X/5 | [Label] | [1 sentence] | [1 sentence or "None"] |
| Cost Optimization | X/5 | [Label] | [1 sentence] | [1 sentence or "None"] |
| Developer Experience | X/5 | [Label] | [1 sentence] | [1 sentence or "None"] |
| **Overall** | **X.X/5** | **[Rating]** | | |

### 2. Per-Pillar Detail (MUST be thorough for each pillar)

**For each of the 6 pillars, provide comprehensive analysis:**

**Format:**

```markdown
## [Pillar Name]: X/5 — [Label]

### Score Breakdown

Evaluated against [number] criteria:

| Criteria | Score | Notes |
|----------|:-----:|-------|
| [Criterion 1] | X/5 | [1 sentence why this score] |
| [Criterion 2] | X/5 | [1 sentence why this score] |
| [Criterion 3] | X/5 | [1 sentence why this score] |
| ... | ... | ... |

**Average: X.X/5 → X/5 ([Label])**

### Strengths (minimum 2-4 bullets)

✅ **[Specific strength]**
   - What: [Describe what's implemented]
   - Why it matters: [Business/technical impact]
   - Reference: [Cite specific architecture decision from manifest]

✅ **[Specific strength]**
   - What: [Describe what's implemented]
   - Why it matters: [Business/technical impact]
   - Reference: [Cite specific architecture decision from manifest]

[Continue for all major strengths...]

### Gaps (minimum 2-4 bullets if score < 5)

⚠️ **[Specific gap]**
   - What's missing: [Describe the missing capability]
   - Risk if not addressed: [Specific risk with impact estimation]
   - Severity: [Critical/High/Medium/Low]

⚠️ **[Specific gap]**
   - What's missing: [Describe the missing capability]
   - Risk if not addressed: [Specific risk with impact estimation]
   - Severity: [Critical/High/Medium/Low]

[Continue for all significant gaps...]

### Recommendations (minimum 3-5 specific actions)

Each recommendation must be:
- **Actionable**: Specific enough to implement immediately
- **Measured**: Include effort estimate and impact level
- **Prioritized**: Show order of implementation

**Format for each recommendation:**

**Recommendation #X: [Short action-oriented title]** — [Impact: High/Medium/Low] — [Effort: X hours/days/weeks]

What to do:
[2-3 sentences describing specific implementation steps]

Why it matters:
[1-2 sentences on business/technical impact]

Implementation notes:
- Tool/service to use: [Specific recommendation]
- Code location: [Where to implement, if applicable]
- Dependencies: [What must be done first]
- Definition of done: [How to verify it's complete]

Cost impact: $[amount]/month or [one-time cost]
Timeline: [When to implement — Pre-launch / Month 1 / Quarter 1 / Future]

**Example full recommendation:**

**Recommendation #1: Implement rate limiting on all API endpoints** — Impact: High — Effort: 4-6 hours

What to do:
Add rate limiting middleware using Vercel's @upstash/ratelimit package. Set default limit of 100 requests per minute per IP, with stricter limits (10 req/min) on authentication endpoints and looser limits (1000 req/min) for authenticated users. Return 429 status with Retry-After header when limit exceeded.

Why it matters:
Without rate limiting, a single malicious user or misconfigured client can overwhelm the API, causing downtime for all users. This is especially critical for authentication endpoints which are common DDoS targets. Rate limiting is a pre-launch requirement for production deployment.

Implementation notes:
- Tool/service to use: @upstash/ratelimit with Vercel KV (free tier: 10K requests/day)
- Code location: src/middleware/rateLimit.ts, apply in src/app/api/*/route.ts
- Dependencies: Set up Vercel KV store (5 minute setup)
- Definition of done: Rate limiting active on all endpoints, returns 429 when exceeded, logged in monitoring

Cost impact: $0/month (Vercel KV free tier sufficient for 10K users)
Timeline: Pre-launch (P0 — blocks production deployment)

### Stage-Appropriate Assessment

This architecture is at: **[Stage name]** stage

Expected score range for this stage: **X.X - Y.Y**
Actual score: **Z.Z**
Assessment: **[Above/At/Below]** expectations for this stage

[If below expectations:]
Critical gaps for this stage:
- [Gap 1 that's unacceptable for current stage]
- [Gap 2 that's unacceptable for current stage]
Must address before [milestone/launch].

[If at/above expectations:]
Well-positioned for [next stage]. Consider improving [pillar names] before scaling to [user count/revenue level].
```

### 3. Improvement Roadmap (minimum 8-12 items)

**Provide comprehensive prioritized roadmap with P0-P3 priority levels:**

| Priority | Pillar | Action | Effort | Impact | Stage | Cost |
|----------|--------|--------|--------|--------|-------|------|
| P0 | Security | Add rate limiting to all API endpoints | 4-6 hours | High | Pre-launch | $0 |
| P0 | Reliability | Implement health checks with dependency verification | 3 hours | High | Pre-launch | $0 |
| P0 | Security | Set up automated dependency scanning in CI | 2 hours | High | Pre-launch | $0 |
| P1 | Operational Excellence | Add structured logging with correlation IDs | 1 day | Medium | Month 1 | $26/mo (Sentry) |
| P1 | Reliability | Set up database backups with tested restore process | 4 hours | High | Month 1 | $0 (included) |
| P1 | Security | Implement secrets rotation for API keys | 2 days | Medium | Month 1 | $0 |
| P2 | Performance | Add Redis caching layer for hot queries | 2-3 days | Medium | Quarter 1 | $7/mo |
| P2 | Operational Excellence | Implement feature flags for gradual rollouts | 1 day | Low | Quarter 1 | $0 (self-hosted) |
| P2 | Developer Experience | Add OpenAPI schema generation for API docs | 1 day | Low | Quarter 1 | $0 |
| P3 | Performance | Implement database query optimization and indexing review | 3-5 days | Medium | Future | $0 |
| P3 | Reliability | Add chaos engineering / failure injection testing | 1 week | Low | Future | $0 |
| P3 | Developer Experience | Set up comprehensive E2E test suite | 1-2 weeks | Medium | Future | $0 |

**Priority Definitions:**
- **P0 (Must-have before launch)**: Blocks production deployment. Critical security, reliability, or operational gaps. Complete in current sprint.
- **P1 (Should-have in first month)**: Important for stability and user trust. Complete within 30 days of launch.
- **P2 (Nice-to-have in first quarter)**: Improves experience and reduces operational burden. Complete within 90 days.
- **P3 (Future enhancement)**: Optimization or nice-to-have. Evaluate after product-market fit.

**Cost Summary:**
- Pre-launch (P0): $X/month + Y hours labor
- Month 1 (P0+P1): $X/month + Y hours labor
- Quarter 1 (P0+P1+P2): $X/month + Y hours labor
- Full roadmap (All): $X/month + Y hours labor

**Timeline Visualization:**

```
Pre-Launch (Week 0):
├─ P0 items (total: X hours)
└─ Must complete before production deployment

Month 1 (Weeks 1-4):
├─ P1 items (total: X hours)
└─ Critical for stability

Quarter 1 (Weeks 5-12):
├─ P2 items (total: X hours)
└─ Improves operational efficiency

Future (Month 4+):
├─ P3 items (total: X hours)
└─ Evaluate based on growth
```

### 4. Quick Wins (REQUIRED if any exist)

**Identify 3-5 high-impact, low-effort improvements that can be done in <1 day each:**

**Format:**

```markdown
Quick Win #X: [Short title] — [Pillar Name]

What: [1-2 sentences on what to implement]
Effort: [X hours]
Impact: [High/Medium impact on pillar score]
How: [3-5 step implementation checklist]
Cost: $[amount or $0]

ROI: [Pillar score improvement: X/5 → Y/5, or specific metric improvement]
```

**Example:**

```markdown
Quick Win #1: Add security headers to API responses — Security

What: Configure Next.js security headers (CSP, X-Frame-Options, HSTS, etc.) in next.config.js to protect against common web vulnerabilities.
Effort: 30 minutes
Impact: High (improves Security pillar from 3/5 to 3.5/5)
How:
1. Add headers configuration to next.config.js
2. Test with securityheaders.com
3. Verify CSP doesn't break any functionality
4. Deploy to staging and production

Cost: $0

ROI: Security pillar: 3/5 → 3.5/5, protects against XSS and clickjacking with minimal effort
```

### 5. Critical Blockers (REQUIRED if any exist)

**If any pillar scores 1/5 or has critical gaps, call them out explicitly:**

```markdown
🚨 CRITICAL BLOCKER: [Issue name]

Pillar: [Name]
Current state: [What's broken or missing]
Risk: [What bad thing will happen]
Probability: [High/Medium/Low chance of occurrence]
Impact: [Severity if it occurs — data loss, security breach, downtime, etc.]

This blocks: [Production launch / Scaling / User trust / Compliance]

Required action: [Specific fix needed]
Effort: [Realistic time estimate]
Must complete by: [Deadline or stage gate]
Owner: [Who should do this — role/skill level]
```

**Example:**

```markdown
🚨 CRITICAL BLOCKER: No database backups configured

Pillar: Reliability
Current state: Supabase project has default backups (daily, 7-day retention) but no tested restore process. No way to recover from accidental data deletion or corruption.
Risk: Single developer mistake (DROP TABLE, bad migration) or Supabase issue could cause permanent data loss for all users.
Probability: Medium (10-15% chance in first year based on industry data)
Impact: Catastrophic — lose all user data, company trust, potential legal liability

This blocks: Production launch with real users

Required action:
1. Enable Supabase point-in-time recovery (PITR) — provides 7-day recovery window
2. Set up daily automated backup export to S3 (in addition to Supabase backups)
3. Document and TEST restore procedure (actually restore a backup to verify it works)
4. Add backup monitoring (alert if backup fails)

Effort: 4-6 hours (2 hours setup + 2 hours testing + 1 hour documentation)
Must complete by: Before production launch (P0)
Owner: Backend developer or DevOps engineer
```

### 6. Scoring Transparency (ALWAYS show)

**Show how the overall score was calculated:**

```
Well-Architected Score Calculation:

Operational Excellence: X/5
Security: X/5
Reliability: X/5
Performance Efficiency: X/5
Cost Optimization: X/5
Developer Experience: X/5
                      ─────
Total: XX/30
Average: XX/30 ÷ 6 = X.XX → X.X/5

Overall Rating: X.X/5 — [Rating Label]
```

**Interpretation based on stage:**

```
Stage: [MVP / Early Product / Growth / Enterprise]
Expected score range: [X.X - Y.Y]
Actual score: [Z.Z]

Assessment: [Above/At/Below] expectations

[If below]: Priority focus areas: [list pillars scoring below stage expectations]
[If at/above]: Continue improving [lowest scoring pillars] while scaling
```

---

## When Evaluating Existing Architectures

When used with `/architect:well-architected` on an existing architecture (not a new blueprint):

1. **Ask about current state** — Don't assume. Ask what's already in place for each pillar.
2. **Be specific** — Reference actual services, endpoints, and tools from the architecture.
3. **Score honestly** — A 3 is not a failure. Most startups are in the 2.5-3.5 range.
4. **Prioritize ruthlessly** — Don't recommend 20 improvements. Pick the top 5 that give the most value.
5. **Match to stage** — An MVP doesn't need the same score as an enterprise product.
