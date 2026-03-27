---
description: Generate a clickable UI prototype with working navigation, design system styling, and realistic data
---

# /architect:prototype

## Trigger

`/architect:prototype` — run after blueprint and design-system phases (ideally after wireframes).

## Purpose

Generate a fully clickable HTML/React prototype that founders can use to demo their product to investors, test user flows with potential customers, or validate UX before committing to full code generation. The prototype uses the project's design system tokens for real styling, includes working navigation between screens, and shows realistic placeholder data from the data models.

This is NOT a production application — it's a **demo prototype** with static/mock data, no backend, but real visual design and working screen flows.

## Workflow

### Step 1: Gather Inputs

Read:
1. **SDL file** — components, auth, data models, core flows, design section
2. **Design tokens** — from `architecture-output/design-system/design-tokens.json` or SDL `design` section
3. **Data model** — from `architecture-output/data-model.md` for entity structure
4. **Wireframes** — from `architecture-output/wireframes/` if they exist (use as layout guide)
5. **Executive summary** — from `architecture-output/executive-summary.md` for product context

### Step 2: Load Skills

Load:
- **design-system** skill — for token application and component library usage
- **wireframe-patterns** skill — for screen layout structure
- **project-templates** skill — for framework-specific starter code
- **founder-communication** skill — for realistic UI copy

### Step 3: Choose Prototype Technology

Based on the SDL frontend component:

| SDL Framework | Prototype Tech | Build Tool |
|---------------|---------------|------------|
| React / Next.js | React + Vite | vite |
| Vue / Nuxt | Vue + Vite | vite |
| Svelte / SvelteKit | Svelte + Vite | vite |
| Any other / none | Plain HTML + CSS + JS | none |

Default to **React + Vite + Tailwind** if no framework preference in SDL.

### Step 4: Generate Prototype Project

Create a standalone project in `prototype/` at the project root:

#### 4.1 — Project Structure
```
prototype/
├── package.json         # Dependencies + dev script
├── index.html           # Entry point
├── vite.config.ts       # Vite config (if React/Vue/Svelte)
├── tailwind.config.ts   # With design tokens from SDL
├── src/
│   ├── main.tsx         # App entry
│   ├── App.tsx          # Router + layout
│   ├── components/      # Shared UI components
│   │   ├── Layout.tsx   # Nav + sidebar + content area
│   │   ├── Button.tsx   # Styled button
│   │   ├── Card.tsx     # Content card
│   │   └── Input.tsx    # Form input
│   ├── pages/           # One file per screen
│   │   ├── Dashboard.tsx
│   │   ├── Login.tsx
│   │   ├── ItemList.tsx
│   │   ├── ItemDetail.tsx
│   │   └── Settings.tsx
│   ├── data/
│   │   └── mock.ts      # Realistic mock data from data models
│   └── styles/
│       └── globals.css   # Design tokens as CSS variables
└── README.md             # How to run the prototype
```

#### 4.2 — Design System Integration
- Import design tokens from SDL `design` section
- Generate Tailwind config with project colours, fonts, radius, shadows
- Apply layout style (dashboard / marketing / editorial / app-shell / saas)
- Load Google Fonts for heading + body fonts

#### 4.3 — Screen Generation
For each screen (same inventory as wireframes):
- Create a React component (or HTML page)
- Apply the layout shell
- Populate with realistic mock data derived from data model entities
- Include working navigation (React Router links or `<a>` tags)
- Add interactive elements:
  - Buttons that navigate
  - Forms with visible field validation (client-side only)
  - Modals that open/close
  - Tabs that switch content
  - Dropdowns that show options

#### 4.4 — Mock Data Generation
From the SDL data models, generate `mock.ts`:
```typescript
export const users = [
  { id: '1', name: 'Sarah Chen', email: 'sarah@example.com', role: 'admin', avatar: '...' },
  { id: '2', name: 'Marcus Johnson', email: 'marcus@example.com', role: 'member', avatar: '...' },
];

export const orders = [
  { id: 'ORD-001', customer: 'Sarah Chen', total: 127.50, status: 'completed', date: '2026-03-15' },
  // 5-10 realistic entries per entity
];
```

#### 4.5 — Core Flow Walkthrough
For each `product.coreFlow`:
- Ensure the screens in the flow are connected via navigation
- Add a "flow indicator" (optional breadcrumb or step counter)
- Make the happy path fully clickable from start to finish

### Step 5: Verify & Output

1. Run `npm install` in `prototype/`
2. Run `npm run dev` to verify it starts
3. Check that all routes render without errors
4. Write `prototype/README.md` with:
   - How to run: `cd prototype && npm install && npm run dev`
   - Screen inventory with descriptions
   - Core flow walkthroughs (which screens to click through)

### Step 6: Summary

Print summary:
```
Prototype generated in prototype/

Screens: X pages
Core flows: Y navigable paths
Design: {design preset} theme with {palette} palette
Run: cd prototype && npm install && npm run dev

To share: zip the prototype/ directory — it runs standalone.
```

## Output Rules

- Use **design-system** skill for consistent styling from SDL tokens
- Use **wireframe-patterns** skill for screen layout structure
- Use **project-templates** skill for framework-appropriate code patterns
- Use **founder-communication** skill — all UI copy should be realistic, not "lorem ipsum"
- Mock data must feel real — use proper names, realistic numbers, plausible dates
- Navigation must work — every button/link goes somewhere meaningful
- Include `README.md` with run instructions
- Include `package.json` with all dependencies so `npm install && npm run dev` works
- Do NOT connect to any real backend — all data is static/mocked
- Do NOT ask questions — generate everything from SDL
- Do NOT skip screens — generate every screen in the inventory
- After generation, run `npm install` and verify the dev server starts without errors
