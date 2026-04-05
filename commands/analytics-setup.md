---
description: Wire analytics SDKs (GA4, PostHog, Mixpanel) with GDPR-compliant consent management
---

# /architect:analytics-setup

## Trigger

`/architect:analytics-setup [options]`

Options:
- `[provider:ga4|posthog|mixpanel|amplitude|plausible]` — override provider (default: GA4)
- `[non_interactive:true]` — skip questions, use defaults

## Purpose

Product insights drive decisions. This command wires analytics infrastructure: GA4, PostHog, Mixpanel, Amplitude, or Plausible SDKs with typed event tracking, GDPR-compliant consent management, and privacy-by-default settings. Generates `src/lib/analytics.ts` with event tracking utilities and consent hooks.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context) |
| **Configuration** | [Step 2](#step-2-ask-configuration) |
| **Generation** | [Step 3](#step-3-generate-analytics-files) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context

ℹ️ **CONTEXT LOADING:** _state.json → SDL

**Read**:
- `_state.json.design.personality` (product stage)
- `_state.json.personas[]` (regions → GDPR requirement)
- Tech stack (frontend framework)

### Step 2: Ask Configuration

❓ **DECISION POINT:** Analytics provider and consent approach

**If not non_interactive**:
- Which provider? GA4, PostHog, Mixpanel, Amplitude, Plausible
- GDPR consent required? (auto-detect from EU regions in personas)

### Step 3: Generate Analytics Files

Create:
- `src/lib/analytics.ts` — Typed event tracking (TypeScript)
- `src/hooks/useConsent.ts` — Consent management hook
- `.env.example` — API key placeholders
- `src/components/ConsentBanner.tsx` — GDPR consent UI

**Example events tracked:**
- Page views
- Outbound clicks
- Form submissions
- Error events
- Custom business events (signup, purchase, etc.)

### Step 4: Log Activity

```json
{"ts":"<ISO-8601>","phase":"analytics-setup","outcome":"completed","provider":"ga4","gdpr_enabled":true,"files_generated":4,"summary":"Analytics configured: GA4 with typed tracking, GDPR consent banner, consent hook."}
```

### Step 5: Signal Completion

```
[ANALYTICS_SETUP_DONE]
```

## Error Handling

### No Frontend Found

> "Run `/architect:scaffold` with a frontend first."

## Output Rules

- Use the **founder-communication** skill
- TypeScript types for all events
- GDPR-compliant opt-in (not opt-out)
- No tracking until user consents
- Consent persistence (localStorage)
- Do NOT include the CTA footer
