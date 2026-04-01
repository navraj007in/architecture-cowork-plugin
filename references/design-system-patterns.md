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
| **organic** | `200ms` | `500ms` | `800ms` | `cubic-bezier(0.4,0,0.2,1)` | fade `500ms` |
| **retro** | `0ms` | `0ms` | `0ms` | `linear` | none — instant toggle |
| **expressive** | `150ms` | `350ms` | `600ms` | `cubic-bezier(0.34,1.56,0.64,1)` | slide + scale `400ms` |
| **cinematic** | `400ms` | `700ms` | `1200ms` | `cubic-bezier(0.25,0.1,0.25,1)` | fade `700ms` |

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

---

## Unconventional Layout Patterns

For consumer, creative, and landing pages that need more than a standard hero + sections structure. Each pattern includes the core CSS technique and personality pairings.

### Split-Screen

Viewport divided into two contrasting halves — each half has its own background, content, and can have its own scroll. Classic for brand contrast, product A/B showcase, or portfolio intros.

```css
.split-screen {
  display: grid;
  grid-template-columns: 1fr 1fr;  /* or 40fr 60fr for asymmetric */
  min-height: 100vh;
}

/* Each half */
.split-left  { background: var(--surface); }
.split-right { background: var(--primary); color: var(--primary-foreground); }

/* On mobile: stack vertically */
@media (max-width: 768px) {
  .split-screen { grid-template-columns: 1fr; }
  .split-left, .split-right { min-height: 50vh; }
}
```

**Personalities:** expressive, cinematic, luxury, bold, retro
**Ratio options:** 50/50, 40/60, 33/67 — asymmetric feels more intentional

---

### Bento Grid

Asymmetric card mosaic. Cards span different column/row counts. Apple-style feature showcase — communicates a lot at a glance without linear scrolling.

```css
.bento-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-auto-rows: 200px;
  gap: 16px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Span variants */
.bento-wide  { grid-column: span 2; }
.bento-tall  { grid-row: span 2; }
.bento-hero  { grid-column: span 2; grid-row: span 2; }
.bento-full  { grid-column: span 4; }

/* Mobile: single column */
@media (max-width: 768px) {
  .bento-grid { grid-template-columns: 1fr; }
  .bento-wide, .bento-tall, .bento-hero, .bento-full {
    grid-column: span 1; grid-row: span 1;
  }
}
```

**Personalities:** expressive, minimal, bold, playful, organic
**Card content ideas:** feature callout, stat/metric, image, quote, CTA, video loop

---

### Full-Bleed Scroll Panels

Each section fills the full viewport. Scroll snapping creates a "page-through" experience. Works with or without snap — snap feels more immersive, free-scroll feels more editorial.

```css
/* With scroll snap (immersive) */
.panel-container {
  height: 100vh;
  overflow-y: scroll;
  scroll-snap-type: y mandatory;
}

.panel {
  height: 100vh;
  scroll-snap-align: start;
  scroll-snap-stop: always;  /* prevents skipping panels */
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Without snap (editorial) — just full-height sections */
.panel {
  min-height: 100vh;
  display: flex;
  align-items: center;
}
```

**Personalities:** cinematic, bold, expressive, luxury
**Common use:** music artists, film, portfolio hero sequences, app launch narratives

---

### Sticky Scroll Reveal

Parent section has a tall height. Child content sticks in the viewport while the user scrolls, revealing elements progressively (driven by scroll position via JS or CSS animation-timeline).

```css
.sticky-section {
  height: 300vh;  /* 3× viewport = scroll distance to move through */
  position: relative;
}

.sticky-content {
  position: sticky;
  top: 0;
  height: 100vh;
  overflow: hidden;
  display: flex;
  align-items: center;
}

/* Reveal elements using animation-timeline (modern browsers) */
@supports (animation-timeline: scroll()) {
  .reveal-element {
    animation: fadeUp linear both;
    animation-timeline: scroll(root);
    animation-range: entry 20% cover 40%;
  }
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(40px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

**Personalities:** cinematic, luxury, editorial, expressive
**Common use:** product storytelling, feature reveals, process walkthroughs

---

### Diagonal / Angled Sections

`clip-path` creates diagonal transitions between sections — breaks the monotony of horizontal bands. Overlap sections with negative margins to maintain continuity.

```css
.diagonal {
  clip-path: polygon(0 5vh, 100% 0, 100% calc(100% - 5vh), 0 100%);
  margin: -5vh 0;
  padding: 10vh 6%;
}

/* Reverse diagonal */
.diagonal-reverse {
  clip-path: polygon(0 0, 100% 5vh, 100% 100%, 0 calc(100% - 5vh));
  margin: -5vh 0;
  padding: 10vh 6%;
}

/* Steeper angle — more dramatic */
.diagonal-steep {
  clip-path: polygon(0 10vh, 100% 0, 100% 100%, 0 100%);
}
```

**Personalities:** bold, expressive, playful, retro (with thick borders on the diagonal)
**Note:** Avoid diagonal on mobile — reduce angle to 2vh or remove entirely below 768px

---

### Horizontal Scroll

Sections flow left-to-right instead of top-to-bottom. User scrolls right through a sequence. Works well for timelines, process steps, portfolio galleries.

```css
.horizontal-scroll {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  height: 100vh;
  /* Hide scrollbar visually */
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.horizontal-scroll::-webkit-scrollbar { display: none; }

.h-panel {
  min-width: 100vw;
  height: 100vh;
  scroll-snap-align: start;
  flex-shrink: 0;
}

/* Narrower panels for gallery feel */
.h-panel-narrow { min-width: 60vw; }
```

**Personalities:** expressive, cinematic, editorial (gallery mode), retro
**Warning:** Accessibility concern — provide vertical scroll fallback for keyboard/mobile

---

### Typography-Forward

Oversized type IS the layout. Content lives within or alongside massive letterforms. The type fills the viewport at sizes where individual letterforms become shapes. Common in fashion and design agency sites.

```css
/* Hero headline that fills the viewport */
.type-hero {
  font-size: clamp(4rem, 18vw, 16rem);
  line-height: 0.9;
  letter-spacing: -0.04em;
  font-weight: 900;
}

/* Mixed scale — different weights create visual hierarchy without layout */
.type-mixed {
  display: flex;
  flex-direction: column;
}
.type-mixed .display { font-size: clamp(5rem, 20vw, 18rem); font-weight: 900; line-height: 0.85; }
.type-mixed .caption { font-size: clamp(0.75rem, 1.5vw, 1rem); font-weight: 300; letter-spacing: 0.3em; text-transform: uppercase; }

/* Type that breaks out of container */
.breakout-type {
  margin-left: -6vw;
  margin-right: -6vw;
  width: calc(100% + 12vw);
}
```

**Personalities:** bold, expressive, brutalist, editorial (lighter weight), cinematic (tracking-wide)
**Font requirement:** Heavy display font needed — Bebas Neue, Syne, Archivo Black, Anton, or Bricolage Grotesque

---

### Magazine Grid

Editorial mosaic. Articles and features span different column counts. Inspired by print magazine layout — varied scale creates visual rhythm.

```css
.magazine-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Common span patterns */
.article-lead     { grid-column: span 8; }  /* dominant story */
.article-sidebar  { grid-column: span 4; }  /* secondary stack */
.article-feature  { grid-column: span 12; } /* full-width feature */
.article-half     { grid-column: span 6; }  /* equal pair */
.article-third    { grid-column: span 4; }  /* three-up */

/* Add visual rhythm with varying image heights */
.article-tall  { min-height: 480px; }
.article-short { min-height: 280px; }

/* Mobile: collapse to single column */
@media (max-width: 768px) {
  .magazine-grid { grid-template-columns: 1fr; }
  [class*="article-"] { grid-column: span 1; }
}
```

**Personalities:** editorial, organic, retro, expressive, luxury
**Common use:** blogs, news sites, portfolio indexes, recipe sites, lookbooks
