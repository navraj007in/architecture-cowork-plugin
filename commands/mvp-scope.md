---
description: MVP boundary definition with prioritized features, user stories, and cut criteria
---

# /architect:mvp-scope

## Trigger

`/architect:mvp-scope`

## Purpose

Define a sharp MVP boundary that maximizes learning while minimizing build time. Produces a prioritized feature set with user stories, complexity estimates, and clear cut criteria — preventing scope creep and ensuring the team builds the right v1.

## Workflow

### Step 1: Gather Context

Read in this order:
1. `architecture-output/_state.json` — read first if it exists; use `project`, `personas`, `market_research`, `mvp_scope` directly — these replace reading intent.json, user-personas.md, and deep-research.md
2. `intent.json` — **only if `_state.json.project` is absent**; extract name, vision, core features, business/technical constraints
3. `architecture-output/problem-validation.md` — **only if it exists**; Grep for "Problem Statement" and "Core Assumptions" sections only
4. `architecture-output/user-journeys.md` — **only if it exists**; Grep for journey names and "Success state" lines only
5. `architecture-output/deep-research.md` — **only if `_state.json.market_research` is absent**; if reading, use Grep for the "Feature Comparison Matrix" and "Opportunity Gaps" sections only
6. `architecture-output/user-personas.md` — **only if `_state.json.personas` is absent**; if reading, use Grep for persona names and "Features they'd use most"

### Step 2: Define the MVP Thesis

Write a clear MVP thesis statement:

> **MVP Goal:** Enable [primary persona] to [core action] so they can [measurable outcome], validated by [success metric].

Then define:
- **Core value proposition** — the ONE thing the MVP must prove
- **Time constraint** — target launch timeline (derive from intent.json or estimate based on scope)
- **Team constraint** — assumed team size (derive from intent.json or assume solo/small team)
- **What this MVP is NOT** — explicit anti-goals (3-5 things people might expect but aren't included)

### Step 3: Feature Inventory

List ALL possible features mentioned across intent.json, personas, and research. For each:

| Feature | Persona | Problem it Solves | Competitor Parity? | Our Angle | Complexity | Effort Estimate |
|---------|---------|-------------------|-------------------|-----------|------------|-----------------|
| ...     | P1/P2   | ...               | Parity/Behind/Ahead | [differentiator] | S/M/L/XL  | [dev-days ± buffer] |

**Competitor Parity Assessment** (NEW):
- **Parity** — All competitors have this, it's table-stakes (include in MVP)
- **Behind** — Competitors have this, we don't (must-have for competitive positioning)
- **Ahead** — We can exceed competitor capability (differentiator, may defer to v1.1)

**Complexity & Estimation** (NEW):
Complexity sizing guide with effort estimates:
- **S** (Small) — 1-2 days, single component, well-understood pattern → Estimate: 1.5 days + 0.5 day buffer = 2 days
- **M** (Medium) — 3-5 days, 2-3 components, some integration → Estimate: 4 days + 1 day buffer = 5 days
- **L** (Large) — 1-2 weeks, multiple components, requires design → Estimate: 10 days + 2 day buffer = 12 days
- **XL** (Extra Large) — 2-4 weeks, significant complexity, high risk → Estimate: 20 days + 5 day buffer = 25 days

**Historical baseline**: If you have past project data, compare similar features (e.g., "User import was 4 days in Project X, similar complexity here, estimate 5 days accounting for 25% overrun")

### Step 4: MoSCoW Prioritization

Categorize every feature with justification:

#### Must Have (MVP will fail without these)
For each feature:
- **Feature name**
- **User story** — "As a [persona], I want to [action] so that [benefit]"
- **Acceptance criteria** (3-5 specific, testable criteria)
- **Complexity** — S/M/L/XL with brief justification
- **Dependencies** — what must be built first
- **Why Must Have** — what breaks if this is missing

#### Should Have (significantly improves MVP but not blocking)
Same format, plus:
- **Deferral risk** — what happens if this ships in v1.1 instead of v1.0

#### Could Have (nice to have, include if time permits)
Same format, plus:
- **Effort-to-value ratio** — is this a quick win or a rabbit hole?

#### Won't Have (explicitly deferred to post-MVP)
For each:
- **Feature name**
- **Why deferred** — specific reason (too complex, unvalidated need, premature optimization, etc.)
- **When to reconsider** — trigger that would move this to Should Have (e.g., "When we have 100+ users requesting this")

### Step 5: MVP Scope Summary

| Priority | Features | Total Complexity | Est. Effort |
|----------|----------|-----------------|-------------|
| Must Have | N features | X story points | Y dev-weeks |
| Should Have | N features | X story points | Y dev-weeks |
| Could Have | N features | X story points | Y dev-weeks |
| Won't Have | N features | — | — |
| **MVP Total** | **N features** | **X points** | **Y dev-weeks** |

### Step 6: Critical Path

Identify the build order — what must be built first:

```
Phase 1 (Foundation): Auth, DB schema, base API → X days
Phase 2 (Core Loop): [primary feature], [supporting feature] → X days
Phase 3 (Complete MVP): [remaining Must Haves] → X days
Phase 4 (Polish): Error handling, edge cases, basic analytics → X days
```

Include a dependency graph showing which features block which.

### Step 6.5: Resource Bottleneck Analysis (NEW)

Identify which resources constrain the timeline:

```
Team: 2 backend engineers, 1 frontend engineer, 1 designer

Phase 1 (Auth + DB): Days 1-20
├─ Both backend engineers: Auth, DB schema, base API (can parallelize partially)
├─ Backend bottleneck: BOTH engineers allocated 100%, frontend waits on API
├─ Timeline: 20 days (no parallelization possible)

Phase 2 (Core loop): Days 20-35
├─ Bottleneck: Backend engineer on data import (8 days)
├─ Frontend can work on UI in parallel: 8 days
├─ But they BOTH need backend API first (dependency)
├─ Timeline: 35 days (backend is critical path)

Phase 3 (Remaining must-haves): Days 35-48
├─ Bottleneck: Backend engineer (spread thin across 3 features)
├─ Frontend moves faster (2 features in 5 days)
├─ Backend BLOCKS progress (one engineer can't do 3 features in 13 days)
├─ Option A: Hire contractor (cost $5-10K, accelerates by 5 days)
├─ Option B: Parallelize differently (defer 1 must-have to v1.1)
├─ Option C: Slow timeline (accept 50+ day MVP)

DECISION: Hire contractor for data import feature (5 days instead of 10)
Cost: $8K, Benefit: Hits 40-day target instead of 50-day
```

**Output**: "Resource Constraints & Mitigation"
- Identify which role is constrained (usually 1 backend engineer, 1 designer)
- Calculate timeline impact (X additional days if no hire)
- Recommend: Hire, outsource, defer feature, or extend timeline

### Step 7: Launch Gates (NEW)

Define explicit pass/hold/pivot criteria:

```markdown
### Launch Gates — MVP Must Clear These

**Beta Testing**:
- [ ] 5+ users complete end-to-end flow without blocking issues
- [ ] <2 critical bugs per user session (average)
- [ ] Qualitative feedback: Users confirm problem is solved

**Performance**:
- [ ] Core action completes in <2 seconds (p95 latency)
- [ ] System handles 1000 concurrent users without degradation
- [ ] No memory leaks or resource exhaustion in 4-hour sessions

**Security & Data**:
- [ ] No critical vulnerabilities in auth, data exposure, injection attacks
- [ ] User data encrypted in transit + at rest
- [ ] Password reset and account recovery tested

**Data Quality**:
- [ ] Automated test suite: 100+ test cases covering happy path + edge cases
- [ ] Data validation: Imported data matches source within <1% variance
- [ ] Error messages: All 500 errors have logged context for debugging

**Documentation**:
- [ ] Onboarding guide tested with 2 non-technical users (can they get value in <30 min?)
- [ ] API documentation complete (if exposing endpoints)
- [ ] Support runbook: Common issues + solutions documented

**Recommendation**:
- ✅ **LAUNCH** — All gates pass, ship to production
- 🟡 **HOLD** — 1-2 gates failing, ship with mitigation plan + hotfix schedule
- 🔴 **PIVOT** — 3+ gates failing, problem is bigger than expected, reassess

**No "ship anyway"** — if a gate fails, explicitly decide to hold/pivot. Don't ignore.
```

### Step 7: Cut Criteria

Define rules for when to cut scope during development:

- **Time trigger** — "If we're at 80% of timeline with <60% features done, cut all Could Haves and re-evaluate Should Haves"
- **Complexity trigger** — "If any single feature exceeds 2x its estimate, descope it to the simplest version"
- **Quality trigger** — "Never ship with broken Must Haves; delay launch instead"
- **Learning trigger** — "If user interviews during dev reveal a Must Have isn't wanted, demote it"

### Step 9: Success Metrics

Define how to measure if the MVP succeeded:

| Metric | Target | Measurement Method | Timeframe |
|--------|--------|-------------------|-----------|
| User signups | X | Analytics | First 30 days |
| Activation rate | X% | Event tracking | First 30 days |
| Core action completion | X% | Funnel analytics | First 30 days |
| Retention (D7) | X% | Cohort analysis | Day 7-14 |
| NPS / satisfaction | X | Survey | Day 14-30 |

### Step 10: Docs Publish (Optional)

Silently probe both Confluence and Notion to check which (if any) is connected.

**Check Confluence** — attempt `search_content` with a lightweight query (e.g. `query: "test", limit: 1`):
- If connected: ask "Publish MVP scope to Confluence? (space key + optional parent page ID)"
- If confirmed: delegate to **confluence-publisher** with `artifact: "mvp-scope"`, `projectName`, `spaceKey`, `parentPageId`, `projectDir`

**Check Notion** — attempt `notion_search` with `query: ""`, `page_size: 1`:
- If connected: ask "Publish MVP scope to Notion? (optional parent page ID or database ID)"
- If confirmed: delegate to **notion-publisher** with `artifact: "mvp-scope"`, `projectName`, `parentPageId` or `databaseId`, `projectDir`

If neither is connected, skip silently.

### Step 11: Log Activity

After writing `mvp-scope.md`, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"mvp-scope","outcome":"completed","files":["architecture-output/mvp-scope.md"],"summary":"Defined MVP scope with MoSCoW prioritization, critical path, and launch gates."}
```

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

### Step 12: Update _state.json

After writing `mvp-scope.md`, update `architecture-output/_state.json` with compact scope decisions:

1. Read existing `_state.json` (or start with `{}`)
2. Extract Must Have feature names, Won't Have features, complexity estimates, and launch gates
3. Merge into the `mvp_scope` key and write back:

```json
{
  "mvp_scope": {
    "must_have": [
      { "feature": "user auth", "complexity": "M", "effort_days": 5 },
      { "feature": "vendor catalog", "complexity": "M", "effort_days": 6 },
      { "feature": "purchase order creation", "complexity": "L", "effort_days": 12 },
      { "feature": "basic approval workflow", "complexity": "M", "effort_days": 8 }
    ],
    "wont_have": ["mobile app", "AI spend prediction", "multi-currency", "ERP integration"],
    "timeline_estimate": {
      "total_dev_days": 40,
      "estimated_weeks": 7,
      "critical_path": "Purchase order + approval workflow",
      "bottleneck": "Backend engineer",
      "mitigation": "Hire contractor for data import feature"
    },
    "launch_gates": {
      "beta_testing": "5+ users complete flow, <2 critical bugs",
      "performance": "Core action <2s (p95), 1000 concurrent users",
      "security": "No critical vulns, auth+data tested",
      "readiness": "Ready to launch"
    }
  }
}
```

Guidelines:
- Each must-have should include complexity (S/M/L/XL) and estimated effort (dev-days)
- Include total timeline estimate and critical path
- List identified bottleneck and recommended mitigation
- Include launch gates pass/hold/pivot status
- Keep feature names short (3-5 words each)

### Signal Completion

Emit the completion marker:

```
[MVP_SCOPE_DONE]
```

This ensures the mvp-scope phase is marked as complete in the project state.

## Output Rules

- Write the full deliverable to `architecture-output/mvp-scope.md`
- Create the `architecture-output/` directory if it doesn't exist
- Be ruthless about scope — a good MVP is smaller than people expect
- Every Must Have needs user stories AND acceptance criteria — no exceptions
- Reference specific personas by name from user-personas.md
- Include the cut criteria section — this prevents scope creep during build
- If any single output file exceeds ~15KB, split into `mvp-scope-features.md` and `mvp-scope-stories.md` (and further parts if needed) and write an index file
- Use tables instead of prose for structured data (feature inventory, MoSCoW summary, success metrics)
- Do NOT include the CTA footer
