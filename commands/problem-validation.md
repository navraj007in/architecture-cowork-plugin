---
description: Structured problem validation with assumptions testing and experiment design
---

# /architect:problem-validation

## Trigger

`/architect:problem-validation`

## Purpose

Rigorously validate the problem space before committing to a solution. Produces a structured analysis of assumptions, risks, evidence, and lightweight validation experiments — the kind of diligence a good investor or advisor would expect.

## Workflow

### Step 1: Gather Context

Read in this order:
1. `architecture-output/_state.json` — read first if it exists; provides compact personas (top pains per segment) and market_research (competitor weaknesses, market size, key insight) — use these instead of reading full markdown files
2. `intent.json` — product vision, target users, problem statement
3. `architecture-output/deep-research.md` — **only if `_state.json.market_research` is absent**; if reading, Grep for "Executive Summary" and "Opportunity Gaps" sections only
4. `architecture-output/user-personas.md` — **only if `_state.json.personas` is absent**; if reading, Grep for "Pain points" and "Current workflow" sections only

### Step 2: Research (if WebSearch available)

Search for:
- Evidence that this problem exists at scale (forum complaints, support tickets, industry reports)
- Existing solutions and their shortcomings (app store reviews, G2/Capterra reviews, Reddit threads)
- Market signals (funding in adjacent spaces, acquisition activity, regulatory changes)
- Counter-evidence — reasons this problem might NOT be worth solving

Tag all findings as [Verified] or [Inferred].

### Step 3: Problem Statement

Write a crisp problem statement using this structure:

> **[Target user segment]** struggles with **[specific problem]** because **[root cause]**. Currently they **[workaround/status quo]**, which costs them **[time/money/frustration metric]**. This affects approximately **[market size estimate]** people/businesses.

Then provide:
- **Problem severity score** (1-10) with justification
- **Problem frequency** — how often users encounter this (daily/weekly/monthly/rarely)
- **Existing alternatives** — what people do today (including "nothing")
- **Why now?** — what has changed that makes this problem solvable or urgent now (technology shift, regulation, behavioral change)

### Step 3.5: Problem Frequency & Severity Scoring (NEW)

Quantify problem validation using web data (reviews, forums, research):

**Frequency Analysis** — How many users mention this problem?
```
Data source: 200 reviews from G2, Capterra, Reddit, competitor support forums

Problem: "Steep learning curve"
- Frequency: 34% of reviews (68/200 mention this)
- Trend: Increasing 15% YoY (was 29% last year)
- Severity: Language = "takes 2 weeks to get productive", "frustrating", "steep"
- Sentiment: Negative (-0.7 on -1 to +1 scale)

Problem Frequency Score = (34% frequency × 0.4) + (15% trend growth × 0.3) + (Severity 7/10 × 0.3) = 64/100

Result: ✅ Validated problem (frequency + trend + sentiment all high)

vs.

Problem: "Doesn't support Italian language"
- Frequency: 2% of reviews (4/200 mention)
- Trend: Stable (no change YoY)
- Severity: Language = "would be nice", "minor issue"
- Sentiment: Neutral (0.1)

Score = (2% × 0.4) + (0% × 0.3) + (Severity 2/10 × 0.3) = 12/100

Result: ❌ Niche request, not foundational problem
```

**Output section**: "Problem Validation Scorecard"
```
| Problem | Frequency | Trend | Severity | Sentiment | Score | Confidence |
|---|---|---|---|---|---|---|
| Steep learning curve | 34% | +15% | 7/10 | -0.7 | 64 | High |
| Poor reporting | 18% | Stable | 6/10 | -0.6 | 48 | Medium |
| No mobile | 12% | -2% | 4/10 | -0.3 | 28 | Medium |

**Key finding**: Steep learning curve is THE problem (64/100). Ignore "no mobile" (28/100).
```

### Step 4: Assumption Mapping

Identify 12-15 assumptions across these categories:

#### Problem Assumptions (does the problem exist?)
List 4-5 assumptions about whether the problem is real and painful enough. For each:
- **Assumption** — one sentence
- **Confidence** — High/Medium/Low with reasoning
- **Evidence for** — what supports this (with sources)
- **Evidence against** — what contradicts this
- **Validation method** — how to test it cheaply
- **Risk if wrong** — what happens to the product if this assumption is false

#### Solution Assumptions (will our approach work?)
List 3-4 assumptions about whether the proposed solution is the right one.

#### Market Assumptions (will people pay?)
List 3-4 assumptions about market size, willingness to pay, and acquisition.

#### Execution Assumptions (can we build it?)
List 2-3 assumptions about technical feasibility, team capability, timeline.

### Step 4.5: Assumption Prioritization Matrix (NEW)

Not all assumptions are equal. Rank by criticality:

```
| Assumption | Category | Deal-breaker? | Current Confidence | Priority | Why |
|---|---|---|---|---|---|
| "Market will pay $X/mo" | Market | Yes | Low | P0 | If false, no revenue model |
| "Problem occurs Z times/week" | Problem | Yes | Medium | P0 | Unblocks all other assumptions |
| "We can build auth in 2 weeks" | Execution | Yes | High | P3 | We have expertise here |
| "Mobile users are 30% of target" | Market | No | Low | P2 | Nice-to-know, doesn't block MVP |
| "Switching from CompA costs $10K" | Market | No | Medium | P2 | Influences pricing, but negotiable |

**Kill-switch assumptions** (P0):
- Market will pay (affects revenue/funding)
- Problem occurs frequently enough (affects TAM)
- Core solution is viable (affects feasibility)

**Blockers** (P1):
- Requires specialized skills (hiring timeline)
- Infrastructure constraints (performance/cost)

**Optimizations** (P2-3):
- Exact feature parity
- Performance targets
- Expansion opportunities
```

**Testing strategy**: Test P0 assumptions immediately (week 1-2). If they fail, pivot before investing in P1-3.

### Step 5: Risk Assessment

Create a risk matrix covering:

| Risk | Category | Probability | Impact | Risk Score | Mitigation |
|------|----------|------------|--------|------------|------------|
| ...  | Market/Tech/Execution/Financial/Legal | 1-5 | 1-5 | P×I | Specific action |

Categories:
- **Market risk** — no demand, market too small, timing wrong
- **Technical risk** — can't build it, performance won't scale, integration complexity
- **Execution risk** — team gaps, timeline too aggressive, scope creep
- **Financial risk** — unit economics don't work, can't raise funding, runway too short
- **Competitive risk** — incumbent responds, well-funded competitor enters
- **Legal/Regulatory risk** — compliance requirements, data privacy, IP issues

### Step 6: Validation Experiments

Design 5 validation experiments, ordered by effort:

For EACH experiment:
- **Hypothesis** — "We believe [assumption]. If true, we expect [measurable outcome]."
- **Method** — specific steps to run the experiment (landing page, survey, fake door test, concierge MVP, etc.)
- **Effort** — time and cost estimate (e.g., "2 days, $50 in ads")
- **Success criteria** — specific numbers that would validate the hypothesis (e.g., "20% signup rate from landing page", "8/10 interview subjects describe this exact pain")
- **Failure criteria** — what would invalidate the hypothesis
- **What you learn** — regardless of outcome, what insight does this generate

Include a mix of:
1. **Smoke test** (1-2 days) — landing page or ad campaign to test demand
2. **Customer discovery** (3-5 days) — structured interviews with target users
3. **Competitive analysis** (1-2 days) — deep-dive into why existing solutions fail
4. **Concierge MVP** (1-2 weeks) — manually deliver the value proposition to 5-10 users
5. **Technical spike** (3-5 days) — prototype the riskiest technical assumption

### Step 6.5: Experiment Sequencing Plan (NEW)

Don't run all 5 experiments in parallel. Sequence them based on dependencies and learning:

```
WEEK 1-2: Smoke Test (validates problem existence)
├─ Hypothesis: "Problem exists at scale, people will search for solution"
├─ Method: Landing page + Google Ads targeting keyword searches
├─ Effort: 2 days, $200 ad spend
├─ Success: 20%+ signup rate, 100+ signups
├─ If PASS → Go to customer discovery
├─ If FAIL → Stop, problem is niche. Pivot or kill idea.
├─ Decision gate: Continue if >15% signup rate

WEEK 2-4: Customer Discovery (validates problem severity + willingness-to-pay)
├─ Prerequisite: Smoke test passed (problem interest confirmed)
├─ Hypothesis: "Target users experience pain frequently enough to pay"
├─ Method: 10 structured interviews with target personas
├─ Effort: 5 days (4 hours per interview + analysis)
├─ Success: 8/10 describe exact pain point, mention pricing range
├─ If PASS → Go to technical spike
├─ If FAIL → Problem isn't painful enough. Pivot to different segment.
├─ Decision gate: Continue if 7+ subjects describe pain

WEEK 4-5: Technical Spike (validates core assumptions are buildable)
├─ Prerequisite: Customer discovery confirms problem + value
├─ Hypothesis: "Core functionality is technically buildable in timeline"
├─ Method: 2-3 day prototype of riskiest component (e.g., auth, data import)
├─ Effort: 3 days
├─ Success: Core flow works, performance acceptable, no blockers
├─ If PASS → Go to concierge MVP
├─ If FAIL → Need to hire specialist or extend timeline
├─ Decision gate: Continue if prototype proves feasibility

WEEK 5-8: Concierge MVP (validates full solution, not just core)
├─ Prerequisite: Tech spike proves buildability
├─ Hypothesis: "Users can achieve value from our solution (manual version)"
├─ Method: Manually deliver solution to 5-10 pilot users
├─ Effort: 2-3 weeks (hands-on service delivery)
├─ Success: 5/10 users see measurable benefit, willing to pay
├─ If PASS → Proceed to full MVP build
├─ If FAIL → Solution concept is wrong. Pivot approach.
├─ Decision gate: Continue if 4+ users see clear value
```

**Key insight**: Each experiment unlocks assumptions for the next one:
- Smoke test → Validates problem exists (unblocks customer discovery)
- Customer discovery → Validates pain severity (unblocks technical spike)
- Technical spike → Validates buildability (unblocks concierge MVP)
- Concierge MVP → Validates full solution (unblocks engineering resources)

**If any gate fails**: Stop, pivot, or kill. Don't proceed to next experiment without passing gate criteria.

### Step 7: Validation Scorecard

Summarize the overall validation status:

| Dimension | Confidence | Key Evidence | Biggest Gap |
|-----------|-----------|-------------|-------------|
| Problem exists | High/Med/Low | ... | ... |
| Problem is painful enough to pay for | High/Med/Low | ... | ... |
| Our solution approach is viable | High/Med/Low | ... | ... |
| Market is large enough | High/Med/Low | ... | ... |
| We can build it | High/Med/Low | ... | ... |
| Timing is right | High/Med/Low | ... | ... |

**Overall readiness:** Ready to build / Needs more validation / Pivot recommended

**Recommended next step:** One specific action to take before writing code.

### Docs Publish (Optional)

Silently probe both Confluence and Notion to check which (if any) is connected.

**Check Confluence** — attempt `search_content` with a lightweight query (e.g. `query: "test", limit: 1`):
- If connected: ask "Publish problem validation to Confluence? (space key + optional parent page ID)"
- If confirmed: delegate to **confluence-publisher** with `artifact: "problem-validation"`, `projectName`, `spaceKey`, `parentPageId`, `projectDir`

**Check Notion** — attempt `notion_search` with `query: ""`, `page_size: 1`:
- If connected: ask "Publish problem validation to Notion? (optional parent page ID or database ID)"
- If confirmed: delegate to **notion-publisher** with `artifact: "problem-validation"`, `projectName`, `parentPageId` or `databaseId`, `projectDir`

If neither is connected, skip silently.

### Final Step: Update _state.json and Log Activity

After writing all output files:

1. Merge a completion marker into `architecture-output/_state.json`:
   - Read existing `_state.json` (or start with `{}`)
   - Merge the `problem_validation` field shown below — do NOT overwrite other fields
   - Write back to `architecture-output/_state.json`

```json
{
  "problem_validation": { 
    "generated_at": "<ISO-8601>", 
    "validated": true,
    "problem_score": 64,
    "problem_score_scale": "0-100",
    "confidence": "High",
    "kill_switch_assumptions": 3,
    "p0_assumptions_count": 3,
    "p1_assumptions_count": 2,
    "p2_assumptions_count": 4,
    "experiments_planned": 5,
    "experiment_sequence": [
      { "name": "Smoke test", "duration": "2 days", "order": 1 },
      { "name": "Customer discovery", "duration": "5 days", "order": 2 },
      { "name": "Technical spike", "duration": "3 days", "order": 3 },
      { "name": "Concierge MVP", "duration": "14 days", "order": 4 }
    ],
    "readiness": "Ready to build"
  }
}
```

**Guidelines**:
- `problem_score` — from Problem Frequency & Severity Scoring (0-100)
- `confidence` — High/Med/Low based on evidence weight
- `kill_switch_assumptions` — count of P0 assumptions
- `experiments_planned` — total number of validation experiments
- `experiment_sequence` — ordered list of experiments with durations
- `readiness` — "Ready to build" / "Needs more validation" / "Pivot recommended"

2. Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"problem-validation","outcome":"completed","files":["architecture-output/problem-validation.md"],"summary":"Problem validation completed: <N> assumptions mapped, <N> experiments designed, overall readiness: <status>."}
```

### Signal Completion

Emit the completion marker:

```
[PROBLEM_VALIDATION_DONE]
```

This ensures the problem-validation phase is marked as complete in the project state.

## Output Rules

- Write the full deliverable to `architecture-output/problem-validation.md`
- Create the `architecture-output/` directory if it doesn't exist
- Be intellectually honest — flag weak evidence, don't just confirm the idea
- Include counter-evidence and reasons this might fail
- Validation experiments must be specific and actionable, not generic
- Reference data from deep-research.md and user-personas.md when available
- Do NOT include the CTA footer
