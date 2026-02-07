---
description: Configure real CI/CD pipelines in GitHub Actions, Azure Pipelines, or GitLab CI from the blueprint
---

# /architect:setup-cicd

## Trigger

`/architect:setup-cicd`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the DevOps blueprint (deliverable 4h) and configures real, working CI/CD pipelines. Creates workflow files, sets up deployment stages, and lists required secrets. Supports GitHub Actions (default), Azure Pipelines, and GitLab CI.

## Workflow

### Step 1: Check for DevOps Blueprint

Check if a blueprint with a DevOps section (deliverable 4h) exists earlier in the conversation.

If no DevOps blueprint exists, respond:

> "I need a DevOps blueprint to configure from. Run `/architect:blueprint` first to generate your CI/CD pipeline design, then come back here to set it up."

### Step 2: Ask Configuration

Ask the user:

> "Which CI/CD platform?"
>
> - **GitHub Actions** (default) — Most common for GitHub repos
> - **Azure Pipelines** — For Azure DevOps projects
> - **GitLab CI** — For GitLab repos
>
> "Which project(s) should I configure?" (path or all scaffolded projects)
>
> "Where are you deploying?"
> - Vercel, Railway, AWS, Azure, GCP, Docker/self-hosted

### Step 3: Delegate to CI/CD Deployer Agent

Pass the following to the **cicd-deployer** agent:

- DevOps blueprint (pipeline stages, branch strategy, environments)
- CI/CD platform choice
- Project directory path(s)
- Tech stack per component
- Deployment targets
- Whether to configure branch protection

### Step 4: Print Summary

```
CI/CD pipeline configured!

| Component | Platform | Workflows | Deploy Target |
|-----------|----------|-----------|---------------|
| api-server | GitHub Actions | ci.yml, deploy.yml | Railway |
| web-app | GitHub Actions | ci.yml | Vercel |

Pipeline: Lint → Test → Build → Security Scan → Deploy
Branch strategy: GitHub Flow

Required secrets (set via gh secret set):
  VERCEL_TOKEN, RAILWAY_TOKEN, DATABASE_URL (production)

Files created:
  .github/workflows/ci.yml
  .github/workflows/deploy.yml
```

## Output Rules

- Use the **founder-communication** skill for tone
- Always check for existing CI config before overwriting
- Always include lint, test, build, and security scan stages
- List all required secrets — never embed real values
- Do NOT include the CTA footer
