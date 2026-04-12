---
description: Generate a CTO / board-ready presentation document from the architecture blueprint
---

# /architect:stakeholder-doc

## Trigger

`/architect:stakeholder-doc`

## Purpose

Transform the architecture blueprint into a presentation-ready document for executive reviews, board presentations, finance approvals, and agency RFPs. Translates technical decisions into business language — cost breakdown, risk summary, timeline, and approval checklist — without losing technical accuracy.

**Perfect for:** CTO reviews, board presentations, finance approvals, agency vendor RFPs, investor deep-dives

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context) |
| **Generation** | [Step 2](#step-2-load-skill) · [Step 3](#step-3-generate-document) |
| **Completion** | [Step 4](#step-4-output) · [Step 5](#step-5-log-activity) |

### Step 1: Read Context

Read in this order:

1. `architecture-output/_state.json` — read first if it exists; extract:
   - `project.name`, `project.description`, `project.stage`
   - `tech_stack` — for the technology decisions section
   - `top_risks` — for the risk summary section
   - `cost_estimate` — monthly low/mid/high totals for the cost section
   - `mvp_scope` — for the scope and what's not included section
   - `personas` — for the audience section

2. **SDL file** — `solution.sdl.yaml` for architecture style, components, auth, deployment; **only read sections not covered by `_state.json`**. Check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then relevant module files.

3. **Supporting outputs** (read if they exist, all typically small):
   - `architecture-output/executive-summary.md` — high-level architecture narrative
   - `architecture-output/cost-estimate.md` — full cost breakdown (if `_state.json.cost_estimate` is absent)
   - `architecture-output/risk-register.md` — risk detail (if `_state.json.top_risks` is absent)
   - `architecture-output/technical-roadmap.md` — timeline and phases
   - Any `adr-*.md` files in `architecture-output/` — architecture decision records

If no blueprint or SDL exists:

> "I need an architecture blueprint to create a stakeholder document from. Run `/architect:blueprint` first, then come back here."

### Step 2: Load Skill

Load:
- **stakeholder-doc** skill — for 11-section document structure and business-focused language rules
- **founder-communication** skill — for plain English, non-technical tone

### Step 3: Generate Document

Using the **stakeholder-doc** skill, generate the full 11-section presentation document:

1. Cover page (project name, date, prepared by)
2. Executive summary (3-5 bullet outcomes)
3. Solution overview (what it does, who it's for, key differentiators)
4. Technology decisions (key choices with business rationale — no jargon)
5. Architecture overview (simplified component diagram — Mermaid, max 6 nodes)
6. Cost breakdown (low/mid/high scenarios; monthly and first-year totals)
7. Risk assessment (top 5 risks with mitigation — from `_state.json.top_risks`)
8. Implementation timeline (phases from technical-roadmap, or estimated if absent)
9. Success metrics (KPIs and how they'll be measured)
10. Next steps (immediate actions required)
11. Approval checklist (sign-off section for stakeholders)

**Tone rules (from stakeholder-doc skill):**
- Lead with outcomes, not technology ("users can check out in 2 clicks" not "we implemented Stripe webhooks")
- Replace all acronyms on first use
- No code snippets — use diagrams and tables instead
- Frame costs as investment, not expense

### Step 4: Output

Write the document to `architecture-output/stakeholder-presentation.md`.

Include header:
```
# Stakeholder Presentation — [Project Name]
Generated: [date]
Prepared for: [CTO review | Board presentation | Agency RFP | Finance approval]
Architecture stage: [ideation | prototype | mvp | product]
```

### Docs Publish (Optional)

After writing the file, silently probe Confluence and Notion to check which (if any) is connected.

**If Confluence is connected**, offer:
> "Publish this stakeholder document to Confluence? Reply with the space key (e.g. `TEAM`) or `skip`."
- If confirmed: delegate to **confluence-publisher** with `artifact:"stakeholder-doc"`, `projectName`, `spaceKey`, `projectDir`

**If Notion is connected**, offer:
> "Publish this stakeholder document to Notion? Reply with a parent page ID or `skip`."
- If confirmed: delegate to **notion-publisher** with `artifact:"stakeholder-doc"`, `projectName`, `parentPageId`, `projectDir`

**If neither**, skip silently.

### Step 5: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"stakeholder-doc","outcome":"completed","files":["architecture-output/stakeholder-presentation.md"],"summary":"Stakeholder presentation generated: 11 sections, business-focused architecture summary for executive review."}
```

### Update _state.json

Merge a completion marker into `architecture-output/_state.json`:

```json
{
  "stakeholder_doc": { "generated_at": "<ISO-8601>" }
}
```

### Signal Completion

Emit the completion marker:

```
[STAKEHOLDER_DOC_DONE]
```

## Output Rules

- Use the **stakeholder-doc** skill for document structure and section content
- Use the **founder-communication** skill for tone throughout
- Never include code snippets — use Mermaid diagrams and tables instead
- Architecture diagram must have ≤ 6 nodes — group components if needed
- Cost section must show 3 scenarios (low/mid/high) and both monthly and annual
- Risk section: top 5 risks maximum, one-line mitigation per risk
- Do NOT include a CTA footer
- Do NOT ask questions — derive everything from available context
