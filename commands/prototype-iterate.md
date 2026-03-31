---
description: Apply targeted changes to an existing prototype without regenerating from scratch
---

# /architect:prototype-iterate

## Trigger

`/architect:prototype-iterate` — run only after `/architect:prototype` has completed (phase_complete === 4). The change request should follow the command in the conversation.

## Purpose

Apply targeted, surgical changes to an existing prototype. This command reads the change request from the conversation, identifies only the affected files, rewrites them, and leaves everything else untouched.

This is NOT a rebuild — do not regenerate the entire prototype.

---

## Step 0: Validate

Check that `prototype/_manifest.json` exists and `phase_complete === 4`.

- If the file does not exist, or `phase_complete` is less than 4: stop and tell the user to run `/architect:prototype` first.
- If validation passes: continue.

---

## Step 1: Read Context

Read the following files to understand the current state of the prototype:

1. **`architecture-output/_state.json`** — project name, design tokens (palette, fonts), entities, personas
2. **`prototype/_manifest.json`** — full manifest: `screens` array, `appName`, `personality`, `files_written`

Then, based on the change request, **selectively read only the relevant files**:

- If the change affects specific screens: read only those screen files (use the `screens` array from manifest to identify file paths — typically `prototype/src/pages/{id}.tsx` or `prototype/src/screens/{id}.tsx`)
- If the change affects shared components: Grep `prototype/src/components/` for the relevant component(s)
- If the change affects theme/design: read `prototype/src/styles/globals.css` and `prototype/tailwind.config.ts`
- If the change affects mock data: read `prototype/src/data/mock.ts`
- If the change affects routing/navigation: read `prototype/src/App.tsx`

Do NOT read all files unless the change request is global (e.g. "redesign the entire UI"). Be selective.

---

## Step 2: Understand Change Request

Parse the change request from the conversation (the text that follows the `/architect:prototype-iterate` command).

Categorise the change into one or more of these types:

| Change Type | Action |
|-------------|--------|
| **New screen** | Add to `screens` array in manifest, generate new screen file, add route to `App.tsx`, add nav link if applicable |
| **Modify existing screen** | Overwrite only the affected screen file(s) |
| **Design change** (colors, fonts, theme) | Update `prototype/src/styles/globals.css` and/or `prototype/tailwind.config.ts` |
| **Data change** (add fields, new entities, more records) | Update `prototype/src/data/mock.ts` |
| **Navigation change** (sidebar → topnav, add nav item) | Update layout component(s): `Sidebar.tsx`, `Header.tsx`, `MobileNav.tsx`, `App.tsx` |
| **Component change** (update a shared UI component) | Update specific component file(s) in `prototype/src/components/` |
| **Global refactor** (RTL, i18n, accessibility) | Update affected files across the prototype |

For ambiguous requests, infer the most logical interpretation and proceed. Do not ask clarifying questions.

---

## Step 3: Apply Changes

For each identified change:

1. **Write or overwrite only the affected files** — never touch files that aren't changing
2. **Maintain consistency** with the existing prototype:
   - Same design tokens (colors, fonts, border-radius, shadows) from `tailwind.config.ts` and `globals.css`
   - Same import paths and component structure
   - Same mock data patterns and TypeScript types from `mock.ts`
   - Same i18n keys namespace — add new keys to `en.json`, `es.json`, `ar.json` if generating new strings
3. **For new screens:**
   - Follow the same file structure as existing screens
   - Import from existing shared components (`Button`, `Card`, `Table`, `Badge`, etc.) — do not duplicate
   - Add the route to `App.tsx`
   - Add a nav entry to `Sidebar.tsx` (or topnav) if the screen is a primary section
   - Add translation keys for new screen title and labels

**Apply the same quality standards as the original prototype command:**

- TypeScript — no `any` types, proper interfaces
- Mobile responsive — all layouts use responsive breakpoints (`sm:`, `md:`, `lg:`)
- Dark/light mode — use CSS variable–backed Tailwind classes (`bg-surface`, `text-text-primary`), never hardcoded hex values
- i18n + RTL — all new user-facing strings via `useTranslation()`, `t('key')`. New keys added to all three locale files (`en.json`, `es.json`, `ar.json`)
- Accessibility (WCAG AA) — semantic HTML, visible focus rings (`focus-visible:ring-2`), `aria-label` on icon-only buttons, WCAG AA contrast
- Use `recharts` for any new charts — import from existing recharts usage if already present
- Do NOT add a CTA footer section

---

## Step 4: Build Check

After writing all changed files, run a build check in the `prototype/` directory:

```bash
npx tsc --noEmit
```

If that fails with environment errors (no tsconfig, etc.), fall back to:

```bash
npx vite build --mode development
```

**Fix ALL TypeScript/build errors before continuing.** Iterate — read the error, fix the file, re-run the check — until the build is clean.

---

## Step 5: Update Manifest

Read `prototype/_manifest.json` and apply these updates:

- **New screens:** add each new screen object to the `screens` array (`{ "id": "...", "title": "...", "phase": 4 }`) and add the screen id to `screens_done`
- **Written files:** add all newly written or overwritten file paths to `files_written` (append, do not replace)
- **Keep `phase_complete: 4`** — never reset this value
- Write the updated manifest back to `prototype/_manifest.json`

---

## Step 6: Update _state.json

After updating the manifest, update `architecture-output/_state.json`:

1. Read existing `architecture-output/_state.json`
2. Update only `prototype.screens` to the new total screen count (from the updated manifest `screens` array length)
3. Write back — do NOT overwrite other fields

Also append to `architecture-output/_activity.jsonl`:
```json
{"ts":"<ISO-8601>","phase":"prototype-iterate","outcome":"completed","files":["<list of modified files>"],"summary":"Prototype updated: <brief description of change, e.g. added invoice-detail screen>."}
```

---

## Step 7: Output

Print a concise summary of what changed:

```
## Changes Applied

**Modified:** src/pages/dashboard.tsx — added revenue chart widget
**Added:** src/pages/invoice-detail.tsx — new invoice detail screen
**Modified:** src/App.tsx — added /invoices/:id route
**Modified:** src/components/layout/Sidebar.tsx — added Invoices nav link
**Modified:** src/i18n/locales/en.json, es.json, ar.json — added invoice detail keys
**Build:** ✓ tsc --noEmit passed
```

Emit: `[PROTOTYPE_DONE]`

---

## Rules

- NEVER regenerate the entire prototype — only change what was requested
- NEVER reset `phase_complete` — it must remain `4` after this command
- NEVER call `[PROTOTYPE_CONTINUE]` — this command completes in a single pass
- ALWAYS run the build check before finishing
- ALWAYS keep existing files that aren't changing
- Do NOT add a CTA footer
- Do NOT ask clarifying questions — infer intent and proceed
