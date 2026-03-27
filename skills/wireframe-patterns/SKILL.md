---
name: wireframe-patterns
description: Screen type templates and layout patterns for generating wireframes from SDL architecture and user flows.
---

# Wireframe Generation Patterns

Templates for generating low-fidelity HTML wireframes from SDL components, core flows, and data models. Each screen type has a structural template that produces a navigable wireframe.

---

## Screen Type Templates

### Auth Screens

**Login**
```
┌─────────────────────────────┐
│         [Logo]              │
│                             │
│   Email    [____________]   │
│   Password [____________]   │
│                             │
│   [     Sign In      ]      │
│                             │
│   Forgot password?          │
│   Don't have an account?    │
│   Sign up                   │
└─────────────────────────────┘
```

**Register**
```
┌─────────────────────────────┐
│         [Logo]              │
│                             │
│   Name     [____________]   │
│   Email    [____________]   │
│   Password [____________]   │
│   Confirm  [____________]   │
│                             │
│   [    Create Account   ]   │
│                             │
│   Already have an account?  │
│   Sign in                   │
└─────────────────────────────┘
```

### Dashboard / Home

**Dashboard with stats + recent items**
```
┌──────────────────────────────────────────────┐
│ [Logo] Nav: Dashboard | Items | Settings  [U]│
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ Stat │ │ Stat │ │ Stat │ │ Stat │       │
│  │  42  │ │ $1.2K│ │  89% │ │  12  │       │
│  └──────┘ └──────┘ └──────┘ └──────┘       │
│                                              │
│  Recent Items                    [View All]  │
│  ┌──────────────────────────────────────┐   │
│  │ Item 1          Status    Date      │   │
│  │ Item 2          Status    Date      │   │
│  │ Item 3          Status    Date      │   │
│  └──────────────────────────────────────┘   │
│                                              │
└──────────────────────────────────────────────┘
```

### List / Table View

**Filterable list with actions**
```
┌──────────────────────────────────────────────┐
│ [Logo] Nav                                [U]│
├──────────────────────────────────────────────┤
│                                              │
│  Items                        [+ New Item]   │
│  [Search...________] [Filter ▼] [Sort ▼]    │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │ □ Name        Category   Status  ⋯  │   │
│  │ □ Item One    Type A     Active  ⋯  │   │
│  │ □ Item Two    Type B     Draft   ⋯  │   │
│  │ □ Item Three  Type A     Active  ⋯  │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  Showing 1-10 of 42         [< 1 2 3 4 >]  │
└──────────────────────────────────────────────┘
```

### Detail / Single Item View

**Item detail with sections**
```
┌──────────────────────────────────────────────┐
│ [Logo] Nav                                [U]│
├──────────────────────────────────────────────┤
│                                              │
│  ← Back to Items                             │
│                                              │
│  Item Title                    [Edit] [Del]  │
│  Status: Active                              │
│                                              │
│  ┌─────────────┬─────────────────────────┐  │
│  │ Details     │ Description text here   │  │
│  │             │                         │  │
│  │ Field 1: V  │ Additional details and  │  │
│  │ Field 2: V  │ context about this item │  │
│  │ Field 3: V  │                         │  │
│  └─────────────┴─────────────────────────┘  │
│                                              │
└──────────────────────────────────────────────┘
```

### Form / Create-Edit

**Multi-field form with validation**
```
┌──────────────────────────────────────────────┐
│ [Logo] Nav                                [U]│
├──────────────────────────────────────────────┤
│                                              │
│  Create New Item                             │
│                                              │
│  Name *        [________________________]    │
│  Description   [________________________]    │
│                [________________________]    │
│  Category      [Select...           ▼]      │
│  Priority      ○ Low  ● Medium  ○ High      │
│  Tags          [tag1] [tag2] [+ Add]        │
│                                              │
│  Upload        [Choose file...]              │
│                                              │
│            [Cancel]  [Save Item]             │
│                                              │
└──────────────────────────────────────────────┘
```

### Settings / Profile

**Tabbed settings page**
```
┌──────────────────────────────────────────────┐
│ [Logo] Nav                                [U]│
├──────────────────────────────────────────────┤
│                                              │
│  Settings                                    │
│  [Profile] [Notifications] [Billing] [Team]  │
│  ─────────────────────────────────────────   │
│                                              │
│  Profile                                     │
│  Avatar  [○]  [Change photo]                │
│  Name    [________________________]          │
│  Email   [________________________]          │
│  Bio     [________________________]          │
│                                              │
│                          [Save Changes]      │
│                                              │
└──────────────────────────────────────────────┘
```

### Chat / Messaging

**Real-time messaging interface**
```
┌──────────────────────────────────────────────┐
│ [Logo] Nav                                [U]│
├──────────┬───────────────────────────────────┤
│ Channels │ # general                         │
│          │                                   │
│ # general│ User A  10:42am                   │
│ # random │ Message content here              │
│ # team   │                                   │
│          │ User B  10:45am                   │
│ DMs      │ Response message                  │
│ @ Alice  │                                   │
│ @ Bob    │                                   │
│          ├───────────────────────────────────┤
│          │ [Type a message...        ] [Send]│
└──────────┴───────────────────────────────────┘
```

### Landing / Marketing

**Hero + features + CTA**
```
┌──────────────────────────────────────────────┐
│ [Logo]                    [Login] [Sign Up]  │
├──────────────────────────────────────────────┤
│                                              │
│        Hero Headline Text                    │
│        Subheading description                │
│                                              │
│     [Get Started]  [Learn More]              │
│                                              │
├──────────────────────────────────────────────┤
│                                              │
│   Feature 1     Feature 2     Feature 3      │
│   [icon]        [icon]        [icon]         │
│   Description   Description   Description    │
│                                              │
├──────────────────────────────────────────────┤
│   Pricing                                    │
│   [Free] [Pro $10/mo] [Enterprise]           │
│                                              │
├──────────────────────────────────────────────┤
│   Footer links                               │
└──────────────────────────────────────────────┘
```

---

## How to Map SDL to Screens

### From Core Flows
Each `product.coreFlow` typically implies screens:
- Flow **trigger** → landing/entry screen
- Each **step** → a screen or UI state
- Final **step** → confirmation/result screen

### From Components
- **Frontend** component → layout shell (dashboard/marketing/app-shell from design.layout.style)
- **Backend** endpoints → detail/list views for each resource
- **Auth** strategy → login/register/forgot-password screens

### From Data Models
- Each **entity** in the data model → list + detail + create/edit screens
- **Relationships** → navigation between screens (e.g., user → orders → order detail)

---

## Wireframe Generation Rules

1. **Use design tokens** — apply palette, typography, shape from SDL design section
2. **Use real field names** — form fields match data model properties
3. **Use real nav items** — navigation matches frontend routes from core flows
4. **Include realistic placeholder data** — "John Smith" not "Lorem ipsum"
5. **Show all CRUD operations** — list, detail, create, edit, delete for each entity
6. **Mark interactive elements** — buttons that navigate should link to other wireframe pages
7. **Responsive hint** — note which sections stack on mobile
8. **Accessibility** — include aria labels, semantic HTML structure
