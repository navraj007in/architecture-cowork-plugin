---
description: Generate a clickable UI prototype with distinctive visual design, working navigation, and realistic data
---

# /architect:prototype

## Trigger

`/architect:prototype` — run after intent.json is created. Works best after blueprint and design-system phases but not required.

## Purpose

Generate a fully clickable React prototype that founders can demo to investors, test with users, or validate UX. The prototype must look like a **real product** — not a developer's wireframe. Distinctive visual design, realistic data, working navigation, and interactive elements.

This is NOT a production application — it's a **demo prototype** with static/mock data, no backend, but polished visual design and working screen flows.

## Workflow

### Step 1: Gather Inputs

Read (use what's available, don't error if missing):
1. **intent.json** — product name, vision, target users, core features, core flows
2. **SDL file** (`solution.sdl.yaml`) — components, auth, data models, design section, `product.screens`, `product.screenFlows`
3. **Design tokens** — from `architecture-output/design-system/design-tokens.json` if available
4. **Data model** — from `architecture-output/data-model.md` for entity structure
5. **Wireframes** — from `architecture-output/wireframes/` if they exist (use as layout guide)
6. **User personas** — from `architecture-output/user-personas.md` for realistic UI copy

### Step 2: Design Direction

**If design tokens exist:** Use them for palette, fonts, spacing, shadows, border radius.

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

### Step 3: Generate Prototype Project

Create a standalone project in `prototype/` at the project root.

#### 3.1 — Project Structure
```
prototype/
├── package.json
├── index.html
├── vite.config.ts
├── tailwind.config.ts
├── src/
│   ├── main.tsx
│   ├── App.tsx
│   ├── components/
│   │   ├── layout/          # Navigation shells
│   │   ├── ui/              # Reusable primitives
│   │   └── {feature}/       # Feature-specific components
│   ├── pages/               # One per screen
│   ├── data/
│   │   └── mock.ts
│   └── styles/
│       └── globals.css
└── README.md
```

#### 3.2 — Layout Variety (pick based on product type)

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

#### 3.3 — Component Library (build 12-15 components, not just 4)

Create components that match the personality. **Each must have visual polish — not just functional HTML.**

**Required base components:**
- `Button` — primary, secondary, outline, ghost, danger variants. Hover/active states. Loading spinner variant.
- `Card` — with header, body, footer slots. Hover elevation effect.
- `Input` — with label, helper text, error state, icon prefix/suffix.
- `Badge` / `StatusBadge` — color-coded status indicators (success/warning/error/info/neutral).
- `Avatar` — with fallback initials, status dot, size variants.
- `Table` — sortable headers, row hover, pagination footer, empty state.
- `Modal` — with overlay, close button, slide-in animation.
- `Dropdown` / `Select` — with search, multi-select variant.
- `Tabs` — horizontal tabs with active indicator.
- `Toast` / `Notification` — success/error/info variants with auto-dismiss.
- `Skeleton` — loading placeholder matching each component shape.
- `EmptyState` — illustration + message + CTA for empty lists/tables.

**Personality-specific components (pick 3-5 based on product):**
- `MetricCard` — for dashboards: number, trend arrow, sparkline
- `ActivityFeed` — for social/SaaS: avatar + action + timestamp
- `PricingCard` — for marketing: tier name, price, features, CTA
- `SearchBar` — for content/marketplace: with filters, suggestions
- `KanbanColumn` — for project management: draggable card placeholders
- `ChatBubble` — for messaging/AI: left/right alignment, typing indicator
- `CalendarView` — for booking/scheduling: month grid with event dots
- `FileCard` — for file management: icon, name, size, actions
- `ProgressBar` / `StepIndicator` — for onboarding/wizards
- `Chart` — simple bar/line/donut chart using pure CSS or a lightweight lib (recharts)

#### 3.4 — Page Design Quality Standards

**Every page MUST meet these standards:**

1. **Visual hierarchy** — clear distinction between headings, subheadings, body text, and metadata. Use font size, weight, AND color to create 3-4 distinct levels.

2. **Density appropriate to personality** — compact for dashboards, spacious for editorial. Don't use the same padding everywhere.

3. **Real content, not lorem ipsum** — page titles, descriptions, button labels, table headers, form labels must all be product-specific. Use persona names from user-personas.md for user data.

4. **Interactive states** — buttons have hover/active effects, table rows highlight on hover, cards elevate on hover, inputs have focus rings matching the primary color.

5. **Empty states** — at least one page should show an empty state (no data yet) with an illustration or icon, message, and CTA.

6. **Loading states** — at least one page should show skeleton loading for 1 second before revealing content (simulated with setTimeout).

7. **Responsive** — sidebar collapses to hamburger on mobile, tables scroll horizontally, cards stack vertically. Test at 375px and 1440px.

8. **Micro-interactions** — page transitions (fade or slide), button hover scales, dropdown animations, modal backdrop fade. Use CSS transitions, not heavy animation libraries.

9. **Data visualization** — if the product involves metrics/analytics, include at least one chart (CSS-only bar chart, or recharts if in deps). Don't show numbers without visual context.

10. **Consistent spacing system** — use a 4px grid: 4, 8, 12, 16, 24, 32, 48, 64. Don't mix arbitrary px values.

#### 3.5 — Screen Generation

**Priority: If `product.screens` exists in SDL, use it as the screen inventory.** Use `product.screenFlows` for navigation routes. Otherwise infer from intent.json `core_features` and `core_flows`.

Generate ALL screens — do NOT skip any. Each screen should feel different (different component compositions, layouts within the shell, data types displayed).

For variety across pages:
- **Dashboard/Home** — metric cards + recent activity + quick actions
- **List pages** — table view with filters, search, bulk actions. Include pagination.
- **Detail pages** — header with title + actions, tabbed content sections, related items sidebar
- **Form pages** — multi-section forms with validation, conditional fields, submit + cancel
- **Settings pages** — left nav with sections, toggle switches, save/reset buttons
- **Auth pages** — centered card, social login buttons, branded background
- **Profile pages** — avatar + info header, tabbed content (activity, settings, billing)
- **Empty/Onboarding** — welcome screen, setup wizard with steps

#### 3.6 — Mock Data Generation

Generate `data/mock.ts` with **realistic, typed, domain-specific data**:
- Use proper names from different cultures (not just English names)
- Use realistic numbers (prices, dates, quantities appropriate to the domain)
- Include edge cases (long names, zero values, pending statuses)
- 10-20 records per entity — enough to fill a table and show pagination
- Include relationships between entities (order references a customer, etc.)
- Add avatar URLs using `https://api.dicebear.com/9.x/avataaars/svg?seed={name}`

#### 3.7 — Navigation & Flow

- Every nav item must route to a real page (no dead links)
- Core flows must be walkable start-to-finish
- Add breadcrumbs on nested pages
- Active nav item must be visually highlighted
- Include a notification bell with a count badge (static)
- Include a user menu dropdown (avatar → dropdown with profile, settings, logout)

### Step 4: Verify & Output

1. Run `npm install` in `prototype/`
2. Run build check (`npx tsc --noEmit` or `npx vite build`)
3. Fix any errors — don't ship a broken prototype
4. Write `prototype/README.md` with:
   - How to run: `cd prototype && npm install && npm run dev`
   - Design direction: personality, palette, fonts chosen and why
   - Screen inventory with descriptions
   - Core flow walkthroughs

### Step 5: Summary

```
Prototype generated in prototype/

Design: {personality} — {heading font} + {body font}, {primary color} palette
Screens: X pages
Components: Y reusable components
Core flows: Z navigable paths

Run: cd prototype && npm install && npm run dev
```

## Output Rules

- **CRITICAL: The prototype must look like a REAL PRODUCT, not a developer exercise.** If you'd be embarrassed to show it to an investor, it's not good enough.
- Mock data must feel real — proper names, realistic numbers, plausible dates, domain-appropriate content
- Navigation must work — every button/link goes somewhere meaningful
- Design must be distinctive — if you removed the product name, someone should still be able to tell what domain it's for based on the visual design alone
- NEVER use generic gray + blue + white for everything. Commit to the personality's palette.
- NEVER use the same layout for every page. Mix cards, tables, forms, metrics, feeds, and visual elements.
- Include `package.json` with all dependencies so `npm install && npm run dev` works
- Do NOT connect to any real backend — all data is static/mocked
- Do NOT ask questions — generate everything from SDL/intent.json
- Do NOT skip screens — generate every screen in the inventory
- After generation, verify the dev server starts without errors
- Do NOT include the CTA footer
