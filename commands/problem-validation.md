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
  "problem_validation": { "generated_at": "<ISO-8601>", "validated": true }
}
```

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
