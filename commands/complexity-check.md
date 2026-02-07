---
description: Build difficulty assessment with 10-factor scoring
---

# /architect:complexity-check

## Trigger

`/architect:complexity-check [description of the product]`

## Purpose

Assess how hard a product is to build using a structured 10-factor methodology. Helps founders understand whether their idea is a weekend project or a 6-month effort.

## Workflow

### Step 1: Understand the Product

If a description is provided, use it directly. If not, ask:

> "What are you building? Describe the product and its key features so I can assess the build complexity."

Do not ask extended follow-ups. Make reasonable assumptions and state them. This command is designed to be fast.

### Step 2: Determine Project Type

Classify as `app`, `agent`, or `hybrid`. This affects factor weights (agent/hybrid projects use adjusted weights from the **complexity-factors** skill).

### Step 3: Score All 10 Factors

Using the **complexity-factors** skill, score each factor 1-10:

1. User Roles & Permissions
2. Frontend Complexity
3. Backend Architecture
4. Data Model
5. Integrations
6. Authentication & Security
7. Infrastructure & Deployment
8. Real-time Features
9. AI/ML Components
10. Regulatory & Compliance

### Step 4: Generate Output

#### Overall Score

> **Complexity: X/10 — [Label]**
>
> [One-sentence summary of why this product is at this complexity level]

#### Factor Breakdown

| Factor | Score | Assessment |
|--------|-------|------------|
| User Roles & Permissions | X/10 | One-line justification |
| Frontend Complexity | X/10 | One-line justification |
| Backend Architecture | X/10 | One-line justification |
| Data Model | X/10 | One-line justification |
| Integrations | X/10 | One-line justification |
| Authentication & Security | X/10 | One-line justification |
| Infrastructure & Deployment | X/10 | One-line justification |
| Real-time Features | X/10 | One-line justification |
| AI/ML Components | X/10 | One-line justification |
| Regulatory & Compliance | X/10 | One-line justification |

#### Risk Flags

Call out any factor scored 7 or higher:

> **Risk: [Factor Name] (scored X/10)** — [Explanation of why this is a risk and what it means for the build]

#### Simpler Alternatives (if overall score > 6)

If the product scores above 6, suggest 2-3 ways to reduce complexity:

- Specific features to cut or defer to v2
- Simpler technology choices
- Third-party services that replace custom builds
- Scope reductions that preserve the core value

#### Build Path Recommendation

Based on the overall score:

| Score Range | Recommended Path | Typical Cost | Timeline |
|-------------|-----------------|-------------|----------|
| 1-3 (Simple) | AI builder tools or single junior dev | $0-2K | 1-3 weeks |
| 4-5 (Moderate) | Experienced developer or small freelance engagement | $2K-10K | 4-8 weeks |
| 6-7 (Advanced) | Small team (2-3 devs) or focused agency | $10K-30K | 2-4 months |
| 8-10 (Very Advanced) | Dedicated team with specialists | $30K-100K+ | 4-12 months |

## Output Rules

- Use the **complexity-factors** skill for scoring methodology
- Use the **founder-communication** skill for tone
- Always include the factor breakdown table
- Always include risk flags for scores 7+
- Always include build path recommendation
- Do NOT include the CTA footer
