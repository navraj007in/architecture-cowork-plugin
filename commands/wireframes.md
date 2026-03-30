---
description: Generate JSON wireframe specs for each screen inferred from SDL
---

# /architect:wireframes

## Why JSON

JSON specs are ~20 lines per screen. Archon renders them natively. Do NOT generate HTML or CSS.

## Output Budget

- All screens in ONE run — JSON is tiny (20-30 lines each, ~300 lines total for 15 screens)
- No HTML, no CSS, no external dependencies
- One `.json` file per screen

## Workflow

### Step 1: Check Manifest

Check if `architecture-output/wireframes/_manifest.json` exists with a non-empty `generated` array. If all screens already exist, output `[WIREFRAMES_DONE]` and stop.

### Step 2: Read SDL

Read the project SDL file. Extract: appName, auth section, product.screens (use as-is if present), product.coreFlows, data entities, component types.

### Step 3: Build Manifest

Using the **wireframe-patterns** skill, map SDL to a screen inventory. Write `architecture-output/wireframes/_manifest.json`:

```json
{
  "appName": "MyApp",
  "screens": [
    { "id": "login", "title": "Login" },
    { "id": "dashboard", "title": "Dashboard" }
  ],
  "generated": []
}
```

### Step 4: Generate All JSON Specs

For each screen, write `architecture-output/wireframes/{id}.json`.

See **wireframe-patterns** skill for section types and examples per screen type.

Key rules:
- `layout`: `"centered"` for auth, `"sidebar"` for apps with many nav items, `"topnav"` otherwise, `"fullpage"` for landing
- `navLinks`: map nav label → screen id (e.g. `"Students": "students-list"`)
- `sections`: use real entity field names from SDL data section, realistic placeholder values

### Step 5: Update Manifest

Rewrite `_manifest.json` with all screen ids in `generated`.

### Step 6: Signal

Output: `[WIREFRAMES_DONE] All {N} screens generated.`
