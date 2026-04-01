# Design System — Patterns Reference

Dark mode tokens, gradient/texture recipes, motion timing values, and layout archetype spatial specs. Loaded alongside `design-systems.md` and `design-system-fonts.md`.

---

## Dark Mode Token Patterns

When `surface: dark` is set in SDL, or when the domain defaults to dark (developer tools, gaming, AI/ML at user preference), apply this token structure.

### Surface Hierarchy (dark)

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#09090b` / `zinc-950` | Page background |
| `surface` | `#18181b` / `zinc-900` | Card, panel, sidebar |
| `surface-elevated` | `#27272a` / `zinc-800` | Modal, dropdown, tooltip |
| `surface-inset` | `#09090b` / `zinc-950` | Input fields, code blocks |
| `border` | `rgba(255,255,255,0.08)` | Subtle dividers |
| `border-strong` | `rgba(255,255,255,0.15)` | Visible borders, inputs |
| `text-primary` | `#fafafa` / `zinc-50` | Body text, headings |
| `text-secondary` | `#a1a1aa` / `zinc-400` | Muted labels, captions |
| `text-disabled` | `#52525b` / `zinc-600` | Disabled states |

### Dark Mode by Personality

| Personality | Background | Surface | Border style | Notes |
|-------------|-----------|---------|-------------|-------|
| minimal | `#0a0a0a` | `#141414` | `rgba(255,255,255,0.06)` | Near-black — maximum contrast without harshness |
| corporate | `#0f172a` / slate-900 | `#1e293b` / slate-800 | `rgba(255,255,255,0.1)` | Slate family — professional, cold |
| playful | `#1a0033` | `#2d1060` | none or coloured | Deep purple-black with vibrant surface accents |
| bold | `#000000` | `#111111` | `2px solid white` | Pure black — maximum punch |
| brutalist | `#ffffff` (invert) or `#000000` | `#000000` | `2px solid #ffffff` | True inversion — brutalism works light OR dark |
| editorial | `#0c0a09` / stone-950 | `#1c1917` / stone-900 | `rgba(255,255,255,0.08)` | Warm black — not cold, ink-on-paper feel |
| luxury | `#080808` | `#121212` | `rgba(255,255,255,0.06)` | Maximum depth — let gold/accent breathe |

### Primary Colour in Dark Mode

Saturated colours appear too aggressive on dark backgrounds. Shift the primary shade:

| Light mode primary | Dark mode equivalent |
|-------------------|---------------------|
| `primary-600` | `primary-400` |
| `primary-700` | `primary-400` or `primary-300` |
| Custom hex | Lighten 20–30% OR increase saturation |

Dark mode interactive elements (buttons, links) use `primary-400` on dark surfaces. Reserve `primary-600+` for filled backgrounds.

### CSS Token Generation Pattern

```css
/* globals.css — dual-mode token structure */
:root {
  --background: 0 0% 100%;
  --surface: 0 0% 98%;
  --surface-elevated: 0 0% 96%;
  --border: 240 5% 90%;
  --text-primary: 240 10% 4%;
  --text-secondary: 240 4% 46%;
  --primary: 221 83% 53%;        /* hsl values for Tailwind opacity modifier */
  --primary-foreground: 0 0% 98%;
}

.dark {
  --background: 240 10% 4%;
  --surface: 240 6% 10%;
  --surface-elevated: 240 5% 16%;
  --border: 240 4% 16%;
  --text-primary: 0 0% 98%;
  --text-secondary: 240 5% 65%;
  --primary: 217 91% 70%;        /* lighter shade for dark mode */
  --primary-foreground: 240 10% 4%;
}
```

---

## Gradient & Texture Recipes

### Minimal — Subtle gradient only

```css
/* Background: barely-there gradient — often none */
background: linear-gradient(180deg, #ffffff 0%, #f9fafb 100%);

/* Surface card: no gradient, use shadow instead */
background: #ffffff;
box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
```

### Corporate — Structured, no decorative gradients

```css
/* Header/hero: clean solid or very subtle gradient */
background: linear-gradient(135deg, #1e40af 0%, #1d4ed8 100%);

/* Cards: flat with border */
background: #ffffff;
border: 1px solid #e2e8f0;
```

### Playful — Mesh gradients, high saturation

```css
/* Full page mesh gradient background */
background-color: #fff0f9;
background-image:
  radial-gradient(at 15% 10%, #fde68a 0px, transparent 50%),
  radial-gradient(at 85% 5%,  #a5f3fc 0px, transparent 50%),
  radial-gradient(at 50% 90%, #f0abfc 0px, transparent 50%),
  radial-gradient(at 5%  80%, #bbf7d0 0px, transparent 50%);

/* Card: coloured surface with soft glow */
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(12px);
border: 1px solid rgba(255,255,255,0.5);
```

### Bold — Directional hard gradients

```css
/* Hero: high-contrast directional */
background: linear-gradient(135deg, #f97316 0%, #ef4444 100%);

/* Dark bold hero */
background: #000000;
/* Accent stripe: 4px solid primary top border on cards */
border-top: 4px solid #f97316;
```

### Brutalist — No gradients. Ever.

```css
/* Everything is flat, high contrast */
background: #ffffff;
border: 2px solid #000000;
/* Hover: invert */
background: #000000;
color: #ffffff;
```

### Editorial — Warm paper tones

```css
/* Page background: warm off-white */
background: #faf9f7;

/* Section break: subtle warm gradient */
background: linear-gradient(180deg, #faf9f7 0%, #f3f0eb 100%);

/* Pull quote / highlight block */
background: #f5f0e8;
border-left: 3px solid #292524;
```

### Luxury — Depth through layering

```css
/* Dark luxury page */
background: #080808;

/* Card: frosted glass on dark */
background: rgba(255, 255, 255, 0.03);
backdrop-filter: blur(20px);
border: 1px solid rgba(255, 255, 255, 0.06);

/* Hero accent: radial glow — primary colour at low opacity */
background-image: radial-gradient(ellipse 60% 40% at 50% 0%, rgba(212,175,55,0.15) 0%, transparent 70%);

/* Noise texture (apply as ::before pseudo-element) */
/* Generate via: https://grainy-gradients.vercel.app */
background-image: url("data:image/svg+xml,..."); /* SVG noise filter */
opacity: 0.03;
```

---

## Motion Timing Values

Actual `duration` and `easing` values per personality. Use in CSS custom properties and design tokens.

| Personality | Fast | Normal | Slow | Easing | Page transition |
|-------------|------|--------|------|--------|----------------|
| **minimal** | `100ms` | `200ms` | `350ms` | `ease-out` | fade `200ms` |
| **corporate** | `80ms` | `150ms` | `250ms` | `ease-in-out` | none |
| **playful** | `200ms` | `400ms` | `600ms` | `cubic-bezier(0.68,-0.55,0.265,1.55)` | slide + fade `400ms` |
| **bold** | `80ms` | `150ms` | `200ms` | `ease-out` | hard cut or flash `80ms` |
| **brutalist** | `0ms` | `0ms` | `0ms` | `linear` | none |
| **editorial** | `150ms` | `300ms` | `500ms` | `cubic-bezier(0.4,0,0.2,1)` | fade `300ms` |
| **luxury** | `300ms` | `600ms` | `1000ms` | `cubic-bezier(0.25,0.1,0.25,1)` | fade + scale `600ms` |

### Token format in design-tokens.json

```json
"motion": {
  "duration": {
    "fast": "100ms",
    "normal": "200ms",
    "slow": "350ms"
  },
  "easing": {
    "default": "ease-out",
    "bounce": "cubic-bezier(0.68, -0.55, 0.265, 1.55)",
    "smooth": "cubic-bezier(0.4, 0, 0.2, 1)",
    "luxury": "cubic-bezier(0.25, 0.1, 0.25, 1)"
  },
  "pageTransition": "fade",
  "reducedMotionOverride": "0ms linear"
}
```

**Reduced motion:** When `accessibility.reducedMotion: true` in SDL, all values collapse to `0ms linear`. Implement via `@media (prefers-reduced-motion: reduce)` — never suppress this.

---

## Layout Archetype Spatial Specs

Precise dimensions for each layout type. Use when generating scaffold layouts and palette preview.

### Dashboard

```
┌──────────────────────────────────────────┐
│ Header (56px)                             │
├──────────┬───────────────────────────────┤
│ Sidebar  │ Content area (fluid)          │
│ 240px    │ padding: 24px                 │
│ (64px    │ max-width: none               │
│  collapsed)│ grid: 12 col, 16px gap      │
└──────────┴───────────────────────────────┘
```

| Element | Value |
|---------|-------|
| Sidebar width | `240px` (expanded), `64px` (collapsed) |
| Header height | `56px` |
| Content padding | `24px` all sides |
| Card gap | `16px` |
| Content grid | 12 columns, `16px` gutter |
| Max content width | fluid (no cap) |

### Marketing

```
┌──────────────────────────────────────────┐
│ Nav (64px)                                │
├──────────────────────────────────────────┤
│ Hero (100vh or 80vh)                      │
├──────────────────────────────────────────┤
│ Sections: max-w-6xl (1152px) centered    │
│ padding: 96px top/bottom, 24px sides     │
├──────────────────────────────────────────┤
│ Footer                                   │
└──────────────────────────────────────────┘
```

| Element | Value |
|---------|-------|
| Nav height | `64px` |
| Max content width | `1152px` (`max-w-6xl`) |
| Section vertical padding | `96px` (`py-24`) |
| Section horizontal padding | `24px` (`px-6`) |
| Hero height | `100vh` or `80vh` |
| Feature grid | 3 columns at `md:`, 1 at `sm:` |
| CTA section | full-width with contrast bg |

### Editorial

```
┌──────────────────────────────────────────┐
│ Nav (48px, minimal)                       │
├──────────────────────────────────────────┤
│          Article content                 │
│          max-w: 680px centered            │
│          padding: 64px top, 32px sides   │
│          line-height: 1.8                │
└──────────────────────────────────────────┘
```

| Element | Value |
|---------|-------|
| Content max width | `680px` |
| Vertical section padding | `64px` |
| Horizontal padding | `32px` |
| Line height (body) | `1.75–1.9` |
| Reading characters per line | `65–75` chars |
| Nav height | `48px` (minimal) |
| No sidebar | — |

### SaaS

Two-phase layout: auth shell → app shell post-login.

**Auth phase:**

| Element | Value |
|---------|-------|
| Auth card width | `448px` (`max-w-md`) |
| Auth card padding | `32px` |
| Card position | centered with split: left brand panel + right form OR centered card |
| Brand panel | `480px` fixed, full-height, primary bg |

**App phase (post-auth):** Use dashboard archetype specs.

**Settings section:**

| Element | Value |
|---------|-------|
| Settings nav width | `200px` |
| Settings content max width | `640px` |
| Settings layout | left nav + content, no sidebar collapse |

### App Shell (mobile-first)

```
┌──────────────────────────────────────────┐
│ Top nav (56px)                            │
├──────────────────────────────────────────┤
│ Content (full width)                     │
│ padding: 16px                            │
│ max-width: none on mobile                │
│ max-width: 768px on md:                  │
├──────────────────────────────────────────┤
│ Bottom nav (56px) — mobile only          │
└──────────────────────────────────────────┘
```

| Element | Value |
|---------|-------|
| Top nav height | `56px` |
| Bottom nav height | `56px` (mobile only, hidden `md:hidden`) |
| Content padding | `16px` |
| Content max width | `768px` at `md:`, fluid at `sm:` |
| Bottom nav items | 4–5 items, icon + label |
