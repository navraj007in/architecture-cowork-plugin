---
description: Phased delivery plan with milestones, dependencies, risk gates, and resource planning
---

# /architect:technical-roadmap

## Trigger

`/architect:technical-roadmap`

## Purpose

Create a realistic, dependency-aware technical roadmap that sequences work into phases with clear milestones, exit criteria, and resource needs. Goes beyond a simple timeline to include risk gates, parallel workstreams, and decision points.

## Workflow

### Step 0: Prerequisites

Before doing anything else, check whether sufficient architecture context exists:

1. Check if `architecture-output/_state.json` exists and has a `tech_stack` object with at least one non-empty field
2. OR check if `solution.sdl.yaml` (or `sdl/` directory) exists at the project root

**If NEITHER condition is met:**

> "I need an architecture blueprint to generate a technical roadmap — it defines the components, tech stack, and scope that the roadmap is built around. Run `/architect:blueprint` first, then come back here."

**Stop immediately. Do NOT attempt to run blueprint yourself. Do NOT continue.**

If at least one condition is met, proceed to Step 1.

### Step 1: Gather Context

Read in this order:
1. `architecture-output/_state.json` — read first if it exists; use `project`, `tech_stack`, `components`, `entities`, `personas`, `mvp_scope`, `top_risks` directly — these replace intent.json and SDL for most roadmap decisions
2. `intent.json` — **only if `_state.json.project` is absent**; extract vision, constraints, timeline expectations
3. SDL — **only if `_state.json.tech_stack` or `_state.json.components` is absent**; check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files. Grep for `components:`, `tech:`, and `product:` blocks only — do NOT read the full file
4. `architecture-output/problem-validation.md` — risk assessment (read in full, typically small)
5. `architecture-output/cost-estimate.md` — budget constraints (read in full, typically small)
6. `architecture-output/data-model.md` — **only if `_state.json.entities` is absent**; if reading, Grep for the header/summary section only to get entity count and domain groupings
7. `architecture-output/user-personas.md` — **only if `_state.json.personas` is absent**; if reading, Grep for persona names and priority only
8. `architecture-output/deep-research.md` — **only if `_state.json.market_research` is absent**; if reading, Grep for competitive timeline pressure

Do NOT read `architecture-output/mvp-scope.md` — use `_state.json.mvp_scope` if available; otherwise derive scope from `intent.json` core_features and the SDL (check `solution.sdl.yaml` first; if absent, use the relevant `sdl/` module).

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

### Final Step: Log Activity

After writing all output files, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"technical-roadmap","outcome":"completed","files":["architecture-output/technical-roadmap.md"],"summary":"Generated phased technical roadmap with milestones, dependency graph, and contingency plans."}
```

Rules: append only — never overwrite. Single JSON object per line, no pretty-printing.

### Final Step: Update _state.json

After writing all output files, merge a completion marker into `architecture-output/_state.json`:
1. Read existing `_state.json` (or start with `{}`)
2. Merge the `roadmap` field shown below — do NOT overwrite other fields
3. Write back to `architecture-output/_state.json`

```json
{
  "roadmap": { "generated_at": "<ISO-8601>", "phases": <N> }
}
```

(Replace `<N>` with the actual number of phases generated.)

### Docs Publish (Optional)

After writing all files, silently probe both Confluence (`list_spaces limit:1`) and Notion (`notion_search query:"test" page_size:1`) to check which are connected.

**If Confluence is connected**, offer:
> "Confluence is connected. Publish this roadmap? Reply with the space key (e.g. `ARCH`), a Notion parent page ID, or `skip`."

- Space key → delegate to **confluence-publisher** with `artifact:"technical-roadmap"`, `projectName`, `spaceKey`, `projectDir`

**If Notion is connected** (and Confluence was not, or user prefers Notion):
> "Notion is connected. Publish this roadmap? Reply with a parent page ID or `skip`."

- Page ID → delegate to **notion-publisher** with `artifact:"technical-roadmap"`, `projectName`, `parentPageId`, `projectDir`

**If both connected**, offer both options in one message.
**If neither**, skip silently.

### Signal Completion

Emit the completion marker:

```
[TECHNICAL_ROADMAP_DONE]
```

This ensures the technical-roadmap phase is marked as complete in the project state.

## Output Rules

- Write the full deliverable to `architecture-output/technical-roadmap.md`
- Create the `architecture-output/` directory if it doesn't exist
- Be realistic about timelines — pad estimates by 30% for solo/small teams
- Include the dependency graph and critical path — these prevent planning errors
- Phase exit criteria must be specific and testable, not vague
- Reference specific features from `intent.json` by name (not from mvp-scope.md)
- Reference architecture components from SDL when available
- If any single output file exceeds ~15KB, split into `technical-roadmap-phases.md` and `technical-roadmap-resources.md` (and further parts if needed) and write an index file
- Use tables instead of prose for structured data (phases, milestones, resource allocation, contingency plans)
- Do NOT include the CTA footer
