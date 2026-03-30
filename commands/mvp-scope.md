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
1. `architecture-output/_state.json` — read first if it exists; provides compact persona summaries, competitor data, and tech stack. Use `_state.json.personas` instead of reading `user-personas.md`. Use `_state.json.market_research` instead of reading `deep-research.md`.
2. `intent.json` — core features, target users, business constraints, technical constraints
3. `architecture-output/problem-validation.md` — validated assumptions, core problem (read in full, typically small)
4. `architecture-output/user-journeys.md` — critical user flows (read in full, typically small)
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

| Feature | Persona | Problem it Solves | Competitor Parity? | Complexity |
|---------|---------|-------------------|-------------------|------------|
| ...     | P1/P2   | ...               | Yes/No/Exceeds    | S/M/L/XL   |

Complexity sizing guide:
- **S** (Small) — 1-2 days, single component, well-understood pattern
- **M** (Medium) — 3-5 days, 2-3 components, some integration work
- **L** (Large) — 1-2 weeks, multiple components, requires design decisions
- **XL** (Extra Large) — 2-4 weeks, significant complexity, high risk

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

### Step 7: Cut Criteria

Define rules for when to cut scope during development:

- **Time trigger** — "If we're at 80% of timeline with <60% features done, cut all Could Haves and re-evaluate Should Haves"
- **Complexity trigger** — "If any single feature exceeds 2x its estimate, descope it to the simplest version"
- **Quality trigger** — "Never ship with broken Must Haves; delay launch instead"
- **Learning trigger** — "If user interviews during dev reveal a Must Have isn't wanted, demote it"

### Step 8: Success Metrics

Define how to measure if the MVP succeeded:

| Metric | Target | Measurement Method | Timeframe |
|--------|--------|-------------------|-----------|
| User signups | X | Analytics | First 30 days |
| Activation rate | X% | Event tracking | First 30 days |
| Core action completion | X% | Funnel analytics | First 30 days |
| Retention (D7) | X% | Cohort analysis | Day 7-14 |
| NPS / satisfaction | X | Survey | Day 14-30 |

### Step 9: Update _state.json

After writing `mvp-scope.md`, update `architecture-output/_state.json` with compact scope decisions:

1. Read existing `_state.json` (or start with `{}`)
2. Extract Must Have feature names and Won't Have feature names
3. Merge into the `mvp_scope` key and write back:

```json
{
  "mvp_scope": {
    "must_have": ["user auth", "vendor catalog", "purchase order creation", "basic approval workflow"],
    "wont_have": ["mobile app", "AI spend prediction", "multi-currency", "ERP integration"]
  }
}
```

Keep feature names short (3-5 words each). This lets `technical-roadmap` and `risk-register` understand MVP scope without reading the full mvp-scope.md.

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
