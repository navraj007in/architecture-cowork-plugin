# Blocker Detection Skill

Identifies missing prerequisites (blockers) for each `/architect:` command based on `_state.json` field requirements. Used by `/architect:next-steps`, `/architect:check-state`, and validation commands to determine which commands can run and which are blocked.

## When to Use

Invoke this skill to determine if a command can execute or what prerequisites must be completed first. Blocker detection:
- Prevents wasted time on commands that will fail due to missing inputs
- Shows users exact remediation steps ("Run X first, then retry Y")
- Enables dependency graph visualization
- Powers `/architect:next-steps` prerequisite analysis

## Input

Provide:
1. `_state.json` (current project state)
2. Target command name (e.g., `"generate-tests"`, `"setup-monitoring"`)
3. Optional: verbose mode for detailed blocker reasoning

## Output

A blocker analysis object:

```json
{
  "command": "generate-tests",
  "can_execute": false,
  "blocking_count": 1,
  "blockers": [
    {
      "blocker_id": "B-001",
      "severity": "critical",
      "field": "components",
      "reason": "Generate-tests needs scaffolded components to generate tests from",
      "missing": true,
      "fix": "Run /architect:scaffold first",
      "fix_eta_minutes": 15,
      "blocking_next_steps": [
        "generate-tests",
        "build-verification",
        "production-readiness"
      ]
    }
  ],
  "unblocked_by": [
    "scaffold",
    "scaffold-component"
  ],
  "dependency_chain": "scaffold (15min) → generate-tests (45min) → production-readiness (30min)",
  "total_unblock_time_minutes": 90
}
```

## Blocker Categories

### 1. Missing SDL or State File (CRITICAL)

**Blocker structure:**
```json
{
  "blocker_id": "B-1xx",
  "severity": "critical",
  "type": "missing_input",
  "field": "solution.sdl.yaml OR _state.json",
  "reason": "Cannot proceed without architecture definition",
  "fix": "Run /architect:blueprint or /architect:sdl first",
  "fix_eta_minutes": 20
}
```

**Commands affected:**
- Any command that reads SDL (scaffold, design-system, generate-data-model, etc.)
- Any command that depends on state (check-state, next-steps, production-readiness, etc.)

### 2. Missing Scaffold (CRITICAL for code-generation commands)

**Blocker structure:**
```json
{
  "blocker_id": "B-2xx",
  "severity": "critical",
  "type": "missing_scaffold",
  "field": "components[].name",
  "reason": "Command needs scaffolded components to generate code for",
  "fix": "Run /architect:scaffold first",
  "fix_eta_minutes": 15
}
```

**Commands affected:**
- `generate-tests` (needs components to test)
- `security-scan` (needs code to scan)
- `setup-monitoring` (needs service structure to instrument)
- `generate-docs` (needs files to document)
- `accessibility-audit` (needs rendered components)

### 3. Missing Data Model (MEDIUM for features that need entity definitions)

**Blocker structure:**
```json
{
  "blocker_id": "B-3xx",
  "severity": "medium",
  "type": "missing_data_model",
  "field": "entities",
  "reason": "Command generates tests/docs that reference entity types",
  "fix": "Run /architect:generate-data-model first",
  "fix_eta_minutes": 10
}
```

**Commands affected:**
- `generate-tests` (better test fixtures with entity schema)
- `generate-data-model` (needs entities first)
- `load-test` (needs entity sizes for payload generation)

### 4. Missing Design Tokens (MEDIUM for UI commands)

**Blocker structure:**
```json
{
  "blocker_id": "B-4xx",
  "severity": "medium",
  "type": "missing_design_tokens",
  "field": "design (primary color, fonts, etc.)",
  "reason": "Command needs design direction to apply tokens consistently",
  "fix": "Run /architect:design-system first",
  "fix_eta_minutes": 15
}
```

**Commands affected:**
- `scaffold-component` (applies design tokens to new components)
- `prototype` (needs design palette)
- `wireframes` (needs color/font specs)

### 5. Missing Blueprint (LOW-MEDIUM for planning commands)

**Blocker structure:**
```json
{
  "blocker_id": "B-5xx",
  "severity": "low",
  "type": "missing_blueprint",
  "field": "blueprint",
  "reason": "Blueprint provides architecture decisions and patterns",
  "fix": "Run /architect:blueprint first",
  "fix_eta_minutes": 20
}
```

**Commands affected:**
- `cost-estimate` (better estimates with architecture detail)
- `load-test` (needs service interaction diagram)
- `technical-roadmap` (needs architecture context)

### 6. Missing Compliance/Monitoring (LOW-MEDIUM for launch gates)

**Blocker structure:**
```json
{
  "blocker_id": "B-6xx",
  "severity": "medium",
  "type": "missing_compliance",
  "field": "monitoring OR compliance",
  "reason": "Launch gates require observability and regulatory sign-off",
  "fix": "Run /architect:setup-monitoring and /architect:compliance first",
  "fix_eta_minutes": 60
}
```

**Commands affected:**
- `launch-check` (gates on monitoring + compliance)
- `production-readiness` (gates on enterprise readiness)

## Blocker Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| **critical** | Command CANNOT run at all without this prerequisite | Block immediately, show remediation path |
| **medium** | Command can run with degraded output; results less useful without this | Warn user, allow proceed with caveats |
| **low** | Command runs fully; output would be richer with this | Inform user, suggest but don't force |

## Dependency Chain Visualization

Show the full unblocking path as a text diagram:

```
Current blockers: scaffold

Unblock path:
  scaffold (15 min)
    ↓
  install-deps (5 min)
    ↓
  build-verify (10 min)
    ↓
  generate-tests (45 min)
    ↓
  production-readiness (30 min)

Total time: 105 minutes
```

## Blocker Resolution Rules

For each blocker, show:
1. **Blocker ID** (B-NNN for auditability)
2. **Severity** (critical/medium/low)
3. **Field that's missing**
4. **Human explanation** (1 sentence why it matters)
5. **Fix command** (what to run)
6. **ETA** (minutes to unblock)
7. **Cascading effects** (what else becomes unblocked after this)

## Commands and Their Blockers

### Blueprint / Architecture Commands

| Command | Blockers | Severity | Fix |
|---------|----------|----------|-----|
| `blueprint` | None (can run on empty state) | — | — |
| `sdl` | None (can run on empty state) | — | — |
| `design-system` | `design` field from blueprint | low | Run `/architect:blueprint` first |
| `generate-data-model` | `entities` in SDL; `components` in scaffold | medium | Run `/architect:scaffold` and provide entities in SDL |
| `visualise` | SDL or state file | critical | Run `/architect:blueprint` or `/architect:sdl` |

### Code Generation Commands

| Command | Blockers | Severity | Fix |
|---------|----------|----------|-----|
| `scaffold` | SDL (`solution.sdl.yaml` or state) | critical | Run `/architect:blueprint` first |
| `scaffold-component` | Existing scaffold | critical | Run `/architect:scaffold` first |
| `implement` | Existing scaffold | critical | Run `/architect:scaffold` first |
| `generate-tests` | Components (scaffold) + test framework choice | critical | Run `/architect:scaffold` first |
| `review` | Source files | critical | Run `/architect:scaffold` first |

### Production & Observability Commands

| Command | Blockers | Severity | Fix |
|---------|----------|----------|-----|
| `setup-monitoring` | Service structure (scaffold) | critical | Run `/architect:scaffold` first |
| `setup-cicd` | Scaffold + git repo | critical | Run `/architect:scaffold` and `git init` |
| `compliance` | Scaffold (for code scanning) | medium | Run `/architect:scaffold` first (can scan SDL for policy gaps) |
| `security-scan` | Source files | medium | Run `/architect:scaffold` first |
| `load-test` | Scaffold + service endpoints | medium | Run `/architect:scaffold` and `/architect:implement` |
| `launch-check` | Scaffold + build artifacts | critical | Run `/architect:scaffold` and build locally |
| `production-readiness` | Monitoring + compliance + tests | critical | Run monitoring, compliance, and generate-tests first |

### Documentation & Planning Commands

| Command | Blockers | Severity | Fix |
|---------|----------|----------|-----|
| `generate-docs` | Scaffold (optional) | low | Run `/architect:scaffold` for better docs, but can generate from SDL alone |
| `cost-estimate` | Tech stack + architecture details | low | Run `/architect:blueprint` for better estimates |
| `technical-roadmap` | Blueprint | low | Run `/architect:blueprint` first |
| `user-journeys` | Personas + use cases | low | Provide in SDL or use `/architect:user-personas` |
| `problem-validation` | Problem statement | low | Define in SDL |

## Usage in Commands

**From `/architect:next-steps`:**
```pseudo
for each candidate_command in [top_10_commands]:
  blockers = blocker_detection(candidate, state)
  if blockers.can_execute == false:
    score -= dependency_cost(blockers.blocking_count)
    show blocker count in recommendation
    show unblock_eta in time estimate
  else:
    score += points (command is ready)
```

**From `/architect:check-state`:**
```pseudo
for each command:
  blockers = blocker_detection(command, state)
  if blockers.critical_count > 0:
    report "Command X blocked by Y. Run Z to unblock."
```

**From user error handling:**
```pseudo
if command fails with "missing prerequisite":
  blockers = blocker_detection(command, state)
  show user: "I need X to continue. Run Y first (est. N minutes). See dependency chain above."
```

## Edge Cases

### Command is blocked by itself
**Example:** `scaffold-component` exists but no initial scaffold

```json
{
  "command": "scaffold-component",
  "can_execute": false,
  "blockers": [{
    "reason": "Need initial scaffold with base structure first",
    "fix": "Run /architect:scaffold to create the initial project structure"
  }]
}
```

### Multiple independent paths to unblock
**Example:** `production-readiness` needs both monitoring AND compliance

```json
{
  "command": "production-readiness",
  "can_execute": false,
  "blockers": [
    { "fix": "Run /architect:setup-monitoring (30 min)" },
    { "fix": "Run /architect:compliance (20 min)" }
  ],
  "note": "Paths are independent; can run in parallel"
}
```

### Optional blocker
**Example:** `generate-tests` works without entities, but better with them

```json
{
  "command": "generate-tests",
  "can_execute": true,
  "blockers": [{
    "severity": "low",
    "type": "missing_entities",
    "reason": "Tests will be generic without entity type information",
    "fix": "Run /architect:generate-data-model for richer fixtures"
  }],
  "note": "Can proceed, but recommend completing blocker first"
}
```

## Implementation Notes

- **Fast lookup:** Blockers are statically defined per command (not computed from graph analysis)
- **No cascades beyond 3 levels:** If unblocking X requires Y which requires Z, show Z but don't compute full graph beyond 3 levels
- **Optimistic:** if a command might work without a blocker (e.g., generate-tests can work with just SDL), mark blocker as `"can_skip": true` with a warning
- **Audit trail:** every blocker detection gets a timestamp and can be logged to `_activity.jsonl` for investigation

## Related Commands

- `/architect:next-steps` — uses blockers to calculate recommendation scores and unblock ETAs
- `/architect:check-state` — uses blockers to recommend prerequisite commands
- `/architect:production-readiness` — uses blockers to gate launch (critical blockers = launch not ready)
- `skills/dependency-graph` — visualizes full command dependency topology
