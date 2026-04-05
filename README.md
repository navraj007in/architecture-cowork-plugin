# Architect — Cowork Plugin

Turn product ideas into structured, buildable architecture blueprints. Generate SDL specifications, C4 diagrams, cost estimates, complexity scores, AI coding rules, and scaffold complete projects.

Built for founders. Useful for engineers.

## Installation

### Claude Code

```
/plugin marketplace add navraj007in/architecture-cowork-plugin
/plugin install architect@architect
```

### Cowork (Claude Desktop)

1. Open Claude Desktop → Cowork tab
2. Click "Plugins" in the left sidebar
3. Click "Upload plugin" and select the plugin folder

### Manual install from GitHub

```bash
git clone https://github.com/navraj007in/architecture-cowork-plugin.git
```

Then add the plugin directory in Claude Code's plugin settings or upload it in Cowork.

## Commands

| Command                            | Description                                                                       |
| ---------------------------------- | --------------------------------------------------------------------------------- |
| `/architect:blueprint`             | Full architecture blueprint — diagrams, costs, complexity, specs, and next steps  |
| `/architect:quick-spec`            | 5-minute lightweight architecture overview for idea validation                    |
| `/architect:import`                | Import an existing codebase — analyze structure, detect stack, generate SDL        |
| `/architect:sdl`                   | Generate, validate, diff, or browse SDL architecture specifications               |
| `/architect:refactor-stack`        | Coordinated architecture refactor — database, framework, provider change with consistency |
| `/architect:scaffold`              | Create project structure plan from a blueprint architecture                        |
| `/architect:scaffold-component`    | Scaffold a single component from the SDL with full starter code                    |
| `/architect:generate-tests`        | Generate unit, integration, and e2e test suites following testing patterns         |
| `/architect:setup-monitoring`      | Configure observability stack (metrics, tracing, logging, alerts, dashboards)      |
| `/architect:implement`             | Implement a user story or feature end-to-end into an already-scaffolded codebase   |
| `/architect:load-test`             | Generate load testing scenarios (k6/Locust) from API contracts                     |
| `/architect:review`                | Review code changes against the project's own patterns, best practices, and security |
| `/architect:cost-estimate`         | Infrastructure + third-party + LLM token cost breakdown                           |
| `/architect:complexity-check`      | Build difficulty assessment with 10-factor scoring                                |
| `/architect:agent-spec`            | AI agent architecture — orchestration, tools, guardrails, token costs             |
| `/architect:compare-stack`         | Side-by-side technology comparison with recommendation                            |
| `/architect:hiring-brief`          | Developer hiring package with role descriptions and interview questions           |
| `/architect:well-architected`      | Six-pillar well-architected review with scores and improvement roadmap            |
| `/architect:design-system`         | Design system generation — 11 personalities, diverse font pairs, dark mode, unconventional layouts, consumer/creative domains |
| `/architect:generate-data-model`   | Generate ORM schemas (Prisma, SQLAlchemy, Mongoose, Drizzle) from blueprint types |
| `/architect:setup-env`             | Walk through account setup, validate API keys, write verified .env files          |
| `/architect:setup-cicd`            | Configure real CI/CD pipelines in GitHub Actions, Azure Pipelines, or GitLab CI   |
| `/architect:security-scan`         | Validate scaffolded code against the blueprint's security checklist               |
| `/architect:compliance`            | Audit code for compliance gaps (SOC2, HIPAA, GDPR, PCI DSS) with remediation plans |
| `/architect:sync-backlog`          | Push sprint backlog into Azure DevOps or Jira as sprints and work items           |
| `/architect:publish-api-docs`      | Generate interactive API documentation (Swagger UI, Redoc, AsyncAPI)              |
| `/architect:generate-docs`         | Generate deployment runbooks, architecture guides, ADRs, and incident playbooks    |
| `/architect:export-diagrams`       | Render Mermaid diagrams to PNG/SVG with light and dark themes                     |
| `/architect:deep-research`         | Web-verified competitor analysis, market sizing, and differentiation map          |
| `/architect:launch-checklist`      | Pre-launch readiness checklist — infra, security, legal, analytics, go-live      |
| `/architect:onboarding-pack`       | Developer onboarding package for first hire or agency handoff                     |
| `/architect:investor-update`       | Stakeholder progress update pre-filled from CRs, ADRs, costs, and scaffold data  |

## What You Get

### From `/architect:blueprint` (flagship command)

A complete architecture blueprint with 15 deliverables:

1. **Executive Summary** — one-page overview with cost breakdown, complexity score, and architecture pattern
2. **Architecture Diagram** — C4 Container diagram in Mermaid, plus agent flow diagram if applicable
3. **Application Architecture & Patterns** — architecture pattern (clean, hexagonal, modular monolith, etc.), folder structure, design principles
4. **Shared Types & Cross-Service Contracts** — shared domain types, service contracts (OpenAPI, event schemas, Protobuf)
5. **API Artifacts** — OpenAPI/Swagger specs, Postman collections, AsyncAPI specs, GraphQL schemas
6. **Security Architecture** — auth strategy, API security checklist, data protection, OWASP threat mitigations
7. **Observability & Monitoring** — structured logging, health checks, metrics, alert thresholds, distributed tracing
8. **DevOps Blueprint** — CI/CD pipeline, branch strategy, environment definitions, config management
9. **Cost Estimate** — infrastructure + third-party + LLM token costs in low/medium/high scenarios
10. **Complexity Assessment** — 10-factor scoring with risk flags and simpler alternatives
11. **Well-Architected Review** — 6-pillar evaluation with per-pillar scores and improvement roadmap
12. **Plain English Specifications** — features written for non-technical stakeholders
13. **Required Accounts** — every third-party service with signup URL, setup steps, and free tier details
14. **Next Steps Guide** — 3 paths forward: build with AI tools, hire a developer, or hire an agency
15. **Sprint Backlog** — time-boxed sprint plan with goals, user stories, and dependencies

### From `/architect:import`

Analyze an existing codebase and generate an SDL specification from it. Detects runtime, framework, database, auth strategy, API patterns, and project structure. Produces a multi-file SDL that captures the existing architecture.

### From `/architect:refactor-stack`

Perform a coordinated architecture refactor when changing databases, frameworks, cloud providers, or other major components. Unlike UI-only patches, this ensures **full SDL consistency** across all affected sections:

- **Parse natural language requests** — "postgres to mongodb", "express to fastapi", "vercel to railway"
- **Validate impact** against 20+ SDL validation rules
- **Systematically rewrite affected sections** — data, ORM, entities, deployment, etc.
- **Generate changelog** — detailed markdown documenting all changes and rationale
- **Flag regeneration needs** — clearly lists which artifacts need to be regenerated (data-model, blueprint, cost-estimate, etc.)
- **Provide rollback instructions** — git commands to safely revert if needed
- **Track cross-cutting impacts** — when changing database, automatically updates ORM compatibility, deployment assumptions, cost model, and migration strategy

**Workflow:**
1. Read existing `solution.sdl.yaml`
2. Parse the change request (natural language or structured)
3. Plan impact across all dependent sections
4. Validate new architecture against constraints
5. Rewrite affected SDL sections
6. Generate changelog with next steps
7. Log activity and flag what needs regeneration

This prevents the fragmentation that happens when only a few SDL fields are updated without checking side effects.

### From `/architect:scaffold-component`

Scaffold a single component from the SDL with:
- Framework-appropriate starter code
- Package manifest with `dev` and `start` scripts
- Dockerfile and docker-compose.yml
- .env.example with all required variables
- CI workflow
- AI coding rules (CLAUDE.md, .cursorrules, copilot-instructions.md)
- Scaffold manifest for progress tracking

Files are created at the exact path specified in the SDL's `path` field for the component.

### From `/architect:design-system`

Generate a complete design system from the SDL's design section:
- Design tokens (colors, typography, spacing, shadows)
- Component library setup (Tailwind, Chakra, MUI, etc.)
- Palette generation with accessibility compliance
- Typography scale with font family selection
- Domain-appropriate color recommendations

### From `/architect:deep-research`

Web-verified market intelligence using Claude's WebSearch and WebFetch tools:
- **Competitor landscape** — 5-8 direct competitors with verified pricing, funding, features, and weaknesses
- **Market sizing** — TAM/SAM/SOM with sourced estimates and confidence tags ([Verified]/[Estimated])
- **Feature comparison matrix** — your product vs competitors across key dimensions
- **Opportunity gaps** — underserved market segments and missing features
- **Technology trends** — relevant industry and adoption trends
- All claims sourced with URLs and data freshness dates

### From `/architect:launch-checklist`

Pre-launch readiness checklist tailored to your SDL and deployment config:
- Infrastructure (DNS, SSL, CDN, auto-scaling)
- Monitoring (error tracking, APM, alerts, health checks)
- Security (secrets rotation, CORS, rate limiting, OWASP)
- Data (backups, migrations, retention policy)
- Legal (privacy policy, ToS, cookie consent, GDPR/CCPA)
- Analytics, performance, documentation, and go-live readiness
- Items tagged [Required]/[Recommended]/[Optional] based on project stage

### From `/architect:onboarding-pack`

Developer onboarding document for first hire or agency handoff:
- Architecture overview with component diagram (Mermaid)
- Codebase map (component → directory → purpose → tech)
- Step-by-step environment setup with copy-pasteable commands
- Key decisions summarized from ADRs
- Coding conventions from CLAUDE.md/.cursorrules
- Component dependency graph and glossary

### From `/architect:investor-update`

Stakeholder progress report pre-filled from project data:
- Features shipped (from applied Change Requests)
- Architecture decisions (from ADRs)
- Technical progress (from scaffold report)
- Infrastructure costs (from cost estimate)
- Risks and blockers (from complexity/security scans)
- Next priorities and team/hiring needs

## Solution Design Language (SDL)

SDL is the structured YAML specification that captures all architecture decisions. For the full specification, schema, and reference implementation, see the [SDL repository](https://github.com/navraj007in/solution-definition-language).

### Modular SDL Structure

```yaml
# solution.sdl.yaml (main file — core only)
sdlVersion: "0.1"

solution:
  name: MyProduct
  description: Brief description
  stage: mvp

architecture:
  projects:
    backend: [...]
    frontend: [...]

data:
  primaryDatabase:
    type: postgres
    hosting: managed

imports:
  - sdl/product.sdl.yaml      # Personas, flows, screens
  - sdl/auth.sdl.yaml         # Auth strategy and roles
  - sdl/deployment.sdl.yaml   # Cloud, CI/CD, environments
  - sdl/nfr.sdl.yaml          # Performance, security, availability
```

**Module files** contain optional/extended sections:
- `sdl/product.sdl.yaml` — personas, coreFlows, screens
- `sdl/auth.sdl.yaml` — authentication & authorization
- `sdl/deployment.sdl.yaml` — infrastructure, CI/CD
- `sdl/nfr.sdl.yaml` — non-functional requirements
- `sdl/integrations.sdl.yaml` — third-party services (optional)

The system automatically resolves and merges imports into a complete architecture specification.

### SDL Templates (12)

| Template | Description |
|---|---|
| SaaS Starter | Multi-tenant SaaS with auth, billing, dashboard |
| E-Commerce | Product catalog, cart, checkout, payments |
| Marketplace | Two-sided marketplace with Stripe Connect |
| Mobile App API | REST/GraphQL API for mobile clients |
| AI Chat App | Conversational AI with RAG and streaming |
| Internal Tool | Admin dashboard with RBAC and workflows |
| API Only | Headless API service with documentation |
| Event-Driven Microservices | Async messaging with queues and event sourcing |
| Real-Time Collaboration | WebSocket-based collaborative editing |
| Admin Dashboard | Data management with charts and reports |
| Landing Page | Marketing page with analytics and forms |
| Portfolio Blog | Static site with CMS and portfolio |

### SDL → AI Coding Rules

Generated from SDL for all major AI coding tools:

- **CLAUDE.md** — Claude Code / Claude Agent SDK
- **.cursor/rules/architecture.mdc** — Cursor IDE
- **.github/copilot-instructions.md** — GitHub Copilot
- **.aider/conventions.md** — Aider

Rules are framework-aware (Node.js, Python, Go, .NET, Java, Rust, Ruby, PHP) and include architecture boundaries, data access patterns, auth rules, API conventions, testing strategy, security checklist — 27+ rule categories.

Per-component rules generated at each component's `path` from the SDL, supporting multi-repo setups.

### SDL → Hard Enforcement (Optional)

Generate linter configs, architecture tests, and CI gates from the SDL:
- ESLint rules (TypeScript/JS)
- Ruff + Mypy config (Python)
- golangci-lint rules (Go)
- dependency-cruiser module boundary enforcement
- Architecture conformance tests (ArchUnit, NetArchTest)
- CI gate workflow (GitHub Actions)

## Skills

The plugin includes 29 domain knowledge skills:

| Skill                          | What It Contains                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| **Architecture Methodology**   | Structured requirements gathering framework, manifest building process, output quality rules                              |
| **Manifest Structure**         | Canonical system manifest format with all enumerated types                                                                |
| **Application Patterns**       | Architecture patterns (clean, hexagonal, modular monolith, CQRS), folder structures, design principles                   |
| **Cost Knowledge**             | Real pricing data for cloud compute, databases, LLM tokens, auth, payments, email, hosting, monitoring                    |
| **Deep Research**              | Structured web research methodology — Discover → Verify → Synthesize with confidence tagging and source citations         |
| **Known Services**             | Setup steps, credentials, and free tier details for 70+ services across 12 categories                                     |
| **Diagram Patterns**           | C4 Context/Container, data flow, agent flow, deployment, sequence diagram templates in Mermaid                            |
| **Agent Architecture**         | AI agent orchestration patterns (ReAct, chain-of-thought, multi-agent), tool design, memory, guardrails                   |
| **Complexity Factors**         | 10-factor weighted scoring methodology with scoring guides and agent/hybrid adjustments                                   |
| **Founder Communication**      | Plain English defaults, acronym expansion, analogy-first explanations, progressive disclosure                             |
| **API Artifacts**              | Templates for OpenAPI specs, Postman collections, AsyncAPI specs, GraphQL schemas                                         |
| **Operational Patterns**       | Security architecture, observability, CI/CD pipelines, database migrations, environment strategy                          |
| **Well-Architected**           | Six-pillar framework for architecture quality evaluation with scoring and improvement roadmaps                             |
| **Project Templates**          | Starter file templates for scaffolding across frontend, backend, mobile, and AI agent frameworks                          |
| **Product Type Detector**      | Auto-detection of product archetypes with templates for AI agents, e-commerce, SaaS, real-time, etc.                      |
| **Design System**              | Design token generation, 11 personalities (including organic/retro/expressive/cinematic), 77+ font pairs, dark mode tokens, gradient recipes, motion timing, 8 unconventional layout patterns, 23 consumer/creative domain defaults, 15 component library presets |
| **Coding Rules**               | AI coding rules generation for CLAUDE.md, .cursorrules, copilot-instructions.md, .aider/conventions.md                   |
| **Coding Rules Enforcement**   | Hard enforcement — ESLint, Ruff, dependency-cruiser, architecture tests, CI gates                                         |
| **Infrastructure Generators**  | Terraform, Kubernetes, Docker Compose, Nginx config generation from SDL                                                   |
| **SDL Knowledge**              | Solution Design Language specification — schema, validation, normalization, multi-file imports, templates                  |
| **Export Diagrams**            | Diagram rendering for Mermaid CLI, mermaid.ink, Kroki API                                                                 |
| **Export DOCX**                | Word document export patterns and formatting                                                                              |
| **Export OpenAPI**             | OpenAPI specification generation and export                                                                               |
| **Generate Data Model**       | ORM schema generation for Prisma, SQLAlchemy, Mongoose, Drizzle                                                          |
| **Security Audit**             | Security audit checklist and validation patterns                                                                          |
| **Setup Env**                  | Environment setup, API key validation, .env file generation                                                               |
| **Stakeholder Doc**            | Stakeholder-facing documentation for non-technical audiences                                                              |
| **Sync Backlog**               | Backlog synchronization for Azure DevOps and Jira                                                                         |
| **Validate**                   | Architecture validation and consistency checking rules                                                                    |
| **Clean Code**                 | Structural quality rules (function length, single responsibility, naming, DRY, dead code, frontend component decomposition) applied at write time and review time |
| **Production Hardening**       | Runtime-specific patterns for retry, timeout, structured logging, graceful shutdown, correlation IDs, and health checks   |

## Plugin Structure

```
architecture-cowork-plugin/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json
├── README.md
├── agents/                          # 11 subagents with tool access
│   ├── api-docs-publisher.md
│   ├── backlog-sync.md
│   ├── cicd-deployer.md
│   ├── data-model-generator.md
│   ├── diagram-exporter.md
│   ├── env-setup.md
│   ├── implementer.md
│   ├── reviewer.md
│   ├── scaffolder.md
│   └── security-scanner.md
├── commands/                        # 31 slash commands
│   ├── agent-spec.md
│   ├── blueprint.md
│   ├── compare-stack.md
│   ├── complexity-check.md
│   ├── cost-estimate.md
│   ├── design-system.md
│   ├── export-diagrams.md
│   ├── generate-data-model.md
│   ├── hiring-brief.md
│   ├── deep-research.md
│   ├── implement-index.md           # split: implement-1.md, implement-2.md
│   ├── import.md
│   ├── investor-update.md
│   ├── launch-checklist.md
│   ├── onboarding-pack.md
│   ├── publish-api-docs.md
│   ├── quick-spec.md
│   ├── refactor-stack.md
│   ├── review-index.md              # split: review-1.md, review-2.md
│   ├── scaffold-component.md
│   ├── scaffold.md
│   ├── sdl.md
│   ├── security-scan.md
│   ├── setup-cicd.md
│   ├── setup-env.md
│   ├── sync-backlog.md
│   └── well-architected.md
├── skills/                          # 31 domain knowledge skills
│   ├── agent-architecture/
│   ├── api-artifacts/
│   ├── application-patterns/
│   ├── architecture-methodology/
│   ├── coding-rules/
│   ├── coding-rules-enforcement/
│   ├── complexity-factors/
│   ├── cost-knowledge/
│   ├── deep-research/
│   ├── design-system/
│   ├── diagram-patterns/
│   ├── export-diagrams/
│   ├── export-docx/
│   ├── export-openapi/
│   ├── founder-communication/
│   ├── generate-data-model/
│   ├── infrastructure-generators/
│   ├── known-services/
│   ├── manifest-structure/
│   ├── operational-patterns/
│   ├── product-type-detector/
│   ├── project-templates/
│   ├── sdl-knowledge/
│   ├── security-audit/
│   ├── setup-env/
│   ├── stakeholder-doc/
│   ├── sync-backlog/
│   ├── clean-code/
│   ├── production-hardening/
│   ├── validate/
│   └── well-architected/
├── templates/                       # 12 SDL starter templates
│   ├── _index.yaml
│   ├── admin-dashboard.sdl.yaml
│   ├── ai-chat-app.sdl.yaml
│   ├── api-only.sdl.yaml
│   ├── e-commerce.sdl.yaml
│   ├── event-driven-microservices.sdl.yaml
│   ├── internal-tool.sdl.yaml
│   ├── landing-page.sdl.yaml
│   ├── marketplace.sdl.yaml
│   ├── mobile-app-api.sdl.yaml
│   ├── portfolio-blog.sdl.yaml
│   ├── realtime-collab.sdl.yaml
│   └── saas-starter.sdl.yaml
└── references/                      # 11 reference documents
    ├── design-systems.md            # personality guide, component libraries, domain defaults
    ├── design-system-fonts.md       # 77+ curated font pairs across 11 personalities
    ├── design-system-patterns.md    # dark mode, gradients, motion timing, layout archetypes, 8 unconventional layouts
    ├── design-system-creative.md    # organic/retro/expressive/cinematic personalities + consumer domains
    ├── example-blueprints.md
    ├── manifest-schema.md
    ├── prescriptive-decision-framework.md
    ├── pricing-tables.md
    ├── sdl-schema.md
    ├── sdl-templates.md
    └── service-profiles.md
```

## Examples

See [references/example-blueprints.md](references/example-blueprints.md) for complete example blueprint outputs:

1. **E-commerce Marketplace** (app) — Next.js, Node.js, PostgreSQL, Stripe
2. **AI Customer Support Bot** (agent) — Python/FastAPI, Claude Sonnet, pgvector, Slack
3. **SaaS with AI Assistant** (hybrid) — Next.js, Node.js, MongoDB, Claude Haiku, Stripe

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For bug reports and feature requests, open an issue on GitHub.

## License

Apache-2.0

---

_Architect AI | v2.0.0 | March 2026_
