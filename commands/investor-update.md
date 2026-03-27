---
description: Investor/stakeholder update template pre-filled from project data
---

# /architect:investor-update

## Trigger

`/architect:investor-update` — run at any time to generate a progress report.

## Purpose

Generate a professional investor or stakeholder update template, pre-filled with real project data: features shipped, architecture decisions made, infrastructure costs, technical progress, and next priorities. Suitable for monthly investor updates, agency client reports, or internal stakeholder briefings. Saves hours of assembling progress from scattered sources.

## Workflow

### Step 1: Gather Project Data

Read all available data sources:

1. **SDL file** (`solution.sdl.yaml` or `sdl.yaml`) — project name, description, stage, components
2. **Cost estimate** — `architecture-output/cost-estimate.md` (if exists) — monthly infra costs
3. **Scaffold report** — `.archon/scaffold-report.json` (if exists) — component build status, timestamps
4. **Change requests** — `.archon/change-requests/cr-index.json` (if exists) — applied CRs with dates
5. **ADR files** — any `adr-*.md` files in `architecture-output/` — architecture decisions
6. **Security scan** — `architecture-output/security-scan.md` (if exists) — security posture
7. **Complexity check** — `architecture-output/complexity-check.md` (if exists) — risk assessment
8. **Well-architected review** — `architecture-output/well-architected-review.md` (if exists)
9. **Hiring brief** — `architecture-output/hiring-brief.md` (if exists) — team needs
10. **Blueprint** — `architecture-output/executive-summary.md` (if exists) — project overview

### Step 2: Load Skills

Load:
- **founder-communication** skill — for clear, non-technical writing
- **stakeholder-doc** skill — for professional document structure

### Step 3: Generate Update Document

Write a professional update with these sections:

#### Header

```markdown
# [Project Name] — Progress Update
**Period**: [Current month/week]
**Prepared**: [Today's date]
**Stage**: [ideation/prototype/mvp/product]
```

#### 1. Executive Summary (3-5 bullets)

Synthesize the most important updates into 3-5 bullet points. Lead with outcomes, not activities.

Good: "Payment processing is now live — users can subscribe to premium plans"
Bad: "We implemented Stripe webhook handlers and subscription management endpoints"

#### 2. Features & Changes Shipped

From CR history (`.archon/change-requests/cr-index.json`):

| Feature | Status | Date |
|---------|--------|------|
| {CR title} | Applied | {date} |

If no CRs exist, note: "Feature tracking via Change Requests not yet initialized."

Also scan `architecture-output/` for recently modified files — list any new deliverables generated.

#### 3. Architecture Decisions

From ADR files in architecture-output:

| Decision | Impact | Rationale |
|----------|--------|-----------|
| {ADR title} | {high/medium/low} | {one-line summary} |

If no ADRs exist, summarize key tech choices from the SDL (framework, database, auth provider, deployment target).

#### 4. Technical Progress

From scaffold report (`.archon/scaffold-report.json`):

**Components:**
| Component | Type | Status | Files |
|-----------|------|--------|-------|
| {name} | {type} | {completed/failed} | {file count} |

**Build & Deploy Status:**
- Scaffold: {complete/in progress/not started}
- CI/CD: {configured/not configured} (check for .github/workflows/)
- Deployment: {deployed/not deployed} (check for deployment config files)

#### 5. Infrastructure & Costs

From cost estimate (`architecture-output/cost-estimate.md`):

- Current monthly estimate: ${amount}
- Breakdown by service (top 3-5 line items)
- Projected cost at 1K/10K/100K users (if available)

If no cost estimate exists: "Cost analysis not yet generated. Run `/architect:cost-estimate` to produce projections."

#### 6. Risks & Blockers

From complexity check and security scan:

| Risk | Severity | Status | Mitigation |
|------|----------|--------|------------|
| {risk description} | {high/medium/low} | {open/mitigated} | {action} |

If no risk data exists, list common early-stage risks:
- Single point of failure (no redundancy yet)
- No automated testing (manual QA only)
- Limited monitoring (no production observability)

#### 7. Team & Hiring

From hiring brief (`architecture-output/hiring-brief.md`):

- Current team size and roles
- Open positions needed
- Key skills required

If no hiring brief exists: "Run `/architect:hiring-brief` to generate role descriptions and interview questions."

#### 8. Next Period Priorities

Synthesize from:
- Incomplete lifecycle phases (from project-state.json)
- Pending CRs (draft/proposed status)
- Items marked as "next steps" in the executive summary
- Security scan findings not yet addressed

List 3-5 priorities in order of importance.

#### 9. Ask / Support Needed

Template section for the founder to fill in:
```
- [ ] [What do you need from investors/stakeholders?]
- [ ] [Introductions, funding, partnerships, hiring referrals?]
```

### Step 4: Output

Write to `architecture-output/investor-update.md`.

## Output Rules

- Use **founder-communication** skill for ALL text — investors are not engineers
- Use **stakeholder-doc** skill for professional formatting
- Lead with outcomes and business impact, not technical details
- Use real data from project files — do NOT fabricate metrics or dates
- If data source doesn't exist, note its absence and suggest the command to generate it
- Tables should be scannable — no more than 5-6 columns
- Keep total length to 2-3 pages (investors won't read more)
- Do NOT include a CTA footer
- Do NOT ask questions — make reasonable assumptions and note them
