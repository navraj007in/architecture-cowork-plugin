---
description: Generate operational, architecture, and ADR documentation from project state
---

# /architect:generate-docs

## Trigger

`/architect:generate-docs [mode] [options]`

Modes:
- `runbook` — Deployment & operational runbooks
- `architecture` — C4 diagrams + narrative architecture guide
- `adr` — Architecture Decision Records for major choices
- `incident` — Incident response playbooks
- `all` — All documentation (default)

Options:
- `[non_interactive:true]` — skip questions, derive from SDL and activity log
- `[audience:engineers|operators|stakeholders]` — adjust technical depth

## Purpose

Production systems need runbooks, architecture guides, and decision records. This command generates deployment procedures, C4 diagrams with narrative, Architecture Decision Records (ADRs) for why key choices were made, and incident response playbooks. Output is Markdown suitable for wikis (Notion, Confluence, GitHub wiki) or standalone.

## Workflow

### Step 1: Read Context

ℹ️ **CONTEXT LOADING:** _state.json → SDL → activity log

**Read**:
- `_state.json` for full project state (all completed commands)
- SDL for architecture decisions
- `_activity.jsonl` for deployment history and timelines
- Existing docs in `docs/` (to avoid duplication)
- Scaffolded project structure (for runbook paths)

### Step 2: Ask Configuration Questions

❓ **DECISION POINT:** Documentation mode and audience

**If not in non-interactive mode**, ask:

1. **Which documentation to generate?**
   > - Runbook (deployment procedures)
   > - Architecture (C4 diagrams + narrative)
   > - ADR (architecture decisions)
   > - Incident (incident response)
   > - All of the above

2. **Target audience**
   > - Engineers (deep technical detail)
   > - Operators (deployment focus)
   > - Stakeholders (high-level overview)

### Step 3: Delegate to docs-generator Agent

🔄 **AGENT DELEGATION:** Launch docs-generator agent

The agent reads modes and generates corresponding documentation.

### Step 4: Verify Generated Docs

✅ **QUALITY GATE:** Check files before proceeding

For each mode generated:
- `docs/runbooks/deploy-*.md` exists (≥1 per service)
- `docs/runbooks/rollback-*.md` exists
- `docs/architecture/` has overview + C4 diagrams
- `docs/architecture/decisions/` has ADRs (≥3)
- `docs/incident-response/` has playbooks (≥2)

### Step 5: Log Activity

```json
{"ts":"<ISO-8601>","phase":"generate-docs","outcome":"completed","modes":["runbook","architecture","adr"],"files_generated":18,"summary":"Documentation generated: 6 runbooks, architecture guide (C4), 4 ADRs, 3 incident playbooks."}
```

### Step 6: Update _state.json

```json
{
  "documentation": {
    "generated_at": "<ISO-8601>",
    "modes": ["runbook", "architecture", "adr"],
    "files_generated": 18,
    "runbooks": 6,
    "adrs": 4,
    "incident_playbooks": 3
  }
}
```

### Step 7: Signal Completion

```
[GENERATE_DOCS_DONE]
```

## Error Handling

### Missing Project State

If `_state.json` is missing:
> "I need project state to generate documentation. Run `/architect:blueprint` or other commands first to build state."

### No Components to Document

If no scaffolded components found:
> "No scaffolded services found. Run `/architect:scaffold` first to create services worth documenting."

### Activity Log Empty

If `_activity.jsonl` is empty (no deployment history):
- Generate docs based on current state only
- Note: "No deployment history available; some runbook details omitted"

### Unable to Write Docs

If `docs/` directory cannot be created:
- Stop, report error, do NOT emit completion marker

## Output Rules

- Use Markdown (.md format)
- Include code snippets and examples (copy-paste ready)
- C4 diagrams should be Mermaid syntax (for GitHub rendering)
- ADRs follow RFC 3986 format (decision, context, consequences)
- Runbooks must be step-by-step (no assumptions)
- Incident playbooks include: detection, assessment, remediation, post-mortem
- All docs cross-reference each other
- Use consistent headers and formatting
- Do NOT include the CTA footer

---

## Generated Documentation Examples

### Runbooks

**docs/runbooks/deploy-api-server.md** — Step-by-step deployment

**docs/runbooks/rollback-api-server.md** — How to rollback if deployment fails

### Architecture

**docs/architecture/overview.md** — High-level C4 context diagram + narrative

**docs/architecture/decisions/** — Numbered ADRs (0001_*, 0002_*, etc.)

### Incident Response

**docs/incident-response/high-error-rate.md** — Detection, debugging, remediation steps

**docs/incident-response/database-down.md** — Database failure playbook
