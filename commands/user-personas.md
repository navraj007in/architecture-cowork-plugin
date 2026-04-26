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

Read in this order — use what's available, skip what isn't needed:

1. **`architecture-output/_state.json`** — read first if it exists. Use directly:
   - `project.name`, `project.description` → product name and domain (replaces `intent.json`)
   - `market_research.key_insight`, `market_research.competitors[].weakness` → user pain context (replaces reading `deep-research.md`)
   - If `_state.json` has both `project` and `market_research`, skip steps 2–4 below

2. **`intent.json`** — only if `_state.json` is absent or missing `project.description`; extract name, vision, target users

3. **`architecture-output/deep-research.md`** — only if `_state.json.market_research` is absent; Grep for "User Segments", "Pain Points", and "Opportunity Gaps" sections only — do NOT read the full file

4. **`architecture-output/problem-validation.md`** — only if it exists AND `_state.json` has no `personas`; Grep for "Problem Statement" section only

5. **SDL** — skip entirely unless no other context is available

If nothing exists, derive personas from the project description in the prompt.

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

#### Psychographic Profile (NEW)
- **Decision-making style** — data-driven vs intuition-based, fast vs deliberative (e.g., "Decides based on peer recommendations" vs "Analyzes 5 tools before choosing")
- **Risk tolerance** — risk-averse vs risk-taking (e.g., "Won't adopt new tools without proof of ROI" vs "Tries new tools regularly")
- **Learning preferences** — self-directed vs hands-on training, reads docs vs calls support (e.g., "Prefers video tutorials" vs "Reads 200-page manuals")
- **Core values** — cost-saving vs quality, innovation vs stability, speed vs thoroughness (e.g., "Values cutting costs above all" vs "Quality matters more than budget")
- **Social proof influence** — influenced by influencers, follows industry trends, cares about brand reputation (e.g., "Always researches G2 reviews before buying" vs "Doesn't care what competitors use")

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

### Step 3.5: Validate Personas Against Market Data (NEW)

Cross-check generated personas against market research and segmentation:

**If `deep-research.md` exists**, run validation checklist:

For each persona:
- [ ] **Market segment alignment** — Which segment does this persona belong to? (Enterprise / Mid-market / SMB / Individual)
- [ ] **Segment size match** — Persona size estimate (S/M/L) aligns with market segment size from deep-research
- [ ] **Pain point verification** — Top pain point mentioned in competitor reviews? (If yes, ✅ validated)
- [ ] **Feature priority match** — Features persona wants align with competitive gaps from deep-research
- [ ] **Willingness-to-pay validation** — Estimated WTP aligns with pricing data from deep-research (not out of market range)

**Output validation summary** (add to personas.md):

```markdown
### Persona Validation Results

| Persona | Segment | Size Match | Pain Validated | Feature Gaps | WTP Alignment |
|---------|---------|-----------|---|---|---|
| Sarah (Procurement Manager) | Mid-market | ✅ 100K+ professionals | ✅ 34% mention "manual reconciliation" | ✅ Import + filter requests common | ✅ $79-99 within SMB range |
| James (Finance Director) | Enterprise | ⚠️ Small segment (10K) | ✅ 18% mention "month-end visibility" | ✅ Advanced reporting requested | ⚠️ Pricing $500-1000 untested |

**Gaps found**: James persona untested in market (small segment, high price). Recommend validating with finance director interviews before building for this persona.
```

**Impact on personas**: If validation reveals misalignments, adjust persona descriptions or defer to lower priority.

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

### Step 6: Docs Publish (Optional)

Silently probe both Confluence and Notion to check which (if any) is connected.

**Check Confluence** — attempt `search_content` with a lightweight query (e.g. `query: "test", limit: 1`):
- If connected: ask "Publish user personas to Confluence? (space key + optional parent page ID)"
- If confirmed: delegate to **confluence-publisher** with `artifact: "user-personas"`, `projectName`, `spaceKey`, `parentPageId`, `projectDir`

**Check Notion** — attempt `notion_search` with `query: ""`, `page_size: 1`:
- If connected: ask "Publish user personas to Notion? (optional parent page ID or database ID)"
- If confirmed: delegate to **notion-publisher** with `artifact: "user-personas"`, `projectName`, `parentPageId` or `databaseId`, `projectDir`

If neither is connected, skip silently.

### Step 7: Log Activity

After writing `user-personas.md`, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"user-personas","outcome":"completed","files":["architecture-output/user-personas.md"],"summary":"Generated user personas with prioritization matrix and design implications."}
```

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

### Step 8: Update _state.json

After writing `user-personas.md`, update `architecture-output/_state.json` with compact persona summaries:

1. Read existing `_state.json` (or start with `{}`)
2. For each persona, extract: name, role, priority (from prioritization matrix), top_pain, segment, validated (from validation step)
3. Merge into the `personas` array and write back:

```json
{
  "personas": [
    { 
      "name": "Sarah Chen", 
      "role": "Procurement Manager", 
      "priority": "P1", 
      "top_pain": "3h/week reconciling vendor invoices manually",
      "segment": "Mid-market",
      "validated": true,
      "decision_style": "data-driven",
      "risk_tolerance": "risk-averse"
    },
    { 
      "name": "James O.", 
      "role": "Finance Director", 
      "priority": "P2", 
      "top_pain": "no visibility into committed spend until month-end",
      "segment": "Enterprise",
      "validated": false,
      "validation_note": "Pricing untested in market segment",
      "decision_style": "deliberative",
      "risk_tolerance": "risk-averse"
    }
  ]
}
```

**Guidelines**:
- `segment` — which market segment from deep-research (Enterprise / Mid-market / SMB / Individual)
- `validated` — true/false based on Step 3.5 validation results
- `validation_note` — if false, why (small segment, untested price, etc.)
- `decision_style` and `risk_tolerance` — from psychographic profiling

### Signal Completion

Emit the completion marker:

```
[USER_PERSONAS_DONE]
```

This ensures the user-personas phase is marked as complete in the project state.

## Output Rules

- Write the full deliverable to `architecture-output/user-personas.md`
- Create the `architecture-output/` directory if it doesn't exist
- Use markdown with clear headings per persona
- Include the prioritization matrix and design implications — these are NOT optional
- Make personas specific and realistic, not generic archetypes
- Reference data from deep-research.md when available
- Do NOT include the CTA footer
