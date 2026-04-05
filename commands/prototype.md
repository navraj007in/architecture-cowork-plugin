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

1. **`architecture-output/_state.json`** — read first if it exists. Use directly:
   - `entities` → field names for typed mock data
   - `personas` → names + roles for realistic UI copy and avatar seeds
   - `design` → personality, colors, fonts (skip Step 2 derivation if present)
   - `mvp_scope.must_have` → which screens/features are in scope

2. **`intent.json`** — product name, vision, target users, core features, core flows

3. **SDL — extract only prototype-relevant sections** (do NOT read the full file):
   Check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Use Grep to extract these sections only:
   - `product:` block → `screens`, `screenFlows`, `coreFlows` (screen inventory + navigation)
   - `auth:` block → which auth screens to generate (login, register, MFA, SSO)
   - `architecture.projects:` block → **CRITICAL: determine application type**:
     * `type: "web"` + `framework: "react"/"next"/"vue"/etc` → **Web Prototype** (responsive React)
     * `type: "mobile"` + `framework: "react-native"/"flutter"/"swift"` → **Mobile Prototype** (native-style mobile UI)
     * `type: "desktop"` + `framework: "electron"/"tauri"` → **Desktop Prototype** (desktop-optimized layout)
     * If multiple types (web + mobile): generate **primary type** only (ask user which to prioritize)
   - `design:` block → palette, fonts, personality if not in `_state.json`
   - `domain:` block → entity names for mock data shape — **only if `_state.json.entities` is absent** (e.g. `domain.entities: [User, Order, Product]`)

   **Skip entirely:** infrastructure, deployment, integrations, environment, security policies, cost — none of these affect the prototype UI.

4. **Design tokens** — `architecture-output/design-system/design-tokens.json` if available

5. **Wireframes manifest** — `architecture-output/wireframes/_manifest.json` if it exists; use the `screens` array as the inventory (already mapped from SDL, saves re-derivation)

6. **User personas** — **only if `_state.json.personas` is absent**; Grep `architecture-output/user-personas.md` for name + role lines only

### Step 1.5: Figma Pull (Optional)

If no `design-tokens.json` exists and `_state.json.design` is absent or incomplete, silently attempt a lightweight Figma MCP call (e.g. `get_me`) to check if the server is connected.

**If connected**, offer:

> "Figma is connected. Paste a Figma file URL to pull frame names and design tokens into the prototype, or reply `skip`."

If the user provides a file URL or key, delegate to the **figma-agent** with:
- `mode: "pull"`
- `figmaFileUrl` — the URL or key provided
- `projectDir` — current working directory

Use the returned palette, fonts, and component names as the design source for Step 2 — treat them with the same authority as `design-tokens.json`.

**If connected but the design system already exists** (`design-tokens.json` or `_state.json.design` is fully populated), skip silently — no need to pull again.

**If not connected**, skip silently.

### Step 2: Design Direction

**If `architecture-output/design-system/design-tokens.json` exists:** This is the authoritative design source. Read it now. Record the exact hex values, font names, spacing scale, border-radius, and shadow. The prototype MUST match the design system exactly — same colors, same fonts, same radii. Skip the domain derivation below entirely.

**Else if `_state.json.design` exists:** Use it verbatim — palette (primary, primary_dark, secondary, accent, surface, surface_elevated, text_primary, text_secondary), fonts (heading_font, body_font), border_radius, shadow, icon_library, component_library. Do not re-derive from domain.

**If neither exists (common case):** Derive a distinctive design from the product domain. Do NOT fall back to generic defaults. Instead:

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

Generate a COMPLETE dual palette — **both light and dark variants for every token**. This is what makes the prototype themeable, not just toggle-able.

Define ALL of the following for **both `:root` (light) and `.dark` (dark)**:

| Token | Light value | Dark value |
|---|---|---|
| `--color-primary` | brand color | same or slightly lighter |
| `--color-primary-dark` | hover/active darker | hover/active lighter |
| `--color-secondary` | accent color | accent color (adjust if needed for contrast) |
| `--color-surface` | white or near-white | dark base (e.g. zinc-950) |
| `--color-surface-elevated` | slightly off-white | slightly lighter than surface (e.g. zinc-900) |
| `--color-surface-overlay` | modal/drawer backdrop tint | modal/drawer backdrop tint |
| `--color-border` | subtle gray | subtle dark border |
| `--color-text-primary` | near-black | near-white |
| `--color-text-secondary` | muted gray | muted light gray |
| `--color-text-on-primary` | white or dark (whichever contrasts primary) | same |
| `--color-success` | green variant | green variant (may lighten for dark bg) |
| `--color-warning` | amber variant | amber variant |
| `--color-error` | red variant | red variant |
| `--color-info` | blue variant | blue variant |

**WCAG AA contract rule:** every `--color-text-*` against its paired `--color-surface-*` must meet 4.5:1 contrast in BOTH light and dark modes. Verify mentally — darken text or lighten surface if in doubt.

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

### Step 2.5: Determine Application Type & Layout Strategy

**Based on the component type detected in Step 1.3:**

#### Web Application (React, Next.js, Vue, Angular, Svelte)
- **Layout approach:** Desktop-first or mobile-first responsive design
- **Viewport:** Full browser window (1920×1080 down to 375px mobile)
- **Navigation patterns** (choose based on app type):
  - **Dashboard/Admin Sidebar** — persistent left sidebar (240px, collapsible), top header with breadcrumbs, for SaaS/admin/CRM/analytics
  - **Top Navigation Only** — horizontal nav bar, no sidebar, for marketing/brochure sites
  - **Sidebar + Header** — left sidebar + top bar, combined navigation, for complex dashboards
  - **Marketing/Landing** — minimal nav (logo + menu items + CTA button), hero sections, for consumer products
  - **App Shell** — mobile-first (header + bottom nav on mobile → sidebar on desktop), for cross-platform
  - **Editorial/Docs** — centered max-w-3xl content, side-by-side navigation tree (sticky), for documentation
  - **Split View** — resizable left panel (list/tree) + right content + optional right panel (metadata), for email/chat/file managers
  - **Authentication Flow** — centered card layout (max-w-sm), minimal header, for login/signup/forgot password
  - **Wizard/Stepper** — multi-step form with progress indicator on left or top, for onboarding/checkout
  - **Command Palette** — Cmd+K / Ctrl+K search box, keyboard-first navigation, for productivity apps
  - **Mega Menu** — dropdown with grid layout, for e-commerce with many categories
  - **Breadcrumbs** — hierarchical path navigation, often paired with sidebar or top nav
- **Components:** HTML/CSS via Tailwind, lucide-react icons
- **Styling:** CSS-in-JS (Tailwind utility classes)
- **Technology Stack:** React + Vite + Tailwind + React Router

#### Mobile Application (React Native, Flutter, Swift, Kotlin)
- **Layout approach:** Mobile-FIRST, optimized for phone screens
- **Viewport:** Fixed phone size (375×812 for iPhone 13, 360×800 for Android)
- **Navigation patterns** (choose one based on architecture intent):
  - **Bottom Tab Bar** (iOS/Material) — 3-5 main sections, always visible, tap to switch
  - **Drawer Navigation** — hamburger icon → side drawer slides in, good for many sections
  - **Tab Bar + Drawer** — fixed bottom tabs (main) + drawer for settings/secondary
  - **Stack Navigation** — push/pop screens (linear flows like onboarding, detail views)
  - **Top Tab Bar** — horizontal tabs below header (less common, for tab-within-tab)
  - **Segmented Control** — iOS-style for 2-4 options (not for main navigation)
- **Components:** Native mobile UI components (not HTML)
  - Use **`expo`** for React Native prototype (fastest)
  - Or **`react-native-web`** to render RN components in browser for demo
  - Use **`expo-router`** for file-based routing (similar to Next.js)
- **Touch targets:** All buttons/taps minimum 44×44px (iOS HIG requirement)
- **Safe areas:** Account for notch, home indicator, rounded corners
- **Styling:** StyleSheet.create() instead of CSS classes
- **Technology Stack:** React Native + Expo + Expo Router + chosen navigation pattern

**Mobile Navigation Selection Logic:**

| App Structure | Recommended Pattern | When to Use | Components |
|---|---|---|---|
| **3-5 main sections** | Bottom Tab Bar | Social, e-commerce, messaging | expo-router (tabs layout) |
| **5-8+ sections** | Drawer Navigation | Content apps, utilities, admin | @react-navigation/drawer |
| **Many sections + core tasks** | Tab Bar + Drawer | Dashboard apps, feature-rich | tabs layout + drawer |
| **Linear flow** | Stack Navigation | Onboarding, checkout, forms | expo-router (stack layout) |
| **Feature comparison** | Top Tab Bar | Filtering, sorting options | expo-router (top-tabs) |
| **2-4 view toggle** | Segmented Control | List/grid toggle, filters | Native segmented control |

**For mobile prototypes, explicitly state:**
```
App Type: Mobile (React Native)
Viewport: iPhone 13 (375×812)
Navigation Pattern: [Bottom Tabs | Drawer | Stack | Hybrid]
Rationale: [based on section count and app structure]
Safe Areas: Notch + Home Indicator
Components: React Native native components
```

**Ask the user if navigation pattern is ambiguous:**
```
"I see 7 main sections. Would you prefer:
1. Bottom Drawer Navigation (hamburger menu)
2. Bottom Tab Bar + Drawer (tabs for core, drawer for secondary)
3. Stack Navigation (push/pop between screens)
"
```

#### Desktop Application (Electron, Tauri, PWA)
- **Layout approach:** Desktop-optimized, window-aware, support for multiple documents
- **Viewport:** Resizable windows (1024×768 minimum, up to 3840×2160 for high-DPI)
- **Navigation patterns** (choose based on app type):
  - **Sidebar + Top Bar** — persistent left sidebar + menu bar + toolbar, for most desktop apps (IDE, email clients)
  - **Menu Bar + Toolbar** — macOS/Windows menu bar + toolbar with icon buttons, for productivity apps
  - **Ribbon UI** — Microsoft Office-style ribbon with grouped commands + tabs, for feature-rich complex apps
  - **Floating/MDI Windows** — Multiple Document Interface with tabbed or floating windows, for creative tools (design, video editors)
  - **Tab Bar** — horizontal tabs for switching between documents/views, for text editors, IDEs
  - **Status Bar** — bottom info bar showing state, file info, view mode, cursor position, for editors
  - **Context Menus** — right-click menus for all major elements, ESSENTIAL for desktop
  - **Keyboard Shortcuts** — Cmd+S, Cmd+N, Ctrl+C, etc., heavily used, must document in Help menu
  - **Toolbar Only** — minimal UI with just toolbar icons + main canvas (for full-screen focused tools)
  - **Sidebar + Tabbed Documents** — sidebar navigation + central tabbed editor area, for IDEs, note apps
- **Components:** Custom desktop UI components (larger text: 14-16px, bigger buttons, generous padding)
- **Styling:** CSS with desktop-appropriate spacing and typography
- **Interactions:** Window resizing, minimize/maximize/close, drag-drop files, system tray (Windows), dock (macOS), keyboard-first
- **Technology Stack:** Electron/Tauri + React + Tailwind + Window management APIs

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

**Before writing any files — resolve the design source (in priority order):**

1. **`architecture-output/design-system/design-tokens.json` exists** → Read it in full. Use its exact values for every color, font, spacing, border-radius, and shadow in `tailwind.config.ts` and `globals.css`. Do not invent or adjust any value.
2. **`_state.json.design` exists but no tokens file** → Use its palette (primary, secondary, accent, surface, text colors, border_radius, shadow) and font names verbatim. Check `_state.json.design.tokens_file` — if it points to a file, read that file.
3. **Neither exists** → Derive from domain as described in Step 2.

Generate these files (config + router + mock data only — no page content yet):

```
prototype/
├── package.json          ← all deps: react, react-dom, react-router-dom, vite, tailwindcss, lucide-react, i18next, react-i18next
├── index.html
├── vite.config.ts
├── tailwind.config.ts    ← exact values from design-tokens.json or _state.json.design — not re-derived; darkMode: 'class'
├── src/
│   ├── main.tsx
│   ├── App.tsx           ← router with <Route> for every screen; wraps in ThemeProvider + I18nextProvider
│   ├── context/
│   │   └── ThemeContext.tsx   ← useTheme() hook — persists to localStorage, defaults to system preference
│   ├── i18n/
│   │   ├── index.ts           ← i18next init (react-i18next)
│   │   └── locales/
│   │       ├── en.json        ← all UI strings in English
│   │       └── es.json        ← all UI strings in Spanish (auto-translated placeholder values)
│   ├── data/
│   │   └── mock.ts       ← realistic typed mock data, 10-20 records per entity
│   └── styles/
│       └── globals.css   ← Google Fonts @import; CSS variables for light AND dark palettes
```

**Dark/light mode — full themeable setup (REQUIRED):**

`globals.css` must define ALL palette tokens as CSS variables for both modes:
```css
@import url('https://fonts.googleapis.com/css2?family=...');

:root {
  --color-primary: #...;
  --color-primary-dark: #...;
  --color-secondary: #...;
  --color-surface: #ffffff;
  --color-surface-elevated: #f8fafc;
  --color-surface-overlay: rgba(0,0,0,0.4);
  --color-border: #e2e8f0;
  --color-text-primary: #0f172a;
  --color-text-secondary: #64748b;
  --color-text-on-primary: #ffffff;
  --color-success: #16a34a;
  --color-warning: #d97706;
  --color-error: #dc2626;
  --color-info: #2563eb;
}

.dark {
  --color-primary: #...;        /* same or adjusted for dark bg */
  --color-primary-dark: #...;
  --color-secondary: #...;
  --color-surface: #09090b;
  --color-surface-elevated: #18181b;
  --color-surface-overlay: rgba(0,0,0,0.6);
  --color-border: #27272a;
  --color-text-primary: #fafafa;
  --color-text-secondary: #a1a1aa;
  --color-text-on-primary: #ffffff;
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #f87171;
  --color-info: #60a5fa;
}
```

`tailwind.config.ts` must wire every CSS variable into Tailwind's theme so utility classes work:
```ts
theme: {
  extend: {
    colors: {
      primary: 'var(--color-primary)',
      'primary-dark': 'var(--color-primary-dark)',
      secondary: 'var(--color-secondary)',
      surface: 'var(--color-surface)',
      'surface-elevated': 'var(--color-surface-elevated)',
      border: 'var(--color-border)',
      'text-primary': 'var(--color-text-primary)',
      'text-secondary': 'var(--color-text-secondary)',
      'text-on-primary': 'var(--color-text-on-primary)',
      success: 'var(--color-success)',
      warning: 'var(--color-warning)',
      error: 'var(--color-error)',
      info: 'var(--color-info)',
    },
    fontFamily: { heading: [...], body: [...] },
  },
  darkMode: 'class',
}
```

`ThemeContext.tsx`: reads `localStorage.getItem('theme')` on init; if absent, **defaults to `'light'`** (do NOT fall back to system preference — light is always the default); toggles `dark` class on `<html>`; exposes `theme` and `toggleTheme()`.

**Every component in the prototype MUST use only these Tailwind classes for color** — `bg-surface`, `bg-surface-elevated`, `text-text-primary`, `text-text-secondary`, `text-primary`, `bg-primary`, `border-border`, `text-on-primary`, etc. **Zero hardcoded hex values or Tailwind color utilities like `bg-zinc-900`, `text-gray-800`, `bg-white` anywhere in component files.** When the theme toggles, every surface, text, and border switches automatically because everything resolves through CSS variables.

Header component (Phase 2) must include a theme toggle button (sun/moon icon from lucide-react).

**Internationalisation & RTL requirements:**
- `i18next` + `react-i18next` — initialised in `src/i18n/index.ts` with `en` as default, `es` as second locale, `ar` as third
- All user-facing strings use `useTranslation()` hook: `const { t } = useTranslation(); ... t('nav.dashboard')`
- `en.json`, `es.json`, and `ar.json` must cover: nav labels, page titles, table headers, button labels, form labels, empty states, error messages
- Header component (Phase 2) must include a language switcher dropdown (EN / ES / AR)
- **RTL support:** When language changes, update `document.documentElement.dir` (`'rtl'` for `ar`, `'ltr'` otherwise) and `document.documentElement.lang`. Store this in the i18n init `languageChanged` callback. Tailwind's `rtl:` modifier is available — use it for layout-sensitive classes (e.g. `rtl:flex-row-reverse`, `rtl:text-right`)

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

**Mobile responsiveness — REQUIRED on all layouts:**
- Sidebar: hidden on mobile (`hidden md:flex`), replaced by `MobileNav` hamburger + slide-in drawer
- Header: collapses search bar to icon on mobile, stacks avatar/actions
- Tables: on mobile, use card-per-row layout (`hidden md:table` for `<table>`, `block md:hidden` card fallback) — never let tables overflow the viewport
- Grids: use responsive columns (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`) — never fixed multi-column grids without breakpoints
- Forms: full-width inputs on mobile (`w-full`), stack label + input vertically
- Modals: full-screen on mobile (`w-full h-full sm:w-auto sm:h-auto sm:max-w-lg sm:rounded-xl`)
- Touch targets: all buttons and links min 44×44px on mobile (`min-h-[44px] min-w-[44px]`)
- Typography: scale down headings on mobile (`text-2xl md:text-4xl`)
- Bottom tab bar for mobile-first layouts: `fixed bottom-0 inset-x-0 flex md:hidden`

Every component must have:
- Hover and active states
- Proper TypeScript props interface
- Uses the chosen palette via Tailwind classes (not hardcoded hex values)
- **Accessibility:** Semantic HTML elements (`<nav>`, `<main>`, `<aside>`, `<section>`, `<button>`, `<header>`). All interactive elements have visible focus rings (`focus-visible:ring-2`). `aria-label` or `aria-labelledby` on icon-only buttons. Tables use `<thead>`, `<th scope="col">`. Form inputs paired with `<label htmlFor>`. Modals trap focus and close on Escape. WCAG AA contrast (4.5:1 for text).

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

### Final Step (Pre-log): Update _state.json

After writing all prototype files, merge prototype metadata into `architecture-output/_state.json`:

1. Read existing `architecture-output/_state.json` (or start with `{}`)
2. Merge only the `prototype` key — do NOT overwrite other fields:
```json
{
  "prototype": {
    "screens": <number of screens generated>,
    "personality": "<personality used>",
    "component_library": "<component library used>",
    "complete": true
  }
}
```
3. Write back to `architecture-output/_state.json`

### Final Step: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"prototype","outcome":"completed","files":["src/App.tsx","src/pages/"],"summary":"Prototype generated: <N> screens, <personality> design, <component-library> components."}
```

List all generated React files in the `files` array.

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

### Application Type-Specific Generation

**WEB APPLICATION (React, Next.js, Vue, Angular, Svelte):**
- Technology: React + Vite + Tailwind + React Router
- Viewport: Responsive (375px mobile → 1920px desktop)
- Navigation: Header + Sidebar (desktop) / Header + Hamburger (mobile)
- Package structure: standard React SPA
- Output: `prototype/` directory with working `npm run dev`

**MOBILE APPLICATION (React Native, Flutter, Swift, Kotlin):**
- Technology: React Native + Expo (or Tauri for web-based mobile)
- Viewport: FIXED phone size (375×812 iPhone, 360×800 Android) — never stretches
- Navigation: Bottom Tab Bar (iOS) or Bottom Navigation (Material Design)
- Design system: Native mobile components, NOT HTML
  - No sidebar (not mobile-idiomatic)
  - No desktop layout variants (mobile-first and locked)
  - Icons from lucide-react or expo icons
  - Spacing scaled for touch (all taps 44×44px minimum)
- Safe areas: Notch awareness, home indicator, rounded corners
- Package structure: Expo project with `expo-router`
- Output: `prototype-mobile/` directory with `eas.json` for preview

**DESKTOP APPLICATION (Electron, Tauri):**
- Technology: Electron/Tauri + React + Tailwind
- Viewport: Large fixed window (1024×768 minimum, resizable)
- Navigation: Menu bar (macOS) or Window menu (Windows), sidebar optional, full-size
- UI patterns: Desktop-specific (drag-drop, resizable panes, context menus, keyboard shortcuts)
- Typography and spacing: Larger than web (comfortable for desktop viewing distance)
- Package structure: Electron or Tauri project with window management
- Output: `prototype-desktop/` directory with Electron/Tauri build files

**Decision Logic:**
1. Read `architecture.projects[]` and filter by `type: "web" | "mobile" | "desktop"`
2. If multiple types exist (e.g. web + mobile): Ask user which to generate first
   ```
   "Found multiple app types (web, mobile). Which should I prototype first?
   1. Web (React)
   2. Mobile (React Native)
   "
   ```
3. Generate only the primary type in this run
4. Mobile/desktop can be generated in follow-up runs

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
- **ALWAYS implement mobile responsiveness** — sidebar hidden on mobile with hamburger drawer, tables degrade to cards, all grids use responsive breakpoints, touch targets min 44px, modals full-screen on mobile
- **ALWAYS implement dark/light mode** — `darkMode: 'class'` in Tailwind, CSS variable palette, `ThemeContext` with **light as the default theme**, toggle in Header. The prototype opens in light mode unless the user has previously toggled to dark.
- **ALWAYS implement i18n** — `i18next` + `react-i18next`, `en.json` + `es.json` + `ar.json` locale files, all strings via `t()`, RTL direction set on `<html>` for Arabic
- **ALWAYS implement accessibility** — semantic HTML, visible focus rings, ARIA labels on icon-only elements, WCAG AA contrast, keyboard navigation, modal focus trap
