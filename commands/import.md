---
description: Reverse-engineer architecture from an existing codebase — generates SDL and analysis
---

# /architect:import

## Trigger

`/architect:import [scan context JSON]`

## Purpose

Analyze an existing codebase folder. Using the static scan results (detected
tech stack, frameworks, databases, etc.) as a starting point, perform a deep
analysis of the actual source code to understand the architecture, then
generate:

1. `solution.sdl.yaml` — A complete SDL capturing the inferred architecture
2. `architecture-output/import-analysis.md` — Detailed findings report
3. `intent.json` — Derived project intent for lifecycle continuity

## Workflow

### Step 1: Load Scan Context

The command argument may contain a JSON object with static scan results
from a codebase scanner. Parse it to understand what technologies,
frameworks, databases, and infrastructure are already in use.

If no scan context is provided, perform your own analysis by reading directory
listings and key config files (package.json, requirements.txt, go.mod, etc.).

### Step 2: Deep Source Analysis

Using the scan results as a guide, read the actual source code to understand
the system architecture. Read a **representative sample** of source files —
do not attempt to read every file. Focus on architecturally significant code:

**Priority reads:**
- Entry points (index.ts, main.ts, app.ts, server.ts, manage.py, main.go)
- Route/controller definitions (routes/, controllers/, api/)
- Database models/schemas/migrations (models/, prisma/schema.prisma, migrations/)
- Middleware and auth setup (middleware/, auth/)
- Configuration files (config/, .env.example)
- Docker and deployment configs (Dockerfile, docker-compose.yml, terraform/)
- README.md for project context and purpose
- CI/CD pipeline definitions (.github/workflows/)

**Determine:**
- **Architecture style**: monolith, modular monolith, microservices, serverless, or hybrid
- **Service boundaries**: distinct services/modules and their responsibilities
- **Data flow**: how data flows between components, key API contracts
- **Database schema**: entities, relationships, indexes from migration files or ORM schemas
- **Auth flow**: authentication and authorization implementation
- **API surface**: endpoints, REST/GraphQL/gRPC/WebSocket
- **Component structure**: for frontends — page/component structure, state management
- **Testing patterns**: test structure, coverage approach, frameworks in use
- **Deployment model**: how the app is deployed, environments, CI/CD

### Step 3: Generate SDL

Using the **sdl-knowledge** skill, build a complete SDL document:

1. **Map discovered architecture to SDL sections:**
   - Project metadata from README/package.json → `solution` (name, description, stage)
   - Detected services/modules → `architecture.projects` and `architecture.services`
   - Infer `architecture.style`: single backend → `modular-monolith`, 2+ services → `microservices`, Lambda/Cloud Functions → `serverless`
   - Detected database → `data.primaryDatabase` with correct `type` enum
   - Auth mechanism → `auth.strategy` and `auth.provider`
   - Deployment config → `deployment.cloud` and `deployment.runtime`
   - User roles from auth/RBAC code → `product.personas`
   - Routes/pages → `product.coreFlows`
   - Set `solution.stage` based on maturity signals:
     - Has CI/CD + monitoring + tests → `Growth` or `Enterprise`
     - Has CI/CD + some tests → `MVP` to `Growth`
     - Minimal infra → `MVP`

2. **Validate** against the 5 SDL conditional rules:
   - `microservices` requires 2+ services
   - `oidc` requires provider
   - `pii = true` requires encryption at rest
   - CloudFormation requires AWS
   - MongoDB incompatible with ef-core ORM

3. **Apply normalization** — let smart defaults fill gaps

4. **Add confidence markers** using SDL extension fields:
   ```yaml
   architecture:
     style: modular-monolith
     x-confidence: high
     x-evidence: "Single Express server with modular route files"
   ```

5. **Save to project root** as `solution.sdl.yaml` (NOT inside architecture-output/)

### Step 4: Generate Import Analysis

Write a comprehensive analysis to `architecture-output/import-analysis.md`:

```markdown
# Import Analysis: {Project Name}

## 1. Project Overview
What the project is, its purpose, and target users. Derived from README,
code comments, and structural analysis.

## 2. Technology Stack
| Category | Technology | Version | Confidence | Source |
|----------|-----------|---------|------------|--------|
Complete listing of all detected and inferred technologies.

## 3. Architecture Pattern
Identified pattern (e.g., modular monolith, microservices) with evidence:
- What structural signals support this classification
- How the code is organized
- Communication patterns between components

## 4. Service Map
Each service/module with:
- Name and responsibilities
- Key files and entry points
- Dependencies on other services
- API surface (endpoints, event handlers)

## 5. Data Model Summary
Key entities, relationships, and storage:
- Primary entities and their fields
- Relationships (one-to-many, many-to-many)
- Database type and ORM
- Migration strategy in use

## 6. API Surface
Discovered endpoints and contracts:
| Method | Path | Handler | Auth | Description |
|--------|------|---------|------|-------------|

## 7. Authentication & Authorization
Current auth implementation:
- Strategy (JWT, session, OAuth, API key)
- Provider (custom, Auth0, Clerk, etc.)
- Role/permission model
- Token storage and refresh

## 8. Infrastructure & Deployment
Current deployment setup:
- Hosting platform and compute
- Container setup (if any)
- CI/CD pipeline stages
- Environment strategy

## 9. Code Quality Signals
| Signal | Status | Details |
|--------|--------|---------|
| Type safety | | TypeScript strict mode, type coverage |
| Test coverage | | Test frameworks, test file ratio |
| Linting | | ESLint/Prettier/Ruff config |
| CI/CD | | Pipeline completeness |
| Documentation | | README, inline docs, API docs |

## 10. Architecture Observations
**Strengths:**
- What the codebase does well architecturally

**Concerns:**
- Potential issues, anti-patterns, or risks

**Technical Debt:**
- Areas that may need attention

## 11. Recommendations
Prioritized suggestions for improvement:
| Priority | Recommendation | Effort | Impact |
|----------|---------------|--------|--------|
```

### Step 5: Generate Intent

Write `intent.json` using the standard intent schema:

```json
{
  "intent": {
    "product_name": "from package.json name, README heading, or directory name",
    "vision": "inferred from README or code comments",
    "problem_statement": "Architecture reverse-engineered from existing codebase.",
    "target_users": [{
      "persona": "inferred from auth roles or UI structure",
      "needs": ["inferred from features"],
      "pain_points": ["inferred from code patterns"]
    }],
    "core_features": [
      {
        "feature": "inferred from routes/pages/handlers",
        "description": "what it does",
        "priority": "P0 or P1",
        "acceptance_criteria": ["derived from existing implementation"]
      }
    ],
    "non_functional_requirements": {
      "performance": { "concurrent_users": "inferred from infra" },
      "security": { "compliance": ["inferred from code patterns"] },
      "availability": { "uptime_sla": "inferred from deployment" }
    },
    "technical_constraints": {
      "preferred_stack": "the detected stack"
    },
    "business_constraints": {
      "timeline": { "mvp": "Already built" },
      "budget": { "initial_development": "N/A — existing codebase" }
    },
    "risks_and_assumptions": {
      "assumptions": ["list what was inferred vs confirmed"]
    }
  }
}
```

## Output Requirements

- Create `architecture-output/` directory if it does not exist
- Write SDL to `solution.sdl.yaml` in the project root (NOT inside architecture-output/)
- Write analysis to `architecture-output/import-analysis.md`
- Write intent to `intent.json` in the project root
- After writing all files, return a brief summary listing every file created
  and key findings
- If the codebase is too large to fully analyze, state assumptions explicitly
  and focus on the most architecturally significant parts

## Output Rules

- Use the **founder-communication** skill for tone — plain English, no jargon
  without explanation
- Use tables and structured sections for scannability
- Include confidence levels for all inferred architecture decisions
- Clearly distinguish between **detected** (from config/code) vs **assumed**
  (inferred/defaulted)
- Do not expose secrets, passwords, or API key values from .env files
- Keep the analysis actionable — every observation should have a recommendation
