---
name: deep-research
description: Structured web research methodology for market analysis, competitor research, and technology evaluation. Ensures research uses live web data with source citations and confidence tags.
---

# Deep Research Methodology

Systematic approach to web-based research for architecture and product decisions. Use this skill whenever generating market research, competitor analysis, pitch decks, cost estimates, or technology evaluations.

---

## When to Use This Skill

- Generating competitor analysis or market landscape
- Estimating market size (TAM/SAM/SOM)
- Validating technology choices against current ecosystem
- Producing investor-facing materials with market data
- Updating cost estimates with current pricing

---

## Three-Phase Research Process

### Phase 1: Discover (Broad Search)

Cast a wide net to identify the landscape:

1. **Competitor search**: Use WebSearch for:
   - `"{product category}" alternatives`
   - `"{product category}" competitors 2025`
   - `"best {product category}" software`
   - `"{product category}" market leaders`

2. **Market sizing search**: Use WebSearch for:
   - `"{product category}" market size 2025`
   - `"{product category}" TAM SAM`
   - `"{industry}" market report`
   - `"{product category}" growth rate forecast`

3. **Funding/trends search**: Use WebSearch for:
   - `"{product category}" startup funding 2024 2025`
   - `"{product category}" trends`
   - `"{competitor name}" funding round`

4. **Collect 10-15 relevant URLs** from search results for Phase 2.

### Phase 2: Verify (Targeted Validation)

Drill into specific sources to extract and verify data:

1. **For each competitor found** — Use WebFetch to:
   - Visit their homepage → extract value proposition, target audience
   - Visit pricing page → extract pricing tiers, free tier limits
   - Visit about page → extract founding date, team size, funding

2. **For market size claims** — Cross-reference with 2+ sources:
   - Industry reports (Gartner, Statista, Grand View Research)
   - Press articles citing market data
   - If sources conflict, note the range and which source is more authoritative

3. **For funding data** — Check:
   - Crunchbase profiles
   - TechCrunch or press release announcements
   - LinkedIn company pages for employee count estimates

4. **For technology claims** — Verify:
   - GitHub star counts (WebFetch `github.com/{repo}`)
   - npm download counts for packages
   - Stack Overflow survey data

### Phase 3: Synthesize (Structured Output)

Organize findings into a clear, actionable document:

1. **Confidence tagging** — Mark every data point:
   - `[Verified]` — Confirmed via direct source (pricing page, press release, report)
   - `[Estimated]` — Based on partial data or extrapolation
   - `[Inferred]` — Based on training data, not web-verified

2. **Source citation** — For every verified claim:
   ```
   Market size: $4.2B in 2025 [Verified]
   Source: Grand View Research, "Collaboration Software Market Report 2025"
   URL: https://example.com/report
   ```

3. **Data freshness** — Note when data was published:
   ```
   Last verified: March 2025
   Source published: January 2025
   ```

4. **Structured tables** — Present competitor data as scannable tables:

   | Competitor | Pricing | Funding | Key Feature | Weakness |
   |-----------|---------|---------|-------------|----------|
   | {name}    | {tier}  | {$Xm}  | {feature}   | {gap}    |

---

## Research Quality Rules

1. **ALWAYS use WebSearch** before making market size, competitor, or pricing claims
2. **ALWAYS cite sources** with URLs for every verified data point
3. **NEVER present estimated data as verified fact** — use confidence tags
4. **If WebSearch is unavailable**, explicitly state:
   > "Note: Based on training data as of [date]. Live web search was not available. Data should be independently verified before use in investor materials."
5. **Prefer recent sources** — prioritize data from the last 12 months
6. **Cross-reference** critical claims with 2+ independent sources
7. **Use WebFetch** on competitor websites directly — don't rely solely on third-party descriptions
8. **Note limitations** — if a competitor's pricing page requires login, note "pricing not publicly available"

---

## Output Structure Template

```markdown
# [Research Topic] — Deep Research Report

**Project**: [Project name from SDL]
**Researched**: [Today's date]
**Web search**: [Used / Not available]

## Executive Summary
[3-5 key findings]

## Competitor Landscape
[Table of competitors with verified data]

## Market Sizing
[TAM/SAM/SOM with sources]

## Feature Comparison Matrix
[Our product vs competitors across key dimensions]

## Opportunity Gaps
[Underserved areas competitors miss]

## Technology Landscape
[Relevant tech trends and adoption]

## Sources
[Numbered list of all URLs referenced]
```

---

## Integration with Other Commands

This skill is automatically loaded by:
- `/architect:deep-research` — Full standalone research report
- `/architect:cost-estimate` — For verifying current cloud/service pricing
- Referenced by Ideation Playbook actions (Market Research, Pitch Deck)

Other commands can reference this skill when they need web-verified data:
```
### Step N: Load Skills
Load **deep-research** skill for web research methodology
```
