# Stack Swap Simulator Skill

Estimates cost and effort to switch from one tech stack to another. Helps answer: "Can we migrate later if needed?"

## When to Use

Use this skill to understand:
1. **Cost of switching stacks** — engineer weeks + downtime risk
2. **Timeline to switch** — how long is the project?
3. **Risk of switching** — what can go wrong?
4. **ROI of switching** — does it save money long-term?
5. **Backwards compatibility** — can we do a gradual migration?

## Input

Provide source and target stacks:

```json
{
  "from_stack": {
    "backend": "Node.js",
    "database": "MongoDB",
    "deployment": "Vercel"
  },
  "to_stack": {
    "backend": "Go",
    "database": "PostgreSQL",
    "deployment": "Kubernetes"
  },
  "codebase_size": 50000,  // lines of code
  "monthly_revenue": 50000,
  "max_downtime_hours": 4
}
```

## Output

A migration impact report:

```json
{
  "from": "Node.js + MongoDB + Vercel",
  "to": "Go + PostgreSQL + Kubernetes",
  "feasibility": {
    "effort_engineer_weeks": 8,
    "cost_dollars": 50000,
    "timeline_weeks": 10,
    "downtime_hours": 4,
    "risk_level": "high"
  },
  "cost_breakdown": {
    "engineering_salaries": 40000,  // 8 weeks × 4 engineers
    "infrastructure_setup": 3000,    // Kubernetes cluster setup
    "testing_and_qa": 2000,         // Migration testing
    "consulting_fees": 5000         // Go/Kubernetes specialists
  },
  "timeline": {
    "week_1_2": "Parallel: Start building Go services, set up Kubernetes",
    "week_3_4": "Migrate first microservice (low-risk service)",
    "week_5_6": "Migrate core services (with fallback to old system)",
    "week_7_8": "Full cutover, run both systems in parallel",
    "week_9_10": "Monitor, optimize, fix issues"
  },
  "payback_period": 8,  // months until savings offset cost
  "roi": {
    "monthly_savings": 2000,  // Go scales cheaper than Node at their scale
    "annual_savings": 24000,
    "breakeven_months": 25  // 50k / 2k per month
  },
  "risk_assessment": {
    "data_loss_risk": 0.02,     // 2% chance of data loss
    "downtime_risk": 0.05,      // 5% chance of >4hr unplanned downtime
    "budget_overrun_risk": 0.25, // 25% chance of going 25% over budget
    "timeline_overrun_risk": 0.4 // 40% chance of taking 12+ weeks
  },
  "mitigation_strategies": [
    "Run both systems in parallel for 2 weeks (verify data consistency)",
    "Implement circuit breakers (if Go service slow, fall back to Node)",
    "Canary deployment (route 5% traffic to Go, verify works)",
    "Comprehensive test suite (validate data integrity)",
    "On-call rotation (engineer available if issues arise)"
  ],
  "can_do_gradual_migration": true,
  "gradual_path": [
    "Week 1-2: Build Go API for new features only",
    "Week 3-4: Route new feature requests to Go, old features to Node",
    "Week 5-6: Migrate historical data incrementally (background job)",
    "Week 7-8: Route more features to Go (30% traffic)",
    "Week 9: Route majority to Go (70% traffic)",
    "Week 10+: Retire old Node system once fully stable"
  ],
  "recommendation": "Worth it only if scaling to >1M DAU. Otherwise cost outweighs savings."
}
```

## Migration Scenarios

### Scenario 1: Easy Migration (Same database, swap backend framework)

**Example:** Node.js → Go (both use PostgreSQL)

**Effort:** 2-3 engineer weeks  
**Cost:** $10-15k  
**Downtime:** 1-2 hours  
**Complexity:** Low (database schema unchanged)

**Steps:**
1. Build Go version of API (reuse same database)
2. Run both systems pointing to same database
3. Route traffic gradually (5% → 25% → 100% to Go)
4. Retire Node.js once stable

**Why easy:** Database contract unchanged, can run both simultaneously

---

### Scenario 2: Medium Migration (Swap backend AND database)

**Example:** Node.js + MongoDB → Go + PostgreSQL

**Effort:** 6-8 engineer weeks  
**Cost:** $40-50k  
**Downtime:** 2-4 hours  
**Complexity:** Medium (schema mapping needed)

**Steps:**
1. Build PostgreSQL schema (map MongoDB documents → tables)
2. Implement data migration script (background job)
3. Build Go API against PostgreSQL
4. Run both systems for parallel testing (1-2 weeks)
5. Final cutover (stop MongoDB writes, run Go only)

**Why harder:** Must map MongoDB doc structure → PostgreSQL schema (not 1-to-1)

---

### Scenario 3: Hard Migration (Swap backend, database, AND deployment)

**Example:** Node.js + MongoDB + Vercel → Go + PostgreSQL + Kubernetes

**Effort:** 8-12 engineer weeks  
**Cost:** $50-80k  
**Downtime:** 4-8 hours  
**Complexity:** High (infrastructure completely different)

**Steps:**
1. Set up Kubernetes cluster (AWS EKS, GCP GKE, etc.)
2. Build data migration pipeline (MongoDB → PostgreSQL)
3. Build Go API
4. Set up Kubernetes deployments, monitoring, logging
5. Test extensively (Kubernetes failure modes different)
6. Cutover with careful monitoring

**Why hard:** Three different systems, all must work together correctly

---

### Scenario 4: Impossible Migration (Too risky)

**When NOT to migrate:**
- System in active development (too much flux)
- No downtime tolerance (24/7 uptime required)
- Complex stateful logic in old system
- Small team (can't afford to stop feature development)

**Example:** Live multiplayer game (can't take 4 hours downtime)

---

## Cost Analysis: When Does Migration Pay Off?

**Formula:**
```
migration_cost = engineering + infrastructure + consulting + opportunity_cost

annual_savings = current_cost - new_cost

payback_period_months = migration_cost / (annual_savings / 12)

worth_it = payback_period <= 18 months (typical 3-5 year horizon)
```

**Example:**
```
Current: Node.js + Vercel = $8k/month
New: Go + Kubernetes = $4k/month
Savings: $4k/month = $48k/year

Migration cost: $50k
Payback period: 50k / (48k/12) = 12.5 months ✅ Worth it

Running payoff calculation:
  Month 0: -$50k (migration)
  Month 12: -$50k + (4k × 12) = -$2k (still not paid back)
  Month 13: -$50k + (4k × 13) = +$2k ✅ (now profitable)
```

---

## Risk Assessment

### Data Loss Risk

**High risk (10-20%):**
- Complex data transformations (high chance of bug)
- No test environment matching production
- One-shot migration (can't rollback)

**Medium risk (3-5%):**
- Simple schema mapping (low chance of bug)
- Good test environment
- Parallel running period (can verify data)

**Low risk (<2%):**
- Straight replication (MongoDB → JSON in PostgreSQL)
- Extensive testing
- Easy rollback plan

**Mitigation:** Run both systems simultaneously for 1-2 weeks, verify data matches exactly

---

### Downtime Risk

**Factors:**
- Can you run both systems in parallel? (Reduces downtime)
- How complex is data cutover? (Simple = fast, complex = slow)
- Have you tested the cutover process? (Untested = risky)

**Typical downtime estimates:**
```
Simple backend swap: 1 hour
Backend + database: 2-4 hours
Everything including infra: 4-8 hours
```

**Mitigation:**
- Cutover during low-traffic window (3am Sunday)
- Have rollback plan ready (can revert to old system)
- On-call engineer present during cutover
- Comprehensive monitoring alerts

---

### Budget Overrun Risk

**Common reasons for overruns:**
1. Data transformation more complex than expected (+20%)
2. Kubernetes learning curve for team (+30%)
3. Production issues discovered during testing (+25%)
4. Scope creep (migrations attract "while we're at it" requests) (+50%)

**Strategies to control:**
- Fixed-scope contract (define exact features to migrate)
- Weekly cost reviews (catch overruns early)
- Dedicated project manager (enforces timeline)
- Allocate 20% buffer (scope creep reserve)

---

### Timeline Overrun Risk

**Most migrations take 20-50% longer than estimated:**
- Reason 1: Underestimating test time (always takes longer)
- Reason 2: Unforeseen data issues (real data messier than expected)
- Reason 3: Team knowledge gaps (learning curve adds weeks)

**Realistic timeline:**
- Optimistic estimate: 8 weeks
- Realistic estimate: 8 × 1.3 = 10-11 weeks
- Pessimistic estimate: 8 × 1.5 = 12-13 weeks

**Buffer to build in:** 2-3 weeks (20-30%)

---

## Gradual Migration vs. Big Bang

### Big Bang Migration
**One day, flip switch from old to new system**

Pros:
- ✅ Clean break (one dramatic moment, then done)
- ✅ Easy to understand timeline
- ✅ Forces team commitment

Cons:
- ❌ High risk (if something breaks, users affected immediately)
- ❌ Hard to rollback (both systems running for month = expensive)
- ❌ All eggs in one basket

**Risk level:** High

---

### Gradual Migration
**Start routing percentage of traffic to new system, increase over time**

Pros:
- ✅ Lower risk (catch issues on 5% traffic before 100%)
- ✅ Easy to rollback (keep old system, just reduce traffic)
- ✅ Real-world testing (production traffic reveals issues labs miss)

Cons:
- ❌ Run both systems longer (more expensive)
- ❌ Complex to coordinate (feature parity needed)
- ❌ Longer timeline (more weeks of dual operation)

**Risk level:** Medium

---

## Decision Tree: Should We Migrate?

```
1. Is the migration forced?
   a) Yes (old tech no longer supported): DO IT
   b) No (voluntary): go to step 2

2. How much will we save annually?
   a) <$10k/year: Don't migrate (not worth effort)
   b) $10-50k/year: Marginal (do if team capacity allows)
   c) $50k+/year: Worth investigating

3. What's the payback period?
   a) <12 months: ✅ DO IT (quick ROI)
   b) 12-24 months: ⚠️ MAYBE (reasonable if business stable)
   c) >24 months: ❌ DON'T (too long to justify)

4. Do we have team capacity?
   a) Dedicated team (can pause feature work): ✅ Good
   b) Shared capacity (features paused 2 months): ⚠️ Okay
   c) No capacity (features continue): ❌ Too risky

5. Can we do gradual migration?
   a) Yes (architecture supports parallel): ✅ Much safer
   b) No (big bang required): ⚠️ Higher risk

→ Decision:
   Forced migration OR (savings > $50k AND payback < 18 months AND team capacity available)
   → DO IT

   Anything else: Wait (improve ROI or find different problem to solve)
```

---

## Real-World Migration Examples

### Example 1: Dropbox (2010-2012)
**From:** Python → Python + Rust (for file syncing)  
**Cost:** Estimated $5-10M over 2 years  
**Payoff:** 40% reduction in sync latency, better battery life  
**ROI:** Millions per month (core product improvement)  
**Lesson:** Strategic migrations (improve product) have higher ROI than cost migrations

---

### Example 2: Heroku to AWS
**From:** Heroku (managed) → AWS (self-managed)  
**Cost:** $100k over 3 months (migration + consulting)  
**Savings:** $500k/year (self-managing cheaper than Heroku premium)  
**Payback:** 2.4 months ✅ (very quick ROI)  
**Timeline:** 3 months (longer than estimated due to DevOps learning curve)  
**Lesson:** Migrations from expensive managed → cheap self-managed always worth it

---

### Example 3: Company Still Running Python 2.7 (2023)
**Problem:** Python 2 end-of-life (no security patches)  
**Migration to:** Python 3  
**Status:** Still not done! (4 years overdue)  
**Cost:** Estimated $1-2M to do now (would have been $100k in 2018)  
**Lesson:** Don't delay forced migrations (cost grows exponentially)

---

## Usage in Commands

### In `/architect:recommend-stack`

```pseudo
// After recommending Go option:
if user_concerned_about_switching_later:
  simulate_swap("Node.js", "Go")
  show: "If you scale to 1M DAU and want Go, it costs $50k and 10 weeks"
  help user: "Is Node.js cheaper for your growth path?"
```

### In `/architect:blueprint-variants`

```pseudo
// For each variant:
if switching_cost_significant:
  add_to_report: "Switching from baseline to this option later costs $X"
  help_user: "Choose baseline now to keep switching options open"
```

### New command: `/architect:simulate-migration`

```
/architect:simulate-migration --from node --to go
→ Estimates cost, timeline, risk, ROI of migration
```

## Related Skills

- `constraint-solver/` — picks initial stack (reduces need to migrate)
- `stack-compatibility/` — helps pick compatible stacks (easier to migrate between)
- `cost-optimizer/` — estimates long-term costs (drives migration decisions)
