---
description: Check local environment readiness for the project — runtimes, databases, tools, credentials
---

# /architect:check-env

## Trigger

`/architect:check-env` — run after blueprint or scaffold to verify local machine is ready for development.

## Purpose

Scan the SDL specification and project files to determine what tools, runtimes, databases, and credentials are needed for local development. Check which are installed and which are missing. Generate an actionable readiness report with install commands for each platform (macOS, Ubuntu, Windows).

## Workflow

### Step 1: Read Project Requirements

Read in this order:

1. `architecture-output/_state.json` — read first if it exists; provides compact `tech_stack` (frontend frameworks, backend frameworks, database, auth, deployment, integrations) and `components` (name, type, port, framework). Use these to identify required runtimes, tools, and credentials — skip reading the full SDL if `_state.json` covers the needed fields.
2. **SDL file** — **only if `_state.json` is absent or lacks `tech_stack`/`components`**; check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Extract:
   - **Components** — for each component, note the `runtime`, `language`, `framework`, and `buildTool`
   - **Data section** — `primaryDatabase`, `cache`, `queue`, `search` — what data stores are needed
   - **Auth section** — what auth provider is configured (may need specific CLIs)
   - **Deployment section** — what cloud platform is targeted (may need specific CLIs)
   - **Infrastructure** — Docker Compose, Kubernetes, Terraform requirements

Also check:
- `package.json` → `engines.node` for required Node.js version
- `.python-version` or `pyproject.toml` for Python version
- `go.mod` for Go version
- `docker-compose.yml` existence
- `.env.example` for required credentials

### Step 2: Check Each Requirement

For each identified requirement, run the appropriate check command:

**Runtimes:**
| Runtime | Check Command | Version Parse |
|---------|--------------|---------------|
| Node.js | `node --version` | `v22.x.x` |
| Python | `python3 --version` | `3.x.x` |
| Go | `go version` | `go1.x.x` |
| Rust | `rustc --version` | `1.x.x` |
| Java | `java --version` | `x.x.x` |
| .NET | `dotnet --version` | `x.x.x` |
| Ruby | `ruby --version` | `x.x.x` |
| PHP | `php --version` | `x.x.x` |

**Package Managers:**
| Manager | Check Command |
|---------|--------------|
| npm | `npm --version` |
| yarn | `yarn --version` |
| pnpm | `pnpm --version` |
| bun | `bun --version` |
| pip | `pip3 --version` |
| cargo | `cargo --version` |

**Tools:**
| Tool | Check Command | When Required |
|------|--------------|---------------|
| Git | `git --version` | Always |
| Docker | `docker --version` | When databases or docker-compose exist |
| Docker Compose | `docker compose version` | When docker-compose.yml exists |

**Databases (check Docker containers OR local install):**
| Database | Docker Check | Local Check |
|----------|-------------|-------------|
| PostgreSQL | `docker ps \| grep postgres` | `psql --version` |
| MySQL | `docker ps \| grep mysql` | `mysql --version` |
| MongoDB | `docker ps \| grep mongo` | `mongosh --version` |
| Redis | `docker ps \| grep redis` | `redis-cli --version` |

**Cloud CLIs (only check if deployment target matches):**
| Platform | CLI | Check Command |
|----------|-----|--------------|
| AWS | `aws` | `aws --version` |
| Azure | `az` | `az --version` |
| GCP | `gcloud` | `gcloud --version` |
| Vercel | `vercel` | `vercel --version` |
| Netlify | `netlify` | `netlify --version` |
| Railway | `railway` | `railway --version` |
| Fly.io | `flyctl` | `flyctl version` |
| Cloudflare | `wrangler` | `wrangler --version` |

### Step 3: Check Credentials

Scan `.env.example` and `.env` files:
- List all required environment variables
- Check which are set in `.env`
- Flag any with placeholder values (`your_*_here`, `changeme`, `TODO`, etc.)

### Step 4: Generate Readiness Report

Write to `.archon/checks/env-readiness.md` (create the directory if it does not exist). This is a per-developer, per-machine artifact — it changes every run and belongs in `.archon/checks/` rather than `architecture-output/`.

```markdown
# Environment Readiness Report — [Project Name]
Generated: [date]

## Summary
- Status: [Ready / Needs attention / Missing requirements]
- X tools ready, Y missing, Z warnings

## Runtimes
| Tool | Status | Version | Required By | Install |
|------|--------|---------|-------------|---------|
| Node.js | ✓ Installed | 22.12.0 | api-server | — |
| Python | ✗ Missing | — | ml-worker | `brew install python` / `apt install python3` |

## Databases & Services
...

## Development Tools
...

## Credentials
| Variable | Status | Source |
|----------|--------|--------|
| DATABASE_URL | ✓ Configured | .env |
| STRIPE_SECRET_KEY | ⚠ Placeholder | .env.example |

## Quick Setup Script
\`\`\`bash
# macOS (Homebrew)
brew install node python docker
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=dev postgres
cp .env.example .env
# Then update placeholder values in .env
\`\`\`
```

### Step 5: Include Platform-Specific Install Commands

For each missing tool, provide install commands for:
- **macOS**: `brew install ...`
- **Ubuntu/Debian**: `sudo apt install ...`
- **Windows**: `choco install ...` or `scoop install ...`
- **Docker**: `docker run ...` for databases

### Final Step: Log Activity

After writing `.archon/checks/env-readiness.md`, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"check-env","outcome":"completed","files":[".archon/checks/env-readiness.md"],"summary":"Environment check: <X> ready, <Y> missing, <Z> warnings."}
```

## Output Rules

- Use **founder-communication** skill for clear descriptions
- Mark each item with status emoji: ✓ (installed), ✗ (missing), ⚠ (warning)
- Include a "Quick Setup Script" section with copy-pasteable commands
- Group by category (Runtimes, Databases, Tools, Credentials)
- Do NOT ask questions — detect everything automatically
- Do NOT include a CTA footer
