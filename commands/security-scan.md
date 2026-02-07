---
description: Validate scaffolded project code against the blueprint's security architecture checklist
---

# /architect:security-scan

## Trigger

`/architect:security-scan`

## Purpose

After scaffolding projects with `/architect:scaffold`, this command validates that the generated code actually implements the security measures specified in the blueprint's security architecture (deliverable 4f). Checks auth middleware, CORS, rate limiting, helmet headers, input validation, and scans for hardcoded secrets.

## Workflow

### Step 1: Check for Security Architecture

Check if a blueprint with a security architecture (deliverable 4f) exists earlier in the conversation.

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

Recommendations:
1. [HIGH] Add Zod schemas for request body validation
2. [MEDIUM] Uncomment rate limiting in security middleware
```

## Output Rules

- Use the **founder-communication** skill for tone
- Accept [STUB] as valid for scaffolded projects — TODOs are expected
- Flag [RISK] items prominently
- Provide specific fix suggestions for [MISSING] items
- This is READ-ONLY — never modify project files
- Do NOT include the CTA footer
