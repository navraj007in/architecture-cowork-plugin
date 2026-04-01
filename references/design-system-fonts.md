# Design System — Font Pairing Library

Curated heading + body font pairs by personality. All fonts are available on Google Fonts. Rotate through these — do not converge on one pairing per personality.

**Rule:** Never use the same pair twice for the same domain in close succession. If Space Grotesk was used recently for a brutalist project, pick Azeret Mono next time.

---

## Personality → Font Pairs

### Minimal

Clean, airy, low visual noise. Geometric or humanist sans. Light-to-medium weights dominate.

| Heading | Body | Character |
|---------|------|-----------|
| Geist | Geist | Same family, weight contrast only — ultra-clean |
| Sora | DM Sans | Friendly geometric pair |
| Outfit | Inter | Rounded geometric + neutral |
| Figtree | Figtree | Single-family, expressive at large sizes |
| Plus Jakarta Sans | Manrope | Modern humanist pair |
| Nunito Sans | Source Sans 3 | Warm minimal, legible at small sizes |
| Urbanist | DM Sans | High-waisted geometric, airy at large scale |

**Weight guidance:** 300–400 for body, 500–600 for headings. Never bold at minimal personality.

---

### Corporate

Structured, confident, trustworthy. Slightly condensed or neutral sans. Never decorative.

| Heading | Body | Character |
|---------|------|-----------|
| Bricolage Grotesque | Source Sans 3 | Contemporary corporate, editorial edge |
| Work Sans | Lato | Balanced, familiar, professional |
| IBM Plex Sans | IBM Plex Sans | Same family — serious, technical credibility |
| Barlow | Open Sans | Condensed heading energy, open body |
| Chivo | Chivo | Single family, high legibility, neutral |
| Lexend | Source Sans 3 | Designed for readability — good for enterprise tools |
| Schibsted Grotesk | Lato | Nordic restraint, authoritative |

**Weight guidance:** 600–700 for headings, 400 for body. Never ultra-light at corporate personality.

---

### Playful

Warm, rounded, energetic. Expressive headings, readable body. Pairs should feel friendly together.

| Heading | Body | Character |
|---------|------|-----------|
| Fredoka | Nunito | Rounded, joyful, approachable |
| Baloo 2 | Poppins | Bouncy display + geometric body |
| Righteous | DM Sans | Retro-playful + clean body |
| Nunito | Nunito Sans | Cohesive family, warm throughout |
| Comfortaa | Quicksand | Rounded pair, soft and friendly |
| Lilita One | Poppins | High-impact display, energetic |
| Boogaloo | Nunito Sans | Fun, hand-lettered feel without being childish |

**Weight guidance:** 700–800 for headings (display impact), 400–500 for body.

---

### Bold

High contrast, assertive, unapologetic. Heavy headings that command the layout. Body stays clean.

| Heading | Body | Character |
|---------|------|-----------|
| Bebas Neue | Archivo | Classic bold display + grotesque body |
| Syne | Manrope | Geometric display, contemporary tech |
| Archivo Black | DM Sans | Heavy grotesque + lightweight body |
| Black Han Sans | Work Sans | High impact, Korean grotesque aesthetics |
| Russo One | IBM Plex Sans | Industrial, strong |
| Teko | Source Sans 3 | Condensed heavy, maximum impact |
| Permanent Marker | DM Sans | Hand-drawn energy + clean body (use sparingly) |

**Weight guidance:** 800–900 for headings, 400 for body. High weight contrast is the design intent.

---

### Brutalist

Raw, monospaced or condensed grotesque. Functional, anti-decorative. Refuses refinement deliberately.

| Heading | Body | Character |
|---------|------|-----------|
| Space Mono | IBM Plex Sans | Classic brutalist pair — code aesthetic |
| Azeret Mono | Space Grotesk | Technical, deliberately awkward |
| IBM Plex Mono | IBM Plex Sans | IBM family cohesion, systematic |
| Courier Prime | Source Code Pro | Old-school typewriter energy |
| Martian Mono | JetBrains Mono | Sci-fi brutalism, developer-coded |
| Share Tech Mono | Share Tech | Military/technical, low-level feel |
| Anonymous Pro | DM Mono | Minimal, pure utility |

**Weight guidance:** Regular weight only (400). Bold is decoration — brutalism avoids it.

---

### Editorial

Refined, literary, generous whitespace. Serif headings are expected. Body can be serif or refined sans.

| Heading | Body | Character |
|---------|------|-----------|
| Playfair Display | Source Serif 4 | Classic editorial — both serif, harmonious |
| DM Serif Display | Karla | High-contrast serif + humanist sans body |
| Cormorant Garamond | Lato | Elegant, thin-stroked, literary |
| Lora | Lora | Single-family serif, book-like reading experience |
| Libre Baskerville | Source Sans 3 | Traditional + modern body contrast |
| Spectral | DM Sans | Distinctive serif display + neutral body |
| EB Garamond | Nunito Sans | Classical type + friendly body |

**Weight guidance:** 400–700 for headings (don't go ultra-bold with serifs), 400 for body. Line heights generous (1.7–1.9 for body).

---

### Luxury

Ultra-refined, slow, high-fashion. Thin weights. Significant letter-spacing. Never feels rushed.

| Heading | Body | Character |
|---------|------|-----------|
| Cormorant | Jost | Ultra-thin serif display + geometric body |
| EB Garamond | Raleway | Literary + fashion-forward body |
| Tenor Sans | DM Sans | High-end editorial, neutral body |
| Josefin Sans | Josefin Sans | Single-family, extreme geometric thin |
| Gilda Display | Lato | Elegant serif with subtle flourishes |
| Bodoni Moda | Montserrat | Contrast-heavy serif + structured body |
| Italiana | Raleway | Italian luxury feel, thin and refined |

**Weight guidance:** 100–300 for headings (thin is the statement), 300–400 for body. Generous letter-spacing on headings: `tracking-[0.15em]` to `tracking-[0.3em]`.

---

## Mono Font Recommendations

Mono font used for code blocks, technical data, tokens, timestamps.

| Font | Character | Pairs well with |
|------|-----------|----------------|
| JetBrains Mono | Developer-focused, high legibility | Any personality |
| Fira Code | Ligatures, warm | Editorial, minimal |
| Source Code Pro | Neutral, professional | Corporate, minimal |
| IBM Plex Mono | Systematic, technical | Brutalist, corporate |
| Space Mono | Retro, character-heavy | Brutalist, bold |
| Inconsolata | Compact, legible | Minimal, editorial |
| Roboto Mono | Familiar, functional | Corporate, playful |

---

## Pairing Rules

1. **Never use the same font for heading and body unless from the same designed family** (e.g. IBM Plex Sans + IBM Plex Mono is fine; Poppins heading + Poppins body is lazy)
2. **Serif heading + sans body = classic contrast** — always works for editorial/luxury
3. **Sans heading + sans body = personality must differ** — one geometric, one humanist, or weight contrast alone
4. **Mono heading = brutalist/developer only** — looks amateurish in any other personality
5. **Never pair two decorative fonts** — one display, one text
6. **Letter-spacing for display fonts:** increase at large sizes (`text-5xl+` → add `tracking-tight` for bold, `tracking-wide` for luxury)

---

## Rotation Mechanism

To avoid convergence, maintain implicit diversity across invocations:

- When domain is fintech and personality is corporate → check if Bricolage Grotesque + Source Sans 3 was used in this project → if yes, pick next pair in the table
- Signal words in the SDL `solution.name` or `description` can hint at character: "swift", "flash", "pulse" → bold/dynamic fonts; "haven", "still", "quiet" → editorial/luxury fonts
- Industry sub-domain breaks ties: B2C e-commerce → Baloo 2 + Poppins; D2C brand e-commerce → Syne + Manrope; B2B procurement → Work Sans + Lato
