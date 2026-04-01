---
description: Full architecture blueprint — diagrams, costs, complexity, specs, and next steps
---

# /architect:blueprint

## Trigger

`/architect:blueprint [optional description of the idea]`

## Workflow

Follow these steps in order. Do not skip steps. Do not generate deliverables before understanding requirements.

### Step 0: Check for Pre-loaded Context (Headless Mode)

Before starting, check if a file named `.arch0-context.json` exists in the current working directory. Read it using the file system.

If it exists and contains an `intent` object with project requirements:
- **This is headless mode** — the user has already answered all questions via the arch0 Studio wizard.
- Load the project name, description, and all intent fields (personas, features, stack, constraints, preferences, budget, timeline).
- Print a brief confirmation: "Loading project context from .arch0-context.json — skipping interactive questions."
- **Skip Steps 1 and 2 entirely** — go directly to Step 3 (Build the System Manifest) using the pre-loaded data.
- For any fields not provided in the context file, make reasonable assumptions and state them in the executive summary.

If the file does not exist or has no `intent` field, proceed with the interactive workflow below (Steps 1 and 2).

### Step 0.5: Detect Existing Blueprint

After Step 0, **before** gathering any requirements, check whether this project already has a blueprint or was previously imported:

1. Look for `solution.sdl.yaml` in the current working directory. If absent, check for an `sdl/` directory.
2. Look for `architecture-output/_state.json`.

**If neither file exists:** this is a fresh project — proceed normally to Step 1.

**If either file exists:** this project has already been blueprinted or imported. Do the following:

a) Read `architecture-output/_state.json` (if present) to get the summary. Also read the first 40 lines of the SDL (`solution.sdl.yaml`, or `sdl/README.md` + the core module if multi-file) for the solution name and component list.

b) Present a brief summary of what was previously designed:

```
Found an existing blueprint for: [project name]
  Components : [list component names and types]
  Tech stack : [frontend / backend / database summary]
  SDL file   : solution.sdl.yaml (or sdl/ directory)
  Deliverables: architecture-output/ ([N] files present)
```

c) Ask the user ONE question with four numbered options:

> "I found an existing blueprint. What would you like to do?
> 1. **Update** — tell me what changed and I'll regenerate only the affected sections
> 2. **Deepen** — same requirements, but go deeper on specific sections to add more detail
> 3. **Full regenerate** — re-run the complete blueprint from scratch (overwrites everything)
> 4. **Cancel** — keep the existing blueprint unchanged"

**Option 1 — Update mode:**
- Ask: "What has changed? (e.g. added a new service, changed the tech stack for payments, updated the budget)"
- Based on the answer, determine the minimal set of deliverables to regenerate:
  - New / changed component → re-run Steps 3, 3.5, and the relevant deliverables: 4b, 4c, 4d, 4e, 4o (sprint backlog)
  - Changed tech stack → re-run Steps 3, 3.5 and: 4c, 4e, 4g, 4h, 4i (cost)
  - Changed requirements / personas → re-run Steps 2–3.5 and: 4a, 4l, 4m, 4n, 4o
  - Changed budget / timeline → re-run: 4i, 4j, 4n
  - Anything structural (auth, database, integrations) → re-run Steps 3, 3.5 and: 4d, 4e, 4f, 4k
- Tell the user which deliverables will be regenerated and which will be preserved.
- Proceed to regenerate only those deliverables.
- For `_state.json` (Step 4.5): **merge** the updated fields — do not overwrite fields owned by other commands (`entities`, `personas`, `market_research`, `mvp_scope`, `top_risks`, `design` if design-system has already run).

**Option 2 — Deepen mode:**

The architecture hasn't changed — the user wants richer, more detailed output on top of what was already generated. Multiple deepen passes are explicitly supported; each pass can expand different sections.

- Ask: "Which sections would you like to go deeper on? For example:
  - **API specs** — full OpenAPI with all error codes, edge cases, pagination
  - **Sprint backlog** — expand stories with more acceptance criteria, sub-tasks, effort breakdowns
  - **Security** — threat model per endpoint, OWASP mitigations with code examples
  - **Data model** — full entity relationships, indexes, constraints, migration scripts
  - **Architecture** — add sequence diagrams for each core flow, detailed error propagation paths
  - **Cost** — per-environment cost breakdown, scaling thresholds, cost-per-user projections
  - **DevOps** — full GitHub Actions YAML, Dockerfile examples, environment config tables
  - **All of the above** — run a full depth pass on every section"

- Read the existing deliverable file(s) for the selected sections **before** regenerating — use the existing content as a baseline, not a blank slate.
- Produce an enriched version that:
  - Retains everything from the previous version
  - Adds the detail that was missing or summarised: concrete examples, edge cases, additional tables, code snippets, sequence diagrams, alternative approaches
  - Explicitly marks new content with a `<!-- deepened: pass N -->` comment at the top of each expanded section (where N = how many deepen passes have been run, tracked in `_state.json` under `blueprint.deepen_passes`)
- Write the enriched file back, overwriting the shallower version.
- Update `_state.json`: increment `blueprint.deepen_passes` (start at 1 if not present).
- Do **not** re-run Steps 1–3 in deepen mode — the SDL and manifest are unchanged.

**Option 3 — Full regenerate:**
- Confirm: "Understood — regenerating full blueprint and overwriting all existing files."
- Proceed with the full workflow from Step 1 as normal.

**Option 4 — Cancel:**
- Reply: "Blueprint unchanged. Run `/architect:blueprint` again when you're ready to update it." Then stop.

> **Never silently overwrite an existing `solution.sdl.yaml` or `architecture-output/` without first asking which option the user wants.**

### Step 1: Load Intent (if available)

**Before asking any questions**, check if the command argument contains a JSON object (starts with `{`). If it does, parse it as the intent. The JSON contains pre-gathered requirements with this structure:

```json
{
  "solution_name": "Name of the product",
  "description": "What the product does, who it's for, and what makes it valuable",
  "personas": ["end users", "admins"],
  "features": ["feature 1", "feature 2"],
  "stack": "preferred tech stack or empty string",
  "constraints": {},
  "preferences": {},
  "budget": "budget info or empty string",
  "timeline": "timeline info or empty string"
}
```

If a valid JSON intent is provided:
- Use its contents as the gathered requirements — **do not ask the user any questions from Step 2**
- Confirm your understanding in 2-3 sentences summarizing the intent, then proceed directly to Step 3
- Map the intent fields to requirements: `description` → idea, `personas` → user roles, `features` → core actions and feature list, `stack` → tech stack preference, `budget` → budget, `timeline` → timeline
- For any fields that are empty or missing, make reasonable assumptions and state them explicitly

Also check if an `intent.json` file exists in the current working directory — if it does, read it and use it the same way as above.

**Additionally, if SDL exists in the current working directory, read it now** — even if intent.json was already loaded. Check `solution.sdl.yaml` first; if absent, check for an `sdl/` directory and read `sdl/README.md` then the relevant module files. The SDL from a prior import or blueprint run contains confirmed technical details (exact frameworks, port numbers, auth strategy, databases, design tokens, observability state, environment URLs) that must be preserved in the new blueprint. When building the manifest in Step 3, treat the SDL as the authoritative source for all technical fields it contains — do not re-derive or overwrite them from intent.json or Step 2 answers. Only add or extend what the SDL is missing.

If neither inline JSON, `intent.json`, nor SDL is found, fall through to Step 2.

### Step 2: Gather Requirements (interactive fallback)

**Only run this step if no intent JSON was provided (inline or file).**

If the user provided a plain-text description in the command, confirm your understanding in one sentence. If no description was provided, ask:

> "What are you building? Describe your product idea in plain English — what it does, who it's for, and what makes it valuable."

Using the **architecture-methodology** skill, ask clarifying questions to understand:

- **Project type**: Is this an app, an AI agent, or a hybrid (app with AI features)?
- **User roles**: Who uses it? (end users, admins, API consumers, agents)
- **Core action**: What is the single most important thing a user does?
- **Integrations**: Payments, email, SMS, auth, maps, storage, analytics?
- **AI agents**: If applicable — what should the agent do, what tools, what LLM?
- **Tech stack preference**: Does the team have an existing stack (e.g. ".NET", "Python", "Angular")? If yes, use it. If no preference, recommend and explain why. For microservices, ask whether each service uses the same framework or different ones — capture framework **per service** for polyglot architectures (e.g. payment-service in .NET, analytics-service in Python). Every component must end up with an explicit `framework` field — never leave it blank or silently apply a global default.
- **Budget**: Monthly infrastructure budget and/or total development budget
- **Timeline**: When do you need this live?

Ask 2-3 questions at a time, not all at once. Skip questions the user has already answered. If the user says "just build it", make reasonable assumptions and state them explicitly.

### Step 3: Build the System Manifest

Using the **manifest-structure** skill, build a structured manifest covering:

- Project metadata (name, type, description)
- User roles and expected counts
- Frontends (type, **framework** — explicit value required e.g. `nextjs`/`react-vite`/`angular`/`vue`/`svelte`, key pages, build tool, routing, data fetching, component library, styling, backend connections, client-side auth, monitoring, deploy target)
- Mobile apps if applicable (**framework** — explicit value required e.g. `react-native`/`flutter`/`swift`/`kotlin`, build platform, navigation, push notifications, deep linking, permissions, OTA updates, real-time provider)
- Backend services (type, **framework** — explicit value required per service e.g. `nodejs`/`dotnet`/`python-fastapi`/`go`/`java-spring`/`django`/`ruby-rails` — every service gets its own field, never share a global default without confirming, responsibilities)
- Databases (type, purpose, key collections)
- Integrations (category, service, purpose)
- AI agents if applicable (orchestration, tools, memory, guardrails)
- Shared types and reusable components across services
- Application patterns (architecture style, folder conventions, DI, error handling)
- Communication patterns between components (protocol, auth, data format, retry strategy)
- Security architecture (auth strategy, API security, data protection, OWASP)
- Observability (logging, metrics, health checks, alerting)
- DevOps (CI/CD pipeline, branch strategy, database migrations, environment strategy)
- Deployment targets

Do not show the raw manifest to the user unless they ask. Use it internally to generate deliverables.

### Step 3.5: Generate SDL Document

After building the system manifest, convert it to a validated SDL (Solution Design Language) document using the **sdl-knowledge** skill.

**Process:**

1. **Map the manifest to SDL** using the manifest-to-SDL mapping:
   - Map project metadata → `solution` (name, description, stage)
   - Map user roles → `product.personas` (each with name and goals)
   - Map frontends/services → `architecture.projects` (frontend, backend, mobile)
   - Map shared types and domain objects from the manifest → `domain.entities[]` (PascalCase entity names only — e.g. User, Order, Product. No fields here, just names)
   - Infer `architecture.style`: single backend → `modular-monolith`, 2+ → `microservices`, functions → `serverless`
   - Map databases → `data` (primary + secondary)
   - Map integrations → `integrations` and `auth` sections
   - Map deployment targets → `deployment.cloud`
   - Map constraints (budget, team, timeline) → `constraints`
   - Map communication patterns between services → `interServiceCommunication[]` (pattern, from, to, async)
   - Map error handling strategy from application patterns → `errorHandling` (strategy, errorFormat, retryPolicy)
   - Map config management from devops/application patterns → `configuration` (strategy, secretsManagement)
   - Map environments (dev, staging, prod) → `environments[]` with `url` (primary URL), `services[].name` + `services[].url` (per-service base URLs)
   - Set `artifacts.generate` for a full blueprint:
     ```
     architecture-diagram, sequence-diagrams, openapi, data-model,
     repo-scaffold, adr, backlog, deployment-guide, cost-estimate
     ```

2. **Validate mentally** against the 5 conditional rules:
   - Microservices → needs 2+ services
   - OIDC → needs provider
   - PII → needs encryptionAtRest
   - CloudFormation → only with AWS
   - MongoDB → no EF Core

3. **Apply normalization mentally** — note what the normalizer would infer (runtime from cloud, ORM from framework+DB, etc.) but do not manually set those fields

4. **Check for warnings:**
   - Microservices with small team
   - Aggressive timeline vs scope
   - Multi-persona without auth
   - Budget vs infrastructure mismatch

5. **If warnings exist**, briefly report them to the user before proceeding:
   - "Before generating deliverables, a few things to note: [warning messages]"
   - Ask if they want to adjust, or proceed with the current architecture

6. **If a conditional rule would fail**, fix it:
   - Adjust the interpretation of the manifest
   - If ambiguous, ask ONE clarifying question

7. **Save the SDL file to the project root directory** as `solution.sdl.yaml`. Do not place it inside `architecture/`, `artifacts/`, or any subfolder. This filename is the canonical SDL name used by all commands — never write `sdl.yaml`.

**If `solution.sdl.yaml` already existed** (from a prior import or blueprint run): merge the newly generated SDL into it — preserve any fields the new manifest doesn't cover (e.g. `x-confidence` annotations, `x-evidence` fields, `observability` detail, `errorHandling`, `configuration`, `interServiceCommunication` that were reverse-engineered during import). The rule is: blueprint-generated fields take precedence for architecture decisions; import-detected fields take precedence for implementation reality (ports, exact library versions, hardening state).

**Do not show raw SDL to the user unless they ask.** Use it internally to drive consistent deliverable generation. Confirm: "Architecture spec saved to `./solution.sdl.yaml`"

**SDL drives these deliverables deterministically:**
- 4b: Architecture Diagrams — solution architecture + service communication + agent flow (from `architecture` + `data` + `auth` + `integrations`)
- 4e: API Artifacts (from `architecture.projects.backend` + `auth`)
- 4i: Cost Estimate (from `deployment` + `data` + `integrations`)
- 4o: Sprint Backlog (from `product.personas` + `coreFlows` + `architecture`)

**SDL provides structured input for LLM-enhanced deliverables:**
- 4a: Executive Summary (SDL summary as foundation)
- 4c: Application Architecture (from `architecture.style` + `projects`)
- 4d: Shared Types (from `architecture.sharedLibraries`)
- 4f: Security Architecture (from `auth` + `nonFunctional.security`)
- 4g: Observability (from `observability` section)
- 4h: DevOps Blueprint (from `deployment.ciCd` + `infrastructure`)
- 4j: Complexity Assessment (from `constraints` + architecture complexity)
- 4k: Well-Architected Review (from `nonFunctional` + `deployment`)
- 4l: Plain English Specs (from `product.personas` + `coreFlows`)
- 4m: Required Accounts (from `integrations` + `auth.identityProvider` + `deployment.cloud`)
- 4n: Next Steps Guide (from `constraints.team` + `budget` + `timeline`)

### Step 4: Generate Deliverables

Generate each deliverable in this order:

#### 4a. Executive Summary

One-page overview containing:
- What the product does (2-3 sentences, plain English)
- Key components (bulleted list)
- Estimated monthly cost range (low / medium / high)
- Complexity score (X/10 with label)
- Top 3 risks or considerations
- Architecture pattern and key design principles
- Recommended build approach

#### 4b. Architecture Diagrams

Using the **diagram-patterns** skill, generate the following diagrams:

1. **Solution Architecture Diagram** (always) — Full system topology showing all layers: clients (web, mobile, admin), ingress (CDN, API gateway), application services, messaging (queues, event bus), data stores (databases, cache, search), object storage, and external integrations. This is the primary "big picture" diagram.

2. **Service Communication Diagram** (when 2+ backend services or modular-monolith with 3+ modules) — Shows how backend services communicate with each other: sync calls (REST/gRPC with endpoints), async events (pub/sub with event names), and queue-based processing. Label arrows with protocols and specific endpoints/events.

3. **Agent Flow Diagram** (when AI agents exist) — Shows agent orchestration, tool usage, and guardrails.

For all diagrams:
- Use the standard color conventions (blue=frontend, green=service, orange=database, purple=external, red=AI/LLM, teal=queue, light-blue=gateway)
- Label every connection with the communication pattern or protocol
- Include technology names on every component

#### 4c. Application Architecture & Patterns

Using the **manifest-structure** skill's architecture pattern and folder convention types:

- **Architecture pattern** — Which pattern fits this product (clean architecture, hexagonal, modular monolith, etc.) and why. Explain in plain English first, then technical rationale.
- **Folder structure** — Recommended folder convention with an example directory tree for the primary service.
- **Key principles** — 3-5 design principles the codebase should follow (e.g. dependency inversion, single responsibility, fail fast at boundaries).
- **Error handling strategy** — How errors flow between layers, services, and to the user.
- **Testing strategy** — What types of tests are needed (unit, integration, contract, e2e) and where they add the most value.

If multiple services share the same codebase pattern, state it once and note which services follow it. If a service needs a different pattern (e.g. a worker vs an API), explain why.

#### 4d. Shared Types & Cross-Service Contracts

Using the **manifest-structure** skill's shared section:

- **Shared types** — List the core domain types (e.g. User, Order, Ticket) that appear in more than one service. For each: name, key fields, and which services use it.
- **Shared libraries** — If services share validation logic, utility functions, or type definitions, recommend a shared package (e.g. `@project/shared-types`, `@project/validators`).
- **Service contracts** — For each service-to-service connection, define the contract type (OpenAPI, event schema, Protobuf, GraphQL schema). Specify who owns the contract and how changes are coordinated.
- **Inter-service communication detail** — For each connection in the communication section: protocol, authentication method, data format, retry/failure strategy, and whether it's sync or async.

Present as a table for quick scanning:

| From | To | Pattern | Protocol | Auth | Data Format | Sync/Async |
|------|----|---------|----------|------|-------------|------------|

#### 4e. API Artifacts

Using the **api-artifacts** skill, generate ready-to-use API documentation and testing artifacts for every REST/GraphQL service in the manifest:

**For each REST API service:**

- **OpenAPI 3.1 specification** (YAML) — Complete spec with paths, request/response schemas, auth schemes, error responses, and server URLs. Derive endpoints from the service's responsibilities and the shared types. Include example values for all fields.

- **Postman collection** (JSON) — Pre-configured collection with folders per resource, requests for all endpoints, environment variables for base URL and auth tokens, and pre-request scripts for auth. Include example request bodies.

**For event-driven / message queue connections:**

- **AsyncAPI 2.6 specification** (YAML) — Channel definitions for each message queue or event bus connection. Include message schemas derived from shared types and event contracts.

**For GraphQL services:**

- **GraphQL schema** — Type definitions, queries, mutations, and subscriptions derived from the manifest.

**Artifact summary table:**

| Artifact | Service | Format | What It Covers |
|----------|---------|--------|----------------|
| OpenAPI spec | api-server | YAML | All REST endpoints, schemas, auth |
| Postman collection | api-server | JSON | Pre-built requests, env vars, examples |
| AsyncAPI spec | worker-service | YAML | Event channels, message schemas |

Include a note explaining how to use each artifact:
- OpenAPI → import into Swagger UI, Redoc, or Stoplight for interactive docs
- Postman → import into Postman app for immediate API testing
- AsyncAPI → import into AsyncAPI Studio for event documentation

#### 4f. Security Architecture

Using the **operational-patterns** skill:

- **Auth strategy** — Read `auth.identityProvider` for the external IdP (Cognito, Auth0, Clerk) and `auth.serviceTokenModel` for how services validate tokens (jwt, session, api-key). Explain both in plain English — they are often different (e.g. Cognito issues tokens, services validate them as JWTs).
- **API security checklist** — Table of security measures each service must implement (rate limiting, input validation, CORS, helmet headers, etc.) with priority level (must-have / should-have).
- **Data protection** — Encryption at rest and in transit, PII field identification, secrets management approach, data retention policy.
- **OWASP considerations** — Top threats relevant to this specific architecture and how each is mitigated. Don't list all 10 — focus on the ones that actually apply.

Present the security checklist as a table:

| Protection | Implementation | Applies To | Priority |
|-----------|---------------|------------|----------|

#### 4g. Observability & Monitoring

Using the **operational-patterns** skill:

- **Logging strategy** — Structured logging format, log levels, what to log, what never to log. Recommend a logging provider based on project stage.
- **Health checks** — Define `/health` and `/health/ready` endpoints for each service, including which dependencies they verify.
- **Key metrics** — Table of metrics to track with alert thresholds (error rate, latency p99, queue depth, etc.).
- **Monitoring stack** — Recommended tools for logging, error tracking, and alerting at the project's current stage. Include cost.
- **Tracing** — Whether distributed tracing is needed (usually not for MVP, essential for multi-service production). If yes, recommend OpenTelemetry setup.

Scale recommendations to the project's complexity — don't prescribe Datadog + PagerDuty for an MVP.

#### 4h. DevOps Blueprint

Using the **operational-patterns** skill:

**CI/CD Pipeline:**
- **Provider** — Recommended CI/CD tool (usually GitHub Actions)
- **Pipeline stages** — Diagram or table showing: lint → test → build → security scan → deploy
- **Branch strategy** — Which branching model and why (github-flow for most startups, trunk-based for mature teams)
- **Environment promotion** — Flow from feature branch → staging → production

**Database Migrations:**
- **Migration tool** — Based on the tech stack (Prisma Migrate, Alembic, Knex, etc.)
- **Strategy** — Versioned migrations, rollback approach, zero-downtime patterns
- **Seed data** — Development seeds (faker data) and staging seeds (anonymized prod subset)

**Environment Strategy:**
- **Environments** — Table of environments (local, dev, staging, production) with purpose, data source, access, and deploy trigger
- **Config management** — How environment variables and secrets are managed per environment
- **Feature flags** — Whether needed, and if so which approach (env vars, LaunchDarkly, PostHog)

Present environments as a table:

| Environment | Purpose | Data | Deploy Trigger | Access |
|------------|---------|------|---------------|--------|

#### 4i. Cost Estimate

Using the **cost-knowledge** skill:

**Infrastructure & Services Breakdown** (show as detailed table):
- List EVERY service from the manifest's integrations and deployment targets
- Break down by category: Hosting, Database, Auth, Storage, Email, Monitoring, Third-party APIs, AI/LLM (if applicable)
- Show 3 scenarios: Low (free tiers), Medium (starter tiers), High (production tiers)
- Include specific tier names (e.g., "Vercel Hobby $0" vs "Vercel Pro $20")
- Show monthly and first-year totals for each scenario

**Development Costs** (add as separate section):
- Estimated development time in weeks based on complexity score
- Three options: Solo developer rate ($50-150/hr), Contractor ($75-200/hr), Agency ($150-300/hr)
- Show ranges: Minimum (complexity × 2 weeks), Typical (complexity × 3 weeks), Maximum (complexity × 4 weeks)
- Total project cost ranges for each option

**Cost Optimization Tips** (minimum 5 specific tips):
- Each tip must reference a specific service from the breakdown
- Include quantified savings where possible (e.g., "Save $X/month by...")
- Prioritize by impact (highest savings first)

**Scale Warnings** (flag any services with sharp cost increases):
- Identify which services have steep pricing tiers
- State the usage threshold where costs jump significantly
- Provide mitigation strategies

#### 4j. Complexity Assessment

Using the **complexity-factors** skill:

**10-Factor Scoring Table** (must be comprehensive):
- Score all 10 factors (1-10 each) with detailed justification (2-3 sentences minimum per factor)
- Show weight percentage for each factor
- Calculate weighted contribution (score × weight)
- Use agent/hybrid weights if project type is agent or hybrid
- Show calculation formula explicitly

**Overall Score**:
- Show weighted sum calculation step-by-step
- Map to label: Simple (1-3), Moderate (4-5), Advanced (6-7), Very Advanced (8-10)
- Provide 2-3 sentences explaining what this score means for the project

**Risk Analysis** (mandatory if any factors score 7+):
- List each high-risk factor (7+) with:
  - Why it scored high (3-4 sentences)
  - Specific risks this introduces
  - Concrete mitigation strategies (not generic advice)
  - Estimated effort to mitigate

**Simpler Alternatives** (mandatory if overall score > 6):
- Suggest 2-3 specific ways to reduce complexity
- For each alternative, show:
  - What to remove or simplify
  - New projected complexity score
  - Trade-offs (what you lose)
  - Effort savings (in weeks)

**Build-Path Recommendation**:
- Based on score, recommend: solo developer, small team, experienced team, or agency
- Explain why this skill level is needed
- Estimate team size (1-5 developers)
- Suggest full-time vs part-time commitment

#### 4k. Well-Architected Review

Using the **well-architected** skill, evaluate the architecture across all 6 pillars:

1. **Operational Excellence** — CI/CD, observability, incident response, change management
2. **Security** — Auth, authorization, data protection, API security, secrets management
3. **Reliability** — Fault isolation, recovery, data durability, retries, scaling
4. **Performance Efficiency** — Response times, right-sizing, caching, async processing
5. **Cost Optimization** — Free tier usage, right-sizing, cost awareness, scaling economics
6. **Developer Experience** — Onboarding, local dev, type safety, testing, code organization

**For each pillar** (this must be thorough):

**Score** (1-5 with explicit label):
- 1 = Critical — Major gaps, unacceptable for production
- 2 = Needs Work — Significant gaps, requires attention before launch
- 3 = Adequate — Meets minimum requirements, room for improvement
- 4 = Good — Solid implementation, minor enhancements possible
- 5 = Excellent — Best practices implemented, production-ready

**Strengths** (minimum 2-4 bullets per pillar):
- Cite specific architecture decisions from the manifest
- Explain why each strength matters
- Reference industry best practices where applicable

**Gaps** (mandatory if score < 5, minimum 2-4 bullets):
- Identify specific missing elements
- Explain the risk or impact of each gap
- Prioritize by severity (Critical / Important / Nice-to-have)

**Recommendations** (minimum 3-5 specific actions per pillar):
- Each recommendation must be actionable (not "improve security", but "add rate limiting to API endpoints")
- Include implementation effort (hours or days)
- Show impact (High / Medium / Low)
- Suggest order of implementation (what to do first)

Present the pillar scores as a visual summary:

```
Operational Excellence  ████░  4/5
Security               ███░░  3/5
Reliability            ██░░░  2/5
Performance Efficiency ████░  4/5
Cost Optimization      █████  5/5
Developer Experience   ███░░  3/5

Overall: X.X/5 — [Rating]
```

End with a prioritized **Improvement Roadmap** table (minimum 8-12 items):

| Priority | Pillar | Action | Effort | Impact | Stage |
|----------|--------|--------|--------|--------|-------|
| P0 | Security | Add rate limiting to all API endpoints | 4 hours | High | Pre-launch |
| P0 | Reliability | Implement health checks with dependency verification | 3 hours | High | Pre-launch |
| P1 | Security | Set up secrets rotation for API keys | 2 days | Medium | Month 1 |
| ... | ... | ... | ... | ... | ... |

**Priority levels**:
- P0 = Must-have before launch (blocks production)
- P1 = Should-have in first month (important for stability)
- P2 = Nice-to-have in first quarter (improves experience)
- P3 = Future enhancement (optimize later)

**Stage guidance**:
- Pre-launch = Must complete before going live
- Month 1 = Complete within first 30 days of production
- Quarter 1 = Complete within first 90 days
- Ongoing = Continuous improvement

Match expectations to the project's stage — an MVP targeting 3/5 overall is healthy. A production system should target 4/5+.

#### 4l. Plain English Specifications

Using the **founder-communication** skill:
- Group features by component (frontend, backend, database, integrations)
- Write each feature as a user-facing description, not a technical spec
- Include acceptance criteria for key features
- Flag any features that are nice-to-have vs. must-have

#### 4m. Required Accounts

Using the **known-services** skill:
- List every third-party service needed
- For each: service name, signup URL, what credentials you'll get, free tier details
- Group by category (auth, payments, hosting, email, etc.)
- Estimate total setup time

#### 4n. Next Steps Guide

Provide 3 paths forward:

1. **Build with AI tools** — Using Cursor, Bolt, v0, or similar. Estimated cost: $20-100/mo for tools. Best for: technical founders who want to build it themselves. Timeline estimate.

2. **Hire a developer** — Freelancer or contractor. Estimated cost range. Where to find them (Upwork, Toptal, etc.). Key skills to look for. Timeline estimate.

3. **Hire an agency** — Development agency. Estimated cost range. What to include in the brief. Timeline estimate.

#### 4o. Sprint Backlog

**Output file:** Write the sprint backlog to `architecture-output/sprint-backlog.md`. If the file exceeds ~15KB, split into `architecture-output/sprint-backlog-1.md`, `sprint-backlog-2.md`, etc. This path is required — `sprint-status` reads from this exact location.

Using the manifest, complexity score, and deliverables above, break the build into time-boxed sprints:

**Sprint parameters:**
- Sprint duration: 2 weeks (default). Use 1-week sprints only if complexity ≤ 3.
- Derive total sprint count from the complexity score: Simple (1–3) → 2-4 sprints, Moderate (4–5) → 4-6 sprints, Advanced (6–7) → 6-10 sprints, Very Advanced (8–10) → 10-16+ sprints.
- Each sprint has a goal, a set of user stories/tasks, and a definition of done.

**Sprint 0 (always first):**
- Project setup, repo scaffolding, CI/CD pipeline, dev environment, .env configuration
- Auth provider setup, database provisioning, shared type packages
- Goal: "Every developer can clone, install, and run the project locally"

**Subsequent sprints — organize by dependency order:**
1. Data model & core API endpoints (entities that other features depend on)
2. Auth flow end-to-end (signup, login, protected routes)
3. Core user action (the #1 thing users do — identified in requirements gathering)
4. Secondary features (payments, notifications, admin dashboard)
5. AI agent integration (if hybrid/agent project)
6. Polish, testing, monitoring, launch prep

**For each sprint, provide:**

| Sprint | Goal | Key Deliverables | Dependencies |
|--------|------|-----------------|--------------|
| Sprint 0 | Dev environment ready | Repo setup, CI/CD, auth config, DB provisioning | None |
| Sprint 1 | Core data model | DB schema, CRUD endpoints, seed data | Sprint 0 |
| Sprint 2 | Auth & user flows | Signup, login, protected routes, role-based access | Sprint 1 |
| ... | ... | ... | ... |

**After the table, provide detailed user stories for EACH sprint** (minimum 4-6 stories per sprint):

**Format for each user story:**
```
Story #: [Short title]
As a [specific role]
I want to [specific action with details]
So that [clear business value/outcome]

Acceptance Criteria:
- [ ] Criterion 1 (specific, testable)
- [ ] Criterion 2 (specific, testable)
- [ ] Criterion 3 (specific, testable)

Estimate: [S/M/L or story points 1-8]
Dependencies: [Sprint X, Story Y]
```

**Parseable story index (required):** After ALL story cards for each sprint, add a compact checklist section that sprint-status can parse:

```
### Sprint N Stories — Status Tracking
- [ ] Story N.1: [Short title]
- [ ] Story N.2: [Short title]
- [ ] Story N.3: [Short title]
```

This section must use the exact `- [ ] Story N.N: Title` format so `/architect:sprint-status` can track completion. The full story cards above are for human reading; this section is for tooling.

**Example Sprint 1 stories:**
```
Story 1.1: User Registration
As a new user
I want to create an account with email and password
So that I can access the platform securely

Acceptance Criteria:
- [ ] Email validation prevents invalid formats
- [ ] Password requires 8+ characters with number and special char
- [ ] Confirmation email sent via Resend
- [ ] User redirected to onboarding after signup

Estimate: M (5 points)
Dependencies: Sprint 0 (auth provider configured)
```

**Technical tasks** (list separately for each sprint):
- Database migrations
- API endpoint implementations
- Third-party integrations
- Testing requirements
- Documentation updates

**Definition of Done** (for each sprint):
- All acceptance criteria met
- Unit tests passing (80%+ coverage)
- Integration tests written
- Code reviewed and merged
- Deployed to staging
- Product owner signoff

**Assumptions to state:**
- Team size (derive from complexity: 1 dev for Simple, 2-3 for Moderate, 3-5 for Advanced)
- Velocity assumption (state it's an estimate that should be calibrated after Sprint 1)
- Whether sprints assume full-time or part-time commitment
- Development hours per sprint (e.g., 40 hrs/week × team size × 2 weeks)

**Risk Buffer:**
- Add 20% contingency for Simple projects
- Add 30% contingency for Moderate projects
- Add 40% contingency for Advanced projects

End with: "This is a starting-point backlog. Expect to refine sprint scope after Sprint 1 based on actual velocity. Adjust story estimates and sprint allocation as the team calibrates its pace."

### Step 4.5: Write _state.json

After completing all deliverables, update `architecture-output/_state.json` with the compact project summary. This file gives downstream commands (scaffold, roadmap, risk-register, etc.) instant access to project facts without reading large files.

Read the SDL to extract these fields (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files). Then:
- If `_state.json` already exists: **read it first, then merge** the blueprint fields into it — do NOT overwrite fields owned by other commands (`entities`, `personas`, `market_research`, `mvp_scope`, `top_risks`, `design` if already set by design-system).
- If `_state.json` does not exist: write it fresh.

Write or merge:

```json
{
  "project": {
    "name": "<solution.name>",
    "description": "<solution.description>",
    "type": "app|agent|hybrid",
    "stage": "concept"
  },
  "tech_stack": {
    "frontend": ["<framework> <version>", "Tailwind CSS"],
    "backend": ["<runtime>", "<framework>", "<orm>"],
    "database": "<primary db type>",
    "auth": "<auth provider>",
    "deployment": "<cloud targets>",
    "integrations": ["<integration names>"]
  },
  "components": [
    { "name": "<component name>", "type": "<type>", "port": <port>, "framework": "<framework>" }
  ],
  "design": {
    "personality": "<personality from SDL design section or derived from domain>",
    "primary": "<hex>",
    "heading_font": "<font name>",
    "body_font": "<font name>"
  },
  "blueprint": {
    "deepen_passes": 0
  }
}
```

Rules:
- Write to `architecture-output/_state.json` (create `architecture-output/` if it doesn't exist)
- `entities`, `personas`, `market_research`, `mvp_scope`, `top_risks` are written by other commands — do NOT add them here
- If the SDL has a `design` section, use those values; otherwise derive from the product domain using the personality table in `/architect:prototype`
- `blueprint.deepen_passes` starts at `0` on first run; increment by 1 each time deepen mode completes

### Step 4.6: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"blueprint","outcome":"completed","files":["architecture-output/executive-summary.md","architecture-output/architecture-diagrams.md","architecture-output/sprint-backlog.md","solution.sdl.yaml","architecture-output/_state.json"],"summary":"Blueprint generated: <style> architecture, <N> components, complexity <score>/10, <sprint-count> sprints."}
```

List every file actually written in the `files` array.

### Step 5: CTA Footer

End the full blueprint with:

```
───────────────────────────────────────────────
This blueprint was generated by Architect AI (Cowork plugin).

For the full experience — validated schema, export zip, version tracking,
rendered diagrams, and .env templates — visit architectai.app
───────────────────────────────────────────────
```

## Output Length & Chunking

The full blueprint with all 15 deliverables is substantial. If you hit output limits:

1. **Generate deliverables in chunks** — Complete 4a-4e in the first response, then continue with 4f-4k, then 4l-4o
2. **Tell the user** — End each chunk with: "Continuing with the next section..." so they know more is coming
3. **Never skip deliverables** — Every deliverable must appear in the final output, even if split across messages
4. **Maintain numbering** — Keep the 4a-4o numbering consistent across chunks

## Output Rules

- Follow the **founder-communication** skill for tone and language
- Use Mermaid for all diagrams
- Show cost ranges, not point estimates
- Explain every acronym on first use
- Keep each section scannable — use tables, bullets, and headers
- Each deliverable should stand alone
- If any single output file exceeds ~15KB, split into numbered parts (e.g. `data-model-1.md`, `data-model-2.md`) and write an index file — never truncate or reduce detail
- Use tables instead of prose for structured data (entities, endpoints, config)
- See `references/example-blueprints.md` for output format examples
