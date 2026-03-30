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

## Section Types by Screen

**login / register / forgot-password** → layout: `centered`
```json
{ "type": "form", "fields": [{"label":"Email","type":"email"},{"label":"Password","type":"password"}] }
```

**dashboard** → layout: `sidebar`
```json
{ "type": "stats", "items": [{"label":"Total Users","value":"1,240","trend":"+8%"},{"label":"Revenue","value":"$42K","trend":"+12%"}] },
{ "type": "table", "title": "Recent Activity", "columns": ["User","Action","Date","Status"], "rows": [["Alice Chen","Created order","Mar 29","Active"]] }
```

**{entity}-list** → layout: `topnav` or `sidebar`
```json
{ "type": "table", "title": "Orders", "columns": ["ID","Customer","Amount","Status","Date"], "rows": [["#1042","Sarah Chen","$240","Pending","Mar 29"]] }
```

**{entity}-detail** → layout: `topnav`
```json
{ "type": "detail", "title": "Order #1042", "pairs": [{"label":"Customer","value":"Sarah Chen"},{"label":"Amount","value":"$240"},{"label":"Status","value":"Pending"}] }
```

**{entity}-form (create/edit)** → layout: `topnav`, centered card
```json
{ "type": "form", "title": "New Order", "fields": [{"label":"Customer","type":"text"},{"label":"Product","type":"select","options":["Widget A","Widget B"]},{"label":"Notes","type":"textarea"}] }
```

**settings-profile** → layout: `sidebar`
```json
{ "type": "tabs", "tabs": ["Profile","Notifications","Security"] },
{ "type": "form", "fields": [{"label":"Full Name","type":"text"},{"label":"Email","type":"email"},{"label":"Bio","type":"textarea"}] }
```

**settings-billing** → layout: `sidebar`
```json
{ "type": "cards", "title": "Plans", "cards": [{"title":"Free","description":"Up to 3 projects","badge":"Current"},{"title":"Pro — $29/mo","description":"Unlimited projects"}] }
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
    {"type":"stats","items":[{"label":"Total Students","value":"142","trend":"+12%"},{"label":"Active Courses","value":"18"},{"label":"Completion Rate","value":"87%"},{"label":"Revenue","value":"$24.5K","trend":"+8%"}]},
    {"type":"table","title":"Recent Enrollments","columns":["Student","Course","Enrolled","Status"],"rows":[["Sarah Chen","React Fundamentals","Mar 28","Active"],["James Liu","Node.js Advanced","Mar 27","Active"],["Emma Wilson","Python Basics","Mar 26","Completed"]]}
  ]
}
```
