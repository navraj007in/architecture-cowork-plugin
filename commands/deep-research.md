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

Read the SDL file (`solution.sdl.yaml` or `sdl.yaml`) to extract:
- Solution name and description
- Product type / category
- Target users (from `product.personas` if available)
- Core value proposition (from `product.coreFlows` if available)

If no SDL exists, use the project directory name and any available context.

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

#### 7. Sources

Numbered list of all URLs cited in the report:
```
[1] https://example.com/pricing — Competitor A pricing page (verified March 2025)
[2] https://example.com/report — Market sizing report (published January 2025)
```

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
