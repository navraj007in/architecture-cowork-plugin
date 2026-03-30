---
name: wireframe-patterns
description: JSON wireframe spec patterns — SDL-to-screen mapping and section examples for each screen type.
---

# Wireframe Patterns (JSON)

## SDL → Screen Inventory

| SDL source | Screens |
|---|---|
| `auth` section | login, register, forgot-password |
| `product.screens` | use as-is (takes priority over inference) |
| `product.coreFlows` | one screen per distinct flow step |
| `data` entity | `{entity}-list`, `{entity}-detail`, `{entity}-form` |
| always | dashboard, settings-profile |
| subscriptions/billing | settings-billing |
| multi-tenant | settings-team |
| marketing/landing component | landing |

## Section Types

| Type | Use for | Key fields |
|------|---------|-----------|
| `header` | Page title + action buttons — use as FIRST section on every non-auth screen | `title`, `subtitle?`, `actions?` (array), `badge?` |
| `stats` | Metric cards with trends | `items: [{label, value, trend?}]` |
| `table` | Data lists with rows | `title?`, `columns`, `rows` |
| `form` | Input forms | `title?`, `fields: [{label, type, options?}]`, `submitLabel?` |
| `detail` | Key-value pairs for a record | `title?`, `pairs: [{label, value}]` |
| `hero` | Landing page hero | `headline`, `subheading?`, `cta?` |
| `cards` | Feature/content cards | `title?`, `cards: [{title, description?, badge?}]` |
| `feed` | Activity/notification feed | `title?`, `feed: [{user, action, time}]` |
| `chat` | Messaging UI | `channels`, `messages: [{user, time, text}]` |
| `tabs` | Tabbed content sections | `title?`, `tabs: [string]` |
| `empty` | Empty state with CTA | `title?`, `message?`, `action?` |

**Form field types:** `text`, `email`, `password`, `select` (needs `options`), `textarea`, `checkbox`, `toggle`

## Screen Patterns

**login / register / forgot-password** → layout: `centered`
```json
{ "type": "form", "fields": [{"label":"Email","type":"email"},{"label":"Password","type":"password"}], "submitLabel": "Sign In" }
```

**dashboard** → layout: `sidebar`
```json
{ "type": "header", "title": "Dashboard", "subtitle": "Welcome back", "actions": ["New Report"] },
{ "type": "stats", "items": [{"label":"Total Users","value":"1,240","trend":"+8%"},{"label":"Revenue","value":"$42K","trend":"+12%"},{"label":"Active Now","value":"38","trend":"+3%"},{"label":"Churn Rate","value":"2.1%","trend":"-0.4%"}] },
{ "type": "feed", "title": "Recent Activity", "feed": [{"user":"Alice Chen","action":"created a new order #1042","time":"2 min ago"},{"user":"James Liu","action":"updated billing details","time":"15 min ago"}] }
```

**{entity}-list** → layout: `sidebar` or `topnav`
```json
{ "type": "header", "title": "Orders", "badge": "142", "actions": ["Export", "+ New Order"] },
{ "type": "table", "columns": ["ID","Customer","Amount","Status","Date"], "rows": [["#1042","Sarah Chen","$240","Pending","Mar 29"],["#1041","James Liu","$180","Complete","Mar 28"]] }
```

**{entity}-detail** → layout: `topnav`
```json
{ "type": "header", "title": "Order #1042", "subtitle": "Created Mar 29 · Sarah Chen", "actions": ["Edit", "Cancel Order"] },
{ "type": "detail", "pairs": [{"label":"Customer","value":"Sarah Chen"},{"label":"Amount","value":"$240"},{"label":"Status","value":"Pending"},{"label":"Created","value":"Mar 29, 2025"}] }
```

**{entity}-form (create/edit)** → layout: `topnav`
```json
{ "type": "header", "title": "New Order", "subtitle": "Fill in the details below" },
{ "type": "form", "fields": [{"label":"Customer","type":"text"},{"label":"Product","type":"select","options":["Widget A","Widget B"]},{"label":"Notes","type":"textarea"}], "submitLabel": "Create Order" }
```

**settings** → layout: `sidebar`
```json
{ "type": "header", "title": "Settings", "subtitle": "Manage your account preferences" },
{ "type": "tabs", "tabs": ["Profile","Notifications","Security","Billing"] },
{ "type": "form", "fields": [{"label":"Full Name","type":"text"},{"label":"Email","type":"email"},{"label":"Timezone","type":"select","options":["UTC","EST","PST"]},{"label":"Email notifications","type":"toggle"}], "submitLabel": "Save Changes" }
```

**settings-billing** → layout: `sidebar`
```json
{ "type": "header", "title": "Billing", "subtitle": "Manage your subscription" },
{ "type": "cards", "title": "Plans", "cards": [{"title":"Free","description":"Up to 3 projects","badge":"Current"},{"title":"Pro — $29/mo","description":"Unlimited projects, priority support"},{"title":"Enterprise","description":"Custom pricing, SLA"}] }
```

**landing** → layout: `fullpage`
```json
{ "type": "hero", "headline": "Build faster with MyApp", "subheading": "The platform for modern teams.", "cta": "Get Started Free" },
{ "type": "cards", "title": "Features", "cards": [{"title":"Fast","description":"Deploy in minutes"},{"title":"Secure","description":"SOC2 compliant"},{"title":"Scalable","description":"Grows with you"}] }
```

**chat/messaging** → layout: `sidebar`
```json
{ "type": "chat", "channels": ["general","team","support"], "messages": [{"user":"Alice","time":"10:42am","text":"Good morning everyone!"},{"user":"Bob","time":"10:45am","text":"Morning! Ready for standup?"}] }
```

**empty/onboarding** → layout: `centered`
```json
{ "type": "empty", "title": "No orders yet", "message": "Create your first order to get started.", "action": "+ Create Order" }
```

## Full Example (dashboard.json)

```json
{
  "screen": "dashboard",
  "title": "Dashboard",
  "appName": "NexusVET",
  "layout": "sidebar",
  "nav": ["Dashboard","Students","Courses","Reports","Settings"],
  "activeNav": "Dashboard",
  "navLinks": {"Students":"students-list","Courses":"courses-list","Reports":"reports","Settings":"settings-profile"},
  "sections": [
    {"type":"header","title":"Dashboard","subtitle":"Welcome back — here's what's happening today","actions":["+ New Enrollment"]},
    {"type":"stats","items":[{"label":"Total Students","value":"142","trend":"+12%"},{"label":"Active Courses","value":"18"},{"label":"Completion Rate","value":"87%"},{"label":"Revenue","value":"$24.5K","trend":"+8%"}]},
    {"type":"feed","title":"Recent Activity","feed":[{"user":"Sarah Chen","action":"enrolled in React Fundamentals","time":"2 min ago"},{"user":"James Liu","action":"completed Node.js Advanced","time":"1 hr ago"},{"user":"Emma Wilson","action":"submitted assignment for Python Basics","time":"3 hr ago"}]}
  ]
}
```
