---
description: Walk through third-party account setup, validate API keys, and write verified .env files
---

# /architect:setup-env

## Trigger

`/architect:setup-env`

## Purpose

After generating a blueprint and scaffolding projects, this command walks through setting up every third-party service account (from deliverable 4m — Required Accounts), validates API keys with live checks, and writes a working `.env` file for each project. Turns 60-90 minutes of manual setup into a guided, validated process.

## Workflow

### Step 1: Check for Required Accounts

Check if a blueprint with a Required Accounts list (deliverable 4m) or scaffolded projects with `.env.example` files exist.

If neither exists, respond:

> "I need a list of services to set up. Run `/architect:blueprint` first to identify required accounts, or `/architect:scaffold` to create projects with `.env.example` files, then come back here."

### Step 2: Show Setup Plan

Present the services in dependency order:

```
Here are the accounts you need to set up:

| # | Service | Category | Free Tier | Est. Time |
|---|---------|----------|-----------|-----------|
| 1 | Clerk | Auth | 10K MAU | 10 min |
| 2 | Neon | Database | 0.5 GB | 5 min |
| 3 | Upstash | Redis | 10K cmds/day | 5 min |
| 4 | Stripe | Payments | Test mode | 15 min |
| 5 | SendGrid | Email | 100/day | 10 min |
| 6 | Sentry | Monitoring | 5K errors/mo | 5 min |

Total estimated setup time: 50-60 minutes

I'll walk you through each one, validate your keys, and write the .env file.
Ready to start? (yes / skip to specific service)
```

### Step 3: Delegate to Env Setup Agent

Pass the following to the **env-setup** agent:

- Required Accounts table from the blueprint
- `.env.example` files from scaffolded projects
- Project directory path(s)
- Which services to set up (all, or specific ones if skipping)

### Step 4: Print Summary

```
Environment setup complete!

| Service | Status | Variables |
|---------|--------|----------|
| Clerk | [VALID] | 2 keys validated |
| Neon | [FORMAT OK] | DATABASE_URL set |
| Upstash | [FORMAT OK] | REDIS_URL set |
| Stripe | [VALID] | Secret key validated |
| SendGrid | [SKIPPED] | — |
| Sentry | [SKIPPED] | — |

Files written:
  ./api-server/.env (10 variables set, 2 skipped)
  ./web-app/.env (4 variables set)

Remaining TODOs:
  - Sign up for SendGrid and add SENDGRID_API_KEY
  - Sign up for Sentry and add SENTRY_DSN

Run `/architect:setup-env` again anytime to configure skipped services.
```

## Output Rules

- Use the **founder-communication** skill for tone
- Walk through one service at a time — don't overwhelm
- Always validate keys before writing
- Never display full API keys (mask middle characters)
- Always verify .gitignore before writing .env
- Do NOT include the CTA footer
