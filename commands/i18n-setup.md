---
description: Setup internationalization for frontend apps with multi-language support and RTL handling
---

# /architect:i18n-setup

## Trigger

`/architect:i18n-setup [options]`

Options:
- `[non_interactive:true]` — skip questions, derive from SDL personas
- `[locales:en,es,fr,de]` — specify target locales (default: en + locales from personas)

## Purpose

Global products need multi-language support. This command scaffolds internationalization (i18n) infrastructure: i18next or react-intl setup, base translation files, locale switcher component, RTL support (Arabic, Hebrew), currency/date formatting utilities. Detects locale needs from SDL personas (if non-English regions specified) and design tokens (CJK/Arabic fonts).

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context) |
| **Configuration** | [Step 2](#step-2-ask-configuration) |
| **Generation** | [Step 3](#step-3-delegate-to-i18n-agent) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context

ℹ️ **CONTEXT LOADING:** _state.json → SDL → personas

**Read**:
- `_state.json.personas[]` with regions (detect non-English locales)
- `_state.json.design.body_font` (check for CJK or Arabic fonts)
- Scaffolded frontend type (React, Vue, Angular, Svelte)
- `_state.json.tech_stack.frontend`

**Detect needed locales**:
- If personas have `region: "Spain"` → add Spanish (es)
- If personas have `region: "Japan"` → add Japanese (ja)
- If body_font is "Noto Sans Arabic" → add Arabic (ar)
- Always include English (en)

### Step 2: Ask Configuration Questions

❓ **DECISION POINT:** Locales and i18n framework

**If not in non_interactive mode**:

1. **Target locales**:
   > "Which languages do you support?"
   > - Default: English + detected from personas
   > - User adds: Spanish, French, German, etc.

2. **i18n framework**:
   > "Which i18n library?"
   > - i18next (recommended, feature-rich)
   > - react-intl (React-specific, complex)
   > - Vue I18n (if Vue frontend)

3. **RTL support**:
   > "Need right-to-left (Arabic, Hebrew)?"
   > - Yes → add RTL support
   > - No → skip RTL

### Step 3: Delegate to i18n-setup Agent

🔄 **AGENT DELEGATION:** Launch i18n-setup agent

The agent generates i18n infrastructure with:
- `i18n/` directory with locale files (en.json, es.json, ar.json, etc.)
- Framework config (i18next.config.ts or react-intl setup)
- Locale switcher component
- RTL Tailwind configuration
- Currency/date formatting utilities
- CJK font stack updates (if needed)

### Step 4: Log Activity

```json
{"ts":"<ISO-8601>","phase":"i18n-setup","outcome":"completed","framework":"i18next","locales":["en","es","fr","ar"],"rtl_enabled":true,"files_generated":12,"summary":"i18n scaffolded: i18next, 4 locales (en, es, fr, ar), RTL support, locale switcher component."}
```

### Step 5: Signal Completion

```
[I18N_SETUP_DONE]
```

## Error Handling

### No Frontend Code Found

If no React/Vue/Angular components detected:
> "No frontend code found. Run `/architect:scaffold` with frontend first."

### Unable to Write i18n Directory

If `src/i18n/` or `src/locales/` cannot be created:
- Stop, report error, do NOT emit completion marker

## Output Rules

- Use the **founder-communication** skill for tone
- Generate working i18n setup (no placeholders)
- Include locale switcher component (copy-paste ready)
- RTL support via Tailwind `rtl:` modifiers
- Currency/date formatting utilities
- Font stack updates for CJK/Arabic
- Comprehensive locale files with common phrases
- Do NOT include the CTA footer
