---
name: wireframe-patterns
description: Screen type patterns and SDL-to-screen mapping rules for HTML wireframe generation.
---

# Wireframe Patterns

## SDL → Screen Mapping

| SDL source | Screens to generate |
|---|---|
| `auth` section | login, register, forgot-password |
| `product.screens` | use as-is (user-defined, takes priority) |
| `product.coreFlows` | one screen per distinct flow step |
| `data` entity | {entity}-list, {entity}-detail, {entity}-form |
| always | dashboard, settings-profile |
| billing/subscriptions | settings-billing |
| multi-tenant | settings-team |
| marketing/landing component | landing |

## Screen → HTML Pattern

**login / register / forgot-password**
— Centered card (max-width 380px), form-groups for fields, btn submit, link to sibling auth screen.

**dashboard**
— grid3 stat cards at top (key metrics from data entities), card with recent-items table below, sidebar-layout if app has 5+ screens.

**{entity}-list**
— actions div with `[+ New {Entity}]` btn, table with entity fields as columns, badge for status fields, `<a>` link on name column to detail screen.

**{entity}-detail**
— `← Back` link, h1 with entity name, card with field/value rows, actions div with Edit and Delete btns.

**{entity}-form (create/edit)**
— card wrapping form-groups for each entity field, input types matching field type (select for enum, textarea for long text), btn submit + btn-ghost cancel.

**settings-profile**
— sidebar-layout with nav links to settings sub-pages, form-groups for user fields.

**settings-billing**
— Current plan card, upgrade options, payment method section.

**landing**
— Full-width hero section, grid3 feature cards, pricing section, footer.

**chat / messaging**
— sidebar-layout: channel list left, message thread right, input bar at bottom.

## Rules

- Use field names from SDL data entities — never generic "field1"
- Use realistic placeholder values: "Sarah Chen", "2024-03-15", "$1,240" — not "lorem ipsum"
- Every screen needs nav links to 3-5 other screens
- List screens need working links to their detail screen
- Forms need Cancel link back to list screen
- Status fields get a `.badge` element
- Keep HTML under 200 lines per file
- Link to `wireframes.css` — never inline styles
