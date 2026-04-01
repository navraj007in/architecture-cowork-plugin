---
description: Validate scaffolded project code against the blueprint's security architecture checklist
---

# /architect:security-scan

## Trigger

`/architect:security-scan`

## Purpose

After scaffolding projects with `/architect:scaffold`, this command validates that the generated code actually implements the security measures specified in the blueprint's security architecture (deliverable 4f). Checks auth middleware, CORS, rate limiting, helmet headers, input validation, and scans for hardcoded secrets.

## Workflow

### Step 1: Read Context

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` → product name for the scan report header
- `tech_stack` → auth provider (Clerk, Auth0, JWT, etc.), framework, ORM — used to tailor checklist items (e.g. Prisma → parameterized queries, Clerk → session token strategy)
- `components` → which components to scan (names + types)

**Also read from SDL** (Grep for `auth:` section — check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then `sdl/security.yaml` or `sdl/auth.yaml`):
- `auth.identityProvider` — the external identity provider (Cognito, Auth0, Clerk, custom) — used to tailor auth middleware checks (e.g. Cognito → JWKS validation, Clerk → session token, custom → JWT verify)
- `auth.serviceTokenModel` — how backend services validate tokens (jwt | session | api-key) — used to verify the correct validation mechanism is implemented in each service's middleware

**Then**, check if a blueprint with a security architecture (deliverable 4f) exists earlier in the conversation.

If no security checklist exists, respond:

> "I need a security checklist to scan against. Run `/architect:blueprint` first to generate your security architecture, then come back here to validate your code."

### Step 2: Ask for Project Path

> "Which project should I scan?"
>
> Provide the path to the scaffolded project directory. If multiple components were scaffolded, I can scan them all.

### Step 3: Delegate to Security Scanner Agent

Pass the following to the **security-scanner** agent:

- Security architecture from the blueprint (auth strategy, API security checklist, OWASP mitigations)
- Project directory path(s)
- Tech stack (framework, language)
- `auth.identityProvider` from SDL (e.g. Cognito, Auth0, Clerk, custom)
- `auth.serviceTokenModel` from SDL (e.g. jwt, session, api-key)

### Step 4: Print Summary

```
Security Scan Results — api-server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: 7/8 checks passed (87%)

| # | Check | Status | Details |
|---|-------|--------|---------|
| 1 | Auth middleware | [PASS] | JWT verification stub present |
| 2 | CORS | [PASS] | Explicit origins configured |
| 3 | Helmet headers | [PASS] | Security headers active |
| 4 | Rate limiting | [STUB] | TODO in code — implement before production |
| 5 | Input validation | [MISSING] | No schemas found — add Zod validation |
| 6 | SQL injection | [PASS] | Prisma ORM (parameterized) |
| 7 | .gitignore | [PASS] | .env excluded |
| 8 | Hardcoded secrets | [PASS] | None found |
| N | Token validation mechanism | [PASS/STUB/MISSING] | Matches auth.serviceTokenModel from SDL |

Recommendations:
1. [HIGH] Add Zod schemas for request body validation
2. [MEDIUM] Uncomment rate limiting in security middleware
```

### Final Step: Log Activity

Write the full scan report to `.archon/security/security-scan-<YYYY-MM-DD>.md` (create the directory if it does not exist). Using a dated filename preserves history — each run creates a new file so you can track whether findings are being resolved between scans.

Also write `.archon/security/.last-scan` with the ISO-8601 timestamp and path of the latest report:
```
2026-04-01T14:23:00Z .archon/security/security-scan-2026-04-01.md
```
This sentinel file is how Archon detects that the security-scan phase is complete.

Then append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"security-scan","outcome":"completed","files":[".archon/security/security-scan-<YYYY-MM-DD>.md"],"summary":"Security scan completed: <X>/<N> checks passed across <component> with <M> recommendations."}
```

Replace the placeholders with actual counts. Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

## Output Rules

- Use the **founder-communication** skill for tone
- Accept [STUB] as valid for scaffolded projects — TODOs are expected
- Flag [RISK] items prominently
- Provide specific fix suggestions for [MISSING] items
- This is READ-ONLY — never modify project files
- Do NOT include the CTA footer
