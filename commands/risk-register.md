---
description: Comprehensive risk register with quantified impact, mitigations, and monitoring triggers
---

# /architect:risk-register

## Trigger

`/architect:risk-register`

## Purpose

Identify, quantify, and plan mitigations for all material risks across the product lifecycle. Produces a living risk register that serves as an early warning system — not a checkbox exercise but a practical tool for making better decisions under uncertainty.

## Workflow

### Step 1: Gather Context

Read these files if they exist:
- `intent.json` — product vision, constraints, business model
- `architecture-output/deep-research.md` — competitive threats, market risks
- `architecture-output/problem-validation.md` — assumption risks, validation gaps
- `architecture-output/mvp-scope.md` — scope and complexity risks
- `architecture-output/technical-roadmap.md` — timeline and dependency risks
- `architecture-output/cost-estimate.md` — financial risks
- `architecture-output/user-personas.md` — adoption risks
- `solution.sdl.yaml` — technical architecture risks

### Step 2: Risk Identification

Systematically identify risks across ALL of these categories:

#### Market Risks (4-5 risks)
- No product-market fit / problem isn't painful enough
- Market too small or too competitive
- Timing wrong (too early / too late)
- Customer acquisition costs exceed LTV
- Regulatory/legal changes that affect the market

#### Technical Risks (4-5 risks)
- Core technology won't scale / performance bottleneck
- Integration complexity with third-party services
- Data migration / schema evolution challenges
- Security vulnerability in a critical path
- AI/ML model accuracy or reliability (if applicable)
- Dependency on a single vendor or API

#### Product Risks (3-4 risks)
- Wrong features prioritized in MVP
- UX too complex for target persona
- Onboarding drop-off too high
- Feature parity gap with competitors

#### Execution Risks (3-4 risks)
- Timeline significantly underestimated
- Key person dependency (bus factor = 1)
- Scope creep during development
- Technical debt accumulates too fast

#### Financial Risks (3-4 risks)
- Infrastructure costs exceed projections at scale
- Revenue per user lower than modeled
- Runway insufficient to reach product-market fit
- Pricing model doesn't convert

#### Legal & Compliance Risks (2-3 risks)
- Data privacy regulations (GDPR, CCPA, HIPAA)
- IP infringement (patents, trademarks)
- Terms of service violations with platform dependencies
- Open source license compliance

### Step 3: Risk Assessment

For EACH risk, produce a detailed assessment:

#### Risk Card Format

**Risk ID:** R-001
**Title:** [Descriptive title]
**Category:** Market / Technical / Product / Execution / Financial / Legal
**Description:** 2-3 sentences describing what could go wrong and the chain of consequences.

**Probability:** 1-5 scale
| Score | Label | Meaning |
|-------|-------|---------|
| 1 | Rare | <10% chance in next 6 months |
| 2 | Unlikely | 10-25% chance |
| 3 | Possible | 25-50% chance |
| 4 | Likely | 50-75% chance |
| 5 | Almost Certain | >75% chance |

**Impact:** 1-5 scale
| Score | Label | Meaning |
|-------|-------|---------|
| 1 | Negligible | Minor inconvenience, <1 day to resolve |
| 2 | Minor | Some rework needed, 1-5 days impact |
| 3 | Moderate | Feature delay or budget overrun of 10-25% |
| 4 | Major | Significant pivot needed, 25-50% budget/timeline impact |
| 5 | Critical | Project failure or existential threat |

**Risk Score:** P × I = X (Low: 1-6, Medium: 7-12, High: 13-19, Critical: 20-25)

**Leading Indicators:** Early warning signs that this risk is materializing:
- Indicator 1: "If [observable event], this risk is becoming real"
- Indicator 2: "Monitor [metric] weekly — if it exceeds [threshold], escalate"

**Mitigation Strategy:**
- **Prevent:** Actions to reduce probability (do these now)
- **Prepare:** Actions to reduce impact if it happens (plan these now, execute if triggered)
- **Respond:** What to do when the risk materializes (decision framework, not improvisation)

**Owner:** Role responsible for monitoring this risk
**Review Frequency:** Weekly / Biweekly / Monthly

### Step 4: Risk Matrix

Visual 5×5 heat map:

```
Impact
  5 | [     ] [     ] [R-003] [R-001] [     ]
  4 | [     ] [R-007] [R-005] [     ] [     ]
  3 | [R-012] [R-008] [R-004] [R-002] [     ]
  2 | [     ] [R-010] [R-009] [     ] [     ]
  1 | [R-011] [     ] [     ] [     ] [     ]
    +------------------------------------------
      1       2       3       4       5
                  Probability
```

Color zones:
- **Critical (20-25):** Immediate action required — block release if unmitigated
- **High (13-19):** Active mitigation in progress — review weekly
- **Medium (7-12):** Monitored with planned response — review biweekly
- **Low (1-6):** Accepted — review monthly

### Step 5: Risk Summary Table

| ID | Risk | Category | P | I | Score | Level | Mitigation Status | Owner |
|----|------|----------|---|---|-------|-------|-------------------|-------|
| R-001 | ... | Market | 4 | 5 | 20 | Critical | In progress | Founder |
| R-002 | ... | Technical | 3 | 4 | 12 | Medium | Planned | Tech Lead |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |

Sort by Risk Score descending.

### Step 6: Top 5 Actions

The 5 most important risk mitigation actions to take in the next 30 days:

| Priority | Action | Addresses Risk | Effort | Deadline |
|----------|--------|---------------|--------|----------|
| 1 | [Specific action] | R-001, R-003 | S/M/L | This week |
| 2 | [Specific action] | R-002 | S/M/L | Week 2 |
| 3 | [Specific action] | R-005 | S/M/L | Week 2 |
| 4 | [Specific action] | R-004 | S/M/L | Week 3 |
| 5 | [Specific action] | R-007 | S/M/L | Week 4 |

### Step 7: Risk Appetite Statement

Define the project's risk tolerance:

- **Technical risk tolerance:** [High — willing to use bleeding-edge tech / Medium — proven stack with some experiments / Low — only battle-tested technologies]
- **Market risk tolerance:** [High — unvalidated market / Medium — some signals / Low — proven demand]
- **Financial risk tolerance:** [Runway of X months, maximum acceptable burn rate of $X/month]
- **Timeline risk tolerance:** [Hard deadline / Flexible / Open-ended]

### Step 8: Review Schedule

| Review Type | Frequency | Participants | Focus |
|-------------|-----------|-------------|-------|
| Risk check-in | Weekly | Tech lead | Critical + High risks only |
| Full risk review | Biweekly | Full team | All risks, update scores |
| Risk retrospective | Monthly | Full team + advisors | Re-score, add new risks, retire resolved |

## Output Rules

- Write the full deliverable to `architecture-output/risk-register.md`
- Create the `architecture-output/` directory if it doesn't exist
- Identify minimum 15 risks across all categories — don't just cover the obvious ones
- Be specific — "technical risk" is not a risk, "PostgreSQL full-text search won't meet latency requirements at 10K concurrent queries" is a risk
- Leading indicators are NOT optional — they're what makes a risk register useful vs. decorative
- Mitigations must be actionable, not generic ("reduce risk" is not a mitigation)
- Reference specific architecture decisions, features, and constraints from other deliverables
- Do NOT include the CTA footer
