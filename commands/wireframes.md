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

### Step 2: Read Context

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` → appName
- `design` → `primary`, `secondary`, `accent`, `personality`, `heading_font`, `body_font`, `mono_font`, `border_radius`, `shadow`, `component_library` — use all of these in the `theme` field of each spec
- `design.tokens_file` → if present, read that file (e.g. `architecture-output/design-system/design-tokens.json`) to get precise token values for spacing, border radius, shadows, and motion — use these values in the `theme` object for complete fidelity
- `entities` → field names for realistic placeholder values in specs

If `_state.json.entities` is absent, read `domain.entities[]` from SDL as the entity list fallback (check `solution.sdl.yaml` first; if absent, check `sdl/data.yaml` or the relevant `sdl/` module). This provides entity names for generating data-display wireframe screens.

**Then** read the SDL — **only if `_state.json` is absent or missing `project.name`**; check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Grep for `product:` block (screens, coreFlows, auth) and `components:` block only. Do NOT read the full SDL file.

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
- `sections`: use real entity field names from `domain.entities[]` or `_state.json.entities`, realistic placeholder values
- `theme`: include a `theme` object in each spec if `_state.json.design` is available:
  ```json
  "theme": {
    "primary": "#f97316",
    "secondary": "#0ea5e9",
    "accent": "#fbbf24",
    "surface": "#ffffff",
    "text_primary": "#0f172a",
    "personality": "bold-commercial",
    "heading_font": "Clash Display",
    "body_font": "Poppins",
    "mono_font": "JetBrains Mono",
    "border_radius": "8px",
    "shadow": "0 1px 3px rgba(0,0,0,0.12)",
    "component_library": "shadcn/ui"
  }
  ```
  Populate from `_state.json.design` first; if `design.tokens_file` exists, override `border_radius`, `shadow`, and any extended palette values from the token file.
  If no design context exists, omit the `theme` field entirely.

### Step 5: Update Manifest

Rewrite `_manifest.json` with all screen ids in `generated`.

### Step 6: Signal

Output: `[WIREFRAMES_DONE] All {N} screens generated.`

### Final Step: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"wireframes","outcome":"completed","files":["architecture-output/wireframes/_manifest.json"],"summary":"Wireframes generated: <N> screens across <N> flows."}
```

List all generated wireframe JSON files in the `files` array.
