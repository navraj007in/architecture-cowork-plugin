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

**First**, check `architecture-output/_state.json`. If it exists, read it in full — it provides instant access to `project`, `tech_stack`, `components`, `design`, `entities`, and `personas` without reading larger files. Use its values directly where available; fall back to SDL (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files) only for detail not in `_state.json`.

**Also check for `sdl/complexity.sdl.yaml`** — if it exists, it contains pre-calculated Architecture Complexity Index (ACI) and Delivery Burden Index (DBI) scores from an import or discovery run. Read it now and set a flag: `has_sdl_complexity = true`.

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

#### SDL Complexity Scores (if `has_sdl_complexity = true`)

If `sdl/complexity.sdl.yaml` exists, display the pre-calculated indices first, before the 10-factor table:

> **Architecture Complexity Index (ACI): {X.X}/10**
> *How hard it is to understand and reason about the system.*
> {Structural / Dynamic / Integration / Technology dimensions}
>
> **Delivery Burden Index (DBI): {X.X}/10**
> *How hard it is to operate and scale safely.*
> {Operational / Organizational dimensions}
>
> **Unified Score: {X.X}/10 — {Simple | Moderate | Advanced | Very Advanced}**
> *(ACI × 0.6 + DBI × 0.4 — based on evidence from codebase scan)*

If any dimension has `confidence: low`, note it:
> ⚠ {dimension} confidence is LOW — {review_reason from complexity.sdl.yaml}. Confirm with your team before using this score for planning.

---

#### Overall Score (10-Factor)

> **Complexity: X/10 — [Label]**
>
> [One-sentence summary of why this product is at this complexity level]
>
> {IF has_sdl_complexity: Note any significant discrepancy (>2 points) between this score and the SDL unified score and explain why they differ.}

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

### Final Step: Write Output and Log Activity

Write the full deliverable to `architecture-output/complexity-check.md`.

Then append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"complexity-check","outcome":"completed","files":["architecture-output/complexity-check.md"],"summary":"Complexity check: <X>/10 (<label>) with <N> risk flags identified."}
```

## Output Rules

- Write the full deliverable to `architecture-output/complexity-check.md`
- Use the **complexity-factors** skill for scoring methodology
- Use the **founder-communication** skill for tone
- Always include the factor breakdown table
- Always include risk flags for scores 7+
- Always include build path recommendation
- Do NOT include the CTA footer
