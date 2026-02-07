# Architect AI — Cowork Plugin

Turn product ideas into structured, buildable architecture blueprints. Whether you're building an app, an AI agent, or both — get C4 diagrams, cost estimates, complexity scores, and a clear next-steps guide.

Built for founders. Useful for engineers.

## Installation

1. Open Claude Code
2. Go to **Settings > Plugins**
3. Search for **architect-ai** or install from the plugin marketplace
4. The plugin's skills and commands are available immediately

**Manual install from GitHub:**

```bash
git clone https://github.com/navraj007in/architecture-cowork-plugin.git
```

Then add the plugin directory in Claude Code's plugin settings.

## Commands

| Command | Description |
|---------|-------------|
| `/architect:blueprint` | Full architecture blueprint — diagrams, costs, complexity, specs, and next steps |
| `/architect:quick-spec` | 5-minute lightweight architecture overview for idea validation |
| `/architect:cost-estimate` | Infrastructure + third-party + LLM token cost breakdown |
| `/architect:complexity-check` | Build difficulty assessment with 10-factor scoring |
| `/architect:agent-spec` | AI agent architecture — orchestration, tools, guardrails, token costs |
| `/architect:compare-stack` | Side-by-side technology comparison with recommendation |
| `/architect:hiring-brief` | Developer hiring package with role descriptions and interview questions |
| `/architect:well-architected` | Six-pillar well-architected review with scores and improvement roadmap |
| `/architect:scaffold` | Create repos and bootstrap projects from a blueprint architecture |
| `/architect:sync-backlog` | Push sprint backlog into Azure DevOps or Jira as sprints and work items |
| `/architect:publish-api-docs` | Generate interactive API documentation (Swagger UI, Redoc, AsyncAPI) |
| `/architect:setup-env` | Walk through account setup, validate API keys, write verified .env files |
| `/architect:export-diagrams` | Render Mermaid diagrams to PNG/SVG with light and dark themes |
| `/architect:security-scan` | Validate scaffolded code against the blueprint's security checklist |
| `/architect:setup-cicd` | Configure real CI/CD pipelines in GitHub Actions, Azure Pipelines, or GitLab CI |
| `/architect:generate-data-model` | Generate ORM schemas (Prisma, SQLAlchemy, Mongoose, Drizzle) from blueprint types |

## What You Get

### From `/architect:blueprint` (flagship command)

A complete architecture blueprint with 15 deliverables:

1. **Executive Summary** — one-page overview with cost breakdown, complexity score, and architecture pattern
2. **Architecture Diagram** — C4 Container diagram in Mermaid, plus agent flow diagram if applicable
3. **Application Architecture & Patterns** — architecture pattern (clean, hexagonal, modular monolith, etc.), folder structure, design principles (DI, SRP), error handling, and testing strategy
4. **Shared Types & Cross-Service Contracts** — shared domain types, reusable libraries, service contracts (OpenAPI, event schemas, Protobuf), and inter-service communication detail table
5. **API Artifacts** — OpenAPI/Swagger specs (YAML), Postman collections (JSON), AsyncAPI specs for event-driven services, and GraphQL schemas — ready to import into Swagger UI, Postman, and AsyncAPI Studio
6. **Security Architecture** — auth strategy, API security checklist (rate limiting, input validation, CORS, headers), data protection (encryption, PII handling, secrets management), and OWASP threat mitigations
7. **Observability & Monitoring** — structured logging, health checks per service, key metrics with alert thresholds, monitoring stack recommendation, and distributed tracing guidance
8. **DevOps Blueprint** — CI/CD pipeline (stages, triggers, provider), branch strategy, environment definitions (local/staging/production), database migration tooling, config management, and feature flags
9. **Cost Estimate** — infrastructure + third-party + LLM token costs in low/medium/high scenarios
10. **Complexity Assessment** — 10-factor scoring with risk flags and simpler alternatives
11. **Well-Architected Review** — 6-pillar evaluation (operational excellence, security, reliability, performance, cost optimization, developer experience) with per-pillar scores, gap analysis, and prioritized improvement roadmap
12. **Plain English Specifications** — features grouped by component, written for non-technical stakeholders
13. **Required Accounts** — every third-party service with signup URL, setup steps, and free tier details
14. **Next Steps Guide** — 3 paths forward: build with AI tools, hire a developer, or hire an agency
15. **Sprint Backlog** — time-boxed sprint plan with goals, user stories, and dependencies derived from complexity score and architecture

### From `/architect:quick-spec`

A one-page architecture overview in under 5 minutes — system overview, component list, cost range, complexity score, and one recommended next step. Perfect for idea validation.

### From `/architect:agent-spec`

Complete AI agent architecture including LLM provider recommendation, orchestration pattern, tool definitions, memory strategy, guardrails, token cost modeling, agent flow diagram, example conversation, and a system prompt skeleton.

### From `/architect:cost-estimate`

Detailed cost breakdown across infrastructure, third-party services, and AI/LLM usage. Three scenarios (free tiers, starter, production), monthly and yearly totals, development cost ranges, and cost optimization tips.

### From `/architect:complexity-check`

10-factor complexity assessment with per-factor scoring, risk flags for high-scoring areas, simpler alternatives if the product scores above 6, and build-path recommendations based on the overall score.

### From `/architect:compare-stack`

Side-by-side technology comparison with scoring matrix, summary scores, a clear recommendation, and guidance on when to choose each option.

### From `/architect:hiring-brief`

Developer hiring package with role descriptions, required skills, interview questions, milestone-based payment schedules, an Upwork posting template, and an agency brief template.

### From `/architect:well-architected`

Six-pillar architecture quality review. Evaluates operational excellence, security, reliability, performance efficiency, cost optimization, and developer experience. Each pillar scored 1-5 with strengths, gaps, and specific recommendations. Includes a prioritized improvement roadmap and stage-appropriate assessment (MVP vs production expectations).

### From `/architect:scaffold`

Turns your architecture blueprint into real projects. After running `/architect:blueprint`, this command creates directories (or GitHub repos) for each component — frontend, backend services, mobile apps, AI agents — and bootstraps them with framework-appropriate starter code, `.env.example` files, READMEs, and git initialization. Supports Next.js, Express, FastAPI, React Native (Expo), BullMQ workers, and Python/Node.js AI agents.

### From `/architect:sync-backlog`

Pushes the sprint backlog (deliverable 4o) from a blueprint directly into Azure DevOps or Jira. Creates epics per architecture component, sprints with goals and dates, and user stories assigned to each sprint. All items tagged `architect-ai` for easy filtering. Supports Azure CLI (`az boards`) and Jira REST API / `jira-cli`.

### From `/architect:publish-api-docs`

Takes the API artifacts (OpenAPI, AsyncAPI, Postman collections) from a blueprint and generates interactive API documentation. Creates Swagger UI and Redoc HTML pages, raw spec files, and an index page — ready to serve locally or deploy to GitHub Pages.

### From `/architect:setup-env`

Guided environment setup that walks through each third-party account from the Required Accounts list, validates API keys with live API calls, and writes a verified `.env` file. Handles multi-component projects, masks secrets in output, and verifies `.gitignore` before writing credentials.

### From `/architect:export-diagrams`

Renders all Mermaid architecture diagrams from a blueprint to PNG and SVG image files. Produces both light and dark theme variants using the Mermaid CLI, with fallback to mermaid.ink and Kroki APIs.

### From `/architect:security-scan`

Read-only security validation that checks scaffolded code against the blueprint's security checklist. Scans for auth middleware, CORS, helmet headers, rate limiting, input validation, SQL injection prevention, and hardcoded secrets. Reports pass/stub/missing/risk status for each check.

### From `/architect:setup-cicd`

Configures real CI/CD pipelines from the blueprint's DevOps section. Creates GitHub Actions workflows (or Azure Pipelines / GitLab CI), adds deployment steps for Vercel, Railway, AWS, or Azure, and lists all required repository secrets.

### From `/architect:generate-data-model`

Turns shared type stubs from the blueprint into real ORM schemas. Generates Prisma schemas, SQLAlchemy models, Mongoose schemas, or Drizzle tables — with relationships, indexes, enums, and seed data. Optionally runs the initial migration.

## Skills

The plugin includes 22 domain knowledge skills that Claude draws on automatically:

| Skill | What It Contains |
|-------|-----------------|
| **Architecture Methodology** | Structured requirements gathering framework, manifest building process, output quality rules |
| **Manifest Structure** | Canonical system manifest format with all enumerated types (project, frontend, service, database, integration, LLM, agent, communication) |
| **Cost Knowledge** | Real pricing data for cloud compute, databases, LLM tokens, auth, payments, email, hosting, and monitoring services |
| **Known Services** | Setup steps, credentials, and free tier details for 70+ services across 12 categories |
| **Diagram Patterns** | C4 Context/Container, data flow, agent flow, deployment, and sequence diagram templates in Mermaid |
| **Agent Architecture** | AI agent orchestration patterns (ReAct, chain-of-thought, multi-agent), tool design, memory strategies, guardrails, token cost modeling |
| **Complexity Factors** | 10-factor weighted scoring methodology with factor definitions, scoring guides, and agent/hybrid adjustments |
| **Founder Communication** | Plain English defaults, acronym expansion, analogy-first explanations, progressive disclosure, risk severity levels |
| **API Artifacts** | Templates for generating OpenAPI specs, Postman collections, AsyncAPI specs, and GraphQL schemas from architecture manifests |
| **Operational Patterns** | Security architecture, observability, CI/CD pipelines, database migrations, and environment strategy patterns |
| **Well-Architected** | Six-pillar framework for evaluating architecture quality with scoring methodology, stage-appropriate expectations, and improvement roadmaps |
| **Project Templates** | Starter file templates and boilerplate for scaffolding projects across frontend, backend, mobile, and AI agent frameworks |
| **Product Type Detector** | Auto-detection of product archetypes with templates for AI agents, e-commerce, SaaS, content platforms, real-time collaboration, and file storage |
| **Export Diagrams** | Diagram rendering knowledge for Mermaid CLI, mermaid.ink, and Kroki API fallbacks |
| **Export DOCX** | Word document export patterns and formatting |
| **Export OpenAPI** | OpenAPI specification generation and export |
| **Generate Data Model** | ORM schema generation patterns for Prisma, SQLAlchemy, Mongoose, and Drizzle |
| **Security Audit** | Security audit checklist and validation patterns |
| **Setup Env** | Environment setup, API key validation, and .env file generation patterns |
| **Stakeholder Doc** | Stakeholder-facing documentation generation for non-technical audiences |
| **Sync Backlog** | Backlog synchronization patterns for Azure DevOps and Jira |
| **Validate** | Architecture validation and consistency checking rules |

## Plugin Structure

```
architecture-cowork-plugin/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── agents/                      # 8 subagents with tool access
│   ├── api-docs-publisher.md
│   ├── backlog-sync.md
│   ├── cicd-deployer.md
│   ├── data-model-generator.md
│   ├── diagram-exporter.md
│   ├── env-setup.md
│   ├── scaffolder.md
│   └── security-scanner.md
├── commands/                    # 16 slash commands
│   ├── agent-spec.md
│   ├── blueprint.md
│   ├── compare-stack.md
│   ├── complexity-check.md
│   ├── cost-estimate.md
│   ├── export-diagrams.md
│   ├── generate-data-model.md
│   ├── hiring-brief.md
│   ├── publish-api-docs.md
│   ├── quick-spec.md
│   ├── scaffold.md
│   ├── security-scan.md
│   ├── setup-cicd.md
│   ├── setup-env.md
│   ├── sync-backlog.md
│   └── well-architected.md
├── skills/                      # 22 domain knowledge skills
│   ├── agent-architecture/SKILL.md
│   ├── api-artifacts/SKILL.md
│   ├── architecture-methodology/SKILL.md
│   ├── complexity-factors/SKILL.md
│   ├── cost-knowledge/SKILL.md
│   ├── diagram-patterns/SKILL.md
│   ├── export-diagrams/SKILL.md
│   ├── export-docx/SKILL.md
│   ├── export-openapi/SKILL.md
│   ├── founder-communication/SKILL.md
│   ├── generate-data-model/SKILL.md
│   ├── known-services/SKILL.md
│   ├── manifest-structure/SKILL.md
│   ├── operational-patterns/SKILL.md
│   ├── product-type-detector/
│   │   ├── SKILL.md
│   │   └── templates/           # 6 product type templates
│   ├── project-templates/SKILL.md
│   ├── security-audit/SKILL.md
│   ├── setup-env/SKILL.md
│   ├── stakeholder-doc/SKILL.md
│   ├── sync-backlog/SKILL.md
│   ├── validate/SKILL.md
│   └── well-architected/SKILL.md
└── references/                  # Supporting reference data
    ├── example-blueprints.md
    ├── manifest-schema.md
    ├── prescriptive-decision-framework.md
    ├── pricing-tables.md
    └── service-profiles.md
```

## Examples

See [references/example-blueprints.md](references/example-blueprints.md) for 3 complete example blueprint outputs:

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

*Architect AI | v1.0.0 | February 2026*
