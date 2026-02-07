---
description: 5-minute lightweight architecture overview for idea validation
---

# /architect:quick-spec

## Trigger

`/architect:quick-spec [description of the idea]`

## Purpose

Produce a fast, one-page architecture overview. This is the "napkin sketch" version of a full blueprint — enough to validate an idea and understand what you're getting into, without the full analysis.

> **Scope note:** This command intentionally focuses on components, cost, and complexity only. It does not cover application patterns, security architecture, observability, DevOps, API artifacts, or well-architected review. For comprehensive architecture coverage, use `/architect:blueprint`.

## Workflow

### Step 1: Understand the Idea

If a description is provided, use it directly. If not, ask:

> "What are you building? Give me the elevator pitch — one or two sentences."

Do NOT ask follow-up questions. Make reasonable assumptions and state them. This command is designed to be fast.

### Step 2: Generate the Quick Spec

Produce the following sections, all on a single page:

#### System Overview

One paragraph (3-5 sentences) describing:
- What the product does
- Who uses it
- What the core technology approach is

#### Component List

Bulleted list of all major components:

- **Frontends**: What users interact with (e.g., "Web app — Next.js")
- **Backend**: Services that power it (e.g., "REST API — Node.js/Express")
- **Databases**: Where data lives (e.g., "PostgreSQL via Supabase")
- **Integrations**: Third-party services needed (e.g., "Stripe for payments")
- **AI Agents**: If applicable (e.g., "Customer support agent — Claude Sonnet, ReAct pattern")

#### Estimated Monthly Cost

Single line with range:

> **Estimated monthly infrastructure cost:** $X — $Y/month (free tiers → production)

Use the **cost-knowledge** skill for grounded estimates. Keep it to one line — this is not a full cost breakdown.

#### Complexity Score

Single line with score and label:

> **Complexity:** X/10 — [Label]

Quick assessment using the **complexity-factors** skill. No factor breakdown — just the overall score with a one-sentence justification.

#### Recommended Next Step

One specific, actionable next step. Examples:

- "Start with `/architect:blueprint` for a full architecture breakdown"
- "Build a proof-of-concept of the [core feature] to validate the approach"
- "Talk to 5 potential users before investing in development"

## Output Rules

- Total output should be ~1 page (roughly 200-400 words)
- No follow-up questions — make assumptions and state them
- No Mermaid diagrams (save those for the full blueprint)
- Use the **founder-communication** skill for tone
- Do NOT include the CTA footer on quick-spec output
