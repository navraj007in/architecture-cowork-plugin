# Cost What-If Simulator Skill

Shows cost and performance impact of "what if" infrastructure changes. Helps users understand trade-offs before committing to changes.

## When to Use

Use this skill to answer questions like:
- "What if we use spot instances instead of on-demand?"
- "What if we upgrade to 32GB database?"
- "What if we add a CDN?"
- "What if we cut monitoring to save money?"
- "What if we support 2× more users?"

## Input

Provide current infrastructure + proposed change:

```json
{
  "current_config": {
    "backend_compute": "Railway Standard (2 vCPU, 1GB RAM)",
    "database": "PostgreSQL 16GB",
    "cache": "Redis 1GB",
    "cdn": "Cloudflare",
    "monitoring": "Datadog Standard",
    "dau": 100000
  },
  "proposed_change": {
    "change": "downgrade_database",
    "from": "PostgreSQL 16GB",
    "to": "PostgreSQL 8GB"
  }
}
```

## Output

A detailed what-if analysis:

```json
{
  "proposed_change": "Downgrade database: 16GB → 8GB",
  "cost_impact": {
    "monthly_savings": 600,
    "annual_savings": 7200,
    "percent_change": "-33%"
  },
  "performance_impact": {
    "query_latency": {
      "current_p50": "5ms",
      "current_p99": "50ms",
      "projected_p50": "10ms",
      "projected_p99": "200ms",
      "change": "+4× slowdown on p99"
    },
    "concurrent_connections": {
      "current": 500,
      "projected": 250,
      "headroom_reduced": true
    },
    "memory_usage": {
      "current": "14GB used (88%)",
      "projected": "14GB used (175% — OVER CAPACITY)",
      "warning": "Database will run out of memory!"
    }
  },
  "risk_assessment": {
    "feasibility": "NOT RECOMMENDED",
    "risk_level": "HIGH",
    "issues": [
      "Database already using 14GB. Downgrading to 8GB means over-capacity.",
      "Queries will slow 4-10× as more goes to disk instead of memory.",
      "User experience degrades noticeably (1+ second response times)."
    ],
    "break_probability": "80% (likely causes incidents)"
  },
  "alternative_suggestions": [
    "Optimize queries instead (same performance, no cost increase)",
    "Add read replicas ($500/mo) to distribute load",
    "Keep current size, optimize application code (no cost increase)"
  ],
  "recommendation": "❌ DO NOT make this change. Find alternative optimizations."
}
```

## What-If Categories

### 1. Cost-Cutting Changes

**What-ifs:**
- Downgrade database tier
- Remove caching layer
- Reduce monitoring verbosity
- Cut log retention
- Downgrade compute

**Analysis:**
- Direct cost savings: -$X/month
- Performance impact: +Y ms latency
- Risk: Break probability assessment

**Example findings:**
```
"Reduce from 16GB to 8GB database"
→ Saves $600/mo
→ But p99 latency increases from 50ms to 200ms
→ Memory over-capacity (break risk: 80%)
→ Recommendation: ❌ DO NOT

"Cut log retention from 90 to 30 days"
→ Saves $300/mo
→ No performance impact
→ Can archive to S3 for compliance
→ Recommendation: ✅ SAFE
```

### 2. Performance/Scale Changes

**What-ifs:**
- Add caching layer
- Upgrade compute
- Add CDN
- Upgrade database
- Add read replicas

**Analysis:**
- Cost increase: +$X/month
- Performance gain: -Y ms latency (faster)
- Scalability gain: support Z× more users

**Example findings:**
```
"Add Redis cache layer"
→ Cost: +$200/mo
→ Performance: p99 latency 200ms → 50ms (4× faster)
→ Scalability: can handle 500k DAU instead of 100k
→ Recommendation: ✅ GOOD IF you have cache expertise
```

### 3. Scale-for-Growth Changes

**What-ifs:**
- What if traffic doubles?
- What if we hit 10M DAU?
- What if we expand to 3 regions?

**Analysis:**
- Cost multiplier: current → projected
- Performance impact: stay same, degrade, improve?
- Rearchitecture needed?

**Example findings:**
```
"Current setup: 100k DAU on $8.5k/mo"

"If traffic 2× (200k DAU)"
→ Cost: $8.5k → $12k (+$3.5k/mo)
→ Performance: stays same (most things scale linearly)
→ Rearchitecture needed: No

"If traffic 10× (1M DAU)"
→ Cost: $8.5k → $35k (+$26.5k/mo)
→ Performance: degrades without architecture change
→ Rearchitecture needed: Yes (add multi-region, sharding)
```

### 4. Architecture Changes

**What-ifs:**
- Switch from monolith to microservices
- Add Kubernetes vs. managed platforms
- Use serverless (Lambda) instead of VMs

**Analysis:**
- Cost change: +/- $X/month
- Complexity change: +/- operational load
- Performance change: usually improves latency, worse cold-start

**Example findings:**
```
"Switch from Vercel to Kubernetes"
→ Cost: $3.5k/mo → $5k/mo (33% increase)
→ Complexity: from simple to high (DevOps needed)
→ Performance: similar latency, but more control
→ Recommendation: ❌ NOT worth it (added cost + complexity for no gain)

"Switch from Vercel to Lambda + RDS"
→ Cost: $3.5k/mo → $2k/mo (43% savings)
→ Complexity: from simple to moderate (serverless learning curve)
→ Cold starts: 200ms cold (not ideal for user-facing)
→ Recommendation: ✅ GOOD for backend APIs, not user-facing
```

## Accuracy Levels

### Level 1: Estimate (quick, ±30% accuracy)
```
"Roughly, database downgrade saves $X"
"Roughly, performance degrades by Y%"
```
Fast, for quick decisions.

### Level 2: Calculated (medium, ±10% accuracy)
```
Uses current metrics (memory usage, query patterns, traffic).
More accurate but requires data collection.
```
Good for important decisions.

### Level 3: Modeled (high, ±5% accuracy)
```
Simulation based on historical data.
Requires 1-2 weeks of production baseline.
```
For critical decisions (major rearchitecture).

## Simulation Algorithm

```
for each proposed_change:
  1. Calculate direct cost impact (easier)
     cost_delta = new_cost - current_cost

  2. Estimate performance impact (harder)
     latency_delta = estimate_latency_change(change_type)
     Examples:
     - Database tier down: latency increases ~4× per tier
     - Add cache: latency decreases ~10× (cache hits)
     - Add CDN: latency depends on user location (geographic)

  3. Assess breaking risk (hardest)
     if over_capacity(change):
       risk = "HIGH (will break)"
     elif has_safety_margin(change):
       risk = "LOW (safe)"
     else:
       risk = "MEDIUM (marginal)"

  4. Calculate break probability
     if under_capacity_by_more_than_50%:
       break_prob = 5% (very safe)
     elif under_capacity_by_more_than_20%:
       break_prob = 20% (safe)
     elif under_capacity_by_5-20%:
       break_prob = 50% (risky)
     elif over_capacity:
       break_prob = 80-90% (will break)

  5. Generate recommendation
     if break_prob > 50%:
       "❌ DO NOT — high break risk"
     elif cost_saves > 30% AND break_prob < 20%:
       "✅ SAFE — go for it"
     elif cost_saves < 10% AND risk_high:
       "❌ NOT WORTH IT — small savings, big risk"
     elif cost_saves > 20% AND break_prob 20-50%:
       "⚠️ RISKY — only if desperate"
     else:
       "✅ GOOD — reasonable trade-off"
```

## Real-World What-If Examples

### Example 1: Cost Cutting (Database Downgrade)
```
Current: PostgreSQL 16GB ($1,200/mo), 14GB used, p99 latency 50ms
Proposed: PostgreSQL 8GB ($600/mo)

Analysis:
- Cost savings: $600/mo ✅
- Memory usage: 14GB → 8GB (over capacity by 75%)
- Performance: p99 latency 50ms → 200ms (4× slower)
- Break probability: 80%

Recommendation: ❌ DO NOT
Reason: Already using 14GB, database will be over-capacity
Alternative: Optimize queries (no cost), add caching (low cost)
```

### Example 2: Performance Investment (Add Cache)
```
Current: No caching, Redis $0, p99 latency 200ms
Proposed: Add Redis 2GB ($200/mo)

Analysis:
- Cost increase: +$200/mo (2.3% of budget)
- Latency improvement: 200ms → 50ms (4× faster)
- Cache hit rate: Estimated 85% (typical for user-heavy apps)
- Break probability: 0% (redis failure can fallback to DB)
- Scalability: Supports 500k DAU instead of 100k

Recommendation: ✅ SAFE
Why: Low cost, high benefit, safe fallback, improves UX
```

### Example 3: Scale Projection (Traffic 10×)
```
Current: 100k DAU on $8.5k/mo, p99 latency 200ms
Proposed: Scale to 1M DAU (10× growth)

Analysis:
Linear scaling:
- Cost: $8.5k × 10 = $85k/mo
- Latency: stays same with more capacity
- Feasibility: Simple architecture scales linearly

Non-linear (architecture hits limits):
- Max single database: ~500k queries/sec
- At 1M DAU: Need sharding (write to multiple DBs)
- Cost after sharding: ~$50k/mo (not 10×, better scaling)
- Latency: Slightly higher (routing, eventual consistency)

Recommendation: ⚠️ POSSIBLE but rearchitecture needed
Why: Current stack hits limits at ~300k DAU
When to plan: Start sharding strategy at 200k DAU
```

### Example 4: Architecture Change (Monolith to Microservices)
```
Current: Monolith on Railway, $3.5k/mo, 3 engineers
Proposed: Microservices on Kubernetes

Analysis:
Costs:
- Current: $3.5k/mo (compute + database)
- Microservices: $6k/mo (more compute, message queues, observability)
- Cost increase: +71%

Operational burden:
- Current: Junior can manage (Vercel is simple)
- Microservices: Requires DevOps specialist ($100k/year salary)
- Real cost increase: $6k/mo + $8.3k/mo (salary) = $14.3k/mo

Recommendation: ❌ NOT WORTH IT
Why: Cost increases 4×, complexity increases 5×, no performance gain
When to consider: Only if hitting 500k+ DAU limits of monolith
```

## Usage in Commands

### In `/architect:optimize-costs`

```pseudo
// When suggesting cost cuts:
for each cost_reduction_option:
  simulation = whatif_simulator(current, option)
  if simulation.break_probability > 50%:
    flag as risky
    show: "This might cause outages"
  else if simulation.break_probability < 20%:
    flag as safe
    show: "Safe to implement"
```

### New command: `/architect:simulate-change`

```
/architect:simulate-change --change "downgrade_database" --from "16GB" --to "8GB"
→ Detailed what-if analysis

/architect:simulate-change --change "add_cache" --cache-size "2GB"
→ Performance and cost impact
```

### In `/architect:cost-estimate`

```pseudo
// When estimating at higher scale:
simulate_scale(current_config, target_dau)
→ Show cost at 2×, 5×, 10× scale
→ Flag when rearchitecture needed
```

## Limitations

**Accuracy limits:**
- Assumes linear scaling (doesn't account for O(n²) queries)
- Doesn't model cascade failures
- Assumes cache-hit rates based on typical patterns
- Geographic distribution complexities simplified

**When simulations are unreliable:**
- Very large changes (10× scale needs actual modeling)
- Novel architectures (we have less historical data)
- Multi-region complexity (many geographic variables)

**Recommendation:** For major decisions, validate with actual testing/measurement.

## Related Skills

- `cost-optimizer/` — finds optimization opportunities
- `constraint-solver/` — identifies cost constraints
- `tradeoff-analysis/` — helps weigh trade-offs
- `continuous-cost-monitor/` — tracks actual vs. estimated (Phase 3.3)
