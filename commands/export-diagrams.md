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

Check if a blueprint with Mermaid diagrams exists earlier in the conversation.

If no diagrams exist, respond:

> "I need architecture diagrams to export. Run `/architect:blueprint` first to generate your architecture diagrams, then come back here to render them."

### Step 2: Ask Configuration

Ask the user:

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
| Architecture | docs/diagrams/light/architecture.png | docs/diagrams/dark/architecture.png | docs/diagrams/light/architecture.svg | docs/diagrams/source/architecture.mmd |
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
