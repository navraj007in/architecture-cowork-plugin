# Trade-Off Analysis Skill

Quantifies exact trade-offs when switching between architecture options. Shows users precisely what they gain and lose when choosing Option A over Option B.

## When to Use

Use this skill to help users decide between options by showing:
1. **Cost difference** — how much more/less per month?
2. **Performance difference** — how much faster/slower?
3. **Complexity difference** — how much harder to build/maintain?
4. **Scalability difference** — when does this option hit limits?
5. **Ops burden difference** — how much more work to operate?
6. **Risk difference** — what new risks arise?

## Input

Provide two architecture options:

```json
{
  "option_a": {
    "name": "baseline",
    "cost_monthly": 4200,
    "latency_p99_ms": 300,
    "complexity_score": 6,
    "team_ramp_weeks": 3,
    "ops_burden_hrs_per_week": 4,
    "max_dau": 100000,
    "scalability_path": "vertical then horizontal"
  },
  "option_b": {
    "name": "performance-optimized",
    "cost_monthly": 8500,
    "latency_p99_ms": 50,
    "complexity_score": 8,
    "team_ramp_weeks": 5,
    "ops_burden_hrs_per_week": 8,
    "max_dau": 1000000,
    "scalability_path": "multi-region from start"
  }
}
```

## Output

A trade-off comparison matrix:

```json
{
  "option_a": "baseline",
  "option_b": "performance-optimized",
  "trade_offs": [
    {
      "dimension": "cost_monthly",
      "option_a_value": 4200,
      "option_b_value": 8500,
      "difference": 4300,
      "percent_change": "+102%",
      "winner": "option_a (cheaper)",
      "interpretation": "Option B costs 2× more per month ($102k/year extra)"
    },
    {
      "dimension": "latency_p99_ms",
      "option_a_value": 300,
      "option_b_value": 50,
      "difference": -250,
      "percent_change": "-83%",
      "winner": "option_b (faster)",
      "interpretation": "Option B is 6× faster (300ms → 50ms). Noticeable for user experience."
    },
    {
      "dimension": "complexity_score",
      "option_a_value": 6,
      "option_b_value": 8,
      "difference": 2,
      "percent_change": "+33%",
      "winner": "option_a (simpler)",
      "interpretation": "Option B is significantly more complex (Kubernetes, caching layers, multi-region)"
    },
    {
      "dimension": "team_ramp_weeks",
      "option_a_value": 3,
      "option_b_value": 5,
      "difference": 2,
      "percent_change": "+67%",
      "winner": "option_a (faster)",
      "interpretation": "Option B takes 2 extra weeks for team to ramp up on complex stack"
    },
    {
      "dimension": "ops_burden_hrs_per_week",
      "option_a_value": 4,
      "option_b_value": 8,
      "difference": 4,
      "percent_change": "+100%",
      "winner": "option_a (less work)",
      "interpretation": "Option B doubles ops burden (4 hrs/week vs. 8 hrs/week for small team)"
    },
    {
      "dimension": "max_dau",
      "option_a_value": 100000,
      "option_b_value": 1000000,
      "difference": 900000,
      "percent_change": "+900%",
      "winner": "option_b (scales further)",
      "interpretation": "Option B scales to 10× more users (100k → 1M). Option A hits limits sooner."
    }
  ],
  "decision_matrix": {
    "choose_option_a_if": [
      "Budget is primary constraint",
      "Expected DAU < 100k",
      "Latency < 300ms acceptable",
      "Team small and inexperienced",
      "Want to launch fastest"
    ],
    "choose_option_b_if": [
      "Performance is critical",
      "Expect scale (100k+ DAU)",
      "Can afford 2× cost",
      "Team experienced with Kubernetes",
      "Long-term growth > short-term speed"
    ]
  },
  "breakeven_analysis": {
    "cost": "Never breaks even (B is always 2× more expensive)",
    "performance": "If you need <100ms latency, B pays for itself (performance critical)",
    "team_productivity": "After month 3, B team more productive (complex stack becomes easier). ROI: 6-12 months"
  }
}
```

## Trade-Off Dimensions

### 1. Cost ($/month)
**Comparison:**
- Absolute: "$X/month difference"
- Relative: "+50% more expensive" or "-30% savings"
- Annual: "$X/year difference"
- ROI: "Pays for itself in N months of extra revenue"

**When it matters:**
- Budget is hard constraint (can't spend more)
- Recurring cost significant vs. revenue
- Cash flow critical (bootstrapped startup)

**When it doesn't matter:**
- Revenue > $10M/year (cost is rounding error)
- Business model scales with cost (e.g., 3% processing fee)

### 2. Latency (milliseconds, p99)
**Comparison:**
- Absolute: "300ms vs. 50ms = 250ms faster"
- Relative: "6× faster"
- User perception: "<100ms feels instant, 100-300ms feels responsive, >300ms feels slow"

**When it matters:**
- Real-time critical (trading, gaming, collaborative editing)
- E-commerce (studies show 100ms delay = 1% conversion loss)
- Mobile users (latency-sensitive on cellular)

**When it doesn't matter:**
- Batch processing (analytics, reports)
- Reading (news, docs where <5s acceptable)
- Async workflows (notifications, emails)

### 3. Complexity (1-10 score)
**What increases complexity:**
- Number of moving parts (database + cache + queue + search engine = more complex)
- Operational knowledge needed (Docker easy, Kubernetes hard)
- Configuration surface (Kubernetes has 100 config options, Vercel has 5)
- Failure modes (single point of failure simple, distributed system complex)

**Impact:**
```
Complexity 3-5: Junior engineers comfortable, 1-2 week ramp
Complexity 5-7: Mid-level engineers needed, 2-4 week ramp
Complexity 7-9: Senior/principal engineers needed, 4-8 week ramp
Complexity 9-10: Very specialized (requires hiring expert)
```

**When it matters:**
- Team is small or junior (complexity hard to manage)
- Timeline tight (no time to learn)
- High turnover expected (easier to hire replacement for simple system)

### 4. Team Ramp Time (weeks)
**Components:**
- Learning curve: "How long to understand the system?"
- Production confidence: "When can team deploy to production safely?"
- Full productivity: "When is team fully productive?"

**Typical paths:**
```
Simple stack (Vercel + managed DB): 1-2 weeks
Standard stack (Node + PostgreSQL): 2-3 weeks
Moderate complexity (Kubernetes): 4-5 weeks
High complexity (custom infrastructure): 6-8 weeks
```

**When it matters:**
- Timeline tight (need to move fast)
- Need to onboard new team members (hiring engineer who needs weeks to ramp)
- Team is junior (needs more learning time)

### 5. Ops Burden (hours/week)
**What requires ops work:**
- Monitoring and alerting (1-2 hrs/week)
- Deployments and rollbacks (2-4 hrs/week)
- Database maintenance (backups, migrations) (1-2 hrs/week)
- Security patching (monthly) (1-2 hrs/week)
- Incident response (when things break) (variable, 0-10 hrs/week)

**By stack:**
```
Fully managed (Vercel + Firebase): 1-2 hrs/week
Managed services (Railway + Neon): 2-4 hrs/week
Self-hosted with containers: 4-8 hrs/week
Full infrastructure (Kubernetes): 8-16 hrs/week
```

**When it matters:**
- Team size small (ops burden takes engineering time from features)
- No dedicated ops person (shared responsibility)
- Scaling concerns (ops burden grows with system size)

### 6. Scalability (max DAU supported)
**Definitions:**
- DAU = Daily Active Users
- Scalability = at what point does performance degrade?

**Typical limits:**
```
Baseline option: 100k DAU (then add read replicas or caching)
Performance option: 1M+ DAU (multi-region, advanced caching)
Enterprise option: 10M+ DAU (sharded, specialized databases)
```

**When it matters:**
- Hypergrowth expected (2x users/month)
- Winner-take-all market (need to scale fast to win)
- Unit economics improve with scale

**When it doesn't matter:**
- Niche product (expected 10k DAU max)
- Premium model (want fewer, paying users)
- MVP testing (scaling can wait until PMF proven)

## Decision Trees

### "Should I pay 2× for better latency?"

```
If latency is critical (real-time, e-commerce): YES
  → performance matters more than cost
  
If latency is nice-to-have (content, reporting): NO
  → cost is better use of money
  
If you're unsure: Start with cheaper, upgrade if customers complain
  → latency complaints usually visible in metrics/reviews
```

### "Should I accept more ops burden?"

```
If you have dedicated ops/DevOps: YES
  → they can handle complex stack

If ops shared among engineers: NO
  → ops burden steals feature development time
  
If you can hire ops person: MAYBE
  → adds $100k+ headcount cost (calculate ROI)
  
If you're unsure: Start simple, hire ops person if needed
  → ops burden grows over time anyway
```

### "Should I choose for scale I don't need yet?"

```
If growth guaranteed (pre-sold, series A funded): YES
  → build for scale from start, cheaper than rearchitect

If growth uncertain (early MVP): NO
  → start simple, rearchitect when you hit limits
  → simpler architecture also easier to pivot
  
If rearchitecting easy (good abstractions, tests): MAYBE
  → depends on your codebase quality
```

## Quantifying Non-Obvious Trade-Offs

### Option A: Cheap but Limited

**Gains:**
- 50% cost savings = $2,100/year saved
- Faster time-to-market (2 weeks)
- Easier to hire replacements
- Lower operational stress

**Loses:**
- Hits scalability limits at 10k DAU
- Rearchitecting costs 4-6 weeks when outgrow
- Cannot attract enterprise customers (no redundancy)
- Higher technical debt (quick-and-dirty vs. solid)

**ROI:** Saves $2,100 initially, but costs $50k in rearchitecting if you scale

### Option B: Expensive but Scalable

**Gains:**
- Scales to 1M+ DAU without rearchitecting
- Enterprise-ready (SLAs, uptime, redundancy)
- Can charge premium pricing (reliability sells)
- Easier to hire (famous tech stack, portfolio piece)

**Loses:**
- 2× monthly cost ($4,300/month × 12 = $51,600/year)
- Slower time-to-market (6 weeks vs. 4 weeks)
- More complex to debug issues
- Higher operational risk (more things can break)

**ROI:** Costs $51k/year, but enables $500k+ customers (breaks even at 1-2 enterprise customers)

## Real-World Trade-Off Examples

### Example 1: Startup MVP (Cheap vs. Baseline)

```
Cost-Optimized:
  - $2,100/mo
  - 4-week launch
  - Limited scale (10k DAU)
  - Junior-friendly

Baseline:
  - $4,200/mo
  - 8-week launch
  - Can scale to 100k DAU
  - Worth it if you expect growth

Decision: Cost-Optimized for MVP (prove market fit)
          → If customers come, rearchitect to Baseline (6-week rearchitect cost acceptable)
```

### Example 2: SaaS (Baseline vs. Enterprise)

```
Baseline:
  - $4,200/mo
  - Can serve startups (SMB market)
  - Cannot serve enterprises (no redundancy, no SLAs)
  - Limited growth past $1M ARR

Enterprise:
  - $12,000/mo
  - Can serve enterprises ($100k+ contracts)
  - Premium positioning
  - Can grow to $10M+ ARR

Decision: Choose based on target market
          - SMB only? → Baseline
          - Enterprise customers? → Enterprise (higher LTV justifies higher cost)
```

### Example 3: Gaming (Performance vs. Cost)

```
Baseline (300ms latency):
  - $4,200/mo
  - Playable but not competitive
  - Users notice delay in real-time games
  - Will lose to competitors with lower latency

Performance-Optimized (50ms latency):
  - $8,500/mo
  - Competitive latency
  - Professional esports viable
  - Users will choose this over competitors

Decision: Performance mandatory (game is unplayable with 300ms)
          → The $4,300/mo difference is non-negotiable
```

## Trade-Off Decision Framework

```
For each dimension (cost, speed, scale, complexity, ops, risk):

1. Rate importance: CRITICAL | HIGH | MEDIUM | LOW | IRRELEVANT
2. Identify winner: Option A or Option B
3. Quantify gap: 10% | 50% | 100% | 10×

If CRITICAL dimension:
  → Choose option that wins that dimension (all else secondary)

If HIGH dimension and gap is 10× or 100%:
  → Still heavily weight winner

If HIGH dimension and gap is 10-50%:
  → Acceptable trade-off, weigh against other dimensions

If MEDIUM/LOW dimension:
  → Can ignore or use as tiebreaker

Example:
  Cost (CRITICAL): A wins by 50%
  Latency (HIGH): B wins by 6×
  Complexity (MEDIUM): A wins by 33%
  
  → Choose A: cost critical and A wins there
     (latency not critical enough to justify 2× cost)
```

## Usage in Commands

### In `/architect:blueprint-variants`

```pseudo
// When showing 4 options, analyze trade-offs:
For each pair of adjacent options:
  - Generate trade-off analysis
  - Show in "trade-offs" section
  - Help user understand cost of upgrading
```

### In `/architect:cost-estimate`

```pseudo
// When user asks "can we go cheaper?"
- Find cost-optimized option
- Show cost difference
- Show what scales/ops/quality they lose
- Help them decide if worth it
```

### New command: `/architect:trade-offs`

```
/architect:trade-offs --option1 baseline --option2 performance
→ Detailed trade-off analysis between two specific options
```

## Related Skills

- `constraint-solver/` — helps pick option that fits constraints
- `blueprint-variants/` — generates options to compare
- `cost-optimizer/` — helps reduce costs while maintaining quality
