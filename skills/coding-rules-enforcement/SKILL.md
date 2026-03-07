---
name: coding-rules-enforcement
description: Generate hard enforcement tooling (ESLint, Ruff, golangci-lint, dependency-cruiser, pre-commit, arch tests, CI) from SDL
---

# Coding Rules Enforcement Generator

Turns advisory coding rules into **hard gates** — linters, module boundary checks, architecture tests, pre-commit hooks, and CI workflows. All configs are derived deterministically from the SDL document.

**Input**: SDL document (via `artifacts.generate` including `coding-rules-enforcement`)
**Output**: Language-specific linter configs, dependency-cruiser rules, pre-commit hooks, architecture tests, CI workflow

**API**: `POST /api/sdl/generate` with `artifactType: "coding-rules-enforcement"` (no dedicated route)

---

## What It Generates

### Language Detection

The generator inspects `architecture.projects.backend[]` and `frontend[]` frameworks to determine which configs to produce:

| Framework | Language | Configs Generated |
|-----------|----------|-------------------|
| `nodejs` | TypeScript | ESLint, dependency-cruiser, arch tests |
| `nextjs`, `react`, `vue`, `angular`, `svelte` | TypeScript | ESLint (with React hooks/a11y if applicable) |
| `python-fastapi` | Python | Ruff + Mypy config |
| `go` | Go | golangci-lint config |
| `java-spring` | Java | ArchUnit tests |
| `dotnet-8` | C# | NetArchTest tests |

### Files Produced

| File | Language | Purpose |
|------|----------|---------|
| `.eslintrc.sdl.js` | TypeScript/JS | Custom ESLint rules from SDL architecture |
| `pyproject.sdl.toml` | Python | Ruff lint + Mypy strict + pytest coverage config |
| `.golangci.sdl.yml` | Go | 16+ linters with complexity limits |
| `.dependency-cruiser.sdl.cjs` | TypeScript/JS | Module boundary enforcement (modular-monolith/microservices) |
| `.lintstagedrc.sdl.json` | All | Pre-commit hook command mapping |
| `.husky/pre-commit` | All | Git pre-commit hook script |
| `__tests__/architecture.sdl.test.ts` | TypeScript | Architecture conformance tests |
| `src/test/java/architecture/ArchitectureTest.java` | Java | ArchUnit architecture tests |
| `tests/Architecture.Tests/ArchitectureTests.cs` | .NET | NetArchTest architecture tests |
| `.github/workflows/enforce-architecture.yml` | All | CI gate workflow |

---

## ESLint Rules (TypeScript/JS)

20+ rules enforced:

- `@typescript-eslint/no-explicit-any: error` — no `any` type
- `max-params: 3` — max function parameters
- `no-console: error` (allow warn) — no console.log in production
- `no-var, prefer-const` — modern variable declarations
- `no-magic-numbers: warn` — avoid unlabeled constants
- `max-depth: 3` — max nesting depth
- `max-lines: 500` — max file size
- `max-lines-per-function: 50` — max function length
- `@typescript-eslint/consistent-type-imports` — type-only imports
- `import/no-cycle` — no circular imports
- `import/order` — enforced import ordering
- `@typescript-eslint/naming-convention` — camelCase functions, PascalCase types, UPPER_CASE enums
- `@typescript-eslint/no-floating-promises` — no unhandled promises
- `no-await-in-loop: warn` — avoid sequential async in loops
- `@typescript-eslint/no-unused-vars` — no dead code

**React-specific** (when frontend uses React/Next.js):
- `react-hooks/rules-of-hooks` — hook call rules
- `react-hooks/exhaustive-deps` — dependency arrays
- `jsx-a11y/*` — accessibility rules (alt-text, valid anchors, key events, labels)

---

## Dependency Cruiser Rules (Module Boundaries)

Generated when `architecture.style` is `modular-monolith` or `microservices`:

| Rule | Severity | What It Prevents |
|------|----------|-----------------|
| `no-circular` | error | Circular dependencies |
| `no-cross-module-internals` | error | Importing another module's internal files (only `.interface.ts` and `.types.ts` allowed) |
| `no-db-in-routes` | error | Routes importing database directly |
| `no-repository-in-routes` | error | Routes bypassing services to access repositories |
| `shared-no-module-imports` | error | Shared utilities depending on business modules |
| `orm-only-in-repositories-{name}` | error | ORM package imported outside repository files |

---

## Architecture Tests

### TypeScript (`__tests__/architecture.sdl.test.ts`)

- **Module Boundaries**: No module imports another module's repository or internal files
- **Data Access Patterns**: Service files don't use database client directly; route files don't import repositories
- **Security**: No hardcoded secrets (Stripe keys, Anthropic keys, base64 keys)
- **Dependency Graph**: Runs dependency-cruiser validation (modular-monolith/microservices)
- **Coverage**: Validates coverage target from SDL `testing.coverage.target`

### Java (`ArchitectureTest.java` with ArchUnit)

- Controllers don't access repositories
- Services don't depend on controllers
- Repositories don't depend on services
- No cyclic package dependencies
- Per-module internal access restrictions

### .NET (`ArchitectureTests.cs` with NetArchTest)

- Controllers don't reference repositories
- Services don't depend on controllers
- Repositories don't depend on services

---

## CI Workflow (`.github/workflows/enforce-architecture.yml`)

Runs on PR to main/develop and push to main. Jobs by language:

| Job | Steps |
|-----|-------|
| `lint-typescript` | npm ci → ESLint → dependency-cruiser → architecture tests |
| `lint-python` | pip install → ruff check → ruff format → mypy → pytest with coverage |
| `lint-go` | golangci-lint → go test with coverage threshold |
| `lint-java` | mvnw verify (includes ArchUnit) |
| `lint-dotnet` | dotnet restore → dotnet test Architecture.Tests |
| `commit-lint` | commitlint (conventional commits) |

---

## SDL Sections Used

| SDL Section | What It Controls |
|-------------|-----------------|
| `architecture.projects.backend[].framework` | Which language configs to generate |
| `architecture.projects.frontend[].framework` | React hooks/a11y rules, TypeScript linting |
| `architecture.style` | Enables dependency-cruiser module boundary rules |
| `architecture.services[]` | Module names for cross-module import restrictions |
| `architecture.projects.backend[].orm` | ORM-specific import restrictions |
| `testing.coverage.target` | Coverage enforcement threshold in CI |

---

## Relationship to Coding Rules (Advisory)

| Aspect | `coding-rules` | `coding-rules-enforcement` |
|--------|----------------|---------------------------|
| Output | CLAUDE.md, .cursorrules, copilot-instructions.md | ESLint, Ruff, golangci-lint, tests, CI |
| Enforcement | Advisory (AI tool reads them) | Hard gates (CI blocks violations) |
| Scope | 27+ categories of architecture rules | Linting, boundaries, secrets, coverage |
| When | Always useful | When team needs CI-level enforcement |

Both are triggered via `artifacts.generate` in SDL. Use `coding-rules` alone for AI-guided development, add `coding-rules-enforcement` for automated CI gates.
