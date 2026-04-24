# Continuous Cost Monitor Skill

Tracks actual infrastructure costs against estimated costs. Alerts when actual spend drifts from projection, identifies cost drivers, and suggests corrective actions.

## When to Use

Use this skill to:
1. **Detect cost creep** — infrastructure spending slowly increases over time
2. **Root-cause cost spikes** — which service changed? traffic? resource use?
3. **Compare actual vs. estimated** — am I spending what I projected?
4. **Trigger optimization cycles** — when do I need to re-optimize?
5. **Alert on budget overruns** — notify team before exceeding budget

## Input

Provide estimated costs + actual spend data:

```json
{
  "estimated_monthly_cost": 8500,
  "actual_monthly_cost": 9200,
  "cost_breakdown_estimated": {
    "backend_compute": 1200,
    "database": 1800,
    "cache": 200,
    "cdn": 300,
    "monitoring": 300,
    "storage": 500,
    "other": 400
  },
  "cost_breakdown_actual": {
    "backend_compute": 1500,
    "database": 2100,
    "cache": 200,
    "cdn": 350,
    "monitoring": 400,
    "storage": 450,
    "other": 200
  },
  "traffic_metrics": {
    "dau_estimated": 100000,
    "dau_actual": 110000,
    "query_volume_estimated": 500000,
    "query_volume_actual": 650000
  },
  "measurement_period_days": 30,
  "budget_threshold": 9000
}
```

## Output

A cost monitoring report:

```json
{
  "period": "April 2026",
  "estimated_vs_actual": {
    "estimated": 8500,
    "actual": 9200,
    "variance": 700,
    "variance_percent": 8.2,
    "status": "YELLOW (over by $700)"
  },
  "cost_breakdown_analysis": {
    "backend_compute": {
      "estimated": 1200,
      "actual": 1500,
      "variance": 300,
      "variance_percent": 25,
      "driver": "Traffic 10% higher than expected (110k vs 100k DAU)"
    },
    "database": {
      "estimated": 1800,
      "actual": 2100,
      "variance": 300,
      "variance_percent": 16.7,
      "driver": "Query volume 30% higher (650k vs 500k queries). Likely N+1 queries or missing cache."
    },
    "cache": {
      "estimated": 200,
      "actual": 200,
      "variance": 0,
      "variance_percent": 0,
      "status": "On budget"
    },
    "cdn": {
      "estimated": 300,
      "actual": 350,
      "variance": 50,
      "variance_percent": 16.7,
      "driver": "Traffic 10% higher (correlates with DAU increase)"
    },
    "monitoring": {
      "estimated": 300,
      "actual": 400,
      "variance": 100,
      "variance_percent": 33,
      "driver": "Increased metric cardinality (added new dashboards or higher scrape frequency)"
    },
    "storage": {
      "estimated": 500,
      "actual": 450,
      "variance": -50,
      "variance_percent": -10,
      "status": "Better than expected"
    },
    "other": {
      "estimated": 400,
      "actual": 200,
      "variance": -200,
      "variance_percent": -50,
      "status": "Significantly better than expected"
    }
  },
  "root_cause_analysis": {
    "primary_driver": "Database query volume 30% higher than expected",
    "contributing_factors": [
      "Traffic 10% higher (110k vs 100k DAU) — accounts for ~$300",
      "Inefficient queries — N+1 patterns or missing caching — accounts for ~$200",
      "Monitoring cost creep — added dashboards — accounts for ~$100"
    ],
    "confidence": 0.85
  },
  "trend_analysis": {
    "month_1_actual": 8100,
    "month_2_actual": 8800,
    "month_3_actual": 9200,
    "trend": "Increasing",
    "monthly_growth": 5.5,
    "projected_next_month": 9700,
    "annualized_growth": 66
  },
  "alerts": [
    {
      "level": "YELLOW",
      "message": "Cost overrun: +$700 (+8.2%) vs. estimate",
      "action": "Review database query patterns and cache hit rates"
    },
    {
      "level": "ORANGE",
      "message": "Database costs growing (16.7% overrun). Query volume 30% higher.",
      "action": "Profile slow queries, implement caching, optimize N+1 patterns"
    },
    {
      "level": "ORANGE",
      "message": "Monitoring cost increasing (33% overrun). Cardinality growth?",
      "action": "Audit new metrics added. Disable unused dashboards."
    },
    {
      "level": "YELLOW",
      "message": "Cost trend: +5.5% per month. At this rate, exceed $10k budget in 2 months.",
      "action": "Run cost optimization (reduce scope or increase efficiency)"
    }
  ],
  "budget_status": {
    "budget": 9000,
    "actual": 9200,
    "over_budget": true,
    "headroom": -200,
    "trajectory": "Will exceed budget next month at current trend"
  },
  "recommendations": [
    {
      "action": "Optimize database queries",
      "potential_savings": 200,
      "effort": "Medium (1-2 weeks)",
      "confidence": "High"
    },
    {
      "action": "Review monitoring cardinality",
      "potential_savings": 100,
      "effort": "Low (1-2 days)",
      "confidence": "High"
    },
    {
      "action": "Consider caching layer for read-heavy queries",
      "potential_savings": 150,
      "effort": "Medium (1 week)",
      "confidence": "Medium"
    },
    {
      "action": "Scale traffic analysis — is 110k DAU sustainable?",
      "potential_savings": 300,
      "effort": "Low (planning only)",
      "confidence": "Medium"
    }
  ],
  "escalation_actions": {
    "if_over_10_percent": "Run `/architect:optimize-costs` to identify quick wins",
    "if_trend_continues": "Trigger roadmap planning discussion (may need rearchitecture)",
    "if_exceeded_budget": "Notify finance and product teams; discuss scope/timeline changes"
  }
}
```

## Monitoring Categories

### 1. Variance Detection

**Green (0-5% overrun):**
- Expected traffic fluctuation
- No action needed
- Continue monitoring

**Yellow (5-15% overrun):**
- Actionable overrun
- Identify root cause
- Plan optimization (1-2 weeks)

**Orange (15-30% overrun):**
- Significant drift
- Immediate investigation required
- Implement fixes within 1 week

**Red (>30% overrun):**
- Major unexpected costs
- Emergency response
- May need scaling or rearchitecture

### 2. Service-Level Analysis

```
For each service, calculate:
- Estimated cost per unit ($/DAU, $/query, $/GB)
- Actual cost per unit
- Variance ratio = actual / estimated

If variance > 1.2 (20% overrun):
  - Service is performing worse than expected
  - Prioritize optimization
```

**Example:**
```
Database estimated: $18/1000 queries = $1.8k at 100k DAU
Database actual: $21/1000 queries = $2.1k at 110k DAU (30% more queries!)

Root cause: Queries increased 30% (not linear with traffic).
Hypothesis: N+1 pattern, missing cache, or change in feature usage.
```

### 3. Trend Analysis

**Linear growth (stable):**
```
Month 1: $8.1k
Month 2: $8.8k
Month 3: $9.2k
Growth: ~$0.5k/month

Projection: Will hit $10k at month 8
Action: Schedule optimization for month 5-6 (preventive)
```

**Exponential growth (concerning):**
```
Month 1: $8.1k
Month 2: $9.2k (+13%)
Month 3: $10.5k (+14%)

Projection: Will hit $15k at month 6
Action: Emergency optimization needed this month
```

**Seasonal patterns:**
```
Traffic spikes certain days (weekends, holidays):
- Normal: expected pattern
- Action: Adjust budget for peak days

Unexpected spike (viral event, marketing campaign):
- Investigate: did marketing team run unplanned campaign?
- Document: for future capacity planning
```

### 4. Budget Tracking

```
Budget: $9,000/month
Threshold red: $10,000 (11% over)
Threshold orange: $9,500 (5.5% over)
Threshold yellow: $9,200 (2.2% over)

Current: $9,200 (YELLOW)
Action: Monitor closely; if hits $9,500, trigger optimization
```

## Monitoring Algorithm

```
run_monthly_cost_monitor():
  1. Collect actual costs from cloud providers (AWS, Vercel, etc.)
  
  2. Calculate total variance
     total_variance = actual_total - estimated_total
     variance_percent = (total_variance / estimated_total) × 100
  
  3. For each service:
     service_variance = actual[service] - estimated[service]
     if service_variance > 15% of estimated[service]:
       flag as "needs investigation"
  
  4. Analyze trends
     growth_rate = (month_3 - month_1) / (month_1 × 2)
     if growth_rate > 10% per month:
       projection = estimated × (1 + growth_rate) ^ months_remaining
       if projection > budget:
         alert "cost trajectory exceeds budget"
  
  5. Correlate with metrics
     for each service_with_variance:
       if traffic increased:
         expected_increase = service_estimated × (traffic_actual / traffic_estimated)
         unexplained_variance = service_actual - expected_increase
         if unexplained_variance > 0:
           "query efficiency degraded"
       if traffic flat:
         "efficiency lost (not traffic-driven)"
  
  6. Generate alerts + recommendations
     sort recommendations by impact × ease
     for each, suggest: action, savings, effort, when to implement
```

## Real-World Monitoring Examples

### Example 1: Normal Growth

```
Month 1 (Jan): $8.1k actual vs $8k estimated (+1.25%)
Month 2 (Feb): $8.8k actual vs $8.3k estimated (+6%)
Month 3 (Mar): $9.2k actual vs $8.5k estimated (+8.2%)

Traffic: 100k → 105k → 110k DAU (linear +5% per month)
Cost growth: +5.5% per month

Status: ✅ HEALTHY
- Cost growth correlates with traffic
- Variance stays under 10%
- Trend is linear (not exponential)

Action: Continue monitoring. No intervention needed yet.
```

### Example 2: Unexpected Database Spike

```
Month 1 (Jan): Database $1.7k (on budget)
Month 2 (Feb): Database $1.9k (+11%, expected for +5% traffic)
Month 3 (Mar): Database $2.4k (+26% vs Feb, but traffic only +5%)

Root cause investigation:
- Query volume: 600k in March (was 500k in Jan) → +20%
- Traffic: 110k DAU (was 100k in Jan) → +10%
- Mismatch: queries grew 2× traffic growth

Hypothesis: New feature (user notifications?) doing N+1 queries
Evidence: Queries per user jumped from 5 to 6

Action: Profile notification feature, add caching, optimize queries
Expected savings: -$300/mo (-12% database cost)
Timeline: 1 week implementation
```

### Example 3: Monitoring Cost Creep

```
Month 1: Monitoring $250 (expected)
Month 2: Monitoring $300 (+20%, no traffic increase)
Month 3: Monitoring $400 (+33% vs expected)

Analysis:
- Dashboards added: 3 new custom dashboards
- Metric cardinality: Up from 500 → 2000 metrics

Root cause: Team added detailed metrics for each user segment
Cost impact: $1.50/metric when cardinality grows

Action: Disable unused dashboards, consolidate metrics
Expected savings: -$100/mo
Timeline: 2 days (administrative)
```

### Example 4: Capacity-Driven Growth (Healthy)

```
Month 1: 100k DAU, $8.1k
Month 2: 150k DAU, $9.8k
Month 3: 200k DAU, $11.2k

Analysis:
- Cost per DAU: $81 → $65 → $56 (improving!)
- Reason: Economies of scale (database utilization higher)

Status: ✅ EFFICIENT SCALING
- Variance: +15% of estimated (acceptable for 2× traffic growth)
- Cost per unit improving (good sign)
- Trend: Sustainable

Action: Continue at current architecture. No optimization needed.
Next major action: Plan rearchitecture at 500k DAU.
```

### Example 5: Warning: Budget Trajectory

```
Budget: $9,000/month
Month 1: $8.1k
Month 2: $8.9k
Month 3: $9.4k

Trend: +$650/month growth
Projection at month 6: $11.3k (26% over budget)

Status: 🔴 ALERT — on collision course with budget

Immediate actions (this week):
1. Profile database for N+1 queries (-$300 potential)
2. Review monitoring cardinality (-$100 potential)
3. Implement caching for hot queries (-$200 potential)
Total potential: -$600/mo (brings us to $8.8k, under budget)

Timeline: 2-3 weeks
If not implemented: Will exceed budget in 5 weeks
```

## Integration with Other Commands

### In `/architect:cost-estimate`

```pseudo
// After estimating costs:
setup_monitoring(estimated_costs)
  → Track actual vs estimated
  → Monthly alerts on variance
  → Feed into optimization cycles
```

### In `/architect:optimize-costs`

```pseudo
// When suggesting optimizations:
if actual_variance > 10%:
  identify_root_cause()
  → Shows which optimizations address the root cause
  → Prioritizes by impact × ease

Example: "Database 20% over expected. Root cause: queries up 30%.
Suggested optimizations: add caching (-$200), optimize queries (-$300)"
```

### New command: `/architect:monitor-costs`

```
/architect:monitor-costs [--period monthly|weekly|quarterly]
→ Generates cost monitoring report
→ Compares actual vs estimated
→ Flags variance, identifies drivers
→ Suggests optimizations

/architect:monitor-costs --alert-threshold 5000
→ Trigger optimization if costs exceed $5k
```

## Limitations

**Accuracy factors:**
- Cloud provider APIs don't report instantly (1-3 day lag typical)
- Cost allocation (shared resources) hard to attribute perfectly
- Pricing changes (provider raises rates mid-month) unpredictable
- One-time costs (data transfer, API calls) volatile

**When monitoring less reliable:**
- First month (no baseline to compare)
- During major infrastructure changes (hard to isolate variance)
- With new features affecting load patterns (unknown relationship to cost)

**Recommendation:** Collect 3 months of data before making major decisions based on variance trends. Single-month spikes are often noise.

## Related Skills

- `cost-optimizer/` — identifies optimization opportunities
- `cost-whatif-simulator/` — models impact of changes before implementing
- `constraint-solver/` — ties cost monitoring to project constraints
- `stack-swap-simulator/` — assesses cost impact of architecture changes
