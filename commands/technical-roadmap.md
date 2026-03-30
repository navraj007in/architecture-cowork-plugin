---
description: Phased delivery plan with milestones, dependencies, risk gates, and resource planning
---

# /architect:technical-roadmap

## Trigger

`/architect:technical-roadmap`

## Purpose

Create a realistic, dependency-aware technical roadmap that sequences work into phases with clear milestones, exit criteria, and resource needs. Goes beyond a simple timeline to include risk gates, parallel workstreams, and decision points.

## Workflow

### Step 1: Gather Context

Read these files if they exist:
- `intent.json` — product vision, constraints, timeline expectations
- `solution.sdl.yaml` or `sdl.yaml` — architecture components, tech stack, data model complexity
- `architecture-output/data-model.md` — entity count and complexity (if large, use Grep for the summary/header section only)
- `architecture-output/user-personas.md` — persona priorities
- `architecture-output/deep-research.md` — competitive timeline pressure
- `architecture-output/problem-validation.md` — risk assessment
- `architecture-output/cost-estimate.md` — budget constraints

Do NOT read `architecture-output/mvp-scope.md` — it can be a large output file. Instead, derive feature scope and complexity from `intent.json` core_features and `solution.sdl.yaml` architecture sections.

### Step 2: Define Roadmap Parameters

- **Team size assumption** — derive from intent.json or assume (solo founder / 2-person team / small team of 3-5)
- **Timeline target** — derive from intent.json or estimate based on MVP scope
- **Working cadence** — 2-week sprints assumed unless specified
- **Tech stack** — from SDL or intent.json

### Step 3: Phase Breakdown

Create 4-6 phases. For EACH phase:

#### Phase Header
- **Phase name** — descriptive (e.g., "Phase 1: Foundation & Infrastructure")
- **Duration** — X weeks (range if uncertain: "2-3 weeks")
- **Goal** — one sentence describing what's true at phase end that isn't true now
- **Theme** — what kind of work dominates (infra, features, integration, polish)

#### Deliverables

For each deliverable in the phase:

| Deliverable | Description | Complexity | Dependencies | Owner Role |
|-------------|-------------|-----------|--------------|------------|
| Auth system | JWT + OAuth2 with refresh tokens | M | DB schema | Backend |
| API scaffolding | Express + route structure + middleware | M | None | Backend |
| ... | ... | ... | ... | ... |

#### Workstream View

Show parallel workstreams within the phase:

```
Week 1-2:
  Backend:  [DB schema + migrations] → [Auth API endpoints]
  Frontend: [Project setup + routing] → [Auth UI (login/signup)]
  DevOps:   [CI/CD pipeline] → [Staging environment]

Week 3-4:
  Backend:  [Core API endpoints] → [Data validation]
  Frontend: [Core screens] → [API integration]
  DevOps:   [Docker setup] → [Monitoring]
```

#### Technical Decisions Required

Decisions that must be made during this phase:

| Decision | Options | Deadline | Impact if Delayed |
|----------|---------|----------|-------------------|
| ORM choice | Prisma vs Drizzle vs TypeORM | Week 1 | Blocks all DB work |
| Auth provider | Custom vs Auth0 vs Clerk | Week 1 | Blocks auth implementation |
| ... | ... | ... | ... |

#### Phase Exit Criteria

Specific, testable criteria that must ALL be true to move to the next phase:

- [ ] All Must-Have deliverables complete and merged
- [ ] CI/CD pipeline runs green on every push
- [ ] Auth flow works end-to-end (signup → login → protected route)
- [ ] API responds under 200ms for all endpoints under light load
- [ ] No Critical or High severity bugs open

#### Risk Gate

Risks specific to this phase and their triggers:

| Risk | Trigger | Response |
|------|---------|----------|
| Auth integration takes 2x estimate | Day 5 of a 3-day estimate | Switch to managed auth (Clerk/Auth0) |
| Database schema needs major redesign | After initial integration testing | Timebox to 2 days, then ship imperfect and iterate |
| ... | ... | ... |

### Step 4: Dependency Graph

Show inter-phase and inter-deliverable dependencies:

```
[DB Schema] ──→ [Auth API] ──→ [Auth UI] ──→ [Protected Routes]
     │                                              │
     └──→ [Core API] ──→ [Core UI] ────────────────┘
                │
                └──→ [Data Validation] ──→ [Integration Tests]
```

Identify the **critical path** — the longest chain of dependencies that determines the minimum project timeline.

### Step 5: Resource Plan

#### Team Allocation

| Role | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|------|---------|---------|---------|---------|
| Backend Dev | 100% | 80% | 60% | 40% |
| Frontend Dev | 80% | 100% | 100% | 80% |
| DevOps | 40% | 20% | 20% | 40% |
| Design | 60% | 40% | 20% | 20% |

#### Key Hires / External Needs

| Need | When | Why | Alternative if Can't Hire |
|------|------|-----|--------------------------|
| ... | Phase X | ... | ... |

### Step 6: Milestone Timeline

Visual timeline:

```
Month 1          Month 2          Month 3          Month 4
|──── Phase 1 ────|──── Phase 2 ────|── Phase 3 ──|── Phase 4 ──|
     Foundation        Core Features     Polish       Launch
         ▲                  ▲               ▲            ▲
    M1: Auth works    M2: Core loop   M3: Beta     M4: Public
                          complete     ready        launch
```

#### Milestone Definitions

| Milestone | Date Target | Definition of Done | Stakeholder Demo |
|-----------|------------|-------------------|-----------------|
| M1 | Week 2-3 | Auth + base API deployed to staging | Internal |
| M2 | Week 5-6 | Core user loop works end-to-end | Internal + 3-5 beta users |
| M3 | Week 8-9 | All Must Haves done, Should Haves triaged | Beta group (10-20 users) |
| M4 | Week 10-12 | Launch checklist complete, monitoring active | Public |

### Step 7: Contingency Plans

| Scenario | Trigger | Response |
|----------|---------|----------|
| Behind by 1+ week after Phase 1 | Exit criteria not met by deadline | Cut all Could Haves, reduce Should Haves by 50% |
| Key technical risk materializes | Risk gate triggered | Execute specified response, re-estimate remaining phases |
| Team member unavailable | Unplanned absence >3 days | Shift to single-workstream mode, extend timeline |
| Scope creep pressure | New feature requests during build | Add to backlog, evaluate only at phase boundaries |

### Step 8: Post-MVP Roadmap Preview

Brief look at what comes after launch:

| Version | Timeline | Key Features | Goal |
|---------|----------|-------------|------|
| v1.1 | +2-4 weeks | Should Haves that didn't make MVP, critical user feedback | Retention improvement |
| v1.5 | +1-2 months | First Could Haves, analytics-driven features | Growth features |
| v2.0 | +3-6 months | Major new capabilities, platform expansion | Market expansion |

## Output Rules

- Write the full deliverable to `architecture-output/technical-roadmap.md`
- Create the `architecture-output/` directory if it doesn't exist
- Be realistic about timelines — pad estimates by 30% for solo/small teams
- Include the dependency graph and critical path — these prevent planning errors
- Phase exit criteria must be specific and testable, not vague
- Reference specific features from `intent.json` by name (not from mvp-scope.md)
- Reference architecture components from SDL when available
- Keep each output file under 15KB — split into `technical-roadmap-phases.md` and `technical-roadmap-resources.md` if needed
- Use tables instead of prose for structured data (phases, milestones, resource allocation, contingency plans)
- Do NOT include the CTA footer
