---
name: design-system
description: Generate a context-aware, production-grade design system from the SDL blueprint. Produces design tokens, typography, palette, motion language, and component inventory — grounded in the product domain, audience, and architecture. Use this skill when generating or refining the SDL design section, scaffolding frontend projects, or when the user asks about visual direction.
---

This skill generates distinctive, production-grade design systems that are **derived from architecture context** — not random aesthetic choices. Every design decision traces back to the product domain, target audience, component library, and accessibility requirements defined in the SDL.

The user has an SDL blueprint. This skill fills, refines, or validates the `design` section and produces actionable design artifacts.

## Design Thinking — Context-Driven

Before making any design choice, ground it in the SDL:

1. **Read the SDL** — extract `solution.name`, `solution.description`, frontend components, target audience, product domain
2. **Derive personality** — map domain + audience to a design personality:
   - Fintech / Banking → corporate or editorial
   - Healthcare → minimal
   - E-commerce → playful or bold
   - Education → minimal or playful
   - Developer tools → brutalist or minimal
   - Enterprise SaaS → corporate
   - Creative / Media → editorial
   - Real estate → luxury
   - Kids / Family → playful
   - AI / ML → minimal
3. **Derive palette** — domain-appropriate colors, NEVER indigo/purple as default:
   - Fintech → emerald or teal
   - Healthcare → sky or cyan
   - E-commerce → orange or rose
   - Developer tools → green or lime
   - Enterprise → blue or slate
   - Creative → violet or fuchsia
   - See `design-systems.md` reference for full domain mapping
4. **Derive layout archetype** — from component types in SDL:
   - Admin/CRM/Dashboard frontends → `dashboard` (sidebar + header + content)
   - Marketing/Landing pages → `marketing` (hero + sections + footer)
   - Content-heavy apps → `editorial` (wide content + typographic hierarchy)
   - SaaS with auth → `saas` (auth layout + dashboard + settings)
   - Mobile-first web → `app-shell` (top nav + responsive content)

## Design Principles

Adapted from Anthropic's frontend-design research — applied through an architecture lens:

### Typography
- Choose fonts that are **distinctive and context-appropriate** — not generic
- NEVER default to Inter, Roboto, Arial, or system fonts for headings
- Pair a characterful display/heading font with a refined body font
- Match font personality to product personality (serif for editorial/luxury, geometric sans for corporate, mono for brutalist/dev)
- All fonts must be available via Google Fonts for scaffold integration

### Color & Palette
- Commit to a **dominant color with sharp accents** — don't distribute color evenly
- Primary color derived from product domain (see domain mapping above)
- Semantic colors (success, warning, error, info) must be distinct from primary palette
- Surface mode (light/dark/auto) based on product context — dev tools default dark, enterprise defaults light
- All colors must meet WCAG contrast requirements per SDL accessibility level

### Motion Language
- Define a motion philosophy, not individual animations
- **One orchestrated page transition > scattered micro-interactions**
- Match motion to personality: none/snappy for brutalist/corporate, smooth for luxury/editorial, expressive for playful
- Respect `reducedMotion` accessibility setting when specified
- Specify transition timing, easing, and scroll behavior preferences

### Spatial Composition
- Match density to personality: compact for corporate/brutalist, relaxed for editorial/luxury
- Define border radius, shadow depth, and border treatment as a cohesive system
- Specify max content width based on layout archetype
- Unexpected layouts are encouraged when personality supports it (bold, editorial) — asymmetry, overlap, grid-breaking elements

### Backgrounds & Texture
- Create atmosphere appropriate to personality — not flat white everywhere
- Luxury/editorial: subtle gradients, noise textures, layered transparencies
- Brutalist: raw, high-contrast, no decoration
- Corporate: clean, structured, minimal texture
- Playful: gradient meshes, geometric patterns, bold fills

## Output Specification

When generating a design system, produce ALL of the following:

### 1. SDL Design Section
Complete the SDL `design` section with all fields:

```yaml
design:
  preset: [component library — shadcn | material | ant | chakra | daisyui | bootstrap | custom]
  personality: [derived from domain + audience]
  palette:
    primary: [domain-appropriate color]
    secondary: [complementary color]
    accent: [contrast color for CTAs and highlights]
    neutral: [slate | gray | zinc | neutral | stone — matched to personality]
    surface: [light | dark | auto — context-appropriate]
    semantic:
      success: [green variant]
      warning: [amber variant]
      error: [red variant]
      info: [blue variant]
  typography:
    heading: [distinctive Google Font — NEVER Inter/Roboto/Arial]
    body: [readable Google Font — paired for contrast]
    mono: [monospace font for code blocks]
    scale: [compact | default | spacious — matched to personality]
  shape:
    radius: [none | sm | md | lg | full — matched to personality]
    density: [compact | default | relaxed]
    shadows: [flat | subtle | elevated | dramatic]
    borders: [none | subtle | visible | bold]
  motion:
    transitions: [none | snappy | smooth | expressive]
    pageTransitions: [true | false]
  layout:
    maxWidth: [1024-1440 based on archetype]
    style: [dashboard | marketing | editorial | app-shell | saas]
  iconLibrary: [lucide | heroicons | phosphor | tabler — matched to personality]
  componentLibrary: [full name e.g. "shadcn/ui", "Radix UI"]
  accessibility:
    wcag: [A | AA | AAA — default AA for most, AAA for healthcare/gov]
    reducedMotion: [boolean]
    highContrast: [boolean]
```

### 2. Design Language Brief
A human-readable 1-page markdown summary:
- **Product context** — what this product is and who it's for (from SDL)
- **Aesthetic direction** — the personality choice and why it fits
- **Palette rationale** — why these colors for this domain
- **Typography pairing** — the heading + body fonts and why they work together
- **Motion philosophy** — how this product moves and why
- **Layout approach** — the spatial logic and density
- **Key differentiator** — the one visual element that makes this design memorable

### 3. Design Tokens (JSON)
Machine-readable tokens for consumption by scaffold:

```json
{
  "colors": {
    "primary": { "50": "...", "100": "...", "...", "950": "..." },
    "secondary": { ... },
    "accent": { ... },
    "neutral": { ... },
    "semantic": { "success": "...", "warning": "...", "error": "...", "info": "..." }
  },
  "typography": {
    "heading": { "family": "...", "googleFont": true, "weights": [400, 600, 700] },
    "body": { "family": "...", "googleFont": true, "weights": [400, 500] },
    "mono": { "family": "...", "googleFont": true, "weights": [400] },
    "scale": "default"
  },
  "shape": {
    "radius": { "sm": "0.25rem", "md": "0.5rem", "lg": "1rem", "full": "9999px", "default": "0.5rem" },
    "shadows": { "sm": "...", "md": "...", "lg": "..." },
    "borders": { "width": "1px", "color": "..." }
  },
  "motion": {
    "duration": { "fast": "150ms", "normal": "300ms", "slow": "500ms" },
    "easing": { "default": "cubic-bezier(0.4, 0, 0.2, 1)", "bounce": "cubic-bezier(0.68, -0.55, 0.265, 1.55)" }
  },
  "layout": {
    "maxWidth": "1280px",
    "style": "dashboard"
  }
}
```

### 4. Component Inventory
Map SDL architecture components to UI components needed:

| SDL Component | UI Components Needed |
|---|---|
| Auth service | Login form, signup form, forgot password, auth layout |
| User dashboard | Sidebar nav, stat cards, data tables, charts |
| API service | API key management, usage meters, code snippets |
| Payment integration | Pricing cards, checkout form, billing history |

### 5. Tailwind Config Patch
Ready-to-merge Tailwind configuration:

```typescript
// tailwind.config.ts extension
import type { Config } from 'tailwindcss'

export default {
  theme: {
    extend: {
      colors: { /* from design tokens */ },
      fontFamily: { /* from typography */ },
      borderRadius: { /* from shape */ },
      boxShadow: { /* from shape */ },
    },
  },
} satisfies Config
```

### 6. Sample Palette Preview
Single-file HTML that visually demonstrates:
- Color palette with all shades
- Typography specimens (heading + body + mono at different sizes)
- Shape system (radius, shadows, borders on sample cards)
- Button variants in the design language
- A mini layout demonstrating the chosen archetype

## Validation Rules

- Every color choice must trace to a domain rationale — no random picks
- Heading font must NOT be the same as body font
- Heading font must NOT be Inter, Roboto, Arial, Helvetica, or system-ui
- Palette must not use indigo/purple as primary unless the domain is creative/gaming
- WCAG contrast must be validated against the accessibility level in SDL
- Motion settings must be consistent with personality (brutalist ≠ expressive)
- All fonts must exist in Google Fonts catalog
- Design tokens must be valid JSON consumable by the scaffold phase

## Diversity Rule

**No two projects should ever look the same.** Even within the same domain, vary:
- Font pairings (maintain a rotation — never converge on one "go-to" font like Space Grotesk)
- Color temperature (warm vs cool within the domain-appropriate range)
- Layout density and whitespace treatment
- Motion intensity within personality constraints
- Light vs dark surface default

The goal is design systems that feel **intentionally crafted for this specific product** — not templated output with a color swap.
