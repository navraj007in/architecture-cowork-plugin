# Stage Detection Skill

Detects the current project stage (concept → mvp → growth → enterprise) based on `_state.json` field presence and completeness. Used by `/architect:next-steps`, `/architect:check-state`, and roadmap commands.

## When to Use

Invoke this skill when you need to determine what stage a project is at based on its state file. Stage detection drives:
- Command recommendations (what to run next)
- Required fields validation (what should exist at this stage)
- Risk assessment (what gaps are critical for this stage)
- Success criteria (MVP = basic components; Growth = 10+ entities; Enterprise = monitoring + compliance)

## Input

Read `architecture-output/_state.json` from the project. If missing, treat as "concept" stage.

## Output

A stage object:
```json
{
  "stage": "growth",
  "confidence": 0.95,
  "detected_at": "2026-04-24T14:32:10Z",
  "rationale": "Has 12 entities, design tokens, blueprint, but missing tests and monitoring",
  "met_criteria": ["project.name", "tech_stack", "components", "entities", "design", "blueprint"],
  "missing_criteria": ["test_suite", "monitoring", "compliance"],
  "next_stage_blockers": ["80% test coverage (currently 0%)", "observability setup (currently none)"],
  "stage_path": "growth → enterprise in ~3 months"
}
```

## Detection Algorithm

```
if _state.json missing or _state.json.project.name missing:
  stage = "concept"

elif missing tech_stack OR missing components:
  stage = "mvp-planning"

elif missing entities OR missing blueprint:
  stage = "mvp"

elif missing test_suite AND (entities count < 10 OR no_monitoring):
  stage = "growth"

elif missing monitoring OR missing compliance:
  stage = "growth"

else if has monitoring AND has compliance AND has >= 15 entities AND test_coverage >= 80%:
  stage = "enterprise"

else:
  stage = "growth"  // most projects land here
```

## Confidence Scoring

Confidence (0.0 → 1.0) reflects whether the detected stage matches the project's actual state:

| Confidence | Meaning | When it happens |
|---|---|---|
| 1.0 | Certain | Stage fields perfectly match expected set (all met, all missing) |
| 0.9 | Very confident | One expected field has inconsistent data (e.g., `test_suite.coverage_target` exists but no actual tests) |
| 0.8 | Confident | Two fields inconsistent or ambiguous (e.g., has monitoring but no compliance) |
| 0.7 | Reasonable | Three+ fields are stale or contradictory |
| < 0.7 | Low | State file severely corrupted or contradicts itself (rare) |

**Example low-confidence scenario:**
```json
{
  "project.stage": "mvp",           // manually set to mvp
  "entities": 20,                   // but has 20 entities (growth indicator)
  "test_suite": { "coverage": 0 },  // has test struct but 0 coverage
  "monitoring": null,               // monitoring not set up
  "confidence": 0.65,
  "note": "Mixed signals: test_suite field exists but empty; entities suggest growth; monitoring missing"
}
```

## Rationale Generation

Generate a 1-2 sentence summary of why the project is at this stage:

| Stage | Example Rationale |
|-------|---|
| concept | No SDL or state file yet. This is the idea stage; ready for market research. |
| mvp-planning | Defined tech stack but no scaffolded components. Ready to scaffold and start building. |
| mvp | Scaffolded components exist with basic features. Needs testing and hardening before growth. |
| growth | 10+ entities with complex logic, design tokens, but missing test coverage and observability. Critical to add tests and monitoring before scaling. |
| enterprise | Full testing, monitoring, compliance setup. Ready for production scale and regulatory scrutiny. |

## Met Criteria vs. Missing Criteria

For each stage, list fields that ARE present (met_criteria) and NOT present (missing_criteria):

**Growth stage example:**
```json
"met_criteria": [
  "project.name",
  "project.description", 
  "tech_stack",
  "components",
  "entities",
  "design",
  "blueprint",
  "personas"
],
"missing_criteria": [
  "test_suite",
  "monitoring",
  "compliance",
  "load_testing"
]
```

These lists help users understand what they have accomplished and what's needed next.

## Next Stage Blockers

For the transition to the next stage, identify 2-3 critical blockers with estimated effort:

**Growth → Enterprise blockers example:**
```json
"next_stage_blockers": [
  "80% test coverage (currently 0%; est. 2 weeks with 2 engineers)",
  "Monitoring setup (Datadog/Prometheus; est. 1 week)",
  "Security compliance audit (est. 2 weeks)"
]
```

Blockers drive recommendations in `/architect:next-steps`.

## Stage Path Estimate

Project lifecycle estimate based on current staffing implied by scope:

| Trajectory | When | Example |
|---|---|---|
| Immediate (same week) | If stage is concept or just started mvp | "mvp in 3-5 days with 3-person team" |
| Short term (1-2 months) | If stage is growth and team is active | "growth → enterprise in 4-6 weeks with current pace" |
| Long term (3+ months) | If growth with partial coverage | "enterprise in 3+ months at current velocity" |

## Stale State Detection

If `_state.json` hasn't been updated in 30+ days:
- Confidence drops to 0.7 or lower
- Add note: "State file is 35 days old; detected stage may not reflect actual progress"
- Recommend running `/architect:check-state` to validate and refresh

## Usage in Commands

**From `/architect:next-steps`:**
```pseudo
1. Load _state.json
2. Call stage-detection skill
3. Use returned stage to:
   - Filter candidates (only recommend commands for this stage)
   - Score by urgency (higher urgency for next-stage blockers)
   - Explain why recommendation is timely
```

**From `/architect:check-state`:**
```pseudo
1. Load _state.json
2. Call stage-detection skill
3. Validate that:
   - All required fields for this stage exist
   - No inconsistencies (test_suite exists but coverage is 0)
   - Report missing fields as warnings for stage transition
```

**From `/architect:production-readiness`:**
```pseudo
1. Load _state.json
2. Call stage-detection skill
3. If stage != "enterprise": block and show blockers to reach enterprise
4. If stage == "enterprise": proceed with launch checks
```

## Implementation Notes

- **No writes**: this skill reads only, does not modify state
- **Deterministic**: same input always produces same stage (unless state file has been updated)
- **Fast**: analyze only required fields (no deep traversal of entities array)
- **Friendly failures**: if state file is missing, return stage: "concept" with confidence 1.0 (not an error)
- **Timestamp all decisions**: include `detected_at` ISO-8601 timestamp for audit trail

## Examples

### Concept Project
```json
{
  "stage": "concept",
  "confidence": 1.0,
  "rationale": "No project state yet. Ready for market research and problem validation.",
  "met_criteria": [],
  "missing_criteria": ["project.name", "tech_stack", "components"],
  "next_stage_blockers": [
    "Define project name and description",
    "Research market and competitors",
    "Finalize tech stack choice"
  ],
  "stage_path": "concept → mvp-planning in 1-2 weeks"
}
```

### MVP Project
```json
{
  "stage": "mvp",
  "confidence": 0.95,
  "rationale": "Scaffolded components with basic features. Ready to add tests and observability for stability.",
  "met_criteria": ["project.name", "tech_stack", "components", "design"],
  "missing_criteria": ["entities", "blueprint", "test_suite", "monitoring"],
  "next_stage_blockers": [
    "Entity schema definition (est. 3 days)",
    "Unit & integration tests (est. 5 days; need 60%+ coverage)",
    "Basic monitoring setup (est. 2 days)"
  ],
  "stage_path": "mvp → growth in 2-3 weeks"
}
```

### Growth Project
```json
{
  "stage": "growth",
  "confidence": 0.92,
  "rationale": "Complex data model (12 entities) with design tokens and blueprint. Missing test coverage and observability for safe scaling.",
  "met_criteria": ["project.name", "tech_stack", "components", "entities", "design", "blueprint", "personas"],
  "missing_criteria": ["test_suite", "monitoring", "compliance"],
  "next_stage_blockers": [
    "Unit & integration test suite (80% coverage target; est. 3 weeks)",
    "Monitoring setup (metrics, traces, logs; est. 1 week)",
    "Security compliance review (est. 2 weeks)"
  ],
  "stage_path": "growth → enterprise in 6-8 weeks at current velocity"
}
```

### Enterprise Project
```json
{
  "stage": "enterprise",
  "confidence": 0.98,
  "rationale": "Full production-hardening: tests (87%), monitoring, compliance controls, load testing plan. Ready for scale and regulatory scrutiny.",
  "met_criteria": ["project.name", "tech_stack", "components", "entities", "design", "blueprint", "personas", "test_suite", "monitoring", "compliance", "load_testing"],
  "missing_criteria": [],
  "next_stage_blockers": [],
  "stage_path": "enterprise: focus on optimization, scalability, and incident response"
}
```

## Related Commands

- `/architect:next-steps` — uses stage to recommend high-ROI commands
- `/architect:check-state` — uses stage to validate required fields
- `/architect:production-readiness` — uses stage to gate launch
- `/architect:roadmap` — uses stage to forecast milestones
