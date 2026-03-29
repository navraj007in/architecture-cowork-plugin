---
description: Generate navigable HTML wireframes from SDL architecture, core flows, and design system
---

# /architect:wireframes

## Trigger

`/architect:wireframes` — run after blueprint phase.

## Output Budget — READ FIRST

- Write **at most 2 HTML files per run** — stop after 2 screens even if more remain
- Each HTML file must be **under 200 lines**
- Use the shared `wireframes.css` — never inline CSS in HTML files
- No JavaScript, no external CDN links

## Workflow

### Step 1: Check for Manifest

Check if `architecture-output/wireframes/_manifest.json` exists.

**If it exists:** Read it. It has `{ "screens": [...], "generated": [...] }`. Jump to Step 3.

**If it does not exist:** Go to Step 2.

### Step 2: First Run Setup

Read the SDL file. Using the **wireframe-patterns** skill, map SDL sections to a screen inventory:

```json
{
  "screens": [
    { "id": "login", "name": "Login", "file": "login.html" },
    { "id": "dashboard", "name": "Dashboard", "file": "dashboard.html" }
  ],
  "generated": []
}
```

Write `architecture-output/wireframes/_manifest.json`.

Write `architecture-output/wireframes/wireframes.css`:

```css
:root{--p:#4f46e5;--bg:#0f172a;--s:#1e293b;--b:#334155;--t:#f1f5f9;--m:#94a3b8;--r:6px}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:system-ui,sans-serif;background:var(--bg);color:var(--t);font-size:14px}
nav{display:flex;align-items:center;gap:12px;padding:12px 24px;background:var(--s);border-bottom:1px solid var(--b)}
nav a{color:var(--m);text-decoration:none;font-size:13px}nav a:hover,nav a.active{color:var(--t)}
nav .logo{font-weight:700;color:var(--t);margin-right:auto}
main{padding:24px;max-width:1100px;margin:0 auto}
h1{font-size:20px;font-weight:600;margin-bottom:16px}h2{font-size:15px;font-weight:600;margin-bottom:10px}
.card{background:var(--s);border:1px solid var(--b);border-radius:var(--r);padding:16px;margin-bottom:16px}
.btn{display:inline-block;padding:8px 16px;background:var(--p);color:#fff;border:none;border-radius:var(--r);cursor:pointer;font-size:13px;text-decoration:none}
.btn-ghost{background:transparent;border:1px solid var(--b);color:var(--t)}
.form-group{margin-bottom:12px}
label{display:block;font-size:12px;color:var(--m);margin-bottom:4px}
input,select,textarea{width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--b);border-radius:var(--r);color:var(--t);font-size:13px}
table{width:100%;border-collapse:collapse}
th,td{text-align:left;padding:8px 12px;border-bottom:1px solid var(--b);font-size:13px}
th{color:var(--m);font-weight:500}
.badge{display:inline-block;padding:2px 8px;border-radius:20px;font-size:11px;background:var(--s);border:1px solid var(--b)}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
.grid3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px}
.stat{text-align:center}.stat .value{font-size:28px;font-weight:700}.stat .label{font-size:12px;color:var(--m)}
.sidebar-layout{display:grid;grid-template-columns:200px 1fr;min-height:calc(100vh - 48px)}
.sidebar{background:var(--s);border-right:1px solid var(--b);padding:16px}
.sidebar a{display:block;padding:6px 10px;border-radius:var(--r);color:var(--m);text-decoration:none;font-size:13px;margin-bottom:2px}
.sidebar a:hover,.sidebar a.active{background:var(--bg);color:var(--t)}
.content{padding:24px}.actions{display:flex;gap:8px;margin-bottom:16px}
.empty{text-align:center;padding:48px;color:var(--m)}
```

Then continue to Step 3 with the empty generated list.

### Step 3: Pick Next 2 Screens

From the manifest, find screens NOT in `generated`. Take the first 2.

If all screens are generated → go to Step 5 (index + done).

### Step 4: Write Screen Files

For each of the 2 screens:

1. Create `architecture-output/wireframes/{file}`
2. Use the pattern for that screen type from the **wireframe-patterns** skill
3. HTML structure: `<!DOCTYPE html>` → `<head>` with `<link rel="stylesheet" href="wireframes.css">` → `<body>` with nav + main content
4. Use real entity field names and realistic placeholder data
5. Include working `<a href>` links to related screens

After writing both files, update the manifest: append the screen ids to `generated` and rewrite `_manifest.json`.

### Step 5: Write Index (final run only — when all screens done)

Create `architecture-output/wireframes/index.html` listing all screens with links.

### Step 6: Signal

After Step 4, check if `generated.length < screens.length`:

- **Screens remain:** End your response with exactly: `[WIREFRAMES_CONTINUE] {generated}/{total} screens done.`
- **All done:** End your response with exactly: `[WIREFRAMES_DONE] All {total} screens generated.`
