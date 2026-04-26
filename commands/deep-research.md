---
description: Deep web research on market, competitors, technology, and differentiation for the project
---

# /architect:deep-research

## Trigger

`/architect:deep-research` — run at any stage, ideally early in the project lifecycle.

## Purpose

Conduct systematic web-based research to produce a verified market analysis with real competitor data, sourced market sizing, feature comparison matrices, and opportunity identification. Replaces guesswork with web-verified intelligence. Essential for pitch decks, investor conversations, and product positioning.

## Workflow

### Step 1: Understand the Product

Read in this order — stop as soon as you have enough to determine the product category:

1. **`architecture-output/_state.json`** — read first if it exists. Use directly:
   - `project.name`, `project.description` → product name and category
   - `project.type` → app / agent / hybrid (shapes competitor search)
   - If `_state.json` has these fields, skip reading SDL and `intent.json` entirely

2. **`intent.json`** — only if `_state.json` is absent or missing `project.description`; extract name, vision, target users

3. **SDL** — only if both above are absent; check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Grep for `product:` block only

If nothing exists, use the project directory name as the product name.

Determine the **product category** for research queries (e.g., "collaborative whiteboard", "HIPAA-compliant messaging", "project management tool").

### Step 2: Load Skills

Load:
- **deep-research** skill — for structured web research methodology (Discover → Verify → Synthesize)
- **founder-communication** skill — for plain English output

### Step 3: Phase 1 — Discover (Broad Search)

Use **WebSearch** to conduct the following searches:

**Competitor discovery** (run at least 4 searches):
- `"{product category}" alternatives`
- `"{product category}" competitors 2025`
- `"best {product category}" software tools`
- `"{product category}" vs` (auto-complete reveals top competitors)

**Market sizing** (run at least 3 searches):
- `"{product category}" market size 2025 2026`
- `"{product category}" TAM SAM SOM`
- `"{broader industry}" market report forecast`

**Funding and trends** (run at least 2 searches):
- `"{product category}" startup funding rounds 2024 2025`
- `"{product category}" industry trends`

Collect a list of 5-8 direct competitors and 3-5 indirect competitors/substitutes.

### Step 4: Phase 2 — Verify (Deep Dive)

Use **WebFetch** to visit each competitor's website:

For each of the top 5-8 competitors:
1. **Homepage** — Extract: tagline, value proposition, target audience
2. **Pricing page** — Extract: pricing tiers, free tier, enterprise pricing
3. **About/Company page** — Extract: founding year, team size, headquarters, notable customers
4. **Features page** — Extract: key features, differentiators

For market sizing:
- Verify claims against 2+ independent sources
- Note the range if sources disagree
- Prefer industry reports (Gartner, Statista, Grand View Research, Fortune Business Insights)

For funding:
- Search `"{competitor name}" funding crunchbase` for each major competitor
- Note: total funding, last round, valuation if public

### Step 5: Phase 3 — Synthesize

Generate the research report with these sections:

#### 1. Executive Summary
3-5 bullet points capturing the most important findings. Lead with insights, not data.

#### 2. Competitor Landscape

**Direct Competitors** (5-8):

| Company | URL | Founded | Funding | Pricing | Key Differentiator | Weakness |
|---------|-----|---------|---------|---------|-------------------|----------|
| [name]  | [url] | [year] [Verified] | [$Xm] [Verified/Estimated] | [free/$X/mo] [Verified] | [1-line] | [gap we can exploit] |

**Indirect Competitors / Substitutes** (3-5):
| Company | How they compete | Why they're not a direct threat |
|---------|-----------------|-------------------------------|

#### 3. Market Sizing

| Metric | Value | Source | Confidence |
|--------|-------|--------|------------|
| TAM | $X.XB | [source name] | [Verified/Estimated] |
| SAM | $X.XB | [derived from TAM] | [Estimated] |
| SOM | $X.XM | [realistic 3-year capture] | [Estimated] |

**Growth rate**: X% CAGR [source]

#### 4. Feature Comparison Matrix

| Feature | Our Product | Competitor A | Competitor B | Competitor C |
|---------|------------|-------------|-------------|-------------|
| [core feature 1] | [planned/built] | [yes/no/partial] | ... | ... |
| [core feature 2] | ... | ... | ... | ... |

Use the SDL's component definitions and core flows to determine "Our Product" features.

#### 5. Opportunity Gaps

Based on the competitor analysis, identify 3-5 underserved areas:
- What are customers complaining about with existing solutions?
- What features are missing across the competitive landscape?
- What market segments are underserved?
- How does our architecture uniquely position us? (reference SDL tech stack)

#### 6. Technology Landscape

Relevant technology trends that impact this market:
- Framework adoption trends
- Infrastructure trends (cloud, edge, serverless)
- AI/ML integration trends in this category
- Regulatory trends (GDPR, HIPAA, SOC2 — if relevant)

#### 7. Competitive Momentum Scoring

Quantify competitor acceleration to identify real threats:

| Competitor | Funding Trend | Hiring Velocity | Release Frequency | Momentum Score | Assessment |
|---|---|---|---|---|---|
| [CompA] | [Series growth] | [engineers/year] | [releases/month] | [0-100] | [accelerating/stalled/plateau] |

**Momentum calculation** (0-100 scale):
- Funding growth rate: +30% YoY (high acceleration) → 35 points
- Hiring velocity: Adding 40 engineers/year on 20-person base → 30 points
- Release frequency: Weekly releases (vs 1/month baseline) → 25 points
- Momentum score: 90/100 = Aggressively expanding

**Why it matters**: Momentum reveals threat level better than current size. A $50M company growing 5%/year is different from a $10M company growing 100%/year.

#### 8. Feature Parity Scoring

Show exactly where we stand versus competitors:

| Feature Category | CompA | CompB | CompC | Our MVP | Avg Parity | Assessment |
|---|---|---|---|---|---|---|
| [Category 1] | [N features] | [N features] | [N features] | [N features] | [X%] | [behind/parity/exceed] |
| [Category 2] | ... | ... | ... | ... | ... | ... |
| **Overall** | — | — | — | — | [X%] | Table-stakes readiness |

**Scoring**: (Our Features / Avg Competitor Features) × 100
- <50%: Playing catch-up, must be faster to differentiate
- 50-80%: Competitive, can win on execution/UX
- 80%+: Feature parity, differentiate elsewhere

**Output section title**: "Competitive Feature Parity Assessment"

#### 9. Market Sizing Confidence & Sensitivity

Replace simple TAM/SAM/SOM with confidence-weighted estimates:

| Metric | Estimate | Range (80% confidence) | Sources Weighted | Confidence Level |
|---|---|---|---|---|
| TAM | $4.2B | $3.8B - $4.8B | Gartner (0.4) + Statista (0.35) + Extrapolation (0.25) | High |
| SAM | $1.2B | $0.9B - $1.5B | Derived from TAM + segment sizing | Medium |
| SOM | $50M | $30M - $80M | Realistic 3-year capture (2% of SAM) | Medium |

**Sensitivity analysis** (how market changes affect us):
```
If market grows at:
  - 8% CAGR (pessimistic): TAM becomes $3.8B in 3 years → SOM $30M
  - 12% CAGR (base case): TAM becomes $4.6B in 3 years → SOM $50M
  - 18% CAGR (optimistic): TAM becomes $5.8B in 3 years → SOM $80M

3-year revenue target: $20M
  - Pessimistic: 0.7% of SAM (achievable)
  - Base: 0.4% of SAM (realistic)
  - Optimistic: 0.3% of SAM (comfortable)
```

**Output section title**: "Market Sizing with Confidence Intervals"

### Step 6: Write Output

Write the complete report to `architecture-output/deep-research.md`.

Include header:
```markdown
# Deep Research Report — [Project Name]
**Category**: [product category]
**Researched**: [today's date]
**Web searches conducted**: [count]
**Sources verified**: [count]
**Confidence**: [High — web-verified / Medium — partially verified / Low — training data only]
```

### Step 7: Docs Publish (Optional)

Silently probe both Confluence and Notion to check which (if any) is connected.

**Check Confluence** — attempt `search_content` with a lightweight query (e.g. `query: "test", limit: 1`):
- If connected: ask "Publish market research to Confluence? (space key + optional parent page ID)"
- If confirmed: delegate to **confluence-publisher** with `artifact: "deep-research"`, `projectName`, `spaceKey`, `parentPageId`, `projectDir`

**Check Notion** — attempt `notion_search` with `query: ""`, `page_size: 1`:
- If connected: ask "Publish market research to Notion? (optional parent page ID or database ID)"
- If confirmed: delegate to **notion-publisher** with `artifact: "deep-research"`, `projectName`, `parentPageId` or `databaseId`, `projectDir`

If neither is connected, skip silently.

### Step 8: Log Activity

After writing `deep-research.md`, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"deep-research","outcome":"completed","files":["architecture-output/deep-research.md"],"summary":"Completed deep market research with competitor landscape, market sizing, and opportunity gaps."}
```

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

### Step 9: Update _state.json

After writing `deep-research.md`, update `architecture-output/_state.json` with compact market intelligence:

1. Read existing `_state.json` (or start with `{}`)
2. Extract summary facts from the research including momentum and parity data
3. Merge into the `market_research` key and write back:

```json
{
  "market_research": {
    "competitors": [
      { 
        "name": "Competitor A", 
        "pricing": "$49/mo", 
        "weakness": "no mobile app",
        "momentum_score": 78,
        "momentum_trend": "accelerating"
      },
      { 
        "name": "Competitor B", 
        "pricing": "$200/mo", 
        "weakness": "steep learning curve",
        "momentum_score": 22,
        "momentum_trend": "stalled"
      }
    ],
    "feature_parity": {
      "overall_score": 58,
      "assessment": "Playing catch-up — must differentiate on execution/UX"
    },
    "market_size": {
      "tam": "$4.2B",
      "tam_range": "$3.8B - $4.8B",
      "tam_confidence": "High",
      "cagr": "12-14%",
      "sam": "$1.2B",
      "som_3year": "$50M"
    },
    "key_insight": "70% of SMBs still use spreadsheets — no affordable modern solution exists"
  }
}
```

Guidelines:
- Limit `competitors` to the top 5 direct competitors with momentum scores
- Include momentum_score (0-100) and momentum_trend for each
- Add feature_parity with overall score and brief assessment
- Market size should be range + confidence, not single point estimate
- `key_insight` is ONE sentence — the single most important finding for product positioning

### Signal Completion

Emit the completion marker:

```
[DEEP_RESEARCH_DONE]
```

This ensures the deep-research phase is marked as complete in the project state.

## Output Rules

- Use **founder-communication** skill — write for founders and investors, not engineers
- Use **deep-research** skill methodology — Discover → Verify → Synthesize
- **MUST use WebSearch and WebFetch** — this is a web research command, not a generation command
- Every market claim, competitor detail, and pricing point must have a confidence tag
- Include source URLs for all verified data
- If WebSearch is unavailable, produce the best report possible from training data but prominently note the limitation at the top
- Keep the report scannable — use tables, not paragraphs
- Do NOT include a CTA footer
- Do NOT ask questions — research independently based on SDL and web data
