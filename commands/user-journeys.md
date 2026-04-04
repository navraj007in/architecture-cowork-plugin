---
description: Detailed user journey maps with touchpoints, emotions, and design opportunities
---

# /architect:user-journeys

## Trigger

`/architect:user-journeys`

## Purpose

Map the complete user experience from discovery through retention. Produces detailed journey maps that reveal design opportunities, potential drop-off points, and emotional dynamics — directly informing UI/UX decisions, onboarding flows, and feature prioritization.

## Workflow

### Step 1: Gather Context

Read in this order:
1. `architecture-output/_state.json` — read first if it exists; use `project`, `personas`, `mvp_scope`, `market_research` directly — these replace reading intent.json and full markdown files
2. `intent.json` — **only if `_state.json.project` is absent**; extract name, vision, core features
3. SDL — **only if `_state.json.components` is absent**; check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Grep for `product:` block (screens, coreFlows) and `components:` block only — do NOT read the full file
4. `architecture-output/user-personas.md` — **only if `_state.json.personas` is absent**; if reading, Grep for persona goals and "Current workflow" sections only
5. `architecture-output/mvp-scope.md` — **only if `_state.json.mvp_scope` is absent**; if reading, Grep for "Must Have" section only
6. `architecture-output/deep-research.md` — **only if `_state.json.market_research` is absent**; if reading, Grep for competitor weakness/UX gaps only

### Step 2: Identify Core Journeys

Define 4-6 journeys covering the full lifecycle:

1. **Discovery → Signup** — how each persona finds and evaluates the product
2. **Onboarding → First Value** — from signup to the "aha moment"
3. **Core Loop** — the primary repeated action that delivers ongoing value
4. **[Feature-Specific Journey]** — for 1-2 key features from MVP scope
5. **Error/Recovery** — what happens when things go wrong
6. **Upgrade/Expansion** — from free to paid, or from basic to advanced usage

### Step 3: Generate Each Journey Map

For EACH journey, produce ALL of the following:

#### Journey Header
- **Journey name** — descriptive title
- **Persona** — which persona (reference by name from user-personas.md)
- **Goal** — what the user is trying to accomplish
- **Entry point** — where/how they start this journey
- **Success state** — what "done" looks like
- **Estimated duration** — how long this journey takes (minutes/hours/days)

#### Stage-by-Stage Breakdown

For each stage of the journey (typically 5-8 stages):

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Points | Opportunities |
|-------|--------|------------|----------|---------|-------------|---------------|
| 1. Awareness | ... | Google/Social/Referral | "I need a better way to..." | Frustrated (3/5) | Too many options | Clear positioning |
| 2. Evaluation | ... | Landing page | "Does this solve my problem?" | Curious (3/5) | Unclear pricing | Social proof |
| ... | ... | ... | ... | ... | ... | ... |

For each stage, expand with:

**Action:** What the user does (specific clicks, reads, decisions)

**Touchpoint:** The interface or channel (landing page, email, app screen, notification, support chat)

**Thinking:** Internal monologue — what questions or thoughts they have (use quotes: "How much does this cost?" / "Is my data safe?")

**Feeling:** Emotional state on a 1-5 scale with label:
- 1 = Frustrated/Anxious
- 2 = Confused/Uncertain
- 3 = Neutral/Evaluating
- 4 = Engaged/Hopeful
- 5 = Delighted/Confident

**Pain Points:** Specific friction (loading time, unclear copy, too many steps, missing info, trust concerns)

**Opportunities:** Design or feature opportunities to improve this moment

#### Emotion Curve

Draw an ASCII emotion curve for the journey:

```
Feeling  5 |                              ★ First value
         4 |                         ·····
         3 |    ···           ·····
         2 |  ··   ···  ····
         1 | ·        ··
           +--------------------------------→ Time
             Aware  Signup  Setup  Use  Success
```

#### Key Moments

Identify the critical moments in this journey:
- **Moment of Truth** — the single interaction that determines if the user continues or abandons
- **Aha Moment** — when the user first realizes the product's value
- **Drop-off Risk** — the stage with highest abandonment probability and why
- **Delight Opportunity** — where a small touch could create outsized positive impression

### Step 4: Cross-Journey Analysis

After all individual journeys, provide:

#### Touchpoint Inventory

| Touchpoint | Journeys | Priority | Status |
|------------|----------|----------|--------|
| Landing page | Discovery, Upgrade | Critical | Needs design |
| Onboarding wizard | Onboarding | Critical | Needs design |
| Dashboard | Core Loop | Critical | Needs design |
| Email notifications | Onboarding, Core Loop | High | Needs design |
| Error page | Error/Recovery | Medium | Needs design |
| ... | ... | ... | ... |

#### Friction Map

Aggregate the top 10 friction points across all journeys:

| Friction Point | Journey | Stage | Severity | Fix Complexity | Priority |
|----------------|---------|-------|----------|----------------|----------|
| ... | ... | ... | High/Med/Low | S/M/L | P1/P2/P3 |

#### Journey Metrics

For each journey, define measurable KPIs:

| Journey | Key Metric | Target | Measurement |
|---------|-----------|--------|-------------|
| Discovery → Signup | Conversion rate | 5-10% | Analytics |
| Onboarding → First Value | Time to value | <5 min | Event tracking |
| Core Loop | Weekly active usage | 3x/week | Analytics |
| ... | ... | ... | ... |

### Step 5: Recommendations

Prioritized list of 8-10 UX/product recommendations derived from the journey analysis:

1. **[Recommendation]** — Because [journey insight]. Impact: [High/Med]. Effort: [S/M/L].

### Docs Publish (Optional)

Silently probe both Confluence and Notion to check which (if any) is connected.

**Check Confluence** — attempt `search_content` with a lightweight query (e.g. `query: "test", limit: 1`):
- If connected: ask "Publish user journeys to Confluence? (space key + optional parent page ID)"
- If confirmed: delegate to **confluence-publisher** with `artifact: "user-journeys"`, `projectName`, `spaceKey`, `parentPageId`, `projectDir`

**Check Notion** — attempt `notion_search` with `query: ""`, `page_size: 1`:
- If connected: ask "Publish user journeys to Notion? (optional parent page ID or database ID)"
- If confirmed: delegate to **notion-publisher** with `artifact: "user-journeys"`, `projectName`, `parentPageId` or `databaseId`, `projectDir`

If neither is connected, skip silently.

### Final Step: Update _state.json and Log Activity

After writing all output files:

1. Merge a completion marker into `architecture-output/_state.json`:
   - Read existing `_state.json` (or start with `{}`)
   - Merge the `user_journeys` field shown below — do NOT overwrite other fields
   - Write back to `architecture-output/_state.json`

```json
{
  "user_journeys": { "generated_at": "<ISO-8601>", "journey_count": <N> }
}
```

(Replace `<N>` with the actual number of journey maps generated.)

2. Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"user-journeys","outcome":"completed","files":["architecture-output/user-journeys.md"],"summary":"User journeys mapped: <N> journeys across <N> personas with friction analysis and touchpoint inventory."}
```

### Signal Completion

Emit the completion marker:

```
[USER_JOURNEYS_DONE]
```

This ensures the user-journeys phase is marked as complete in the project state.

## Output Rules

- Write the full deliverable to `architecture-output/user-journeys.md`
- Create the `architecture-output/` directory if it doesn't exist
- Reference personas by name from user-personas.md
- Include the emotion curve for every journey — visual thinking matters
- Cross-journey analysis is NOT optional — it's where the real insights emerge
- Map touchpoints to specific product screens/features where possible
- Do NOT include the CTA footer
