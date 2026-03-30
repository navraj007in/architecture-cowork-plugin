---
description: Generate screen spec JSON files (NOT HTML) — one .json file per screen, rendered natively by Archon
---

# /architect:wireframes

## CRITICAL — Output Format

**You MUST write `.json` files only. This is not optional.**

| ✅ Correct | ❌ Wrong |
|-----------|---------|
| `dashboard.json` | `dashboard.html` |
| `users-list.json` | `wireframes.html` |
| `_manifest.json` | Any `.html`, `.css`, `.tsx`, `.jsx` file |

If you are about to write an HTML file, STOP. This command does not generate HTML. Archon renders the JSON natively — no HTML is needed or wanted.

## Why JSON (not HTML)

JSON specs are ~20 lines per screen. Archon renders them as polished wireframes natively. Generating HTML would:
- Exceed the output token limit (15 screens × 200 lines HTML = 3,000 lines)
- Produce files Archon cannot render
- Defeat the purpose of this command

Each screen = one `.json` file, ~20-30 lines. 15 screens = ~400 lines total. All in one run.

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
