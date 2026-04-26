---
description: Identify emerging competitive threats, strategic moves by rivals, and existential risks
---

# /architect:competitive-threat

## Trigger

`/architect:competitive-threat` — Run to analyze specific competitive threats or at any time to stay ahead of market movements.

**Prerequisite**: Should run after `/architect:deep-research` (needs competitor list + market context).

**Optional intensity levels**:
- Quick: 1 hour, focus on top 3 competitors
- Standard: 2-3 hours, analyze top 5 competitors + market leaders
- Deep: 4+ hours, comprehensive threat assessment + scenario planning

## Purpose

Identify **emerging** competitive threats beyond current feature comparison. Reveals:
- What competitors are building next (funding, hiring, roadmap signals)
- Who's winning and why (strategic moves, market consolidation)
- Existential risks (incumbent response, well-funded entrants)
- What could kill us and how to address it

Different from deep-research: deep-research is landscape (market sizing, features, pricing), competitive-threat is threat detection (momentum, strategic moves, risk assessment).

## Workflow

### Step 1: Gather Context

Load competitor list from previous research:

```
Read: architecture-output/deep-research.md (competitor list, market sizing)
Read: architecture-output/_state.json (momentum scores, feature parity)
Read: architecture-output/mvp-scope.md (our differentiation, timeline)
```

Identify: Which competitors are the real threats? (Usually top 3, ranked by momentum score)

### Step 2: Load Skills

Load:
- **deep-research** skill — for verification methodology
- **founder-communication** skill — for risk communication

### Step 3: Strategic Moves Research (Phase 1 — Discover)

Use WebSearch to find signals of competitive strategy:

**Funding & Consolidation** (run 5+ searches):
- `"{top competitor}" Series A / Series B / Series C funding round`
- `"{competitor}" IPO acquisition investment 2024 2025`
- `"{market leader}" acquires {adjacent category} 2024`
- `"startup funding {product category}" 2024 2025`

**Hiring & Talent** (run 3+ searches):
- `"{competitor}" hiring engineering 2025 site:linkedin.com`
- `"{competitor}" jobs careers "machine learning" OR "AI"`
- `"heading to {competitor}" job change site:linkedin.com` (signals who joined)

**Product Strategy** (run 4+ searches):
- `"{competitor}" roadmap announcement blog 2025`
- `"{competitor}" new features product launch 2024 2025`
- `"{competitor}" vs {our product} comparison reddit hacker news`
- `"{product category}" product comparison alternatives`

**Market Consolidation** (run 2+ searches):
- `"{market leader}" {broader category} 2024 2025` (incumbent moving down-market?)
- `"{industry} market share shift" 2024 2025 report`

**Collect**: 10-15 verified URLs about competitor moves

### Step 4: Deep Dive into Top Threats (Phase 2 — Verify)

For each top 3 competitor:

**Funding Analysis** (WebFetch):
1. **Crunchbase or announcement** — Total funding, series details, valuation, investor names
2. **Press release** — What they say about the funding (strategic focus)
3. **LinkedIn hiring** — Extract job postings: what are they hiring for?

Extract:
```
CompA: Series B $30M (Q4 2024)
├─ Focus: "Expanding into SMB market" (from press release)
├─ Hiring: 5 ML engineers, 3 product managers, 2 sales engineers
├─ Implication: Building AI features + SMB sales motion
└─ Timeline: 6-9 months to product launch

CompB: Acquired by market leader (Q2 2024)
├─ What they acquired: [Technology, team, customer base]
├─ Integration: Integrated into platform vs standalone
├─ Implication: [How does this threaten us?]
```

**Product Roadmap Clues** (WebFetch):
1. **Product Hunt posts** — Recent launches, upcoming
2. **User forums/Reddit** — What users want, what competitors are building
3. **Changelog/blog** — Feature release pace and focus areas

Extract:
```
CompA releases per month: 8 (high velocity)
├─ Feature focus: Authentication (4), Data Import (3), Reporting (1)
└─ Implication: They're solving onboarding + data integration faster than us

CompC releases per month: 2 (slower, consolidated releases)
├─ Feature focus: Enterprise (2)
└─ Implication: They're betting on premium market, not SMB
```

**Technology Stack Signals** (WebFetch GitHub/docs):
1. **GitHub activity** — Language distribution, technology trends
2. **Job postings** — Tech skills they're hiring for
3. **Infrastructure choices** — Cloud provider, database, frameworks

Extract:
```
CompA is hiring Rust engineers (not typical for SaaS)
├─ Implication: Building high-performance system (real-time? distributed?)
└─ Risk: They might be building something faster/more scalable
```

### Step 5: Threat Assessment Matrix

```markdown
## Competitive Threat Landscape

| Competitor | Recent Move | Strategic Signal | Timeline | Risk to Us |
|---|---|---|---|---|
| CompA | Series B $30M | Expanding SMB | 6-9mo | High: Direct competition |
| CompB | Acquired | Incumbent backing | 3-6mo | Critical: Distribution + funding |
| CompC | IPO planned | Market validation | 12-18mo | Medium: Pricing pressure |

### Threat Scoring (0-100 scale)

**Threat Score = (Funding velocity × 0.3) + (Hiring velocity × 0.3) + (Feature velocity × 0.25) + (Market position × 0.15)**

| Competitor | Funding | Hiring | Features | Position | Total Score | Trend |
|---|---|---|---|---|---|---|
| CompA | 30 | 28 | 25 | 20 | **76** | 📈 Accelerating |
| CompB | 35 | 32 | 20 | 30 | **79** | 📈 Critical (acquired) |
| CompC | 15 | 12 | 20 | 25 | **43** | → Stable |

**Interpretation**:
- 70+: Existential threat (could kill us)
- 50-70: Major threat (could slow us down)
- <50: Manageable threat
```

### Step 6: Existential Risk Scorecard

Assess: Which threats could kill us?

```markdown
## Existential Risk Assessment

### Risk 1: Incumbent Responds
**Scenario**: Market leader (CompB parent) decides to enter our segment aggressively.
- **Probability**: Medium (60%) — they have SMB products, could extend
- **Timeline**: 6-12 months to credible offering
- **Impact**: CRITICAL
  - They have: $500M funding, sales team, brand
  - We have: Speed, niche focus
  - Likely outcome: Price war we can't win

**Mitigation**:
1. Build loyal user base FAST (12 months = moat)
2. Expand TAM aggressively (if we own SMB, incumbent can't
)
3. Partner with distribution (reseller, channel)
4. Plan exit scenario: attractive acquisition target if they move in

**Owner**: CEO  
**Timeline**: Start now, not later

---

### Risk 2: Well-Funded Competitor Enters
**Scenario**: CompA (Series B $30M) pivots from enterprise to SMB.
- **Probability**: Medium-High (65%) — they have budget, hiring aggressively
- **Timeline**: 6-9 months to product-market fit
- **Impact**: HIGH
  - They'll undercut our pricing (can afford to)
  - They'll match our features (can hire faster)
  - We win only on: speed to market, community

**Mitigation**:
1. Ship MVP in 4 months (before their launch)
2. Build community + network effects (harder to copy)
3. Focus on retention (lower churn = defensible)
4. Don't compete on features, compete on experience

**Owner**: CPO (product)  
**Timeline**: Q1 (now)

---

### Risk 3: Technology Disruption
**Scenario**: CompA is hiring Rust engineers + building real-time infrastructure. We use standard tech stack.
- **Probability**: Low (30%) — might be over-engineering
- **Timeline**: 12-18 months to see if it matters
- **Impact**: MEDIUM (if real-time becomes table-stakes)

**Mitigation**:
1. Validate: Do customers actually need real-time? (Interview 10 users)
2. Plan B: Re-architecture in 6 months if we need it
3. Stay on standard stack until proven otherwise

**Owner**: CTO  
**Timeline**: Validation in Month 2-3
```

### Step 7: Monitoring Plan

```markdown
## Ongoing Threat Monitoring

Run competitive-threat every quarter to track changes.

**Metrics to Watch**:
- [ ] CompA funding raised (every quarter)
- [ ] CompA hiring headcount (extrapolate from LinkedIn)
- [ ] CompA feature releases (count per month)
- [ ] CompA social mentions (sentiment analysis)
- [ ] CompB integration progress (how aggressive is incumbent?)
- [ ] Market consolidation (any other acquisitions?)
- [ ] Our vs CompA: Pricing diff, feature parity, release velocity

**Decision Gates**:
- If CompA reaches $100M funding + 50 engineers → Escalate threat level to CRITICAL
- If incumbent launches in our space → Immediate pivot strategy meeting
- If our release velocity drops vs competitors → Hiring sprint

**Review Cadence**: Quarterly (every 3 months)
**Owner**: CEO / CPO
```

### Step 8: Threat-Informed MVP Decisions

Connect threats to MVP scope (did we de-risk the right things?):

```markdown
## How Threats Inform MVP

**Threat**: CompA is 6-9 months away from SMB-focused product

**MVP Response**:
- ✅ Accelerate timeline (4 months, not 6)
- ✅ Ship core value fast (onboarding is table-stakes)
- ✅ Build for retention (community features > advanced)
- ⚠️ Don't build performance-heavy features yet (Rust can out-do us)
- 🟡 Plan for pricing pressure (CompA will undercut us)

**Feature Cuts**:
- Cut: "Advanced reporting" (nice-to-have, not defensive)
- Cut: "Real-time collaboration" (not requested, hard to defend)
- Keep: "Dead-simple onboarding" (our differentiation)
- Keep: "Community/sharing" (hard to copy, builds loyalty)
```

### Step 9: Write Output

Write to: `architecture-output/competitive-threat.md`

**Sections**:
1. Threat Landscape Matrix (competitors + scores)
2. Existential Risk Scorecard (high-impact risks)
3. Monitoring Plan (how to track threats over time)
4. Threat-Informed MVP (how threats reshape scope)
5. Sources (numbered list of URLs)

### Step 10: Update _state.json

```json
{
  "competitive_threats": {
    "generated_at": "<ISO-8601>",
    "top_threats": [
      { "competitor": "CompA", "threat_score": 76, "timeline": "6-9mo", "risk_level": "High" },
      { "competitor": "CompB", "threat_score": 79, "timeline": "3-6mo", "risk_level": "Critical" }
    ],
    "existential_risks": [
      { "risk": "Incumbent response", "probability": "Medium", "impact": "Critical", "mitigation": "[action plan]" }
    ],
    "monitoring_frequency": "Quarterly",
    "next_assessment_date": "2026-07-26"
  }
}
```

### Step 11: Log Activity

```json
{"ts":"<ISO-8601>","phase":"competitive-threat","outcome":"completed","files":["architecture-output/competitive-threat.md"],"summary":"Threat assessment complete. Top threat: [CompX, score X]. Existential risk level: [Medium/High]. Mitigations: [action plan]."}
```

## Output Rules

- Use founder-communication skill — this is CEO-level strategic analysis
- Every threat should be traced to specific evidence (WebSearch/WebFetch URLs)
- Confidence tags: [Verified], [Estimated], [Inferred] on all numbers
- Avoid alarmism (but don't downplay either)
- Always pair risk with specific, actionable mitigation
- Focus on what we can control (our speed, our quality, our positioning), not what we can't (market forces)

## When to Run

**Solo founder**: Optional (maybe yearly check-in)
**Competitive market**: Run quarterly (every 3 months)
**After funding raise**: Run immediately (investor will ask)
**Before major launches**: Run before each release (are we still differentiated?)
**Defensive mode**: Run monthly if competitor just moved

## Typical Output

- 4-6 pages
- 1 matrix of competitors with threat scores
- 2-3 existential risks with mitigations
- 1-2 pages on monitoring plan
- Appendix with sources
