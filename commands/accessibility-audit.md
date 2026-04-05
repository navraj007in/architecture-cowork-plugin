---
description: Audit frontend code for WCAG 2.1 AA accessibility compliance with scored findings
---

# /architect:accessibility-audit

## Trigger

`/architect:accessibility-audit [options]`

Options:
- `[non_interactive:true]` — skip questions, scan all frontend components
- `[components:web-app,mobile-app]` — audit specific components only

## Purpose

Accessible products serve more users and reduce liability. This command scans scaffolded frontend code for WCAG 2.1 AA compliance: color contrast (from design tokens), focus management, ARIA labels, keyboard navigation, semantic HTML, screen reader support. Uses axe-core/pa11y/playwright-axe for automated scanning plus heuristic checks for manual review items.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context-detect-frontends) |
| **Scanning** | [Step 2](#step-2-scan-frontend-code) · [Step 3](#step-3-verify-results) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 5](#step-5-update-_statejson) · [Step 6](#step-6-signal-completion) |

### Step 1: Read Context & Detect Frontends

ℹ️ **CONTEXT LOADING:** _state.json → SDL → scaffolded frontends

**Read**:
- `_state.json.components[]` with type: web, mobile, desktop
- `_state.json.design` for color palette (used for contrast checking)
- Scaffolded frontend paths (`web-app/src/`, `app/src/`, etc.)

**Check for frontend technologies**:
- React/Next.js: component files in `src/components/`
- Vue: component files in `src/components/`
- Angular: component files in `src/components/`
- Svelte: component files in `src/components/`
- Flutter/React Native: view files (accessibility different - report separately)

**If no frontends found**:
> "I need scaffolded frontend code to audit. Run `/architect:scaffold` first, then come back here."

### Step 2: Scan Frontend Code

✅ **QUALITY GATE:** Run accessibility scanning

For each frontend component, use axe-core patterns to check:

**Automated Checks (via code scanning):**
1. **Color Contrast** — Check all text against design tokens primary/secondary colors
   - Success Criterion 1.4.3 (AA): contrast ratio ≥ 4.5:1 for normal text, 3:1 for large text
2. **ARIA Labels** — Missing alt text, aria-label, aria-labelledby
   - Success Criterion 1.1.1: All images have alt text
   - Success Criterion 4.1.2: All form inputs have labels
3. **Keyboard Navigation** — Check for keyboard trap, focus visible, tabindex
   - Success Criterion 2.1.1: All functionality available via keyboard
   - Success Criterion 2.4.7: Focus visible
4. **Semantic HTML** — Check for proper heading hierarchy, list structure
   - Success Criterion 1.3.1: Semantic structure (no div-based button without proper ARIA)
5. **Form Accessibility** — Label association, error messaging
   - Success Criterion 3.3.1: Error identification
   - Success Criterion 3.3.4: Error prevention

**Manual Review Items (reported but not auto-checked):**
- Screen reader testing (requires testing with NVDA, JAWS, VoiceOver)
- Focus management in dynamic content
- Motion/animation sensitivity (no auto-playing videos)
- Text alternative quality (not just "link" or "image")
- Meaningful error messages (not just red text)

### Step 3: Generate Audit Report

Create `architecture-output/accessibility-audit.md`:

```markdown
# WCAG 2.1 AA Accessibility Audit

**Date:** 2026-04-06  
**Scope:** web-app, api-server-admin  
**Compliance Score:** 72% (9/12 auto-checks passed)

## Summary

- ✅ **Passed:** 9 automated checks
- ⚠️ **Warnings:** 3 items needing manual review
- ❌ **Critical:** 2 contrast issues found

## Critical Issues (Fix Before Launch)

### 1. Low Color Contrast in Primary Button
**Component:** `Button.tsx` (line 42)  
**Issue:** Primary button text color (#666666) on primary background (#0EA5E9) = 3.2:1 ratio (needs 4.5:1)  
**Fix:** Use text-white instead of text-gray-500
**Severity:** Critical (foundational component, blocks all buttons)

### 2. Missing Form Labels
**Component:** `LoginForm.tsx` (line 18)  
**Issue:** Email input has no associated label element  
**Fix:** Add `<label htmlFor="email">Email</label>` before input
**Severity:** Critical (forms inaccessible to screen reader users)

## Warnings (Should Fix Before Launch)

### 1. Focus Visible Not Apparent
**Component:** `Link.tsx` (line 5)  
**Issue:** Links don't show visible focus indicator on keyboard navigation  
**Fix:** Add Tailwind `focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2`
**Severity:** Warning (keyboard users can't see focus)

## Manual Review Items (Schedule Testing)

- [ ] Screen reader testing with NVDA/JAWS (required)
- [ ] Keyboard-only navigation test (Tab through entire app)
- [ ] Heading hierarchy review (h1, h2, h3 should be sequential)
- [ ] Alt text quality (are alt texts descriptive?)
- [ ] Color blindness simulation (use color-blind simulator)

## Compliance Score

**Current:** 72% (9/12 auto-checks) + 3 manual items pending  
**Target:** 100% for AA compliance

## Next Steps

1. **Fix critical issues** (1-2 hours)
   - Button contrast: update to white text
   - Form labels: add labels to all inputs
2. **Fix warnings** (30 min)
   - Focus indicators: add focus-visible classes
3. **Manual testing** (2-3 hours)
   - Screen reader testing with NVDA
   - Keyboard navigation full walkthrough
   - Heading hierarchy review
4. **Re-audit** (30 min)
   - Re-run scan after fixes
   - Verify all issues resolved
```

### Step 4: Log Activity

```json
{"ts":"<ISO-8601>","phase":"accessibility-audit","outcome":"completed","components":["web-app"],"compliance_score":72,"critical_issues":2,"warnings":3,"files_generated":1,"summary":"Accessibility audit: 72% WCAG 2.1 AA compliance. 2 critical issues (contrast, form labels), 3 warnings (focus), 4 manual review items."}
```

### Step 5: Update _state.json

```json
{
  "accessibility": {
    "generated_at": "<ISO-8601>",
    "wcag_level": "AA",
    "compliance_score": 72,
    "critical_issues": 2,
    "warnings": 3,
    "manual_review_items": 4
  }
}
```

### Step 6: Signal Completion

```
[ACCESSIBILITY_AUDIT_DONE]
```

## Error Handling

### No Frontend Code Found

If no React/Vue/Angular components detected:
> "No frontend code found. Run `/architect:scaffold` with frontend components first."

### Design Tokens Missing

If `_state.json.design` is empty (no color palette):
- Report: "Design tokens not found. Run `/architect:design-system` first."
- Continue with generic contrast checking (WCAG minimum standards)

### Unable to Write Report

If `architecture-output/` cannot be written:
- Stop, report error, do NOT emit completion marker

## Output Rules

- Use the **founder-communication** skill for tone (technical but actionable)
- Report automated findings with code locations (file:line)
- Include specific fixes (not just "fix this", but "add role='button'")
- Critical issues must be fixed before launch
- Warnings should be fixed for best practices
- Manual review items are informational (require actual testing)
- Provide fixes organized by component/priority
- Include compliance score (X% of automated checks passed)
- Do NOT include the CTA footer
