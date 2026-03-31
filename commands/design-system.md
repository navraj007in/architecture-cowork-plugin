---
description: Generate a complete design system from the architecture blueprint
---

# /architect:design-system

## Trigger

`/architect:design-system`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command creates a complete, context-aware design system — palette, typography, motion language, component inventory, and design tokens — grounded in the product domain and architecture. Turns a technical blueprint into a visual identity that the scaffold phase consumes.

## Workflow

### Step 1: Read Context & Check for Blueprint

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` and `project.description` → product name and domain context
- `tech_stack` → framework and component library choices already made
- `design` → if present and fully populated (personality + full palette + fonts), the design system was already set — use these values as the starting point rather than re-deriving from scratch
- `personas` → target audience context; use instead of reading `user-personas.md`

**Then**, check if the command argument contains a `[blueprint_dir:/path/to/dir]` tag. If it does:
- Read `solution.sdl.yaml` for the SDL document
- Read `blueprint.json` for the full blueprint
- Extract product domain, target audience, and frontend components

**If no local directory tag**, check if an SDL or blueprint exists earlier in the conversation.

If no blueprint exists:

> "I need an architecture to design for. Run `/architect:blueprint` first to generate your architecture, then come back here to create the design system."

### Step 2: Analyze Architecture Context

Extract from SDL and blueprint:
- **Product domain** — what category is this product? (fintech, healthcare, e-commerce, etc.)
- **Target audience** — who uses this? (enterprise users, consumers, developers, children, etc.)
- **Frontend components** — list all frontends from the manifest with their types and frameworks
- **Existing design section** — is `design` already partially filled in the SDL?
- **Component library** — is a preset already chosen? (shadcn, material, etc.)
- **Accessibility requirements** — any WCAG level specified?

Present the analysis:

```
Architecture context for design system:

Product: [name] — [one-line description]
Domain: [detected domain]
Audience: [target audience]
Frontends: [list of frontend components with types]
Design preset: [if specified, else "not set — will recommend"]
Existing design: [complete | partial | empty]
```

### Step 3: Load Skills & References

Load:
- **design-system** skill — for generation logic and principles
- **sdl-knowledge** skill — for SDL schema awareness
- **design-systems.md** reference — for preset configs, personality mapping, domain defaults

### Step 4: Generate or Refine Design System

**If SDL design section is EMPTY:**
Run full generation — infer personality, palette, typography, motion, layout, and component inventory from domain + audience + architecture. Make bold, distinctive choices. Follow the design-system skill fully.

**If SDL design section is PARTIAL:**
Fill in missing fields while respecting existing choices. Validate that existing choices are consistent (e.g., brutalist personality shouldn't have expressive motion). Flag inconsistencies and suggest corrections.

**If SDL design section is COMPLETE:**
Validate consistency, check WCAG compliance, and suggest refinements. Ask if the user wants any changes.

### Step 5: Present Design Direction

Before generating artifacts, present the design direction for approval:

```
Design System for [Product Name]

Personality: [personality] — [one sentence why]
Palette: [primary] + [secondary] + [accent] on [neutral] [surface]
Typography: [heading font] / [body font] / [mono font]
Shape: [radius] radius, [shadows] shadows, [borders] borders
Motion: [transitions] transitions, [pageTransitions ? "with" : "no"] page transitions
Layout: [style] at [maxWidth]px max width
Icons: [iconLibrary]
Components: [componentLibrary]
Accessibility: WCAG [wcag], reduced motion [on/off]

Does this direction look right, or would you like to adjust anything?
```

**If `[non_interactive:true]` is in the command argument**, skip approval and proceed directly.

### Step 6: Generate Deliverables

Generate and write the following files to `architecture-output/design-system/`:

| File | Description |
|---|---|
| `design-brief.md` | Human-readable design language brief — shareable with stakeholders |
| `design-tokens.json` | Machine-readable tokens for scaffold consumption |
| `component-inventory.md` | UI components needed, mapped to SDL architecture |
| `tailwind.config.patch.ts` | Ready-to-merge Tailwind config extensions |
| `palette-preview.html` | Single-file visual preview of the design system |

### Step 7: Update SDL

Write the complete `design` section back into `solution.sdl.yaml`:

```yaml
design:
  preset: ...
  personality: ...
  palette: ...
  typography: ...
  shape: ...
  motion: ...
  layout: ...
  iconLibrary: ...
  componentLibrary: ...
  accessibility: ...
```

If `solution.sdl.yaml` already exists, update only the `design` section — preserve everything else.

### Step 7.5: Update _state.json

After updating SDL and writing design-tokens.json, merge the design summary into `architecture-output/_state.json`:

1. Read existing `_state.json` (or start with `{}`)
2. Extract the key design facts — compact enough to inform prototype + scaffold without reading design-tokens.json
3. Write back merging only the `design` key:

```json
{
  "design": {
    "personality": "bold-commercial",
    "primary": "#f97316",
    "primary_dark": "#ea580c",
    "secondary": "#0ea5e9",
    "accent": "#fbbf24",
    "surface": "#ffffff",
    "surface_elevated": "#f8fafc",
    "text_primary": "#0f172a",
    "text_secondary": "#64748b",
    "border_radius": "8px",
    "shadow": "0 1px 3px rgba(0,0,0,0.12)",
    "heading_font": "Clash Display",
    "body_font": "Poppins",
    "mono_font": "JetBrains Mono",
    "icon_library": "lucide-react",
    "component_library": "shadcn/ui",
    "tokens_file": "architecture-output/design-system/design-tokens.json"
  }
}
```

This lets `prototype` and `scaffold-component` get the full palette and font config from `_state.json` without reading `design-tokens.json` or re-deriving the design direction.

### Step 7.6: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"design-system","outcome":"completed","files":["architecture-output/design-system/design-tokens.json","architecture-output/design-system/design-brief.md","architecture-output/design-system/tailwind.config.patch.ts","architecture-output/design-system/component-inventory.md","architecture-output/_state.json"],"summary":"Design system generated: <personality> personality, <primary> primary, <heading>/<body> fonts."}
```

### Step 8: Print Summary

```
Design system complete for [Product Name]!

Personality: [personality]
Palette: [primary] / [secondary] / [accent]
Typography: [heading] + [body]
Layout: [style]

Deliverables written to architecture-output/design-system/:
- design-brief.md — Share with co-founders and designers
- design-tokens.json — Consumed by scaffold phase
- component-inventory.md — UI components your product needs
- tailwind.config.patch.ts — Merge into your Tailwind config
- palette-preview.html — Open in browser to see your design language

SDL updated with complete design section.

Next steps:
1. Open palette-preview.html to review your design system visually
2. Run /architect:scaffold to generate projects with these design tokens baked in
3. Share design-brief.md with your team for alignment
```

## Output Rules

- Use the **design-system** skill for all generation logic
- Use the **founder-communication** skill for tone
- Load **design-systems.md** reference for domain defaults and preset configurations
- Every design choice must have a rationale tied to the product context
- NEVER default to indigo/purple palette
- NEVER use Inter, Roboto, or Arial as heading font
- Heading font must differ from body font
- All fonts must be available on Google Fonts
- Validate WCAG contrast for the chosen palette and accessibility level
- The palette-preview.html must be a self-contained single file (inline CSS, no external deps)
- Do NOT include the CTA footer
