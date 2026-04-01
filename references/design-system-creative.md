# Design System — Creative & Consumer Reference

Four new personalities for consumer, creative, and non-business landing pages. Consumer domain defaults. Loaded alongside `design-systems.md` for any project where the SDL domain suggests a consumer or creative context.

---

## New Personalities

### Organic

Warm, flowing, tactile. Inspired by natural materials — paper, clay, linen. Curves everywhere. Never sharp. Never corporate.

**When to use:** Wellness, food/beverage (craft/artisan), sustainability brands, mental health, nature-adjacent products, boutique hospitality.

| Attribute | Value |
|-----------|-------|
| Radius | `xl` to `full` — flowing, never sharp |
| Density | Relaxed |
| Shadows | Warm and soft (`0 4px 24px rgba(120,80,40,0.10)`) |
| Borders | None, or `1px solid rgba(0,0,0,0.06)` |
| Whitespace | Very generous — breathing room is the aesthetic |
| Animation | Slow, smooth (`600ms ease-in-out`) — nothing snaps |
| Surface mode | Light default — warm off-white, not pure white |

**Tailwind pattern:**
```
bg-stone-50 text-stone-800
Cards: bg-white rounded-2xl shadow-sm border border-stone-100 p-8
Headings: font-serif font-medium tracking-tight text-stone-900
Body: font-sans font-light leading-relaxed text-stone-600
Buttons: bg-stone-800 text-stone-50 rounded-full px-6 py-3 hover:bg-stone-700
Dividers: border-stone-100
```

**Palette:**
- Primary: `stone-700` or custom `#8B6F47` (warm tan/terracotta)
- Secondary: `emerald-700` or `sage` custom `#6B7C6A`
- Accent: `amber-400` or terracotta `#C4704A`
- Surface: `#FAF8F5` (warm off-white — never `#FFFFFF`)
- Texture: grain overlay at 3–5% opacity (CSS noise filter or SVG)

---

### Retro / Nostalgic

Deliberately vintage. Draws from print design, old signage, 70s/80s/90s aesthetics. Grain textures, muted palettes, offset shadows, typewriter energy. Feels like something found rather than designed.

**When to use:** Music artists (vintage/indie), independent bookshops, craft beer/spirits, vintage fashion, record labels, zines, cultural events.

| Attribute | Value |
|-----------|-------|
| Radius | `none` or `sm` — flat, vintage printing aesthetic |
| Density | Compact or default |
| Shadows | Hard offset (no blur): `4px 4px 0 #000` or `3px 3px 0 currentColor` |
| Borders | Visible, sometimes double border or thick rule |
| Whitespace | Moderate — vintage layouts are denser than modern |
| Animation | None or instant toggle — vintage doesn't animate |
| Surface mode | Either light (aged paper) or dark (concert poster) |

**Tailwind pattern:**
```
Light: bg-amber-50 text-zinc-900
Dark: bg-zinc-900 text-amber-50
Cards: border-2 border-zinc-900 rounded-none shadow-[4px_4px_0_#18181b] bg-amber-100
Headings: font-display tracking-tight uppercase (or mixed case for softer retro)
Body: font-mono or font-serif text-sm leading-relaxed
Buttons: border-2 border-zinc-900 bg-transparent hover:bg-zinc-900 hover:text-amber-50 rounded-none uppercase tracking-widest text-xs px-5 py-2.5
Accents: rose-600 or yellow-400 used sparingly — single colour pops on muted bg
```

**Palette:**
- Primary: muted brick `#B5452A` or olive `#6B7A3D` or ochre `#C8A84B`
- Secondary: complementary muted — aged teal `#3D7A6B` or dusty rose `#C4857A`
- Neutral: warm-gray, never cold zinc
- Surface light: `#F5EDD8` (aged paper), surface dark: `#1A1512` (old film)
- Always add grain texture at 6–10% opacity

---

### Expressive / Maximalist

Loud, layered, unapologetic. Type is design. Colour is everywhere. No neutral safety nets. Inspired by graphic design studios, fashion editorials, contemporary art. Breaks grid deliberately.

**When to use:** Creative studios, design agencies, contemporary fashion brands, festival events, art galleries, youth-oriented brands, experimental products.

| Attribute | Value |
|-----------|-------|
| Radius | Mixed — some elements `full`, some `none`. Contrast is the point. |
| Density | Dense, layered |
| Shadows | Dramatic (`0 20px 60px rgba(0,0,0,0.3)`) or coloured shadows |
| Borders | Bold and coloured — `2px solid hsl(var(--primary))` |
| Whitespace | Tight overall, with deliberate explosive openings |
| Animation | Expressive, layered, but purposeful — not random |
| Surface mode | Both work — often mixed (dark hero, light sections) |

**Tailwind pattern:**
```
bg-white text-zinc-900 (or invert)
Hero: bg-zinc-950 text-white with primary colour splashes
Cards: bg-primary-400 text-zinc-950 OR bg-zinc-950 text-primary-400 — high contrast pairs
Headings: font-display font-black text-6xl+ tracking-tighter leading-none — type fills space
Body: font-sans font-medium text-base leading-snug
Buttons: bg-primary text-primary-foreground rounded-none OR rounded-full — pick one, commit
Accent elements: use rotation (rotate-3, -rotate-6) and absolute positioning to break grid
```

**Palette:**
- Primary: high-saturation — electric `#FF3B00`, vivid fuchsia `#E040FB`, acid green `#AAFF00`, electric blue `#0066FF`
- Secondary: direct complement or analogous — never muted
- Neutral: `zinc-950` for dark or `gray-50` for light — neutrals are extreme
- Coloured shadows: `drop-shadow(4px 4px 0 hsl(var(--primary)))` on text/elements

---

### Cinematic

Dark, atmospheric, immersive. Full-bleed imagery or video. Minimal text — when text appears, it commands. Inspired by film titles, luxury car brands, high-end game trailers. The absence of elements is as powerful as their presence.

**When to use:** Film/video production, gaming, luxury experiences, music artists (premium/dark), high-end automotive, travel experiences, nightlife/hospitality.

| Attribute | Value |
|-----------|-------|
| Radius | `none` — sharp edges feel cinematic. No friendly rounding. |
| Density | Spacious — key moments have generous air around them |
| Shadows | None on UI elements (they float in darkness). Dramatic glow on accents. |
| Borders | None, or `1px solid rgba(255,255,255,0.1)` (barely visible) |
| Whitespace | Asymmetric — some areas very tight, hero areas very open |
| Animation | Slow fades, `600–1000ms`, nothing snaps |
| Surface mode | **Dark by default** — light mode is an exception |

**Tailwind pattern:**
```
bg-zinc-950 text-zinc-50 (or bg-[#080808])
Sections: bg-zinc-900 or bg-transparent over a full-bleed image/video
Cards: bg-zinc-900/50 backdrop-blur-md border border-zinc-800
Headings: font-display font-thin tracking-[0.15em] uppercase text-5xl+ — wide tracking is the signature
Body: font-sans font-light text-zinc-400 leading-relaxed
Buttons: border border-zinc-600 text-zinc-200 uppercase tracking-widest text-xs px-8 py-3 hover:bg-white hover:text-zinc-950
Accent: single colour — amber-400 (#FBBF24), red-500, or electric-blue (#3B82F6) used very sparingly
Glow: drop-shadow(0 0 20px hsl(var(--accent)/0.4)) on accent elements
```

**Palette:**
- Surface: `#080808` to `#0f0f0f` — near-black, not `zinc-950` (too blue-tinted)
- Primary: near-black, letting accent do the work
- Accent: single high-impact colour — amber `#FBBF24`, electric blue `#3B82F6`, red `#EF4444`, or pure white
- Text: `#FAFAFA` primary, `#71717A` secondary (zinc-500)

---

## Consumer Domain Defaults

Domains that produce consumer, creative, or non-business websites. Use sub-domain notes to break ties.

| Domain | Primary | Neutral | Personality | Layout | Dark default? |
|--------|---------|---------|-------------|--------|--------------|
| **Personal portfolio — creative** | mono or `rose-600` | zinc | expressive or minimal | split-screen or bento | Optional |
| **Personal portfolio — developer** | `green-500` or `zinc-400` | zinc | minimal or brutalist | bento or marketing | Yes |
| **Music artist — mainstream** | brand-specific or `violet-600` | zinc | bold or expressive | full-bleed panels | Yes |
| **Music artist — indie/folk** | muted `amber-700` or `stone-600` | stone | retro or organic | magazine grid | Optional |
| **Music artist — electronic/dark** | `zinc-900` + electric accent | zinc | cinematic or bold | full-bleed panels | Yes |
| **Event / conference** | event brand or `blue-600` | slate | bold or editorial | marketing (hero-forward) | No |
| **Festival / cultural event** | high-saturation, multi-colour | zinc | expressive or retro | full-bleed + bento | Optional |
| **Restaurant — fine dining** | `stone-700` or `amber-800` | stone | luxury or organic | split-screen or editorial | Optional |
| **Restaurant — casual / street food** | `red-600` or `orange-500` | warm-gray | bold or retro | marketing | No |
| **Café / coffee** | `amber-800` or `stone-600` | stone | organic or minimal | editorial | No |
| **Fashion — luxury** | mono or `rose-800` | stone | luxury or cinematic | magazine grid or split-screen | Optional |
| **Fashion — streetwear / youth** | high-saturation | zinc | bold or expressive | bento or full-bleed | Optional |
| **Fashion — sustainable** | `emerald-700` or `stone-600` | stone | organic | editorial or split-screen | No |
| **Photography portfolio** | mono | minimal or cinematic | full-bleed panels | Optional |
| **Architecture / interior design** | `stone-700` or `slate-600` | stone | luxury or minimal | magazine grid | Optional |
| **Film / video production** | `zinc-900` + accent | zinc | cinematic | full-bleed panels | Yes |
| **Non-profit / cause** | `teal-600` or `amber-500` | gray | minimal or editorial | marketing | No |
| **App launch page** | from app domain | bold or minimal | bento + full-bleed | Optional |
| **Personal blog / newsletter** | `stone-700` or `slate-600` | stone | editorial | editorial | No |
| **Fitness / gym brand** | `lime-500` or `red-600` | zinc | bold | full-bleed + bento | Optional |
| **Wedding / events planning** | `rose-300` or `stone-400` | stone | luxury or organic | editorial or magazine grid | No |
| **Tattoo studio / barbershop** | mono or `red-700` | zinc | brutalist or retro | marketing or split-screen | Yes |
| **Craft brewery / spirits** | `amber-700` or `stone-600` | stone | retro or bold | marketing or magazine grid | Optional |

---

## Personality × Domain Quick Guide

When domain and desired feeling are clear but personality isn't obvious:

| Desired feeling | Personality |
|----------------|-------------|
| "Natural, handmade, warm" | Organic |
| "Vintage, found, nostalgic, cool" | Retro |
| "Loud, creative, studio, agency" | Expressive |
| "Dark, premium, atmospheric, film" | Cinematic |
| "Clean, quiet, premium" | Minimal or Luxury |
| "Trustworthy, clear, business" | Corporate |
| "Fun, accessible, joyful" | Playful |
| "Strong, assertive, commercial" | Bold |
| "Raw, anti-design, developer" | Brutalist |
| "Long-form, thoughtful, literary" | Editorial |
