---
description: Research-backed user personas with behavioral depth and product implications
---

# /architect:user-personas

## Trigger

`/architect:user-personas`

## Purpose

Generate detailed, research-informed user personas that go beyond demographics to capture behaviors, motivations, and product design implications. These personas feed into user journeys, MVP scoping, and architecture decisions.

## Workflow

### Step 1: Gather Context

Read these files if they exist (do NOT ask the user — use what's available):
- `intent.json` — product name, vision, target users, core features
- `architecture-output/deep-research.md` — market data, competitor analysis, user segments
- `architecture-output/problem-validation.md` — problem statement, assumptions
- `solution.sdl.yaml` or `sdl.yaml` — existing architecture context

If none exist, derive personas from the project description provided in the prompt.

### Step 2: Research (if WebSearch available)

Use WebSearch to find:
- Real user complaints/needs in the product's domain (Reddit, forums, reviews)
- Demographic and behavioral data for the target market
- Competitor user reviews to identify underserved segments

Tag research findings as [Verified] or [Inferred].

### Step 3: Generate 4-5 Personas

For EACH persona, produce ALL of the following sections:

#### Identity
- **Name** — realistic first name + last initial
- **Age** — specific age, not a range
- **Role/Title** — specific job title or life role
- **Location** — city/region (affects tech access, cultural context)
- **Photo placeholder** — brief physical/style description for future design use

#### Demographics & Context
- **Income level** — approximate range relevant to pricing decisions
- **Tech savviness** — 1-5 scale with specific indicators (e.g., "Uses Notion daily, comfortable with APIs")
- **Device preferences** — primary device, OS, browser
- **Work environment** — remote/office/hybrid, team size, tools used daily

#### Behavioral Profile
- **Goals** (3-4) — what they're trying to achieve, ordered by priority
- **Pain points** (3-4) — current frustrations, with severity (Critical/High/Medium)
- **Current workflow** — step-by-step how they solve this problem TODAY without the product (include tools, workarounds, time spent)
- **Triggers** — what events or moments would make them search for a solution
- **Barriers to adoption** — what would stop them from trying/buying (price, switching cost, trust, learning curve)

#### Product Relationship
- **Features they'd use most** — map to specific product features from intent.json
- **Features they'd ignore** — what's irrelevant to this persona
- **Willingness to pay** — price sensitivity, payment preferences (monthly/annual), comparison anchor ("I currently pay $X for Y")
- **Acquisition channel** — how they'd discover the product (Google search, word of mouth, social media, community)
- **Success metric** — how THEY would measure if the product is working for them

#### Scenario
A 150-200 word narrative showing a day-in-the-life scenario where this persona discovers, evaluates, and uses the product. Include emotional states (frustrated → hopeful → satisfied). Make it specific and vivid.

#### Quotes
2-3 fictional but realistic quotes this persona might say:
- One about their current pain ("I spend 3 hours every week just...")
- One about what they'd want ("If only I could...")
- One about their evaluation criteria ("I'd switch if...")

### Step 4: Persona Prioritization Matrix

After all personas, include a summary table:

| Persona | Segment Size | Revenue Potential | Acquisition Cost | Priority |
|---------|-------------|-------------------|-----------------|----------|
| Name    | S/M/L       | $/$$/$$$          | Low/Med/High    | P1/P2/P3 |

And a brief recommendation: "Build for [Primary Persona] first because..."

### Step 5: Design Implications

A section mapping personas to product decisions:
- **Onboarding complexity** — which personas need hand-holding vs. self-serve
- **Feature gating** — which features matter to which tier
- **Pricing tiers** — how personas map to pricing plans
- **Communication tone** — technical vs. friendly vs. enterprise
- **Platform priority** — mobile-first vs. desktop-first based on persona devices

### Step 6: Update _state.json

After writing `user-personas.md`, update `architecture-output/_state.json` with compact persona summaries:

1. Read existing `_state.json` (or start with `{}`)
2. For each persona, extract: name, role, priority (from prioritization matrix), top_pain (single most critical pain point, ≤15 words)
3. Merge into the `personas` array and write back:

```json
{
  "personas": [
    { "name": "Sarah Chen", "role": "Procurement Manager", "priority": "P1", "top_pain": "3h/week reconciling vendor invoices manually" },
    { "name": "James O.", "role": "Finance Director", "priority": "P2", "top_pain": "no visibility into committed spend until month-end" }
  ]
}
```

## Output Rules

- Write the full deliverable to `architecture-output/user-personas.md`
- Create the `architecture-output/` directory if it doesn't exist
- Use markdown with clear headings per persona
- Include the prioritization matrix and design implications — these are NOT optional
- Make personas specific and realistic, not generic archetypes
- Reference data from deep-research.md when available
- Do NOT include the CTA footer
