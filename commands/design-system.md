---
description: Generate a complete design system from product context and wireframes — no blueprint required
---

# /architect:design-system

## Trigger

`/architect:design-system`

## Purpose

Creates a complete, context-aware design system — palette, typography, motion language, component inventory, and design tokens — grounded in the product domain and target audience. Works at any stage: after wireframes (pre-blueprint), after blueprint, or as a standalone command. The scaffold phase consumes the output.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context--check-for-blueprint) · [Step 1.5](#step-15-figma-pull-optional) |
| **Analysis** | [Step 2](#step-2-analyze-architecture-context) · [Step 3](#step-3-load-skills--references) |
| **Generation** | [Step 4](#step-4-generate-or-refine-design-system) · [Step 5](#step-5-present-design-direction) · [Step 6](#step-6-generate-deliverables) |
| **Updates** | [Step 7](#step-7-update-sdl) · [Step 7.5](#step-75-update-_statejson) |
| **Completion** | [Step 7.6](#step-76-log-activity) · [Step 8](#step-8-print-summary) · [Step 9](#step-9-figma-push-optional) · [Step 9.5](#step-95-application-type-specific-adjustments) |

### Step 1: Read Context

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` and `project.description` → product name and domain context
- `tech_stack` → framework and component library choices already made (optional — may not exist yet)
- `design` → if present and fully populated (personality + full palette + fonts), the design system was already set — use these values as the starting point rather than re-deriving from scratch
- `personas` → target audience context; use instead of reading `user-personas.md`
- `mvp_scope` → feature scope; informs which UI components are needed

**Then**, scan for wireframe output in `architecture-output/wireframes/`. If JSON wireframe files exist, read them to extract:
- Screen inventory (all screen names and layouts)
- Component patterns already decided (navbars, sidebars, modals, cards, forms)
- Application type hint (sidebar navigation → likely dashboard web app; bottom tabs → mobile; etc.)

**Then**, check if an SDL exists (optional):
- Check `solution.sdl.yaml` — if it exists, read `architecture.projects[]` for application type and tech stack
- If no SDL, check for a `[blueprint_dir:/path/to/dir]` tag in the command argument and read from that path
- **SDL is optional at this stage** — if no SDL exists, proceed with `_state.json` + wireframes context

If none of `_state.json`, wireframes, or SDL exist, ask:

> "What are you building? Give me a one-sentence description so I can create a design system that fits your product."

### Step 1.5: Figma Pull (Optional)

ℹ️ **OPTIONAL PATH:** May pull existing colors/fonts from Figma

Before deriving the design direction, silently attempt a lightweight Figma MCP call (e.g. `get_me`) to check if the server is connected.

**If connected**, offer:

> "Figma is connected. Do you have an existing Figma file to pull colors and fonts from? Paste the file URL or key, or reply `skip` to derive the design system from scratch."

If the user provides a file URL or key, delegate to the **figma-agent** with:
- `mode: "pull"`
- `figmaFileUrl` — the URL or key provided
- `projectDir` — current working directory

Use the returned palette and typography values as the authoritative design input for Step 3 onward — skip domain derivation for any values the Figma file provides.

**If not connected**, skip silently.

### Step 2: Analyze Context

Determine the following from all available sources (`_state.json`, wireframes, SDL — whichever exist):

- **Product domain** — what category is this product? (fintech, healthcare, e-commerce, etc.)
  - Source priority: `_state.json.project.description` → SDL `domain` → user description
- **Target audience** — who uses this? (enterprise users, consumers, developers, children, etc.)
  - Source priority: `_state.json.personas[0]` → SDL `targetAudience` → infer from domain
- **Application type** — determines component library and spacing scale:
  - **If SDL exists**: read from `architecture.projects[].type`
  - **If wireframes exist but no SDL**: infer from screen layouts (sidebar/top-nav patterns → `web`; bottom tabs/stack screens → `mobile`; window chrome/menu bar → `desktop`)
  - **If neither**: default to `web` — note this assumption in the output summary
  - `web` → web component library (shadcn/ui, Material, Chakra)
  - `mobile` → mobile component library (React Native Paper, NativeBase)
  - `desktop` → desktop-adapted component library (shadcn/ui adapted, larger sizing)
  - If multiple types: ask which to design for first
- **Component inventory** — what UI components are needed:
  - **If wireframes exist**: extract from wireframe JSON (screens, layouts, navigation patterns, form types)
  - **If SDL exists**: cross-reference with `architecture.projects[].type` for platform-specific components
  - **If neither**: derive from `_state.json.mvp_scope.must_have` feature list
- **Tech stack** (affects token format output):
  - **If SDL/`_state.json.tech_stack` exists**: use specified framework (Next.js → Tailwind config, React Native → StyleSheet tokens, etc.)
  - **If not known yet**: default to CSS custom properties + Tailwind config — note in output: "Token format defaults to CSS variables + Tailwind. Confirm after blueprint."
- **Existing design** — is `_state.json.design` or SDL `design` section partially populated?
- **Accessibility requirements** — any WCAG level in SDL or inferred from domain (healthcare/fintech → WCAG AA minimum)

Present the analysis:

```
Design system context:

Product: [name] — [one-line description]
Domain: [detected domain]
Audience: [target audience from personas or inference]
Application type: [web | mobile | desktop] — [source: SDL | wireframes | default assumption]
Screens/components: [N screens from wireframes, or derived from MVP scope]
Tech stack known: [yes — Next.js/React Native/etc. | no — defaulting to CSS variables + Tailwind]
Existing design: [complete | partial | empty]
```

### Step 3: Load Skills & References

Load:
- **design-system** skill — for generation logic, principles, and dark mode output spec
- **sdl-knowledge** skill — for SDL schema awareness
- **design-systems.md** reference — component library presets, personality guide, domain defaults, sub-domain differentiation
- **design-system-fonts.md** reference — curated font pairing library by personality (49+ pairs with rotation rules, including organic/retro/expressive/cinematic)
- **design-system-patterns.md** reference — dark mode tokens, gradient/texture recipes, motion timing values, layout archetype spatial specs, 8 unconventional layout patterns with CSS
- **design-system-creative.md** reference — 4 creative personalities, consumer/creative domain defaults, personality × domain quick guide

### Step 4: Generate or Refine Design System

🔄 **AGENT DELEGATION:** Derive or refine design direction

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
| `navigation-patterns.md` | (CONDITIONAL) Error state styling, context switcher specs, guard feedback — ONLY if patterns exist in SDL |
| `tailwind.config.patch.ts` | Ready-to-merge Tailwind config extensions |
| `palette-preview.html` | Single-file visual preview of the design system |

**Step 6a: Generate `navigation-patterns.md`** (ONLY if SDL has `product.navigationPatterns`):

Skip this file if no patterns exist in SDL. Otherwise, document styling and component specs for:

**A. Error States** (if `errorHandling` exists):
```
## Error Pages

### 404 — Page Not Found
- Layout: centered card on surface
- Icon: AlertCircle or HelpCircle (primary color)
- Heading: "Page not found" (heading font, dark variant of primary)
- Message: "The page you're looking for doesn't exist" (body font, secondary text)
- CTA Button: "Back to Home" (primary button)
- Background: surface with subtle pattern/gradient optional

### 403 — Forbidden
- Icon: Lock (error color)
- Heading: "Access Denied" (heading font, error color)
- Message: "You don't have permission to access this resource" (secondary text)
- CTA: "Request Access" or "Go Back"

### 500 — Server Error
- Icon: AlertTriangle (warning color)
- Heading: "Something went wrong" (heading font, warning color)
- Message: "An unexpected error occurred. Please try again later." (secondary text)
- CTA: "Reload" or "Report Issue"

### Offline
- Layout: full-screen banner or modal
- Icon: Wifi Off (warning color)
- Heading: "You're offline"
- Message: "Check your connection and try again"
- CTA: "Retry"
- Background: muted/desaturated surface color
```

**B. Context Switcher** (if `contextualRouting` exists):
```
## Workspace / Tenant Switcher

Location: Top-left header (below logo or next to hamburger menu)

Component specs:
- Trigger: Button with current workspace name + ChevronDown icon (primary text color)
- Dropdown: Card with list of 3-5 workspaces
- Workspace item: 
  - Avatar/icon (2-letter initials or logo)
  - Workspace name (body font, bold if selected)
  - Optional: "admin" badge if user is workspace admin
  - Hover: surface-elevated background
  - Selected: checkmark icon (primary color) + bold text
- "New Workspace" link at bottom (secondary text, hover primary)

Colors: Match header background (surface or surface-elevated)
```

**C. Guard UI Feedback** (if `guards` exist):
```
## Route Guard UX

Protected route redirect flow:
1. User tries to access admin-only page without admin role
2. Show toast notification: "You don't have permission to access this" (error toast, 4s duration)
3. Redirect to /forbidden page OR show inline error in current location

For feature-flagged content:
- Hide nav item entirely (don't show greyed-out)
- If user tries deep link: 404 page ("Feature not available in your plan")

For auth-required:
- Redirect to login page
- Show toast: "Please log in to continue" (info toast)
- Save return URL so user returns to original page after login
```

### Step 7: Update SDL

Write the complete `design` section back into SDL:

```yaml
design:
  personality: ...
  preset: ...
  tokens:               # Full token set per SDL spec v1.1
    colors:
      primary: "..."
      primary-dark: "..."
      secondary: "..."
      success: "..."
      warning: "..."
      error: "..."
    typography:         # camelCase per spec
      headingFont: "..." # e.g. "Clash Display"
      bodyFont: "..."    # e.g. "Poppins"
      monoFont: "..."    # e.g. "JetBrains Mono"
      scale:
        h1: "32px"
        h2: "24px"
        h3: "20px"
        body: "16px"
        small: "14px"
    spacing:
      xs: "4px"
      sm: "8px"
      md: "16px"
      lg: "24px"
      xl: "32px"
    radius:
      sm: "4px"
      md: "8px"
      lg: "12px"
      full: "9999px"
    shadows:
      sm: "..."
      md: "..."
      lg: "..."
  componentLibrary: ...
  iconLibrary: ...
  themes:               # Light/dark theme overrides
    - name: light
      colors:
        background: "#ffffff"
        text: "#111827"
    - name: dark
      colors:
        background: "#111827"
        text: "#f9fafb"
  layouts:              # Named layout shells
    - name: ...
      description: ...
  shape: ...
  motion: ...
  accessibility: ...
```

- **Single-file SDL** (`solution.sdl.yaml` exists): update only the `design` section — preserve everything else.
- **Multi-file SDL** (`sdl/` directory): write design section to `sdl/design.yaml` (create if absent); ensure `solution.sdl.yaml` imports it if an imports list is maintained.

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

### Step 9: Figma Push (Optional)

ℹ️ **OPTIONAL PATH:** May push tokens to Figma if configured

If the Figma MCP server was detected in Step 1.5 (or silently re-check now), offer:

> "Push these design tokens to Figma as local color and text styles? Reply with a Figma file key to update an existing file, `new` to create a new file, or `skip`."

If the user confirms, delegate to the **figma-agent** with:
- `mode: "push-tokens"`
- `projectDir` — current working directory
- `figmaFileKey` — from user input (or omit for new file)

**If Figma is not connected**, skip silently.

### Step 9.5: Application Type-Specific Adjustments

**Before finalizing the design system, adjust for the target application type:**

#### Web Design System
- **Component library reference:** shadcn/ui, Material UI, Chakra, Ant Design, etc.
- **Spacing scale:** 8px baseline (8, 12, 16, 24, 32, 48, 64, 96px)
- **Typography scale:** Web-optimized sizes (12px, 14px, 16px body; 20px, 24px, 32px, 40px headings)
- **Icons:** lucide-react, heroicons, or phosphor-icons (standard SVG icons)
- **Responsive:** Mobile-first (375px min, 1920px max), Tailwind breakpoints (sm, md, lg, xl, 2xl)
- **Dark mode:** Full CSS variables for light/dark toggle
- **Animations:** CSS transitions, Framer Motion optional
- **Navigation component patterns** (design for chosen web pattern):
  - Dashboard Sidebar: 240px sidebar nav (collapsible to 60px), header breadcrumbs
  - Marketing Top Nav: horizontal nav, sticky on scroll, no sidebar
  - App Shell: hamburger menu (mobile) → sidebar (tablet+), bottom nav (mobile)
  - Docs/Editorial: sticky side TOC, centered content column, breadcrumbs
  - Split View: resizable left panel divider, right content panes
  - Command Palette: modal search input, keyboard shortcut badge, filtering UI
  - Mega Menu: large dropdown grid, category headers, subcategories
- **Output:** design-tokens.json + Figma file + web component library + Storybook optional

#### Mobile Design System
- **Component library reference:** React Native Paper, NativeBase, Gluestack, Tamagui
- **Spacing scale:** 4px baseline (4, 8, 12, 16, 24, 32, 48px) — tighter on mobile
- **Typography scale:** Mobile-optimized sizes (12px, 14px, 16px body; 18px, 22px, 26px headings)
- **Touch targets:** ALL interactive elements minimum 44×44px (iOS HIG requirement)
- **Icons:** Expo icons, react-native-vector-icons, or lucide-react-native
- **Responsive:** Fixed viewport (not responsive — one size per device category)
- **Safe areas:** Account for notch, home indicator, rounded corners
- **Navigation patterns** (choose based on app structure):
  - **Bottom Tab Bar** (3-5 main sections) — persistent, always visible, good for 2-5 main flows
  - **Drawer Navigation** (hamburger → side drawer) — good for 5+ sections, less frequently accessed items
  - **Stack Navigation** (push/pop) — linear flows like detail pages, forms, onboarding
  - **Tab Bar + Drawer Hybrid** — fixed bottom tabs for main, drawer for secondary/settings
  - **Top Tab Bar** (below header) — for tab-within-tab, less common
  - **Segmented Control** (2-4 options) — iOS-style, for switching between views, not main navigation
- **Output:** design-tokens.json + mobile component library + navigation pattern components + Figma file for mobile frames

#### Desktop Design System
- **Component library reference:** Electron UI libraries (Chakra, shadcn/ui adapted), or custom native-feeling desktop components
- **Spacing scale:** 8px baseline, but larger defaults comfortable for desktop (12px, 16px, 24px, 32px preferred)
- **Typography scale:** Larger sizes for comfortable desktop viewing distance (13-14px body, 16-18px body default; 22px-40px headings)
- **Icons:** Larger icons with clear hit areas (24px minimum, 32px comfortable), desktop platform-aware
- **Fixed layout:** Resizable windows (1024×768 minimum), NOT responsive — each window size is fixed
- **Dark mode:** Full support (many desktop users prefer dark, sometimes as default)
- **Window chrome:** Title bar, menu bar (macOS) / window menu (Windows), status bar if applicable
- **Interactions:** 
  - Keyboard shortcuts (Cmd+S, Cmd+N, Ctrl+C, etc.) with visible shortcut hints
  - Context menus (right-click for common actions)
  - Drag-drop for files and UI elements
  - Window resize/minimize/maximize/close buttons
  - System integration (system tray, dock, taskbar)
- **Navigation component patterns** (design for chosen desktop pattern):
  - Sidebar + Top Bar: vertical nav sidebar + menu bar + toolbar
  - Ribbon UI: groupedcommand tabs (Microsoft Office style) + main content
  - MDI/Floating Windows: tabbed or floating document windows + main toolbar
  - Menu Bar Only: macOS/Windows menu bar + toolbar, minimal sidebar
  - Context Menus: right-click patterns for all major elements
  - Keyboard Navigation: full keyboard operability, shortcut keys everywhere
  - Status Bar: bottom bar with mode, file info, cursor position, zoom level
- **Output:** design-tokens.json + desktop component library + Figma file for desktop frames + keyboard shortcut reference

**Decision logic:**
1. If multiple application types found (web + mobile): ask which is PRIMARY
   ```
   "Found both web and mobile apps. Which design system should I create first?
   1. Web (for React)
   2. Mobile (for React Native)
   "
   ```
2. Generate the primary design system
3. Note in deliverable: "Secondary design systems (mobile/web) can be generated separately"

### Step 9.5: Signal Completion

🚀 **COMPLETION MARKER:** Signals end of design-system phase

Emit the completion marker:

```
[DESIGN_SYSTEM_DONE]
```

This ensures the design-system phase is marked as complete in the project state.

## Error Handling

### Missing All Context

If no `_state.json`, no wireframes, no SDL, and no user description is available:
> "What are you building? Give me a one-sentence description of your product so I can create a design system for it."

Do NOT require a blueprint — the design system can be generated from product description alone.

### Unable to Write Design Tokens File

If `architecture-output/design-system/` directory cannot be created due to permissions:
- Stop execution
- Report: "Cannot write to design-system/ directory: [error]. Check file permissions."
- Do NOT emit completion marker

### Conflicting Color Palette

If generated tokens conflict with existing CSS variables or Tailwind config:
- Report: "Design tokens conflict with existing Tailwind config. Review and merge manually."
- Still emit completion marker (generation succeeded; user may need to merge)

### Unsupported Font Library

If user requests a font from Google Fonts that is unavailable:
- Detect via failed fetch attempt
- Fall back to system font: "Font X unavailable; using fallback system font Y"
- Continue generation

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
