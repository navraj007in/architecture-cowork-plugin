---
name: coding-rules
description: Generate AI-consumable coding rules (CLAUDE.md, .cursorrules, copilot-instructions) and enforcement tooling from SDL
---

# Coding Rules Generator

Generate **architecture-aware coding rules** that AI coding tools (Claude Code, Cursor, GitHub Copilot) enforce automatically across every session. Optionally generates hard enforcement tooling (ESLint, dependency-cruiser, pre-commit hooks, architecture tests).

**Input**: SDL document
**Output**: `CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, per-project `CLAUDE.md`, optional enforcement configs

---

## What It Generates

### Advisory Rules (CLAUDE.md / .cursorrules / copilot-instructions.md)

A single markdown file (output to 3 locations for tool coverage) containing architecture-derived coding rules organized by category:

| Category | Source SDL Section | Example Rules |
|---|---|---|
| Architecture | `architecture.style` | Module boundary rules, service isolation, communication patterns |
| File Structure | `architecture.projects` | Framework conventions, ORM patterns, folder organization |
| Data Access | `data` | Repository pattern, database query rules, search engine usage |
| API Patterns | `architecture.projects.backend` | REST/GraphQL/gRPC conventions, versioning, service base paths |
| Authentication | `auth` | Provider-specific rules (Clerk/Auth0/Cognito), token handling, RBAC |
| Error Handling | `errorHandling` | Error format, global handler, circuit breaker, retry patterns |
| Integrations | `integrations` | Service client isolation, webhook handling, payment/email patterns |
| Testing | `testing` | Framework-specific rules, coverage targets, test structure |
| Observability | `observability` | Logging rules, tracing, metrics collection |
| Security | `nonFunctional.security` | PII handling, encryption, audit logging, OWASP compliance |
| Caching | `data.cache` | Cache invalidation, TTL, cache-aside pattern |
| Queues | `data.queues` | Message handling, idempotency, dead letter queues |
| Code Quality | (always generated) | SOLID principles, naming, DRY, single responsibility |
| Design Patterns | (always generated) | Framework-appropriate patterns (repository, factory, strategy) |
| File Size & Structure | (always generated) | Max file length, function complexity, extraction rules |
| API Design Quality | (always generated) | Pagination, filtering, consistent responses, HATEOAS |
| Database Queries | (always generated) | N+1 prevention, indexing, query optimization |
| Testing Quality | (always generated) | AAA pattern, test naming, mocking boundaries |
| Performance | (always generated) | Lazy loading, pagination, connection pooling |
| Import Organization | (always generated) | Import ordering, barrel exports, circular dependency prevention |
| Tech Debt Avoidance | (always generated) | TODO tracking, deprecation patterns, refactoring triggers |
| Resilience | (always generated) | Retry policies, timeouts, fallbacks, circuit breakers |
| Input Validation | (always generated) | Schema validation, sanitization, boundary validation |
| Concurrency | (always generated) | Race conditions, locking, atomic operations |
| Configuration | (always generated) | Env var patterns, secrets management, feature flags |
| Migration Safety | (always generated) | Backward compatibility, zero-downtime deploys, rollback |
| Documentation | (always generated) | When to document, inline comments, API docs |
| Git Workflow | (always generated) | Branch naming, commit messages, PR conventions |

### Conditional Categories (added when applicable)

| Category | Condition | Rules |
|---|---|---|
| Accessibility | Frontend projects exist | WCAG compliance, ARIA, keyboard navigation, color contrast |
| State Management | Frontend projects exist | Framework-specific state rules (React Context, Redux, Zustand) |
| Mobile | Mobile projects exist | Platform guidelines, navigation, permissions, offline |
| Internationalization | Multiple regions defined | i18n patterns, locale handling, RTL support |

### Per-Project Rules

For monorepo setups, generates `{project-name}/CLAUDE.md` with project-specific rules:
- Backend: framework conventions, API style, ORM patterns, port assignment
- Frontend: rendering mode, styling approach, component library, state management

### Enforcement Tooling (Optional)

When `coding-rules-enforcement` is in `artifacts.generate`, produces hard gates:

| File | Purpose | Language |
|---|---|---|
| `.eslintrc.sdl.js` | Custom ESLint rules from architecture | TypeScript/JS |
| `pyproject.sdl.toml` | Ruff/flake8 config from architecture | Python |
| `.golangci.sdl.yml` | golangci-lint config from architecture | Go |
| `.dependency-cruiser.sdl.cjs` | Module boundary enforcement | TypeScript/JS |
| `.lintstagedrc.sdl.json` | Pre-commit hook config | All |
| `tests/architecture.test.ts` | Architecture conformance tests | TypeScript |

---

## How Rules Are Generated

Rules are **deterministic** — same SDL input always produces identical output. The generator:

1. Reads architecture style, projects, data layer, auth, integrations from SDL
2. Applies framework-specific rule templates (e.g., Express error handling vs FastAPI exception handlers)
3. Adds conditional categories based on project composition
4. Generates per-project overlays for monorepo setups
5. Renders all rules into a single markdown document

### Framework-Aware Rules

The generator tailors rules to the specific tech stack:

| Framework | Tailored Rules |
|---|---|
| Node.js/Express | Middleware patterns, async/await error handling, route organization |
| Python/FastAPI | Pydantic models, dependency injection, async endpoints |
| Go | Interface-based design, error wrapping, goroutine safety |
| .NET 8 | Controller patterns, DI container, middleware pipeline |
| Java/Spring | Bean lifecycle, AOP patterns, Spring Security |
| Next.js | App Router conventions, Server Components, RSC boundaries |
| React | Hook rules, component composition, render optimization |

---

## When to Use

- After `/architect:scaffold` — generate rules that match the scaffolded project structure
- After SDL changes — regenerate to keep rules in sync with architecture evolution
- When onboarding AI tools — drop `CLAUDE.md` into any project for instant architecture awareness
- When adding enforcement — use `coding-rules-enforcement` artifact for CI/CD gates

## Integration

The coding rules generator is available as an SDL artifact type:
```yaml
artifacts:
  generate:
    - coding-rules              # Advisory rules (CLAUDE.md, .cursorrules, copilot-instructions)
    - coding-rules-enforcement  # Hard gates (ESLint, dependency-cruiser, pre-commit, arch tests)
```

Both are generated via the `generate_from_sdl` agent tool or the `/api/sdl/generate` endpoint.
