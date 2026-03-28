---
description: Full 15-slide investor pitch deck with web-verified market data — generates .md + .pptx
---

# /architect:pitch-deck

## Trigger

`/architect:pitch-deck`

## Purpose

Generate a comprehensive, investor-ready pitch deck with web-verified market data. Produces both a markdown document and a PowerPoint file. Builds on all prior ideation outputs for maximum depth and accuracy.

## Workflow

### Step 1: Gather Context

Read ALL of these files if they exist (do NOT ask the user — use what's available):
- `intent.json` — product name, vision, target users, core features, business constraints
- `architecture-output/deep-research.md` — web-verified competitor analysis, market sizing (TAM/SAM/SOM), feature comparison matrices, sourced data. USE this data directly instead of re-researching.
- `architecture-output/user-personas.md` — persona details, prioritization
- `architecture-output/problem-validation.md` — problem statement, evidence, validation status
- `architecture-output/mvp-scope.md` — feature priorities, MVP thesis
- `architecture-output/cost-estimate.md` — infrastructure and development costs
- `solution.sdl.yaml` — architecture overview

If deep-research.md does NOT exist, use WebSearch to research market data, competitors, and pricing. Tag numbers as [Verified] or [Estimated].

### Step 2: Generate All 15 Slides

Create a pitch deck with ALL of these slides (do NOT skip any). Each slide MUST have substantial content — not just a title and one bullet point.

#### Slide 1: Title / Cover
- Product name and one-line tagline
- Date
- Company name (from intent.json or "NEXPER PTY LTD")
- Optional: website URL

#### Slide 2: Problem
- What pain exists — cite real user complaints, market gaps, or inefficiencies
- Use data from deep-research.md or web search
- 2-3 specific pain points with evidence
- Quantify the cost of the problem (time wasted, money lost, opportunity cost)

#### Slide 3: Solution
- How the product solves the problem
- Key insight or "aha moment"
- 3-4 bullet points max — be concise and compelling
- One sentence on why this approach is better than alternatives

#### Slide 4: Product Overview
- 4-6 key capabilities with brief descriptions
- Feature walkthrough of the core product
- If prototype/ directory exists, mention it as a demo reference

#### Slide 5: How It Works
- 3-4 step user flow from signup to value delivery
- Use a numbered sequence
- Keep it simple enough for a non-technical investor to follow

#### Slide 6: Market Opportunity
- TAM/SAM/SOM with sources
- Market size table with growth rates (CAGR)
- Use data from deep-research.md if available
- Tag each number as [Verified] or [Estimated]
- Include market trends driving growth

#### Slide 7: Business Model
- Pricing tiers with specific prices
- Revenue streams (SaaS, marketplace, usage-based, etc.)
- Unit economics (CAC, LTV, LTV:CAC ratio)
- Competitor pricing comparison table for context

#### Slide 8: Traction & Milestones
- What has been built so far
- Key technical milestones achieved
- Early users, design partners, or waitlist numbers
- If no traction yet: development milestones (architecture designed, prototype built, etc.)

#### Slide 9: Competitive Landscape
- Comparison table: product vs 4-6 competitors across 6-8 key dimensions
- 2x2 positioning matrix (e.g., Ease of Use vs. Feature Depth)
- Use deep-research.md data if available
- Highlight the gap the product fills

#### Slide 10: Competitive Advantage & Moats
- 3-4 defensible moats (technology, data, network effects, ecosystem, switching costs)
- For each moat: why it's defensible and time to replicate
- What competitors can't easily follow

#### Slide 11: Go-To-Market Strategy
- Distribution channels ranked by expected ROI
- Customer acquisition strategy for first 6-12 months
- Partnerships or ecosystem plays
- Content/community strategy if applicable

#### Slide 12: Team
- Founders and key team members
- Relevant experience, domain expertise, prior exits
- If not in intent.json: "[Team details to be filled in]" as placeholder
- Advisory board if applicable

#### Slide 13: Financial Projections
- 3-year revenue forecast table (Year 1, Year 2, Year 3)
- Key assumptions (conversion rate, ARPU, churn, growth rate)
- Monthly burn rate and path to profitability
- Reference cost-estimate.md for infrastructure costs

#### Slide 14: The Ask
- Funding amount sought (or reasonable estimate based on scope)
- Use of funds breakdown (engineering %, marketing %, operations %)
- Key milestones the funding unlocks
- Expected runway

#### Slide 15: Vision
- Where the company is in 5 years
- The big picture opportunity
- Compelling closing statement

### Step 3: Generate Output Files

Generate TWO files:

1. **`pitch-deck.md`** — Full pitch deck in markdown. Use `## Slide 1: Title` through `## Slide 15: Vision` as headings. Include all data, tables, and source references inline.

2. **`pitch-deck.pptx`** — A PowerPoint file:
   - Install pptxgenjs (`npm install pptxgenjs`)
   - Write and run a Node.js script that creates a professional .pptx
   - Use a dark theme (background #1a1a2e, white text, accent color #e94560)
   - One slide per section with proper titles
   - Include source URLs in speaker notes
   - After generating the .pptx, delete the generator script

## Output Rules

- Write BOTH files to the project root
- Every slide must have substantial content — minimum 3-4 bullet points or a data table
- For slides with market data, include a "Sources" note
- Reuse data from existing deliverables — don't re-research what's already been done
- Financial projections must show the math (assumptions → calculations → numbers)
- Do NOT include the CTA footer
