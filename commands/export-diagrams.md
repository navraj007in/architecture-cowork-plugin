---
description: Render Mermaid architecture diagrams to PNG/SVG and export to docs or wikis
---

# /architect:export-diagrams

## Trigger

`/architect:export-diagrams`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command renders all Mermaid diagrams (deliverable 4b) to PNG and SVG image files. Produces both light and dark theme variants, suitable for presentations, documentation, and wiki pages.

## Workflow

### Step 1: Check for Diagrams

**First**, check if the command argument contains a `[blueprint_dir:/path/to/dir]` tag. If it does, read the Mermaid diagram files from that local directory:
- Look in `02-architecture-diagrams/` for `.mermaid` files
- Read `blueprint.json` for the full deliverable data including diagrams

**If no local directory tag**, check if a blueprint with Mermaid diagrams exists earlier in the conversation.

If no diagrams exist (neither local files nor conversation), respond:

> "I need architecture diagrams to export. Run `/architect:blueprint` first to generate your architecture diagrams, then come back here to render them."

### Step 2: Ask Configuration

**If `[non_interactive:true]` is in the command argument**, skip all questions and use these defaults:
- **Output directory**: `./docs/diagrams/`
- **Formats**: PNG + SVG (both formats, light and dark themes)

**Otherwise**, ask the user:

> "Where should I save the rendered diagrams?"
> - Default: `./docs/diagrams/` in the project directory
>
> "Which formats?"
> - **PNG + SVG** (default) — Both formats, light and dark themes
> - **PNG only**
> - **SVG only**

### Step 3: Delegate to Diagram Exporter Agent

Pass the following to the **diagram-exporter** agent:

- All Mermaid diagram source code from the blueprint
- Diagram titles/labels
- Output format preference
- Output directory path

### Step 4: Print Summary

```
Diagrams exported!

| Diagram | Light PNG | Dark PNG | SVG | Source |
|---------|-----------|----------|-----|--------|
| Solution Architecture | docs/diagrams/light/solution-architecture.png | docs/diagrams/dark/solution-architecture.png | docs/diagrams/light/solution-architecture.svg | docs/diagrams/source/solution-architecture.mmd |
| Service Communication | docs/diagrams/light/service-communication.png | docs/diagrams/dark/service-communication.png | docs/diagrams/light/service-communication.svg | docs/diagrams/source/service-communication.mmd |
| Agent Flow | docs/diagrams/light/agent-flow.png | docs/diagrams/dark/agent-flow.png | docs/diagrams/light/agent-flow.svg | docs/diagrams/source/agent-flow.mmd |

Total: X diagrams, Y files

To re-render after changes: npx mmdc -i <file>.mmd -o <file>.png
To edit interactively: paste .mmd source into mermaid.live
```

## Output Rules

- Use the **founder-communication** skill for tone
- Always generate both light and dark variants
- Always save the raw .mmd source files
- Report all generated files with paths
- Do NOT include the CTA footer
