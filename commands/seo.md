---
description: Configure SEO metadata, structured data, sitemaps, robots.txt, and Core Web Vitals tracking
---

# /architect:seo

## Trigger

`/architect:seo [options]`

Options:
- `[non_interactive:true]` — generate default SEO config

## Purpose

Search engine visibility drives discovery. This command generates SEO configuration: meta tags (Open Graph, Twitter), structured data (JSON-LD), sitemap.xml, robots.txt, Core Web Vitals setup. Framework-specific: Next.js `metadata` API, Vite `vite-plugin-sitemap`. Outputs ready-to-deploy config files.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context) |
| **Generation** | [Step 2](#step-2-generate-seo-files) |
| **Completion** | [Step 3](#step-3-log-activity) · [Step 4](#step-4-signal-completion) |

### Step 1: Read Context

ℹ️ **CONTEXT LOADING:** _state.json → SDL → frontend type

**Read**:
- `_state.json.project` (name, description, stage)
- `_state.json.tech_stack.frontend` (Next.js, Vue, etc.)
- Scaffolded frontend path

### Step 2: Generate SEO Files

Create in scaffolded frontend:

**`src/lib/seo.ts`** — Meta tag utilities
**`public/sitemap.xml`** — All indexable pages
**`public/robots.txt`** — Crawler directives
**`next.config.ts`** — Core Web Vitals config (if Next.js)

### Step 3: Log Activity

```json
{"ts":"<ISO-8601>","phase":"seo","outcome":"completed","framework":"next","files_generated":5,"summary":"SEO configured: metadata API, sitemap.xml, robots.txt, Core Web Vitals tracking."}
```

### Step 4: Signal Completion

```
[SEO_DONE]
```

## Error Handling

### No Frontend Found

> "Run `/architect:scaffold` with a frontend first."

## Output Rules

- Use the **founder-communication** skill
- Framework-appropriate meta tag setup (Next.js metadata API for Next.js projects)
- Valid sitemap.xml (tested against spec)
- Correct robots.txt (no blocks for search engines)
- Open Graph + Twitter card tags
- Structured data (JSON-LD for Organization, Product, etc.)
- Do NOT include the CTA footer
