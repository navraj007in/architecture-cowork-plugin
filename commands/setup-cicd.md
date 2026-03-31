---
description: Configure real CI/CD pipelines in GitHub Actions, Azure Pipelines, or GitLab CI from the blueprint
---

# /architect:setup-cicd

## Trigger

`/architect:setup-cicd`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the DevOps blueprint (deliverable 4h) and configures real, working CI/CD pipelines. Creates workflow files, sets up deployment stages, and lists required secrets. Supports GitHub Actions (default), Azure Pipelines, and GitLab CI.

## Workflow

### Step 1: Read Context

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` → product name for workflow file comments
- `tech_stack.deployment` → default deployment target (Vercel, Railway, AWS, etc.) — pre-fill Step 2 question
- `tech_stack.frontend`, `tech_stack.backend` → framework detection for build commands (e.g. Next.js → `npm run build`, Go → `go build ./...`)
- `components` → list of components to configure pipelines for

**Then**, read `solution.sdl.yaml` and extract:
- Read `architecture.services[].dependsOn[]` from `solution.sdl.yaml` to determine service dependency order. Services with no dependents should build/deploy first. Services that depend on others should deploy after their dependencies are healthy. Include this ordering in the CI/CD pipeline job dependencies (`needs:` in GitHub Actions).

**Then**, check if a blueprint with a DevOps section (deliverable 4h) exists earlier in the conversation.

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

### Final Step: Log Activity

After writing all CI/CD workflow files, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"setup-cicd","outcome":"completed","files":[".github/workflows/ci.yml"],"summary":"Configured CI/CD pipelines for all components with lint, test, build, and deploy stages."}
```

Adjust the `files` array to list all workflow files actually created. Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

## Output Rules

- Use the **founder-communication** skill for tone
- Always check for existing CI config before overwriting
- Always include lint, test, build, and security scan stages
- List all required secrets — never embed real values
- Do NOT include the CTA footer
