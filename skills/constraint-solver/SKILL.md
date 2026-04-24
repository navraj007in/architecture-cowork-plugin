# Constraint Solver Skill

Maps project constraints (budget, team size, timeline, ops maturity, compliance) to architecture decisions. Used by `/architect:blueprint-variants` and `/architect:recommend-stack` to generate informed options.

## When to Use

Invoke this skill to:
1. **Understand constraint implications** — what does $2k/mo budget mean for tech choices?
2. **Find feasible options** — which architectures fit these constraints?
3. **Identify constraint conflicts** — can we really do enterprise-ready in 4 weeks with 1 engineer?
4. **Suggest trade-offs** — to hit budget, what do we sacrifice (speed, scale, compliance)?

## Input

Provide 5 constraint dimensions:

```json
{
  "budget_monthly": 5000,           // dollars/month
  "team_size": 3,                   // engineers
  "timeline_weeks": 8,              // weeks to launch
  "ops_maturity": "startup",        // startup | growing | mature
  "compliance_required": ["GDPR"],  // [] | HIPAA | SOC2 | GDPR | FedRAMP | etc.
  "target_users": 10000,            // expected DAU at launch
  "latency_requirement_ms": 500     // p99 latency target (optional)
}
```

## Output

A feasibility analysis object:

```json
{
  "constraints": { ... },
  "feasibility": {
    "overall_score": 0.85,    // 0-1.0: can achieve these constraints?
    "critical_constraints": [  // hard limits
      "budget_monthly: $5000 limits database choice (max PostgreSQL + Redis)"
    ],
    "flexible_constraints": [  // trade-off opportunities
      "timeline_weeks: 8 is tight but achievable with baseline tech stack"
    ]
  },
  "implied_architecture": {
    "deployment": "managed (Vercel, Railway)",
    "database": "PostgreSQL managed (Render, Neon, AWS RDS)",
    "cache": "Redis managed (Upstash)",
    "monitoring": "basic (Datadog free, CloudWatch)"
  },
  "option_variants": [
    {
      "name": "baseline",
      "matches_constraints": true,
      "fit_score": 0.92,
      "cost": 4200,
      "timeline_weeks": 8,
      "ops_burden_hrs_per_week": 4
    },
    {
      "name": "cost-optimized",
      "matches_constraints": true,
      "fit_score": 0.78,
      "cost": 2100,
      "timeline_weeks": 6,
      "ops_burden_hrs_per_week": 8,
      "trade_offs": ["higher latency (2s vs 300ms)", "less predictable costs", "more manual devops"]
    }
  ],
  "constraint_conflicts": [
    {
      "constraints": ["ops_maturity: startup", "compliance_required: HIPAA"],
      "conflict": "HIPAA requires enterprise ops (logging, audit trails, multi-region); startup ops maturity can't support this",
      "resolution": "hire compliance/ops expert OR relax to SOC 2 instead"
    }
  ],
  "recommendations": [
    "Budget is your primary constraint. Baseline at $4.2k/mo fits.",
    "Team of 3 can execute in 8 weeks with standard tech stack.",
    "No compliance constraints = simplifies architecture significantly.",
    "Choose Baseline option."
  ]
}
```

## Constraint Dimensions

### 1. Budget (monthly operating cost)

**Typical ranges:**
- **$0-500/mo** — MVP/hobby (free tiers, shared hosting, 1 engineer part-time)
- **$500-2k/mo** — Early-stage startup (<5k DAU, single region, basic monitoring)
- **$2-5k/mo** — Growing startup (<100k DAU, multi-region, production monitoring)
- **$5-20k/mo** — Series A/B startup (>100k DAU, enterprise customers)
- **$20k+/mo** — Scale-up/enterprise (millions DAU, global, high availability)

**Implications:**
```
$500/mo → use Lambda + SQLite + free monitoring
$2k/mo → managed services (Railway, Render, Neon)
$5k/mo → Kubernetes becomes viable + enterprise services
$20k/mo → multi-cloud, disaster recovery, 24/7 support
```

**Constraint mapping:**
- Database choice constrained by storage $/GB
- Compute choice constrained by $/CPU-hour
- Monitoring tool choice (free vs. paid tier)
- Team structure (do you hire DevOps or use managed services?)

### 2. Team Size (engineers available)

**Typical team capabilities:**
- **1 engineer** — MVP only (no DevOps complexity, use fully managed services)
- **2-3 engineers** — Startup baseline (full-stack + DevOps, moderate complexity)
- **4-6 engineers** — Can handle Kubernetes, microservices
- **10+ engineers** — Complex systems, domain specialization possible

**Implications:**
```
1 engineer: Keep it simple. Managed services only. No self-hosted databases.
2 engineers: Full-stack + DevOps split. Can manage 1-2 open-source tools.
3 engineers: Can run Kubernetes cluster, multiple services, complex monitoring.
5+ engineers: Can build internal platforms, custom tooling, research new tech.
```

**Constraint mapping:**
- Team size → max complexity allowed (Kubernetes needs expertise)
- Team size → hiring timeline (need compliance expert? security lead?)
- Team size → ops burden (one engineer can handle 4 hrs/week ops only)
- Team size → feature velocity (N engineers = N feature streams typical)

### 3. Timeline (weeks to launch)

**Typical development timelines:**
- **2-4 weeks** — MVP (sketch → scaffold → quick implement → launch)
- **4-8 weeks** — Beta (full feature set, basic testing, launch ready)
- **8-12 weeks** — Production launch (tests, monitoring, compliance checks)
- **12+ weeks** — Enterprise launch (security audit, redundancy, disaster recovery)

**Implications:**
```
4 weeks → no time for learning. Use familiar tech only.
8 weeks → baseline timeline for standard stack. Acceptable learning curve.
12 weeks → can onboard new tools, patterns. More experimental stack OK.
16+ weeks → time for complex setup (Kubernetes, multi-region, enterprise hardening).
```

**Constraint mapping:**
- Timeline → learning budget (do you have time to learn new tool?)
- Timeline → complexity ceiling (Kubernetes adds 4 weeks minimum)
- Timeline → risk tolerance (proven stack safer than cutting-edge)
- Timeline → team ramp (need experienced architects for tight timelines)

### 4. Ops Maturity (team's operational capability)

**Levels:**
- **Startup** (Level 1): No ops experience, need fully managed services
- **Growing** (Level 2): Can manage some self-hosted, familiar with containers
- **Mature** (Level 3): Run Kubernetes in production, multi-region failover, custom dashboards

**Implications:**
```
Startup: Vercel, Railway, managed databases. Zero self-hosted complexity.
Growing: Some self-hosted (Postgres on own server), but with backups/monitoring.
Mature: Kubernetes, custom infra, complex observability.
```

**Constraint mapping:**
- Ops maturity → deployment tool choice (Vercel vs. Kubernetes vs. Lambda)
- Ops maturity → monitoring depth (free tier vs. enterprise APM)
- Ops maturity → incident response capability (DIY debugging vs. on-call rotation)
- Ops maturity → hiring needs (need DevOps engineer?)

### 5. Compliance Required (regulatory frameworks)

**Common frameworks:**
- **None** — Standard web app (no regulation)
- **GDPR** — EU user data handling (data residency, consent, retention)
- **SOC 2** — Trust/security for enterprise customers (logging, access controls)
- **HIPAA** — Healthcare data (encryption, audit logs, multi-region disaster recovery)
- **FedRAMP** — US federal government (extremely strict, expensive)
- **PCI-DSS** — Payment card data (encryption, PCI-certified infrastructure)

**Implications:**
```
None → standard architecture, any tech stack OK
GDPR → ensure EU data residency, consent flows, no forbidden locations
SOC 2 → add audit logging, role-based access control, annual audit ($20k)
HIPAA → encryption everywhere, multi-region, full audit trail, major cost jump (+$5k/mo)
FedRAMP → government datacenters required, enterprise consulting, $100k+ implementation
```

**Constraint mapping:**
- Compliance → hosting location (EU for GDPR, US for FedRAMP)
- Compliance → team expertise needed (compliance officer? security lead?)
- Compliance → cost overhead ($1-10k+ for compliance auditing, tools, consultants)
- Compliance → ops complexity (audit logging, retention policies, access controls)

## Constraint Conflict Detection

Some constraints conflict and can't be satisfied together:

### Conflict: Cheap + Compliant
```
Constraints: budget_monthly: 2000, compliance_required: HIPAA
Problem: HIPAA requires multi-region, 99.99% uptime, 24/7 monitoring
  → Costs minimum $15k/mo, but budget is $2k/mo
Resolution:
  Option A: Increase budget to $15k+/mo
  Option B: Relax compliance to SOC 2 instead (~$5k/mo)
  Option C: Launch without compliance, add later when revenue comes
```

### Conflict: Fast Timeline + Complex Ops Maturity
```
Constraints: timeline_weeks: 4, ops_maturity: startup
Problem: Startup ops can only use managed services (simple). Takes 4 weeks just to learn tooling.
Resolution:
  Option A: Extend timeline to 8 weeks
  Option B: Hire experienced ops person (2-week lead time)
  Option C: Use even simpler stack (just Vercel + Firebase)
```

### Conflict: Small Team + Enterprise Complexity
```
Constraints: team_size: 1, compliance_required: HIPAA, timeline_weeks: 8
Problem: 1 engineer can't implement, test, AND audit for HIPAA. Need 3-4 people.
Resolution:
  Option A: Hire additional team members
  Option B: Outsource compliance audit ($5k)
  Option C: Launch without HIPAA, add compliance after MVP
```

## Feasibility Scoring

Calculate 0-1.0 feasibility score for constraint set:

```
feasibility = 0.0

// Can we actually afford this?
if budget >= calculated_cost:
  feasibility += 0.3
elif budget >= calculated_cost * 0.8:  // close enough
  feasibility += 0.2
else:
  flag: "BUDGET INFEASIBLE: need ${amount} more/month"

// Is team large enough?
if team_size >= required_team_size:
  feasibility += 0.2
elif team_size >= required_team_size - 1:  // close
  feasibility += 0.1
else:
  flag: "TEAM UNDERSIZED: need ${count} more engineers"

// Is timeline achievable?
if timeline_weeks >= required_weeks:
  feasibility += 0.2
elif timeline_weeks >= required_weeks * 0.8:
  feasibility += 0.1
else:
  flag: "TIMELINE INFEASIBLE: need ${weeks} more weeks"

// Can ops maturity handle this?
if ops_maturity_level >= required_level:
  feasibility += 0.15
elif ops_maturity_level >= required_level - 1:
  feasibility += 0.075
else:
  flag: "OPS MATURITY INSUFFICIENT: hire or use managed services"

// Are compliance requirements supported?
if compliance_frameworks <= team_expertise:
  feasibility += 0.15
else:
  flag: "COMPLIANCE EXPERTISE LACKING: hire compliance lead"

return min(feasibility, 1.0)
```

**Interpretation:**
- **0.9-1.0:** All green, achievable with current constraints
- **0.7-0.9:** Feasible with one minor adjustment (e.g., extend timeline by 2 weeks)
- **0.5-0.7:** Possible but tight; identify which constraint to relax
- **<0.5:** Not feasible as-is; need to change multiple constraints

## Option Variant Scoring

For each variant (baseline, cost-optimized, etc.), score fit to constraints:

```
fit_score = 0.0

// Does cost fit budget?
cost_fit = 1.0 - min(1.0, (variant_cost - budget) / budget)
fit_score += cost_fit * 0.25

// Does timeline fit?
timeline_fit = 1.0 - min(1.0, (variant_weeks - timeline_weeks) / timeline_weeks)
fit_score += timeline_fit * 0.25

// Does ops maturity fit?
ops_fit = variant_ops_level <= user_ops_maturity ? 1.0 : 0.5
fit_score += ops_fit * 0.25

// Does it support compliance?
compliance_fit = variant_supports_compliance ? 1.0 : 0.0
fit_score += compliance_fit * 0.25

return fit_score
```

**Example:** 
- Baseline: cost_fit 0.8, timeline_fit 1.0, ops_fit 1.0, compliance_fit 0.8 → fit_score 0.90
- Cost-Optimized: cost_fit 1.0, timeline_fit 1.0, ops_fit 0.5, compliance_fit 1.0 → fit_score 0.88
- Enterprise: cost_fit 0.0, timeline_fit 0.7, ops_fit 1.0, compliance_fit 1.0 → fit_score 0.68

Winner: Baseline (0.90 > 0.88 > 0.68)

## Usage in Commands

### In `/architect:blueprint-variants`

```pseudo
1. Load or ask for constraints
2. Call constraint-solver(constraints)
3. If feasibility < 0.7:
   - Show conflicts and suggested changes
   - Ask user to adjust constraint
   - Recalculate
4. If feasibility >= 0.7:
   - Generate all variants
   - Score each against constraints
   - Rank by fit_score
   - Recommend highest-scoring variant
```

### In `/architect:recommend-stack`

```pseudo
1. Load constraints
2. For each possible tech stack:
   - Calculate cost, complexity, ops burden
   - Score fit to constraints
3. Return top 3 stacks ranked by fit_score
4. Show trade-offs of switching stacks
```

### In `/architect:cost-estimate`

```pseudo
1. Load constraints (especially budget, timeline)
2. Estimate costs based on constraint targets
3. If estimated cost > budget:
   - Suggest cost-optimized variant
   - Show what gets cut (latency, scale, features)
```

## Real-World Examples

### Example 1: Startup MVP
```json
{
  "budget_monthly": 2000,
  "team_size": 2,
  "timeline_weeks": 6,
  "ops_maturity": "startup",
  "compliance_required": []
}
```

**Solver output:**
- Feasibility: 0.92 ✅
- Recommended: Cost-Optimized option
- Cost: $2,100/mo (fits budget)
- Timeline: 6 weeks (fits)
- Team: 2 engineers OK for simple stack
- Implications: Use Vercel + Lambda + managed database, no Kubernetes

### Example 2: Growing SaaS
```json
{
  "budget_monthly": 8000,
  "team_size": 4,
  "timeline_weeks": 12,
  "ops_maturity": "growing",
  "compliance_required": ["SOC2"]
}
```

**Solver output:**
- Feasibility: 0.88 ✅
- Recommended: Baseline option
- Cost: $6,500/mo (fits within budget with buffer)
- Timeline: 10 weeks (fits with 2-week buffer)
- Team: 4 engineers sufficient for moderate complexity
- Compliance: Add SOC 2 audit trail (+$1k/mo) — budget has room
- Implications: Managed Kubernetes on AWS/GCP, enterprise monitoring

### Example 3: Healthcare Startup (Impossible)
```json
{
  "budget_monthly": 3000,
  "team_size": 1,
  "timeline_weeks": 4,
  "ops_maturity": "startup",
  "compliance_required": ["HIPAA"]
}
```

**Solver output:**
- Feasibility: 0.15 ❌ NOT FEASIBLE
- Critical conflicts:
  - HIPAA minimum cost: $15k/mo (budget: $3k) — $12k/mo gap
  - HIPAA minimum team: 4 engineers (have: 1) — need 3 more
  - HIPAA minimum timeline: 16 weeks (have: 4) — need 12 more weeks
- Recommendations:
  - Option A: Increase budget to $15k+/mo, hire team, extend timeline to 16 weeks
  - Option B: Launch without healthcare data, add compliance later
  - Option C: Use HIPAA-certified third-party (AWS healthcare) for $8k/mo base

## Related Skills

- `blueprint-variants/` — generates options based on constraint analysis
- `tech-stack-recommender/` — picks specific tools fitting constraints
- `cost-optimizer/` — helps reduce costs while maintaining quality
