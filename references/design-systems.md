# Design System Reference for Scaffold Generation

When scaffolding frontend components, apply the design section from SDL strictly. This reference provides implementation patterns for each preset and personality to ensure diverse, intentional UI output.

**CRITICAL:** Never default to indigo/purple Tailwind palette. When no design section exists in SDL, select colors appropriate to the project domain (see Domain-Based Defaults below).

---

## Design Presets

### shadcn (shadcn/ui)
- **Install:** `npx shadcn-ui@latest init`, add components with `npx shadcn-ui@latest add`
- **Styling:** CSS variables in `globals.css`, Tailwind `hsl()` color tokens
- **Config:** `components.json` at project root, `cn()` utility from `@/lib/utils`
- **Key patterns:** Compound components, Radix primitives underneath, class-variance-authority for variants
- **Default look:** Clean, minimal borders, subtle shadows, medium radius

### material (Material UI / Material Design 3)
- **Install:** `@mui/material @emotion/react @emotion/styled`
- **Styling:** Theme provider with `createTheme()`, `sx` prop
- **Key patterns:** Elevation system (0-24), ripple effects, 8px grid, type scale with rem
- **Default look:** Rounded corners (md), subtle elevation, dense information hierarchy

### ant (Ant Design)
- **Install:** `antd`, optional `@ant-design/pro-components` for dashboards
- **Styling:** CSS-in-JS via `ConfigProvider` theme, design tokens API
- **Key patterns:** Form-heavy layouts, data tables, breadcrumbs, enterprise density
- **Default look:** Corporate, compact density, visible borders, flat shadows

### chakra (Chakra UI)
- **Install:** `@chakra-ui/react @emotion/react @emotion/styled framer-motion`
- **Styling:** Theme object with `extendTheme()`, style props
- **Key patterns:** Composable components, responsive array syntax, color mode built-in
- **Default look:** Friendly, medium radius, balanced spacing

### daisyui
- **Install:** `daisyui` as Tailwind plugin
- **Styling:** Tailwind utility classes with `data-theme` attribute, semantic color names
- **Key patterns:** `btn`, `card`, `hero`, `drawer` component classes, 30+ built-in themes
- **Default look:** Depends on theme — provides immediate variety

### bootstrap
- **Install:** `react-bootstrap` + `bootstrap` or `reactstrap`
- **Styling:** SCSS variables, utility classes
- **Key patterns:** Grid system, card deck, form groups, navbars
- **Default look:** Familiar, rounded, visible borders, medium shadows

### mantine
- **Install:** `@mantine/core @mantine/hooks @mantine/form`
- **Styling:** CSS Modules + `createTheme()`, built-in dark mode
- **Key patterns:** Rich form components, date pickers, charts, notifications out of the box
- **Default look:** Modern, rounded (md), vibrant accents, full-featured
- **Best for:** SaaS dashboards, admin panels, data-heavy apps

### radix (bare)
- **Install:** `@radix-ui/react-dialog @radix-ui/react-select` etc. per component
- **Styling:** Unstyled — bring Tailwind, CSS Modules, or any system
- **Key patterns:** Headless primitives, full a11y built-in, composition over configuration
- **Default look:** None — purely structural. Pair with Tailwind for full control.
- **Best for:** Design systems that need maximum visual customisation

### headless-ui
- **Install:** `@headlessui/react`
- **Styling:** Fully unstyled — Tailwind utilities
- **Key patterns:** Transition, Dialog, Listbox, Combobox, Menu, Popover — accessible by default
- **Default look:** None — Tailwind-driven
- **Best for:** Tailwind-first projects wanting a11y without UI opinions

### Vue — Vuetify
- **Install:** `vuetify` + `vite-plugin-vuetify`
- **Styling:** Material Design 3 theme system, `v-theme-provider`
- **Key patterns:** Data tables, virtual scrolling, form validation built-in
- **Default look:** Material Design, rounded, elevation system
- **Best for:** Vue enterprise apps, dashboards, data-heavy tools

### Vue — Naive UI
- **Install:** `naive-ui`
- **Styling:** Theme editor, `n-config-provider`, dark mode built-in
- **Key patterns:** 80+ components, tree-shaking, TypeScript-first
- **Default look:** Clean, modern, consistent — close to Ant Design aesthetic
- **Best for:** Vue SaaS apps needing a complete component library

### Svelte — shadcn-svelte
- **Install:** `npx shadcn-svelte@latest init`
- **Styling:** Tailwind CSS variables, same token structure as shadcn/ui
- **Key patterns:** Same component API as shadcn/ui — familiar for React devs migrating
- **Default look:** Clean, neutral, high adaptability
- **Best for:** Svelte projects wanting the shadcn design language

### Svelte — Skeleton UI
- **Install:** `@skeletonlabs/skeleton`
- **Styling:** Tailwind plugin, design token system
- **Key patterns:** Theming system, AppShell component, drawer/modal
- **Default look:** Modern, full-featured, dark mode first
- **Best for:** SvelteKit apps needing an opinionated full system

### Angular — Angular Material
- **Install:** `ng add @angular/material`
- **Styling:** Material Design 3, `MatTheme`, CSS custom properties
- **Key patterns:** CDK for a11y, form fields, data table, tree, virtual scroll
- **Default look:** Material Design 3 — adaptive density, rounded
- **Best for:** Enterprise Angular apps, Google-adjacent products

---

## Personality Guide

The `personality` field shapes layout decisions, whitespace, and visual treatment:

| Personality | Radius | Density | Shadows | Borders | Whitespace | Typography | Animation |
|-------------|--------|---------|---------|---------|------------|------------|-----------|
| **minimal** | sm | default | flat | subtle | generous | light weights, small sizes | none/snappy |
| **corporate** | md | compact | subtle | visible | moderate | system fonts, structured | snappy |
| **playful** | lg-full | relaxed | elevated | none | generous | rounded fonts, large headings | expressive |
| **bold** | none-sm | default | dramatic | bold | tight | heavy weights, oversized titles | snappy |
| **brutalist** | none | compact | none | bold | minimal | mono/sans, raw | none |
| **editorial** | none-sm | relaxed | flat | subtle | very generous | serif headings, fine body | smooth |
| **luxury** | sm | relaxed | subtle | none | very generous | thin weights, tracking-wide | smooth |
| **organic** | xl-full | relaxed | warm/soft | none | very generous | serif or soft humanist, medium | slow/smooth |
| **retro** | none-sm | compact | hard offset | visible/double | moderate | slab serif, condensed, mono | none |
| **expressive** | mixed | dense | dramatic or coloured | bold/coloured | tight with explosive openings | heavy + clashing scale | expressive/layered |
| **cinematic** | none | spacious | none or glow | none | asymmetric | wide tracking, thin-to-bold | slow fade |

### Personality → Tailwind Mapping Examples

**minimal:**
```
bg-white text-gray-900, font-light, tracking-tight
Cards: border border-gray-100, rounded-sm, shadow-none
Buttons: bg-gray-900 text-white rounded-sm px-4 py-2 text-sm
Spacing: space-y-8, p-8
```

**bold:**
```
bg-black text-white, font-black, text-4xl+
Cards: bg-zinc-900 border-2 border-white, rounded-none
Buttons: bg-yellow-400 text-black font-bold uppercase tracking-wider
Spacing: space-y-4, p-6
```

**brutalist:**
```
bg-white text-black, font-mono, raw borders
Cards: border-2 border-black, no-radius, no-shadow
Buttons: border-2 border-black bg-transparent hover:bg-black hover:text-white uppercase
Spacing: space-y-2, p-4
```

**editorial:**
```
bg-stone-50 text-stone-900, serif headings (Playfair/Lora), sans body
Cards: no border, max-w-2xl mx-auto, leading-relaxed
Buttons: underline text-stone-700 hover:text-black, no bg
Spacing: space-y-12, py-16, narrow content column
```

**luxury:**
```
bg-neutral-950 text-neutral-100, thin font weights, tracking-[0.2em]
Cards: bg-neutral-900/50 backdrop-blur border border-neutral-800
Buttons: border border-neutral-600 text-xs tracking-widest uppercase
Spacing: space-y-10, p-10, generous margins
```

---

## Domain-Based Defaults

When NO `design` section is present in SDL, infer an appropriate palette from the project domain. NEVER use indigo/purple as the default.

| Domain | Suggested Primary | Neutral | Personality |
|--------|------------------|---------|-------------|
| **Fintech / Banking** | emerald-600 or teal-600 | slate | corporate |
| **Healthcare** | sky-600 or cyan-600 | gray | minimal |
| **E-commerce** | orange-600 or rose-600 | zinc | playful |
| **Education** | blue-600 or cyan-500 | slate | minimal |
| **Social / Community** | pink-500 or fuchsia-500 | neutral | playful |
| **Developer tools** | green-500 or lime-500 | zinc | minimal or brutalist |
| **Enterprise SaaS** | blue-700 or slate-700 | gray | corporate |
| **Creative / Media** | violet-500 or fuchsia-600 | stone | editorial |
| **Real estate** | amber-700 or emerald-700 | stone | luxury |
| **Food / Restaurant** | red-600 or orange-500 | warm-gray | bold |
| **Fitness / Health** | lime-500 or cyan-500 | zinc | bold |
| **Travel** | sky-500 or teal-500 | slate | editorial |
| **AI / ML products** | cyan-500 or emerald-500 | zinc | minimal |
| **Government / Legal** | blue-800 or slate-700 | gray | corporate |
| **Gaming** | purple-600 or red-500 | zinc | bold |
| **Logistics / Supply chain** | amber-600 or orange-600 | slate | corporate |
| **HR / People ops** | teal-500 or sky-500 | gray | minimal |
| **CRM / Sales tools** | blue-600 or sky-600 | slate | corporate |
| **Analytics / BI** | violet-600 or blue-700 | zinc | corporate |
| **Security / Cybersecurity** | red-700 or slate-700 | zinc | minimal or brutalist |

If the domain doesn't match any of the above, randomly select from: teal, emerald, sky, rose, amber, cyan — NOT indigo.

### Sub-Domain Differentiation

Same top-level domain can produce very different design systems depending on the audience and product type. Always check these before applying the default.

**E-commerce sub-domains:**

| Sub-domain | Primary | Personality | Notes |
|------------|---------|-------------|-------|
| B2C Marketplace (multi-vendor, discovery) | orange-500 or teal-500 | playful | Card-heavy, search-forward, high image density |
| D2C Brand (single brand, premium) | monochrome or amber-700 | bold or luxury | Editorial layout, product photography focus |
| B2B Procurement (purchasing, approval flows) | blue-700 or slate-600 | corporate | Dense tables, workflow-heavy, approval states |
| Flash sale / deals | red-600 | bold | Countdown timers, urgency design, high contrast |

**Healthcare sub-domains:**

| Sub-domain | Primary | Personality | Notes |
|------------|---------|-------------|-------|
| Patient-facing consumer app | sky-500 or teal-500 | minimal | Friendly rounded forms, high readability, WCAG AA+ |
| Clinical / EHR tools | slate-700 or blue-800 | corporate | Dense data, compact, information hierarchy critical |
| Provider / admin portal | slate-600 | corporate | Workflow-heavy, role-based views |
| Mental health / wellness | emerald-400 or rose-300 | minimal or luxury | Calm, soft palette, never clinical |

**SaaS sub-domains:**

| Sub-domain | Primary | Personality | Dark default? |
|------------|---------|-------------|--------------|
| Developer-first (APIs, infra) | green-500 or zinc-400 | minimal or brutalist | Yes — dark by default |
| SMB productivity | sky-600 or blue-500 | minimal | No |
| Enterprise (IT, ops, finance) | blue-700 or slate-700 | corporate | No |
| AI-powered tools | cyan-500 or violet-500 | minimal | Optional |
| No-code / low-code | fuchsia-500 or orange-500 | playful | No |

**Education sub-domains:**

| Sub-domain | Primary | Personality |
|------------|---------|-------------|
| K-12 / children | blue-400 or yellow-400 | playful — rounded, friendly |
| Higher education / university | blue-800 or slate-700 | corporate or editorial |
| Professional / corporate training | teal-600 | corporate |
| Online course marketplace | orange-500 | bold or playful |

---

## Tailwind Config Injection

When `palette` is specified in SDL, generate a `tailwind.config.ts` that maps SDL colors to the Tailwind theme:

```typescript
// Example for palette: { primary: "teal-700", secondary: "amber-500", neutral: "slate" }
import type { Config } from 'tailwindcss'
import colors from 'tailwindcss/colors'

export default {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: colors.teal,
        secondary: colors.amber,
        accent: colors.pink, // from palette.accent
      },
    },
  },
} satisfies Config
```

When custom hex values are used instead of Tailwind names, generate a full shade scale:

```typescript
colors: {
  primary: {
    50: '#f0fdfa',
    100: '#ccfbf1',
    // ... generate shades from the base hex
    600: '#0d9488',
    700: '#0f766e', // the declared primary
    800: '#115e59',
    900: '#134e4a',
    950: '#042f2e',
  },
}
```

---

## Typography Setup

When `design.tokens.typography.headingFont` or `design.tokens.typography.bodyFont` specifies a Google Font (or when `_state.json.design.heading_font` / `body_font` is set):

```typescript
// app/layout.tsx (Next.js) or equivalent
import { DM_Sans, Inter } from 'next/font/google'

const heading = DM_Sans({ subsets: ['latin'], variable: '--font-heading' })
const body = Inter({ subsets: ['latin'], variable: '--font-body' })

// tailwind.config.ts
theme: {
  extend: {
    fontFamily: {
      heading: ['var(--font-heading)', 'sans-serif'],
      body: ['var(--font-body)', 'sans-serif'],
    },
  },
}
```

---

## Icon Library Setup

| Library | Install | Import Pattern |
|---------|---------|----------------|
| lucide | `lucide-react` | `import { Home, Settings } from 'lucide-react'` |
| heroicons | `@heroicons/react` | `import { HomeIcon } from '@heroicons/react/24/outline'` |
| phosphor | `@phosphor-icons/react` | `import { House } from '@phosphor-icons/react'` |
| tabler | `@tabler/icons-react` | `import { IconHome } from '@tabler/icons-react'` |

---

## Accessibility Checklist

When `accessibility.wcag` is AA or AAA:
- All text must meet contrast ratios (4.5:1 for AA, 7:1 for AAA)
- Focus indicators must be visible (ring-2 ring-offset-2)
- All interactive elements need aria-labels
- Respect `prefers-reduced-motion` when `reducedMotion: true`
- Keyboard navigation must work for all interactive elements
- Skip links for page navigation
