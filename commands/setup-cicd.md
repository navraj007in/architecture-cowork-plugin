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

**Then**, read the SDL and extract `architecture.services[].dependsOn[]` to determine service dependency order. Services with no dependents should build/deploy first. Services that depend on others should deploy after their dependencies are healthy. Include this ordering in the CI/CD pipeline job dependencies (`needs:` in GitHub Actions). Check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module (typically `sdl/architecture.yaml` or `sdl/services.yaml`).

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

### Step 2.5: Check Existing Infrastructure (Optional)

Before delegating, silently probe the relevant MCP servers based on the deployment target chosen in Step 2:

**If deploying to AWS** — attempt `list_ec2_instances` (maxResults: 1) to check if AWS MCP is connected:
- If connected: call `list_ec2_instances`, `describe_rds_instances`, `list_lambda_functions` to surface existing resources. Pass this snapshot to the cicd-deployer agent so it can reference real cluster/function names in the generated pipeline config (e.g. actual ECS cluster name, actual ECR repo ARN).
- If not connected: proceed with blueprint values only.

**If deploying to Kubernetes** — attempt `list_namespaces` to check if Kubernetes MCP is connected:
- If connected: call `list_namespaces` and `list_deployments` to understand existing cluster state. Pass namespace list to cicd-deployer so K8s manifests target the correct namespace.
- If not connected: proceed with `default` namespace unless the blueprint specifies otherwise.

**If Terraform is in the stack** — attempt a Terraform MCP call (`terraform_show`) to check if the server is connected:
- If connected: note that generated `.tf` files will be validated via `terraform_validate` after writing.
- If not connected: skip Terraform validation.

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
