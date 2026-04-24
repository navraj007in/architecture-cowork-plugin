# Prerequisite Graph Skill

Documents the complete dependency graph of all 54 `/architect:` commands, showing which commands must run before others, in what order, with estimated execution times for full dependency chains.

## Quick Reference: Command Dependency Tiers

Commands are organized by execution order:

| Tier | Commands | ETA | Depends on |
|------|----------|-----|-----------|
| **Tier 0: Foundation** | blueprint, sdl, import | 20-30 min | Nothing (can start empty) |
| **Tier 1: Design & Schema** | design-system, generate-data-model | 15-30 min | Tier 0 complete |
| **Tier 2: Code Generation** | scaffold, scaffold-component | 15-60 min | Tier 0, Tier 1 |
| **Tier 3: Development** | implement, review, visualise | 30 min - days | Tier 2 complete |
| **Tier 4: Quality** | generate-tests, security-scan | 30-120 min | Tier 3 complete |
| **Tier 5: Scale** | load-test, setup-cicd, setup-monitoring | 20-120 min | Tier 2 + Tier 4 |
| **Tier 6: Production** | compliance, launch-check, production-readiness | 60-180 min | Tier 5 complete |
| **Tier 7: Growth** | cost-estimate, technical-roadmap, etc. | 15-45 min | Any tier (no strict dependency) |

---

## Full Dependency Graph

### Tier 0: Foundation (Nothing required)

```
START
  ↓
blueprint — 20 min
  ├─ Problem validation (optional baseline)
  ├─ SDL generation (alternative to blueprint)
  └─ Import existing project (alternative entry)
```

**Commands:**
- `blueprint` (20 min) — generates tech stack, components, design palette
- `sdl` (varies) — validates or generates solution.sdl.yaml
- `import` (10 min) — reverse-engineers SDL from existing codebase
- `problem-validation` (30 min) — validates market problem before architecture

**Outputs:**
- `solution.sdl.yaml` or `_state.json` with project basics
- Foundational design palette

**Exit criteria:**
- ✅ State has `project.name`, `tech_stack`, `components`, `design`

---

### Tier 1: Design & Data Model (depends on Tier 0)

```
blueprint (Tier 0)
  ↓
design-system — 15 min
  ├─ Generate design tokens
  ├─ Create Tailwind config
  └─ Define component library
  
generate-data-model — 20 min
  ├─ Entity schema (Prisma, SQLAlchemy, etc.)
  ├─ Relationships and constraints
  └─ Migration templates
```

**Dependencies:**
- `design-system` requires: `blueprint` (design section)
- `generate-data-model` requires: SDL entities OR state.entities

**Outputs:**
- Design tokens, Tailwind config, CSS variables
- Database schema (Prisma, SQL, etc.)
- Entity types and relationships

**Exit criteria:**
- ✅ Design tokens generated
- ✅ Data schema exists

---

### Tier 2: Code Generation (depends on Tier 0 + Tier 1)

```
blueprint (Tier 0)
design-system (Tier 1) — 15 min
generate-data-model (Tier 1) — 20 min
  ↓
scaffold — 30-60 min
  ├─ Generate project structure
  ├─ Install dependencies
  ├─ Apply design tokens
  ├─ Generate schemas
  └─ Create env.example files
  ↓
scaffold-component (2-10 min each)
  ├─ Generate individual components
  ├─ Apply design tokens
  └─ Create stubs for routes/services
```

**Dependencies:**
- `scaffold` requires: Blueprint + design tokens + data model
- `scaffold-component` requires: Existing scaffold

**Outputs:**
- Full project directory structure
- package.json / requirements.txt / go.mod
- Source files with correct imports
- Individual component folders

**Exit criteria:**
- ✅ `npm install` succeeds
- ✅ Build passes (no syntax errors)
- ✅ Project structure matches blueprint

---

### Tier 3: Development (depends on Tier 2)

```
scaffold (Tier 2) — 30-60 min
  ↓
implement — N days
  ├─ Add feature logic
  ├─ Update entity schema
  ├─ Create database migrations
  └─ Write component code
  ↓
visualise — 5 min
  ├─ Generate C4 diagrams
  ├─ Create mermaid visualizations
  └─ Update architecture diagrams
  ↓
review — 10-30 min
  ├─ Analyze code quality
  ├─ Check architecture compliance
  └─ Generate PR feedback
```

**Dependencies:**
- `implement` requires: Existing scaffold
- `visualise` requires: Blueprint + scaffold
- `review` requires: Scaffold + implemented code

**Outputs:**
- Feature code (controllers, services, components)
- Updated schema with new entities
- Database migrations
- C4 diagrams, mermaid files
- Code review reports (optional PR feedback)

**Exit criteria:**
- ✅ Features implemented
- ✅ Code passes linting
- ✅ Tests pass (once written)

---

### Tier 4: Quality (depends on Tier 3)

```
implement (Tier 3) — N days
  ↓
generate-tests — 30-120 min
  ├─ Unit tests (Jest, Vitest, pytest)
  ├─ Integration tests
  ├─ E2E tests (optional)
  └─ Test fixtures and mocks
  ↓
security-scan — 20-60 min
  ├─ SAST analysis
  ├─ Dependency vulnerability scan
  ├─ Secret scanning
  └─ Security report
  ↓
accessibility-audit — 15-45 min
  ├─ WCAG 2.1 AA compliance check
  ├─ Screen reader testing
  └─ Keyboard navigation audit
```

**Dependencies:**
- `generate-tests` requires: Source files from scaffold + test framework
- `security-scan` requires: Source code to analyze
- `accessibility-audit` requires: Rendered UI (scaffold + implement)

**Outputs:**
- Test suites (unit, integration, e2e)
- Test fixtures and mocks
- Coverage report
- Security scan results
- Vulnerability report
- Accessibility report

**Exit criteria:**
- ✅ 60%+ test coverage (or project-specific target)
- ✅ No critical security vulnerabilities
- ✅ WCAG 2.1 AA compliance

---

### Tier 5: Scale (depends on Tier 2 + Tier 4)

```
scaffold (Tier 2) — 30-60 min
generate-tests (Tier 4) — 30-120 min
design-system (Tier 1) — 15 min
  ↓
setup-cicd — 20-30 min
  ├─ Configure CI/CD pipeline
  ├─ Setup code coverage tracking
  ├─ Configure deployment stages
  └─ Setup secrets management
  ↓
setup-monitoring — 20-60 min
  ├─ Configure observability (Datadog, New Relic, Prometheus)
  ├─ Setup dashboards
  ├─ Create alert rules
  ├─ Configure SLOs
  └─ Setup distributed tracing
  ↓
load-test — 30-90 min
  ├─ Define load test scenarios
  ├─ Configure target RPS
  ├─ Generate test data
  └─ Execute tests and report
```

**Dependencies:**
- `setup-cicd` requires: Scaffold + builds
- `setup-monitoring` requires: Service structure + framework choice
- `load-test` requires: Deployed or deployed-simulation infrastructure

**Outputs:**
- CI/CD configuration (.github/workflows, .gitlab-ci.yml, etc.)
- Pipeline definitions (build, test, deploy stages)
- Monitoring dashboards
- Alert rules and SLOs
- Load test results and capacity estimates

**Exit criteria:**
- ✅ CI/CD passes build + tests
- ✅ Monitoring collects metrics
- ✅ Load test targets met (or documented constraints)

---

### Tier 6: Production (depends on Tier 5)

```
setup-monitoring (Tier 5) — 20-60 min
generate-tests (Tier 4) — 30-120 min
  ↓
compliance — 60-120 min
  ├─ Audit security controls
  ├─ Check compliance frameworks (SOC 2, GDPR, HIPAA, etc.)
  ├─ Generate remediation plan
  └─ Create control documentation
  ↓
launch-check — 10-30 min
  ├─ Final pre-flight checklist
  ├─ Verify all systems ready
  ├─ Check documentation complete
  └─ Confirm team ready
  ↓
production-readiness — 30-60 min
  ├─ Final gate: score readiness
  ├─ Block launch if <80% ready
  ├─ Generate readiness report
  └─ Approve for launch
  ↓
LAUNCH
```

**Dependencies:**
- `compliance` requires: Monitoring + security scan
- `launch-check` requires: Complete scaffold + tests + monitoring + CI/CD
- `production-readiness` requires: All above complete + compliance pass

**Outputs:**
- Compliance audit report
- Security remediation plan
- Control implementation checklist
- Launch readiness checklist
- Production readiness score
- Sign-off documentation

**Exit criteria:**
- ✅ All critical compliance controls addressed
- ✅ >80% test coverage
- ✅ Monitoring in place
- ✅ Disaster recovery plan documented
- ✅ Team trained and ready

---

### Tier 7: Growth (no strict dependency, can run anytime)

```
Any prior tier complete
  ↓
cost-estimate — 15-30 min
  └─ Estimate infrastructure costs
  
technical-roadmap — 30-45 min
  └─ Plan scaling and feature roadmap
  
user-journeys — 20-30 min
  └─ Map user workflows and pain points
  
user-personas — 20-30 min
  └─ Define target users and characteristics
  
deep-research — 30-60 min
  └─ Market research, competitor analysis
  
mvp-scope — 20-30 min
  └─ Define MVP scope vs. later phases
  
problem-validation — 30-60 min
  └─ Validate market problem
  
generate-docs — 30-90 min
  └─ Generate full documentation suite
  
pitch-deck — 30-60 min
  └─ Generate investor pitch deck
  
hiring-brief — 20-30 min
  └─ Create hiring guide for new team members
```

**Dependencies:**
- No strict dependencies
- Can run in any order
- Outputs used for planning, analysis, documentation

**Outputs:**
- Cost projections
- Roadmap (3-12 months)
- User journey maps
- Persona definitions
- Market research
- MVP/Phase definitions
- Full documentation
- Presentations and slides

**Exit criteria:**
- ✅ Cost understood
- ✅ Roadmap planned
- ✅ Team aligned on direction

---

## Critical Paths

**Path A: Minimum Viable Product (MVP)**
```
blueprint (20 min)
  ↓
design-system (15 min)
  ↓
generate-data-model (20 min)
  ↓
scaffold (45 min)
  ↓
implement (3-7 days)
  ↓
generate-tests (60 min)
  ↓
READY FOR MVP (7-14 days total)
```

**Path B: Launch-Ready (MVP + Observability)**
```
Path A (above) — 7-14 days
  ↓
setup-cicd (25 min)
  ↓
setup-monitoring (40 min)
  ↓
security-scan (30 min)
  ↓
compliance (90 min)
  ↓
launch-check (15 min)
  ↓
production-readiness (45 min)
  ↓
READY FOR PRODUCTION (9-17 days total)
```

**Path C: Enterprise-Ready (All hardening)**
```
Path B (above) — 9-17 days
  ↓
load-test (60 min)
  ↓
accessibility-audit (30 min)
  ↓
technical-roadmap (30 min)
  ↓
disaster-recovery (60 min)
  ↓
READY FOR ENTERPRISE (11-19 days total)
```

---

## Dependency Rules

### Hard Dependencies (blocking)

Some commands **cannot** start until other commands complete:

```
scaffold ⚠️  requires design-system + generate-data-model
  └─ Cannot generate code without design tokens or schema

generate-tests ⚠️  requires scaffold
  └─ Cannot test code that doesn't exist

setup-monitoring ⚠️  requires scaffold
  └─ Cannot monitor services that don't exist

production-readiness ⚠️  requires generate-tests + setup-monitoring + compliance
  └─ Cannot launch without safety gates
```

### Soft Dependencies (recommended but not blocking)

Some commands work better with other commands completed, but don't strictly require them:

```
generate-tests ✓ works better after blueprint
  └─ Can test without blueprint context, but tests are more meaningful with architecture context

cost-estimate ✓ works better after scaffold
  └─ Can estimate based on blueprint alone, but better with actual component count

technical-roadmap ✓ works better after implement
  └─ Can plan without implementation, but roadmap more accurate with progress
```

### Optional Dependencies

Some commands have no dependencies:

```
blueprint — can run on empty project
sdl — can generate schema from nothing
user-personas — can define without any code
problem-validation — can validate without system
```

---

## Parallel Execution Opportunities

Some commands can run in parallel (no dependency relationship):

```
Parallel Safe:
┌─ design-system (15 min)
│
blueprint (20 min) ┤
│
└─ generate-data-model (20 min)

All three can run together, save ~25 minutes vs. sequential
Actual time: max(20, 15, 20) = 20 min instead of 20+15+20 = 55 min
```

```
Another parallel opportunity:
┌─ generate-tests (120 min)
│
scaffold (45 min) ┤─ implement (N days)
│
└─ setup-cicd (25 min)

After scaffold completes, tests + cicd can run in parallel during implement
```

---

## Dependency Matrix

Quick lookup of what each command requires:

| Command | Requires | Optional | Tier |
|---------|----------|----------|------|
| blueprint | — | problem-validation | 0 |
| sdl | — | blueprint | 0 |
| import | existing codebase | — | 0 |
| problem-validation | — | — | 0 |
| design-system | blueprint | — | 1 |
| generate-data-model | SDL entities | — | 1 |
| user-personas | — | problem-validation | 1 |
| deep-research | — | — | 7 |
| mvp-scope | blueprint | — | 7 |
| scaffold | blueprint, design-system, generate-data-model | — | 2 |
| scaffold-component | scaffold | — | 2 |
| implement | scaffold | blueprint | 3 |
| visualise | blueprint, scaffold | — | 3 |
| review | scaffold, code | — | 3 |
| generate-tests | scaffold | blueprint | 4 |
| security-scan | scaffold | — | 4 |
| accessibility-audit | scaffold | — | 4 |
| setup-cicd | scaffold | — | 5 |
| setup-monitoring | scaffold | — | 5 |
| load-test | scaffold | — | 5 |
| compliance | scaffold | security-scan | 6 |
| launch-check | scaffold, tests, monitoring | — | 6 |
| production-readiness | tests, monitoring, compliance | — | 6 |
| cost-estimate | blueprint | scaffold | 7 |
| technical-roadmap | blueprint | — | 7 |
| user-journeys | — | mvp-scope | 7 |
| pitch-deck | — | user-personas | 7 |
| wireframes | design-system | — | 7 |
| prototype | scaffold | design-system | 7 |
| prototype-iterate | prototype | — | 7 |
| sync-backlog | — | — | 7 |
| agent-spec | — | — | 7 |
| check-env | scaffold | — | 7 |
| publish-api-docs | scaffold | contracts | 7 |
| validate-consistency | — (any project state) | — | 7 |
| next-steps | — (any project state) | — | 7 |
| check-state | — (any project state) | — | 7 |
| launch-checklist | blueprint | — | 7 |
| onboarding-pack | — | — | 7 |
| hiring-brief | blueprint | — | 7 |
| compare-stack | — | — | 7 |
| complexity-check | blueprint | — | 7 |
| well-architected | blueprint | — | 7 |
| database-scaling | generate-data-model | — | 7 |
| seo | scaffold | — | 7 |
| analytics-setup | scaffold | — | 7 |
| disaster-recovery | production-readiness | setup-monitoring | 6 |
| i18n-setup | scaffold | — | 7 |
| setup-env | scaffold | — | 7 |
| export-diagrams | visualise | — | 7 |
| quick-spec | — | — | 7 |
| sprint-status | — (in-conversation) | — | 7 |

---

## Estimated Total Runtimes

By project goal:

| Goal | Critical Path | Total Time | Commands |
|------|---|---|---|
| **Concept Phase** | problem-validation | 30 min | 1-2 |
| **MVP Ready** | Tier 0-3 | 7-14 days | 5-7 |
| **Launchable** | Tier 0-6 | 9-17 days | 10-14 |
| **Enterprise-Ready** | Tier 0-7 | 11-20 days | 20-25 |
| **Full Scope** | All 54 commands | 30-60 days | 54 |

Note: Actual time depends heavily on `implement` duration (days to months).

---

## Using This Graph

### For `/architect:next-steps`

Use the prerequisite graph to:
1. **Score commands** — give higher scores to unblocked commands in critical path
2. **Calculate ETAs** — show total time from current state to launch
3. **Show blockers** — explain why a high-value command is blocked

### For `/architect:validate-consistency`

Use the graph to:
1. **Detect cascading failures** — if Tier 2 command failed, warn about Tier 3+ being at risk
2. **Recommend rerunning prerequisites** — if Tier 2 is stale, suggest rerun before Tier 3

### For `/architect:production-readiness`

Use the graph to:
1. **Check all required commands complete** — verify Path B (Launch-Ready) is done
2. **Block launch if gaps** — if any Tier 0-6 command missing, fail gate

### For Users Planning Work

Use the graph to:
1. **Understand sequencing** — see which commands must run before others
2. **Estimate timeline** — pick a critical path and estimate days/hours
3. **Identify parallelization** — find commands that can run together

---

## Updating the Graph

When a new command is added to the plugin:

1. **Identify tier:** Where does it fit (foundation, design, code gen, etc.)?
2. **List dependencies:** What must exist before this command runs?
3. **Estimate time:** How long does it take (include I/O time)?
4. **Update diagram:** Add to tier section and dependency matrix
5. **Update critical paths:** Does this change MVP or launch timelines?

---

## Related Documentation

- `/architect:next-steps` — uses graph to recommend commands
- `/architect:check-state` — validates state from completed commands
- `/architect:validate-consistency` — detects when prerequisites are incomplete
- `blocker-detection/SKILL.md` — identifies specific blockers
- `stage-detection/SKILL.md` — uses graph to understand project progression
