---
description: Find cost savings in infrastructure without sacrificing quality or performance
---

# /architect:optimize-costs

Analyzes current infrastructure costs and recommends 5-10 savings opportunities. For each saving, shows: monthly savings, trade-off, effort to implement, and ROI.

Instead of "cut costs anywhere", users get: "Here are 8 ways to save $3k/month. Ranked by savings. Pick which you're comfortable with."

## Trigger

```
/architect:optimize-costs
/architect:optimize-costs [--target-monthly 3000]     # hit specific budget
/architect:optimize-costs [--target-percent -20]      # reduce costs by 20%
/architect:optimize-costs [--exclude database]        # don't touch certain services
/architect:optimize-costs [--show-all]                # show all 20+ possible optimizations
```

## Purpose

Infrastructure costs creep upward:
- Database grows, per-query cost increases
- Traffic spikes, compute needs double
- Monitoring gets more verbose (logs cost more)
- You suddenly realize you're paying $15k/month

**This command stops the creep.** It finds low-hanging fruit ($500-5k/month savings) without hurting product.

## Input

**Required:** Current cost estimate or actual spend

```json
{
  "current_monthly_cost": 8500,
  "target_monthly_cost": 5500,      // optional: hit this budget
  "current_dau": 100000,            // expected users
  "scaling_plan_months": 6,         // when expect to double users?
  "can_sacrifice": {
    "latency": false,               // can we be slower?
    "uptime": false,                // can we have more downtime?
    "features": false,              // can we cut features?
    "scale": true                   // can we handle less traffic?
  }
}
```

## Output

**1. `architecture-output/cost-optimization-plan.md`**

```markdown
# Cost Optimization Plan

**Current monthly:** $8,500  
**Target:** $5,500 (save $3,000/month = -35%)  
**Annual savings:** $36,000  
**Effort:** 2 weeks implementation

---

## Quick Summary: Top 8 Savings

| Savings | Monthly | Annual | Effort | Trade-off | Implement |
|---------|---------|--------|--------|-----------|-----------|
| 1. Downgrade DB tier | -$1,200 | -$14.4k | 2 days | Slower queries 1-2s | ✅ Easy |
| 2. Add caching layer | -$800 | -$9.6k | 1 week | Cache invalidation bugs | ⚠️ Medium |
| 3. Use spot instances | -$600 | -$7.2k | 3 days | 2-5min interruptions | ✅ Easy |
| 4. Reduce log retention | -$300 | -$3.6k | 1 day | Can't debug 30+ days old | ✅ Easy |
| 5. Compress asset delivery | -$200 | -$2.4k | 3 days | Minor build slowdown | ✅ Easy |
| 6. Upgrade to annual plans | -$400 | -$4.8k | 0 days | Less flexibility | ✅ Free |
| 7. Remove unused monitoring | -$150 | -$1.8k | 2 days | Blind spots in dashboards | ✅ Easy |
| 8. Right-size compute instances | -$350 | -$4.2k | 1 week | Tight CPU margins | ⚠️ Medium |

**Total savings if all implemented: -$3,600/month (-42%)**  
**Recommended subset (easy + medium): -$3,000/month (-35%)**

---

## Saving #1: Downgrade Database Tier (-$1,200/month)

**Current:** PostgreSQL 32GB RAM, 16 vCPU ($1,800/mo on Render or AWS RDS)  
**Optimized:** PostgreSQL 16GB RAM, 8 vCPU ($600/mo)

**Trade-off:**
- ⚠️ Query performance: 20-50ms → 100-300ms (for slow queries)
- ⚠️ Concurrent connections: 500 → 200 (less headroom)
- ✅ Still handles 100k DAU (just with slower response on heavy queries)

**When safe:**
- ✅ Your queries already optimized (use indexes, avoid N+1)
- ✅ Not memory-bound (don't cache 10GB datasets)
- ✅ Can tolerate slower analytics queries (real-time user queries unaffected)

**When NOT safe:**
- ❌ Unoptimized queries (slow queries will become slower)
- ❌ Memory-bound workload (caching 50% of dataset)
- ❌ Can't tolerate 1+ second query latency

**Implementation:**
```
1. Benchmark current queries: identify slow ones
2. If queries already optimized: safe to downgrade
3. Downgrade DB tier (rolling, minimal downtime)
4. Monitor p99 latency for 1 week
5. If latency acceptable: keep it; if not: roll back
```

**Risk:** Medium (can roll back if needed)  
**Payoff:** -$1,200/mo (-14% of budget)  
**Effort:** 2 days

---

## Saving #2: Add Caching Layer (-$800/month)

**Current:** Database handles all reads directly  
**Optimized:** Add Redis cache ($200/mo) but reduce DB queries 80% (-$1,000/mo)

**Trade-off:**
- ⚠️ Cache invalidation bugs (change data but cache doesn't update)
- ⚠️ More moving parts (Redis cluster to manage)
- ✅ 10-100× faster reads (milliseconds vs. milliseconds)

**When safe:**
- ✅ Data doesn't change constantly (blog posts, user profiles OK; live inventory risky)
- ✅ Slight staleness acceptable (show data from 10 seconds ago)
- ✅ Team experienced with caching (knows TTLs, invalidation patterns)

**When NOT safe:**
- ❌ Real-time consistency critical (trading, payments, live stock prices)
- ❌ Team new to caching (bugs emerge in production)
- ❌ Data changes frequently

**Implementation:**
```
1. Identify heavy read queries (top 10 by frequency)
2. Add Redis for those queries (cache for 5-60 seconds)
3. Implement cache invalidation (on write, clear cache)
4. Test thoroughly (cache bugs hard to catch)
5. Deploy with circuit breaker (if Redis down, hit DB)
```

**Risk:** Medium-High (cache bugs subtle)  
**Payoff:** -$800/mo (-9% of budget)  
**Effort:** 1 week

---

## Saving #3: Use Spot Instances (-$600/month)

**Current:** On-demand compute ($1,200/mo guaranteed)  
**Optimized:** Spot instances (70% discount, $350/mo but can be interrupted)

**Trade-off:**
- ⚠️ 2-5 minute interruptions (Kubernetes auto-reschedules, but brief outage)
- ⚠️ Not suitable for stateful services (sessions, live connections)
- ✅ Handles stateless services fine (REST APIs, workers)

**When safe:**
- ✅ Stateless services (APIs, workers, batch jobs)
- ✅ Can tolerate occasional 1-2 min restart
- ✅ Using Kubernetes (auto-reschedules on interruption)

**When NOT safe:**
- ❌ Stateful services (WebSocket connections, long-polling)
- ❌ Cannot tolerate any downtime (SLA critical)
- ❌ Not using container orchestration (manual restart = delayed)

**Implementation:**
```
1. Identify stateless services (APIs, workers)
2. Configure Kubernetes spot instance pools
3. Set fallback to on-demand (if spot unavailable)
4. Test interruption handling (does app reconnect?)
5. Monitor for unexpected downtime
```

**Risk:** Low (easy to roll back)  
**Payoff:** -$600/mo (-7% of budget)  
**Effort:** 3 days

---

## Saving #4: Reduce Log Retention (-$300/month)

**Current:** Keep logs 90 days ($500/mo retention cost)  
**Optimized:** Keep logs 30 days, archive to S3 for 90 days ($200/mo)

**Trade-off:**
- ⚠️ Can't query logs older than 30 days in real-time
- ⚠️ Debugging 60-day-old issues harder (archived logs slower to search)
- ✅ Keep logs for compliance (90-day archive on S3 cheap)

**When safe:**
- ✅ Most bugs found within 30 days
- ✅ Compliance requires 90-day retention (S3 archive OK)
- ✅ Don't debug ancient issues frequently

**When NOT safe:**
- ❌ Long debugging windows (performance issues appear weeks later)
- ❌ Frequent need for 90-day-old logs
- ❌ Regulatory requirement for real-time queryable 90 days

**Implementation:**
```
1. Set retention to 30 days in Datadog/CloudWatch
2. Setup automated export to S3 (daily)
3. Compress logs before S3 upload (10:1 ratio typical)
4. Test S3 retrieval (can you find a log from 60 days ago?)
5. Cost calculation: 30-day retention + S3 archive
```

**Risk:** Very low (easy to extend retention if needed)  
**Payoff:** -$300/mo (-3.5% of budget)  
**Effort:** 1 day

---

## Saving #5: Compress Asset Delivery (-$200/month)

**Current:** Serve uncompressed assets (CSS, JS, images)  
**Optimized:** Auto-compress with gzip/brotli, image optimization

**Trade-off:**
- ⚠️ Build time increases 20-30 seconds (compress on deploy)
- ✅ Bandwidth reduced 60-80% (huge savings)
- ✅ User experience improves (faster page loads)

**When safe:**
- ✅ Always (compression is universally supported)
- ✅ Especially for image-heavy sites

**When NOT safe:**
- ❌ Build pipeline can't tolerate 30s extra (but this is rare)

**Implementation:**
```
1. Enable gzip compression in web server
2. Add brotli for text assets (better than gzip)
3. Optimize images: use WebP format, responsive sizes
4. Test: measure bandwidth before/after
```

**Risk:** None (easy to disable if issues)  
**Payoff:** -$200/mo (-2% of budget, plus speed improvement)  
**Effort:** 3 days

---

## Saving #6: Upgrade to Annual Plans (-$400/month)

**Current:** Monthly billing (higher per-unit cost)  
**Optimized:** Annual billing (10-15% discount typical)

**Trade-off:**
- ⚠️ Less flexibility (committed for year)
- ✅ Save 10-15% on all services (free money)

**When safe:**
- ✅ Service is core (not trying it out)
- ✅ Company stable (won't pivot away)

**When NOT safe:**
- ❌ Evaluating service still (lock-in risk)
- ❌ Company might fail in 6 months (pre-revenue startup)

**Implementation:**
```
1. List all annual-capable services (most are)
2. Calculate savings: month_cost × 12 × 0.85 = annual_cost
3. Switch to annual billing
```

**Risk:** None (just commitment)  
**Payoff:** -$400/mo (-4.7% of budget, basically free)  
**Effort:** 0 days (administrative change only)

---

## Remaining Savings (Brief)

**Saving #7: Remove unused monitoring** (-$150/mo)  
- Turn off dashboards no one watches
- Remove metrics you never alert on

**Saving #8: Right-size compute** (-$350/mo)  
- CPU usage 10%? Downgrade instance
- Runs fine on 2 vCPU instead of 4

---

## Total Savings Projection

| Scenario | Savings | Timeline | Risk | Recommended |
|----------|---------|----------|------|---|
| **Easy only** (3,4,5,6,7) | -$1,050/mo | 1 week | Very Low | ✅ Start here |
| **Easy + caching** (1,2,3,4,5,6,7) | -$2,850/mo | 2 weeks | Medium | ⚠️ If cache expertise available |
| **All optimizations** (1-8) | -$3,600/mo | 3 weeks | Medium | ❌ Might break things |
| **Custom mix** | -$2,000/mo | 2 weeks | Low | ✅ Pick what you're comfortable with |

---

## Implementation Priority

**Week 1 (Easy, low-risk):**
1. Upgrade to annual plans (free money, 0 days) — FIRST
2. Reduce log retention (1 day)
3. Compress assets (3 days)
4. Remove unused monitoring (2 days)
5. **Subtotal: -$1,050/mo savings, 6 days effort, very low risk**

**Week 2 (If confident):**
1. Use spot instances (3 days)
2. Right-size compute (1 week, overlaps week 1)
3. **Subtotal: -$950/mo additional savings, overlaps week 1**

**Week 3+ (High-value but complex):**
1. Add caching layer (1 week, medium risk)
2. Downgrade database (2 days, medium risk)
3. **Subtotal: -$2,000/mo additional, but requires careful testing**

---

## Cost Monitoring Going Forward

After optimizing, monitor actual costs:

```
Setup weekly cost alerts:
- Budget: $5,500/mo
- Yellow alert: $6,000 (10% over)
- Red alert: $6,500 (18% over)

If costs creep:
1. Identify which services increased
2. Root cause (more traffic? more logging? infrastructure change?)
3. Adjust within 1 week
```

---

## When to Re-optimize

Run optimization again if:
- Traffic grows 2×+ (new optimizations available)
- Technology changes (new tools available)
- Budget tightens (new constraints)
- Quarterly review (check if saved money maintained)

---

## ROI Calculation

```
Optimization effort: 2 weeks = $10k (2 engineers × $5k/week)
Monthly savings: $3,000
Annual savings: $36,000

Payback period: $10k / $3k per month = 3.3 months ✅
Year 1 net: $36k - $10k = $26k
3-year net: (36k × 3) - 10k = $98k

ROI: ($26k / $10k) = 260% in year 1
     ($98k / $10k) = 980% over 3 years
```

---

## Behavior

### Step 1: Load current costs
- If provided: use input
- If not: ask user for current monthly bill

### Step 2: Identify optimization opportunities
For each common cost driver:
- Database: can we downgrade?
- Compute: can we use spot? right-size?
- Storage/CDN: can we compress? reduce retention?
- Monitoring: unused dashboards?
- Plans: monthly → annual discount available?

### Step 3: Calculate savings + trade-offs
For each opportunity:
- Monthly savings
- Implementation effort
- Risk level
- Trade-off explanation
- When safe vs. when NOT safe

### Step 4: Rank by ROI
```
roi_score = (monthly_savings × 12) / (effort_days × cost_per_day)

High ROI (>500): Annual plans, remove monitoring
Medium ROI (100-500): Log retention, compression, spot instances
Low ROI (<100): Database downgrade (more effort)
```

### Step 5: Generate report
Output: `cost-optimization-plan.md` with:
- Summary table (all savings ranked)
- Detailed breakdown for top 8
- Implementation timeline
- Risk assessment
- ROI calculation

### Step 6: Update activity log
```json
{"ts":"...","phase":"optimize-costs","outcome":"success","savings_identified":8,"total_potential_savings":3600,"recommended_savings":3000,"summary":"Identified $3.6k/mo savings ($36k/year). Recommend $3k/mo easy wins (1 week effort)."}
```

---

## Flags

### `--target-monthly 5500`
Only show optimizations that hit this budget target. Ranks by effort.

### `--target-percent -20`
Save this percentage of budget. Example: `-20` = reduce costs 20%.

### `--exclude database`
Don't touch certain services. Useful if: "we know DB is optimized, find savings elsewhere".

### `--show-all`
Show all 20+ possible optimizations (not just top 8). For spreadsheet analysis.

---

## Related Commands

- `/architect:cost-estimate` — baseline current costs
- `/architect:recommend-stack` — different stack = different costs
- `/architect:blueprint-variants` — cost-optimized architecture option
- `/architect:monitor-costs` — continuous tracking (Phase 3.3)
