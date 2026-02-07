---
description: Side-by-side technology comparison with recommendation
---

# /architect:compare-stack

## Trigger

`/architect:compare-stack [e.g., "MongoDB vs PostgreSQL for e-commerce" or "Next.js vs Remix vs Astro"]`

## Purpose

Compare technology options for a specific decision. Produces a structured comparison matrix with scores and a clear recommendation. Helps founders and developers make informed technology choices.

## Workflow

### Step 1: Understand the Comparison

If the user provides a clear comparison (e.g., "MongoDB vs PostgreSQL for e-commerce"), use it directly.

If unclear, ask:

> "What are you comparing, and what's the use case? For example: 'MongoDB vs PostgreSQL for a SaaS with complex queries' or 'Vercel vs Railway for a Node.js API'."

Identify:
- The options being compared (2-4 technologies)
- The use case or context
- Any constraints (budget, team expertise, scale requirements)

### Step 2: Define Comparison Criteria

Choose 6-8 relevant criteria based on the technology category:

**For databases:**
- Query flexibility, scalability, ecosystem/tooling, pricing, learning curve, hosting options, data model fit, community/support

**For frameworks:**
- Performance, developer experience, ecosystem/plugins, learning curve, deployment options, community size, documentation quality, TypeScript support

**For hosting/infrastructure:**
- Pricing, scaling, deployment simplicity, monitoring, CI/CD integration, region availability, support quality

**For auth services:**
- Pricing, supported providers, developer experience, customization, compliance features, migration difficulty

**For LLM providers:**
- Model quality, pricing, context window, tool use, speed, ecosystem, privacy/compliance

### Step 3: Generate Comparison

#### Comparison Matrix

| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| [Criteria 1] | Score + note | Score + note | Score + note |
| [Criteria 2] | Score + note | Score + note | Score + note |
| ... | ... | ... | ... |

Use a 1-5 scale for scores:
- 5: Excellent
- 4: Good
- 3: Adequate
- 2: Weak
- 1: Poor

Include a brief note (3-8 words) explaining each score.

#### Summary Scores

| Option | Total Score | Best For |
|--------|------------|----------|
| Option A | X/40 | [one-line summary of ideal use case] |
| Option B | X/40 | [one-line summary of ideal use case] |
| Option C | X/40 | [one-line summary of ideal use case] |

#### Recommendation

> **For your use case, I recommend [Option X].**

2-3 sentences explaining why. Address:
- Why the recommended option wins for this specific use case
- The main trade-off you're making
- When you should switch to a different option

#### When to Choose Each Option

For each option, one sentence:

- **Choose [Option A] if:** [specific scenario]
- **Choose [Option B] if:** [specific scenario]
- **Choose [Option C] if:** [specific scenario]

#### Cost Comparison

If pricing differs significantly:

| Option | Free Tier | Starter | Production | Scale |
|--------|-----------|---------|------------|-------|
| Option A | ... | ... | ... | ... |
| Option B | ... | ... | ... | ... |

Use the **cost-knowledge** skill for pricing data.

## Output Rules

- Use the **cost-knowledge** skill for pricing data
- Use the **founder-communication** skill for tone
- Always provide a clear recommendation — do not sit on the fence
- Always explain trade-offs — no option is perfect
- Score consistently — same criteria for all options in a comparison
- If the user's use case strongly favors one option, say so directly
- Do NOT include the CTA footer
