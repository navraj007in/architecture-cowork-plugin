---
description: Generate multiple architecture options based on project constraints (budget, team size, timeline, ops maturity)
---

# /architect:blueprint-variants

Generates 3-5 viable architecture options for a project based on constraints. Instead of a single "one-size-fits-all" blueprint, users see: baseline (recommended), cost-optimized, performance-optimized, and other variants with explicit trade-offs.

## Trigger

```
/architect:blueprint-variants
/architect:blueprint-variants [--count 5]           # show 5 options instead of 3
/architect:blueprint-variants [--baseline-only]     # just show recommended, no variants
/architect:blueprint-variants [--constraints file.json]  # load constraints from JSON
```

## Purpose

Most teams have constraints (budget, team size, timeline, compliance needs). A single blueprint doesn't account for these. Blueprint-variants generates multiple architectures, each showing:
- Cost ($X/month)
- Complexity (1-10 scale)
- Team ramp time (weeks)
- Ops overhead (high/medium/low)
- Risk profile (low/medium/high)
- Key trade-offs vs. baseline

Users can compare, choose what fits their situation, and understand exactly what they gain/lose with each option.

## Input

**Required:** Project context from `/architect:blueprint` output (or provide interactively):
- Project type (web app, API, mobile backend, data pipeline, hybrid)
- Team expertise (startup, growing, mature)
- Primary concern (speed, cost, scale, compliance)

**Optional:** Constraint file (JSON):
```json
{
  "budget_monthly": 5000,
  "team_size": 3,
  "timeline_weeks": 8,
  "ops_maturity": "startup",
  "compliance_required": ["GDPR"],
  "target_users": 10000
}
```

## Output Files

**1. `architecture-output/options-comparison.md`** (always generated)

```markdown
# Architecture Options Comparison

**Generated:** 2026-04-24 14:32:10  
**Project:** my-startup (web app)  
**Constraints:** $5k/month, 3 engineers, 8 weeks, startup ops

---

## Quick Summary

| Option | Cost/mo | Complexity | Team Ramp | Ops Load | Risk | Recommendation |
|--------|---------|-----------|----------|----------|------|---|
| **Baseline** | $4,200 | 6/10 | 3 weeks | Medium | Low | ✅ RECOMMENDED |
| Cost-Optimized | $2,100 | 5/10 | 2 weeks | Low | Medium | Good if budget tight |
| Performance-Optimized | $8,500 | 8/10 | 5 weeks | High | Medium | Good for scale |
| Enterprise-Ready | $12,000 | 9/10 | 6 weeks | Very High | Very Low | For regulated industry |

---

## Option 1: Baseline (RECOMMENDED) ✅

**Cost:** $4,200/month | **Complexity:** 6/10 | **Team Ramp:** 3 weeks | **Ops:** Medium

### Architecture
```
Frontend: Next.js 14 (Vercel)
Backend: Node.js + Express (Railway)
Database: PostgreSQL (Render or Neon)
Auth: Clerk
Cache: Redis (upstash)
CDN: Cloudflare
Monitoring: Datadog free tier
```

### Why Recommended
- **Sweet spot** for your constraints: fits $5k budget, 3 engineers can execute in 8 weeks
- **Industry standard** tech stack (hire easily, lots of docs)
- **Scalable**: can grow to 100k users without rearchitecture
- **Ops manageable**: ~4 hours/week for 3-person team
- **Cost predictable**: no surprises, scales linearly

### Components Generated
- web-app (Next.js frontend, Vercel deploy)
- api-server (Express REST API, Railway deploy)
- database (PostgreSQL, auto-backups)
- worker-service (background jobs, Bull queue)
- auth-service (OAuth integration, Clerk managed)

### Timeline Breakdown
```
Week 1: Scaffold + design system (3 days dev, 2 days design)
Week 2: Core API endpoints (5 services)
Week 3: Frontend components (auth, dashboard, CMS)
Week 4-5: Feature development (2 features, thorough testing)
Week 6: Load testing, monitoring setup, launch prep
Week 7: Buffer for fixes, last-minute features
Week 8: Launch + initial support
```

### Cost Breakdown
```
Compute:
  - Frontend hosting (Vercel): $20/month
  - API hosting (Railway): $1,200/month (2×0.5CPU)
  - Database (Neon): $1,800/month (8GB RAM, auto-scaling)
  - Cache (Upstash Redis): $200/month
  
Services:
  - Auth (Clerk): free tier (sufficient for <50k users)
  - CDN (Cloudflare): $200/month (Pro plan)
  - Monitoring (Datadog): $300/month (free tier + APM)
  - Email (SendGrid): $100/month
  
Third-party:
  - Stripe processing: 2.9% + $0.30 per transaction (variable)
  
Total: ~$4,200/month baseline + variable transaction fees
```

### Team Structure
```
3 engineers:
  - 1 full-stack (frontend + API) — 40 hrs
  - 1 backend (database, scaling, ops) — 40 hrs
  - 1 DevOps/QA (testing, monitoring, deployment) — 40 hrs

Skills needed: Node.js, React, PostgreSQL, Docker, Vercel/Railway
Hire difficulty: Easy (common stack, lots of candidates)
```

### Ops Burden
- **Daily:** Deploy pipeline runs automatically (GitHub Actions), 0 manual intervention
- **Weekly:** Review logs (Datadog), check database size, monitor costs
- **Monthly:** Patch dependencies, review security alerts, capacity planning
- **Total:** ~4 hours/week for team

### Risk Profile: LOW
- ✅ Well-documented (thousands of tutorials)
- ✅ Large community (find help easily)
- ✅ Mature dependencies (stable, security patches regular)
- ✅ Vendor lock-in minimal (switch hosting providers easily)
- ✅ Security standard (no known weaknesses)

### Scalability Path
```
Current: ~1,000 DAU (Daily Active Users) on this config
10k DAU: Add read replicas for database (+$400/month)
100k DAU: Switch to managed Kubernetes (+$2,000/month)
1M+ DAU: Multi-region deployment (+$5,000/month)

No rearchitecture needed — just scale vertically then horizontally
```

### Transition from Baseline
If constraints change:
- **Budget cuts?** → Cost-Optimized option below
- **Need sub-100ms latency?** → Performance-Optimized option
- **Compliance requirements?** → Enterprise-Ready option
- Easy to migrate: all options use same database schema + API contracts

---

## Option 2: Cost-Optimized (-50% budget)

**Cost:** $2,100/month | **Complexity:** 5/10 | **Team Ramp:** 2 weeks | **Ops:** Low

### Tradeoffs vs. Baseline
| Dimension | Baseline | Cost-Optimized | Impact |
|---|---|---|---|
| **Database** | PostgreSQL, 8GB | SQLite + tiered (hot/cold) | Slower analytics queries (5-10s vs. <1s) |
| **Compute** | Railway $1,200 | Deploy to Lambda $300 | Colder starts, less predictable latency |
| **Cache** | Redis $200 | Local in-memory cache | Cache warms slower, single-server limit |
| **CDN** | Cloudflare Pro $200 | Cloudflare free $0 | No advanced DDoS protection, slower edge |
| **Monitoring** | Datadog $300 | CloudWatch $100 | Less detailed alerting, harder debugging |

### When to Choose
- **Bootstrap phase** (MVP, <5k users)
- **Cost is primary constraint** (non-profit, startup at risk)
- **Can tolerate higher latency** (5-10s for background jobs OK)
- **Team can handle DevOps** (more manual setup)

### Not Recommended If
- User-facing latency critical (<500ms required)
- >5k concurrent users
- Compliance needed (HIPAA, SOC 2)
- Scale expected in 6 months

### Cost Breakdown
```
Compute:
  - Frontend (Vercel): $20
  - API (AWS Lambda): $300 (first 1M requests free, then $0.20/1M)
  - Database (SQLite on S3): $50 (storage only, compute local)
  - Cache (in-memory only): $0
  
Services:
  - Auth (Clerk free): $0
  - CDN (Cloudflare free): $0
  - Monitoring (CloudWatch): $100
  - Email (SendGrid free): $0 (limited to 100/day)
  
Total: ~$2,100/month (can be $500/month for <100 requests/day)
```

---

## Option 3: Performance-Optimized (-50ms latency)

**Cost:** $8,500/month | **Complexity:** 8/10 | **Team Ramp:** 5 weeks | **Ops:** High

### Tradeoffs vs. Baseline
| Dimension | Baseline | Performance | Gain | Cost |
|---|---|---|---|---|
| **Latency** | 200-500ms | <50ms | 4-10× faster | +$4,300/mo |
| **Database** | PostgreSQL | DynamoDB + ElastiCache | Single-digit ms queries | +$1,500/mo |
| **Compute** | Railway | Kubernetes + CDN edge | Worldwide <100ms | +$2,000/mo |
| **Caching** | Redis | Multi-region Redis | Cache hits 99%+ | +$800/mo |
| **Complexity** | Moderate | High | Many moving parts | +2 weeks ramp |

### When to Choose
- **Real-time critical** (trading, gaming, live collab)
- **Worldwide users** (need edge caching)
- **High traffic** (100k+ QPS)
- **User retention tied to speed** (e-commerce, SaaS)

### Technology Stack
```
Frontend: Next.js + React Server Components (Vercel Edge)
Backend: Node.js + GraphQL (on Kubernetes)
Database: DynamoDB (auto-scale) + ElastiCache (multi-region)
CDN: Cloudflare + Fastly edge (worldwide)
Monitoring: New Relic + DataDog (full-stack APM)
Queue: SQS (managed, scalable background jobs)
Search: Elasticsearch (sub-100ms full-text search)
```

### Cost Breakdown
```
$8,500/month breakdown:
  - Kubernetes cluster: $2,000
  - DynamoDB auto-scale: $1,500
  - ElastiCache multi-region: $800
  - CDN (Cloudflare + Fastly): $600
  - Elasticsearch: $1,200
  - Monitoring (full-stack): $1,000
  - Other (SQS, SES, S3): $400
```

### Risk: MEDIUM
- ⚠️ Complex deployment (Kubernetes learning curve)
- ⚠️ Cost predictability harder (auto-scaling can spike)
- ⚠️ More services = more operational toil
- ✅ But: less vendor lock-in, industry standard

---

## Option 4: Enterprise-Ready (compliance + scale)

**Cost:** $12,000/month | **Complexity:** 9/10 | **Team Ramp:** 6 weeks | **Ops:** Very High

### For When
- **Compliance required** (HIPAA, SOC 2, FedRAMP)
- **Data sovereignty** (GDPR data residency)
- **Enterprise customers** (need SLAs, uptime guarantees)
- **Security critical** (healthcare, fintech, gov)

### Additions vs. Baseline
```
+ Multi-region failover: $2,000/mo
+ VPC + private databases: $1,500/mo
+ WAF + DDoS protection: $800/mo
+ Compliance monitoring: $1,200/mo (logs, audit trails)
+ Support (enterprise SLA): $2,000/mo
+ Incident response team: $2,500/mo

Total additional: ~$10,000/mo over baseline
```

### Risk: LOW
- Mature, proven architecture
- Professional support included
- Compliance validated
- Not recommended unless actually needed (overkill for most startups)

---

## Comparison Matrix: All Options

```
Metric                 | Baseline | Cost-Opt | Perf-Opt | Enterprise
-----------------------|----------|----------|----------|----------
Cost/month            | $4,200   | $2,100   | $8,500   | $12,000
Complexity (1-10)     | 6        | 5        | 8        | 9
Team ramp (weeks)     | 3        | 2        | 5        | 6
Ops burden (hrs/wk)   | 4        | 6        | 8        | 12
Scalability (DAU)     | 100k     | 10k      | 1M+      | 10M+
Latency (p99)         | 300ms    | 2s       | 50ms     | 10ms
Uptime SLA            | 99.5%    | 99%      | 99.95%   | 99.99%
Compliance ready      | No       | No       | No       | Yes
Risk profile          | LOW      | MEDIUM   | MEDIUM   | LOW
Time to market        | 8 weeks  | 4 weeks  | 10 weeks | 12 weeks
Hire difficulty       | Easy     | Medium   | Hard     | Hard
```

---

## Trade-Off Analysis: Key Decisions

### Baseline vs. Cost-Optimized
**Choose Cost-Optimized if:**
- Budget is hard constraint (can't spend $4.2k/mo)
- MVP phase (prove market fit first)
- Analytics/reporting not critical
- Team comfortable with Lambda/serverless

**Choose Baseline if:**
- Can afford $4.2k/month
- Want predictable costs
- Team prefers traditional stack
- Planning 12+ month roadmap

**Switching cost:** 2-3 weeks, moderate refactor

### Baseline vs. Performance-Optimized
**Choose Performance-Optimized if:**
- Latency is competitive advantage (trading, gaming)
- Users worldwide (need edge caching)
- Willing to spend 2× budget for 4× speed
- Team wants ops challenge

**Choose Baseline if:**
- 200-500ms latency acceptable
- Budget is constraint
- Team is small (Kubernetes complex)
- Can add Performance-Opt later if needed

**Switching cost:** 4-6 weeks, significant refactor, database strategy change

### Any Option vs. Enterprise-Ready
**Choose Enterprise if:**
- Legal/compliance requirement (not optional)
- Customers demand SLAs
- Data handling highly regulated
- Funding supports it

**All others:** Start with Baseline, migrate to Enterprise only if needed

---

## How to Choose

**Decision tree:**
```
1. What's your constraint?
   a) Budget → Cost-Optimized
   b) Speed → Performance-Optimized
   c) Compliance → Enterprise-Ready
   d) Balanced → Baseline (MOST TEAMS HERE)

2. Verify timeline
   Baseline: 8 weeks → on track?
   Performance: 10 weeks → 2 week buffer?
   Enterprise: 12 weeks → time available?

3. Verify team
   Baseline: 3 full-stack OK?
   Performance: Need DevOps expert?
   Enterprise: Need compliance/security lead?

4. Reality-check costs
   Can you afford ongoing monthly spend?
   Can you scale if revenue comes?
   What if costs 2× than expected?

→ Pick option that answers YES to all
```

---

## Next Steps After Choosing

1. **If Baseline chosen:**
   - Run `/architect:scaffold` to generate project
   - Estimated time: 45 minutes
   - Next: implement features

2. **If Cost-Optimized chosen:**
   - Run `/architect:scaffold --template cost-optimized`
   - May need to adjust: database strategy, monitoring, caching
   - Estimated time: 2 weeks development (slower due to serverless learning curve)

3. **If Performance-Optimized chosen:**
   - Run `/architect:scaffold --template performance-optimized`
   - Will need: Kubernetes knowledge, GraphQL experience, cache strategies
   - Estimated time: 10 weeks (requires most careful planning)

4. **If Enterprise-Ready chosen:**
   - Consult compliance framework (HIPAA, GDPR, SOC 2)
   - Run `/architect:scaffold --template enterprise`
   - Coordinate with security/legal teams
   - Estimated time: 12 weeks

---

## Changing Options Later

**Easy to switch:** Cost-Optimized ↔ Baseline (database schema same, just scale horizontally)

**Medium effort:** Baseline ↔ Performance-Optimized (need to adopt DynamoDB, change caching strategy, ~4-6 weeks)

**Hard to switch:** To/from Enterprise (compliance strategies embedded, data handling different, 6-8 weeks)

**Recommendation:** Start with Baseline unless constraints force otherwise. Scale up to Performance or down to Cost-Optimized as needs change.

---

## Behavior

### Step 1: Load constraints
- If provided via JSON flag: read file
- If not provided: ask user interactively:
  - Budget per month? ($X)
  - Team size? (N engineers)
  - Timeline? (weeks to launch)
  - Ops maturity? (startup|growing|mature)
  - Primary concern? (cost|speed|compliance|balanced)

### Step 2: Detect baseline blueprint
- If exists: use current blueprint as baseline
- If not: run `/architect:blueprint` first

### Step 3: Generate variants
For each variant type (cost, performance, enterprise):
- Start from baseline blueprint
- Apply modifications:
  - Change tech stack components
  - Adjust deployment strategy
  - Modify infrastructure
  - Update team structure
  - Recalculate costs and complexity

### Step 4: Calculate trade-offs
For each option vs. baseline:
- Cost delta
- Complexity delta
- Latency impact
- Ops burden impact
- Risk profile
- Scalability limits
- Timeline impact

### Step 5: Generate report
Output: `options-comparison.md` with:
- Quick summary table
- Detailed breakdown for each option
- Trade-off matrix
- Decision tree for choosing
- Next steps for each option

### Step 6: Update activity log
```json
{"ts":"...","phase":"blueprint-variants","outcome":"success","options_generated":4,"chosen_option":"baseline","summary":"Generated 4 options: baseline, cost-optimized, performance-optimized, enterprise-ready"}
```

---

## Flags

### `--count N`
Generate N options instead of default 3. Max 5.

### `--baseline-only`
Skip variants, show only recommended baseline option.

### `--constraints file.json`
Load constraints from JSON file instead of interactive input.

### `--compare-to baseline|cost|perf|enterprise`
Show detailed comparison vs. specific option.

---

## Related Commands

- `/architect:blueprint` — original single architecture blueprint
- `/architect:cost-estimate` — detailed cost breakdown (used by variants)
- `/architect:scaffold` — generate code for chosen option
- `/architect:trade-off-analysis` — deep dive on specific option pairs
- `/architect:technology-selector` — help choose specific tools within option
