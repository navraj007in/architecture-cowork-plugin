---
description: Generate a clickable UI prototype with distinctive visual design, working navigation, and realistic data
---

# /architect:prototype

## Trigger

`/architect:prototype` — run after intent.json is created. Works best after blueprint and design-system phases but not required.

## Purpose

Generate a fully clickable React prototype that founders can demo to investors, test with users, or validate UX. The prototype must look like a **real product** — not a developer's wireframe. Distinctive visual design, realistic data, working navigation, and interactive elements.

This is NOT a production application — it's a **demo prototype** with static/mock data, no backend, but polished visual design and working screen flows.

## Output Budget Strategy

A full prototype (10+ screens, 15+ components) exceeds a single output budget. Generation is split into phases using a manifest file. Each phase emits `[PROTOTYPE_CONTINUE]` — Archon auto-reruns until `[PROTOTYPE_DONE]`.

## Workflow

### Step 0: Check Manifest

Check if `prototype/_manifest.json` exists.

**If it exists:** Read it, determine which phase is complete, and continue from the next phase. Skip to the appropriate step below.

**If it does NOT exist:** This is Phase 1 — start from Step 1.

### Step 1: Gather Inputs

Read (use what's available, don't error if missing):
1. **`architecture-output/_state.json`** — read first if it exists; provides compact personas (names + roles for realistic mock data), entities (field lists for typed mock data), and design (personality, colors, fonts). Use these instead of reading full markdown files.
2. **intent.json** — product name, vision, target users, core features, core flows
3. **SDL file** (`solution.sdl.yaml`) — components, auth, data models, design section, `product.screens`, `product.screenFlows`
4. **Design tokens** — from `architecture-output/design-system/design-tokens.json` if available
5. **Wireframes** — from `architecture-output/wireframes/` if they exist (use as layout guide)
6. **User personas** — **only if `_state.json.personas` is absent**; from `architecture-output/user-personas.md` for realistic UI copy

### Step 2: Design Direction

**If `_state.json.design` exists (set by `design-system` command):** Use it as the authoritative source — it contains the full palette (primary, secondary, accent, surface, text colors), fonts, border radius, shadow, icon library, and component library. Do not re-derive from domain.

**If design-tokens.json exists** (`architecture-output/design-system/design-tokens.json`): Use it for full spacing scale, all semantic tokens, and Tailwind config values. `_state.json.design.tokens_file` points to this file.

**If NO design tokens exist (common case):** Derive a distinctive design from the product domain. Do NOT fall back to generic defaults. Instead:

#### Personality Selection (pick ONE based on domain)

| Domain | Personality | Visual Character |
|--------|------------|-----------------|
| Fintech / Banking | Corporate-sleek | Dark surface (#0f172a), emerald accents, sharp corners, data-dense tables, number-heavy |
| Healthcare / Wellness | Clean-minimal | White space, sky/teal palette, rounded corners (12px+), soft shadows, breathing room |
| E-commerce / Marketplace | Bold-commercial | Vibrant hero sections, orange/rose accents, product cards with hover effects, prominent CTAs |
| Education / Learning | Warm-approachable | Amber/indigo palette, playful illustrations, progress indicators, card-based content |
| Developer Tools | Technical-dark | Dark theme (zinc-950), green/lime accents, monospace elements, code blocks, compact layout |
| Creative / Media | Editorial-expressive | Asymmetric layouts, large typography, violet/fuchsia, image-heavy, whitespace as design element |
| Real Estate / Luxury | Premium-refined | Serif headings, muted gold/stone palette, large imagery, generous padding, subtle animations |
| Social / Community | Vibrant-social | Rounded avatars, reaction badges, activity feeds, bright accent colors, card-heavy |
| Enterprise SaaS | Professional-structured | Blue/slate palette, structured grids, sidebar navigation, data tables, status badges |
| AI / ML Products | Modern-minimal | Dark mode, cyan/purple gradients, glass morphism, streaming text effects, metric dashboards |
| Food / Restaurant | Warm-appetizing | Warm amber/orange, large food imagery, rounded cards, menu-style layouts |
| Travel / Hospitality | Aspirational-visual | Full-width imagery, map integrations, booking cards, calendar views, destination cards |

#### Color Palette Generation

Generate a COMPLETE palette — not just a primary color:
- **Primary** — main brand color (domain-derived)
- **Primary-light / Primary-dark** — lighter and darker variants for hover/active states
- **Secondary** — contrasting accent for CTAs and highlights
- **Surface** — background color (light or dark based on personality)
- **Surface-elevated** — cards, modals, dropdowns (slightly lighter/darker than surface)
- **Border** — subtle border color
- **Text-primary** — main text color
- **Text-secondary** — muted text
- **Text-on-primary** — text on primary color backgrounds
- **Success / Warning / Error / Info** — semantic colors

#### Typography

Pick a **distinctive heading font** paired with a readable body font. NEVER use Inter, Roboto, or Arial for headings.

| Personality | Heading Font | Body Font |
|------------|-------------|-----------|
| Corporate-sleek | Plus Jakarta Sans, Instrument Sans | Inter, DM Sans |
| Clean-minimal | Outfit, Manrope | Source Sans 3, Nunito Sans |
| Bold-commercial | Clash Display, Cabinet Grotesk | Poppins, Lato |
| Warm-approachable | Quicksand, Baloo 2 | Nunito, Open Sans |
| Technical-dark | JetBrains Mono, Space Grotesk | IBM Plex Sans, Fira Sans |
| Editorial-expressive | Playfair Display, Fraunces | Source Serif 4, Literata |
| Premium-refined | Cormorant Garamond, DM Serif Display | Lora, EB Garamond |
| Vibrant-social | Urbanist, Red Hat Display | DM Sans, Noto Sans |
| Professional-structured | Figtree, General Sans | Inter, Geist Sans |
| Modern-minimal | Sora, Space Grotesk | Geist Sans, Satoshi |

### Step 3: Build Screen Inventory & Write Manifest

Before generating any files, build the full screen list and write `prototype/_manifest.json`:

```json
{
  "appName": "ProductName",
  "personality": "professional-structured",
  "layout": "dashboard",
  "screens": [
    { "id": "dashboard", "title": "Dashboard", "phase": 3 },
    { "id": "users-list", "title": "Users", "phase": 3 },
    { "id": "user-detail", "title": "User Detail", "phase": 4 },
    { "id": "settings", "title": "Settings", "phase": 4 },
    { "id": "login", "title": "Login", "phase": 4 }
  ],
  "phase_complete": 0,
  "files_written": []
}
```

Assign screens to phases: Phase 3 gets the first 3 screens, Phase 4 gets the rest.

**Priority: If `product.screens` exists in SDL, use it as the screen inventory.** Otherwise infer from intent.json `core_features` and `core_flows`.

### Step 4: Phase 1 — Foundation Files

Generate these files (config + router + mock data only — no page content yet):

```
prototype/
├── package.json          ← all deps: react, react-dom, react-router-dom, vite, tailwindcss, lucide-react
├── index.html
├── vite.config.ts
├── tailwind.config.ts    ← themed with chosen palette + fonts
├── src/
│   ├── main.tsx
│   ├── App.tsx           ← router with <Route> for every screen (lazy imports ok)
│   ├── data/
│   │   └── mock.ts       ← realistic typed mock data, 10-20 records per entity
│   └── styles/
│       └── globals.css   ← Google Fonts import, CSS variables for palette
```

**mock.ts requirements:**
- Use proper names from different cultures (not just English names)
- Use realistic numbers (prices, dates, quantities appropriate to the domain)
- Include edge cases (long names, zero values, pending statuses)
- 10-20 records per entity — enough to fill a table and show pagination
- Include relationships between entities (order references a customer, etc.)
- Add avatar URLs using `https://api.dicebear.com/9.x/avataaars/svg?seed={name}`
- For entity structure: use `_state.json.entities` if available

Update `prototype/_manifest.json` → set `phase_complete: 1`, add written files to `files_written`.

Emit: `[PROTOTYPE_CONTINUE]`

### Step 5: Phase 2 — Layout & UI Primitives

Generate layout shell and base UI components:

```
prototype/src/
├── components/
│   ├── layout/
│   │   ├── Layout.tsx        ← wraps all app pages (sidebar or topnav shell)
│   │   ├── Sidebar.tsx       ← (if dashboard layout) collapsible, icon + label
│   │   ├── Header.tsx        ← search bar, notifications bell, user avatar menu
│   │   └── MobileNav.tsx     ← hamburger + drawer for mobile
│   └── ui/
│       ├── Button.tsx        ← primary/secondary/outline/ghost/danger + loading state
│       ├── Card.tsx          ← header/body/footer slots, hover elevation
│       ├── Input.tsx         ← label, helper text, error state, icon prefix/suffix
│       ├── Badge.tsx         ← success/warning/error/info/neutral variants
│       ├── Avatar.tsx        ← fallback initials, status dot, size variants
│       ├── Table.tsx         ← sortable headers, row hover, pagination, empty state
│       ├── Modal.tsx         ← overlay, close button, slide-in animation
│       ├── Tabs.tsx          ← horizontal tabs with active indicator
│       ├── Skeleton.tsx      ← loading placeholder shapes
│       └── EmptyState.tsx    ← icon + message + CTA
```

**Layout variety — match to product type:**
- Dashboard/SaaS/CRM: sidebar layout (240px collapsible)
- Consumer/Marketplace: topnav layout (sticky, transparent-to-solid scroll)
- Mobile-first/Social: bottom tabs (mobile) + topnav (desktop)
- Chat/Files: split layout (resizable panels)

Every component must have:
- Hover and active states
- Proper TypeScript props interface
- Uses the chosen palette via Tailwind classes (not hardcoded hex values)

Update manifest → `phase_complete: 2`.

Emit: `[PROTOTYPE_CONTINUE]`

### Step 6: Phase 3 — Personality Components & First Screens

Generate 3-5 personality-specific components then the first 3 screens from the manifest:

**Personality-specific components (pick based on product):**
- `MetricCard` — dashboards: number, trend arrow, sparkline
- `ActivityFeed` — social/SaaS: avatar + action + timestamp
- `PricingCard` — marketing: tier name, price, features, CTA
- `SearchBar` — content/marketplace: with filters, suggestions
- `KanbanColumn` — project management: draggable card placeholders
- `ChatBubble` — messaging/AI: left/right alignment, typing indicator
- `CalendarView` — booking/scheduling: month grid with event dots
- `FileCard` — file management: icon, name, size, actions
- `ProgressBar` / `StepIndicator` — onboarding/wizards
- `Chart` — simple bar/line/donut chart (pure CSS or recharts)

**First 3 screens** — each page MUST meet:
1. Visual hierarchy — 3-4 distinct text levels (size + weight + color)
2. Real content — product-specific labels, table headers, button text (no lorem ipsum)
3. Interactive states — hover effects on all interactive elements
4. Uses mock data from `data/mock.ts`

**Page variety requirements:**
- Dashboard/Home: metric cards + recent activity + quick actions
- List pages: table with filters, search, bulk actions, pagination
- Detail pages: header + actions, tabbed content, related items
- Form pages: multi-section, validation, submit + cancel
- Settings: left nav, toggles, save/reset
- Auth: centered card, social buttons, branded background

Update manifest → `phase_complete: 3`, add screen ids to a `screens_done` array.

Emit: `[PROTOTYPE_CONTINUE]`

### Step 7: Phase 4 — Remaining Screens & Verification

Generate all remaining screens from the manifest (those not in `screens_done`).

For each remaining screen, apply the same quality standards as Phase 3:
- At least one screen should show an **empty state** (no data yet + CTA)
- At least one screen should show **skeleton loading** (setTimeout 1s before content)
- Auth pages: centered card layout, not the main shell
- Every nav item must route to a real page (no dead links)
- Active nav item visually highlighted
- Breadcrumbs on nested pages

After all screens are written:

1. Write `prototype/README.md`:
   - How to run: `cd prototype && npm install && npm run dev`
   - Design direction: personality, palette, fonts chosen and why
   - Screen inventory with descriptions
   - Core flow walkthroughs

2. Run `npm install` in `prototype/`

3. Run build check: `npx tsc --noEmit` (or `npx vite build`)
   - Fix ALL errors before continuing — type errors, missing imports, broken paths
   - Re-run until zero errors

Update manifest → `phase_complete: 4`.

Print summary:
```
Prototype complete!

Design: {personality} — {heading font} + {body font}, {primary color} palette
Screens: X pages
Components: Y reusable components
Core flows: Z navigable paths

Run: cd prototype && npm install && npm run dev
```

Emit: `[PROTOTYPE_DONE]`

## Layout Variety Reference

**Do NOT always use sidebar layout.** Match layout to the product:

**Dashboard layout** (SaaS, admin, analytics, CRM):
- Collapsible sidebar (240px) with icon + label nav items
- Top header with search, notifications, user avatar
- Main content area with breadcrumbs

**Marketing/Landing layout** (consumer products, marketplaces):
- Sticky top navigation with transparent-to-solid scroll effect
- Hero section with headline + CTA
- Feature sections with alternating image/text
- Footer with links

**App Shell layout** (mobile-first web, social, messaging):
- Bottom tab navigation (mobile) / top nav (desktop)
- Full-width content
- Floating action button

**Editorial layout** (content, blogs, documentation):
- Centered content column (max-w-3xl)
- Large typography with generous line height
- Table of contents sidebar (desktop)

**Split layout** (email, chat, file managers):
- Resizable left panel (list/tree)
- Main content panel (detail view)
- Optional right panel (metadata/properties)

## Output Rules

- **CRITICAL: The prototype must look like a REAL PRODUCT, not a developer exercise.**
- Mock data must feel real — proper names, realistic numbers, plausible dates, domain-appropriate content
- Navigation must work — every button/link goes somewhere meaningful
- Design must be distinctive — if you removed the product name, someone should still be able to tell the domain from the visual design alone
- NEVER use generic gray + blue + white for everything. Commit to the personality's palette.
- NEVER use the same layout for every page. Mix cards, tables, forms, metrics, feeds.
- Include `package.json` with all dependencies so `npm install && npm run dev` works
- Do NOT connect to any real backend — all data is static/mocked
- Do NOT ask questions — generate everything from SDL/intent.json/_state.json
- Do NOT skip screens — every screen in the manifest must be generated
- Each phase must update `_manifest.json` before emitting `[PROTOTYPE_CONTINUE]`
- Do NOT emit `[PROTOTYPE_DONE]` until build verification passes
- Do NOT include the CTA footer
