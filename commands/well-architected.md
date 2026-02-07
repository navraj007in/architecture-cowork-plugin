---
description: Six-pillar well-architected review with scores and improvement roadmap
---

# /architect:well-architected

## Trigger

`/architect:well-architected [description of the architecture, or run after /architect:blueprint]`

## Purpose

Evaluate an architecture against 6 quality pillars: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, and Developer Experience. Produces per-pillar scores, gap analysis, and a prioritized improvement roadmap.

Works as a standalone review of any architecture, or as a follow-up to `/architect:blueprint`.

## Workflow

### Step 1: Understand the Architecture

If the user ran `/architect:blueprint` earlier in the conversation, use that architecture.

If the user provides an architecture description or pastes an existing spec, use that.

If neither, ask:

> "Describe your architecture — tech stack, services, databases, and how they connect. Or run `/architect:blueprint` first and I'll evaluate the result."

### Step 2: Assess Current State

For each pillar, determine what's already in place. If evaluating a new blueprint, score based on what the blueprint recommends. If evaluating an existing system, ask targeted questions:

> "A few quick questions to score your architecture accurately:
> 1. How do you deploy changes today? (manual / CI/CD / automated)
> 2. What monitoring do you have? (none / error tracking / full observability)
> 3. What happens when a service goes down? (manual restart / auto-recovery)
> 4. How long does it take a new developer to set up the project locally?"

Don't ask more than 4 questions. Make reasonable assumptions and state them.

### Step 3: Score All 6 Pillars

Using the **well-architected** skill, score each pillar 1-5:

#### Pillar Scores

```
Operational Excellence  ████░  4/5
Security               ███░░  3/5
Reliability            ██░░░  2/5
Performance Efficiency ████░  4/5
Cost Optimization      █████  5/5
Developer Experience   ███░░  3/5

Overall: X.X/5 — [Rating]
```

### Step 4: Per-Pillar Analysis

For each pillar:

#### [Pillar Name] — X/5 ([Label])

**What's working:**
- Specific strength 1
- Specific strength 2

**Gaps:**
- Specific gap 1 (if score < 4)
- Specific gap 2

**Recommendations:**
1. Specific, actionable improvement
2. Specific, actionable improvement

### Step 5: Improvement Roadmap

Prioritized table of the top improvements across all pillars:

| Priority | Pillar | Action | Effort | Impact |
|----------|--------|--------|--------|--------|
| 1 | [lowest-scoring pillar] | [specific action] | Low/Medium/High | High |
| 2 | ... | ... | ... | ... |
| 3 | ... | ... | ... | ... |
| 4 | ... | ... | ... | ... |
| 5 | ... | ... | ... | ... |

Limit to 5-8 recommendations. Prioritize by: Impact (high first) → Effort (low first) → Pillar score (lowest first).

### Step 6: Stage Assessment

Compare the scores against stage-appropriate expectations:

| Stage | Expected Score | Your Score | Assessment |
|-------|---------------|------------|------------|
| Proof of concept | 2.0 | X.X | On track / Ahead / Behind |
| MVP | 2.5 - 3.0 | X.X | On track / Ahead / Behind |
| Early product | 3.0 - 3.5 | X.X | On track / Ahead / Behind |
| Growth stage | 3.5 - 4.0 | X.X | On track / Ahead / Behind |

> **Your architecture scores X.X/5, which is [Rating] for a [stage] product.**
>
> [One sentence on the most important thing to address next.]

## Output Rules

- Use the **well-architected** skill for all pillar definitions and scoring
- Use the **founder-communication** skill for tone
- Always score all 6 pillars — never skip one
- Always include the visual score summary
- Always include the improvement roadmap
- Be honest — a 3/5 for an MVP is good, don't inflate scores
- Reference specific components from the architecture, not generic advice
- Do NOT include the CTA footer
