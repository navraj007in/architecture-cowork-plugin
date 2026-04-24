# Pre-Execution Validation Skill

Validates that a command can execute before running it. Prevents wasted time by stopping early if prerequisites are missing, state is invalid, or conflicting outputs exist.

## When to Use

Invoke this skill at the start of every command to:
1. **Fail fast** — detect impossible prerequisites before spending 30 minutes generating output
2. **Provide guidance** — tell users exactly what's missing and how to fix it
3. **Prevent cascading failures** — stop if earlier commands didn't complete successfully
4. **Guard against stale state** — warn if state file is outdated

## Input

Provide:
1. Target command name (e.g., `generate-tests`, `scaffold`)
2. Current project state (`_state.json` + `_activity.jsonl`)
3. Scaffold/source code (if checking code-generation prerequisites)

## Output

A validation result object:

```json
{
  "command": "generate-tests",
  "can_execute": true,
  "validation_passed": true,
  "warnings": [],
  "blockers": [],
  "state_health": 0.95,
  "execution_readiness": 0.98,
  "action": "proceed"
}
```

Or (if blocking):

```json
{
  "command": "generate-tests",
  "can_execute": false,
  "validation_passed": false,
  "blockers": [
    {
      "type": "missing_scaffold",
      "message": "Scaffold doesn't exist. Run /architect:scaffold first.",
      "severity": "critical",
      "fix": "/architect:scaffold"
    }
  ],
  "action": "block"
}
```

## Validation Categories

### 1. Input Availability Checks

**Check:** Required files exist and are readable

| Command | Required files | Fail if missing? |
|---------|---|---|
| `scaffold` | `solution.sdl.yaml` or `_state.json` | Critical |
| `scaffold-component` | Existing scaffold | Critical |
| `generate-tests` | Source files from scaffold | Critical |
| `design-system` | Blueprint or SDL design section | Medium |
| `implement` | Existing scaffold | Critical |
| `cost-estimate` | `_state.json` with tech_stack | Medium |
| `setup-monitoring` | Scaffold service structure | Medium |
| `generate-data-model` | SDL with entities or existing schema | Medium |

**Validation logic:**
```javascript
for each required_file in command.requirements:
  if file_exists(required_file) == false:
    severity = command.fail_if_missing[required_file]
    if severity == "critical":
      return {can_execute: false, blockers: [...]}
    else:
      return {can_execute: true, warnings: [...]}
```

### 2. State Validity Checks

**Check:** `_state.json` passes schema validation and contains no contradictions

**Validations:**
- ✅ JSON syntax is valid (not corrupted)
- ✅ Required fields for current stage exist
- ✅ No type errors (colors are hex, ports are numbers, versions are semver)
- ✅ No critical conflicts (same port for two components, contradictory colors)
- ✅ State file is not ancient (>90 days old)

**Validation logic:**
```javascript
if state_json_syntax_invalid:
  return {can_execute: false, blockers: ["State file corrupted"]}
if not state.project.stage:
  return {can_execute: false, blockers: ["Stage not detected"]}
if has_critical_conflicts(state):
  return {can_execute: false, blockers: ["State has " + N + " critical conflicts"]}
if days_since(state.last_updated) > 90:
  return {can_execute: true, warnings: ["State file is " + age + " days old"]}
```

### 3. Activity Log Continuity Checks

**Check:** Previous commands completed successfully; no cascading failures

**Validations:**
- ✅ If this command depends on X, verify X completed (outcome: "success")
- ✅ If X failed recently, don't run this command
- ✅ If X partially succeeded, warn but allow proceeding

**Validation logic:**
```javascript
const prerequisites = command.prerequisites; // e.g., ["scaffold"]
for each prereq in prerequisites:
  const last_run = activity_log.filter(a => a.phase == prereq).last();
  if last_run.outcome == "failed":
    return {can_execute: false, blockers: [prereq + " failed last time"]}
  if last_run.outcome == "partial":
    return {can_execute: true, warnings: [prereq + " only partially succeeded"]}
  if days_since(last_run.ts) > 7 and command.is_sensitive:
    return {can_execute: true, warnings: [prereq + " hasn't run in 7 days; consider rerunning"]}
```

### 4. Conflict Detection Checks

**Check:** Consistency validator found no critical issues (or allowed conflicts for this command)

**Validations:**
- ✅ No design token contradictions (if design-related command)
- ✅ No component port conflicts (if scaffold-related command)
- ✅ No stale outputs blocking this command
- ⚠️ (warning) Some non-critical conflicts exist

**Validation logic:**
```javascript
const consistency_report = load("consistency-report.md");
const critical_conflicts = consistency_report.critical_conflicts
  .filter(c => c.affects_command == command.name);
if critical_conflicts.length > 0:
  return {can_execute: false, blockers: critical_conflicts}
const warnings = consistency_report.warnings
  .filter(w => w.affects_command == command.name);
if warnings.length > 0:
  return {can_execute: true, warnings: warnings}
```

### 5. Codebase Validity Checks (for code-generation commands)

**Check:** Scaffold is not broken (builds, no syntax errors)

**Validations for commands like `implement`, `generate-tests`, `scaffold-component`:**
- ✅ TypeScript/code syntax is valid (for TS projects)
- ✅ Project builds without errors
- ✅ No dependency conflicts (package.json is valid)
- ✅ No merge conflict markers in source

**Validation logic:**
```javascript
if command.type == "code-generation":
  // Quick syntax check without full build
  const syntax_result = run_linter();
  if syntax_result.errors > 10:
    return {can_execute: false, blockers: ["Codebase has " + errors + " syntax errors"]}
  if package_json_invalid:
    return {can_execute: false, blockers: ["package.json is malformed"]}
```

---

## Execution Readiness Scoring

Calculate readiness as a 0-1.0 score:

```javascript
score = 0.0;

// Inputs (0-0.3)
score += file_exists(required_file) ? 0.1 : 0.0;  // × 3 files max

// State health (0-0.3)
score += state_is_valid ? 0.15 : 0.0;
score += stage_is_detected ? 0.15 : 0.0;

// Activity continuity (0-0.2)
score += prerequisites_succeeded ? 0.1 : 0.0;
score += activity_log_recent ? 0.1 : 0.0;

// Conflicts (0-0.2)
score += no_critical_conflicts ? 0.1 : 0.0;
score += no_codebase_errors ? 0.1 : 0.0;

// Final score
return Math.min(score, 1.0);
```

**Interpretation:**
- **0.9-1.0:** Excellent — execute immediately
- **0.7-0.9:** Good — proceed with warnings
- **0.5-0.7:** Risky — fix warnings before proceeding
- **<0.5:** Dangerous — fix blockers before executing

---

## Blocker vs. Warning Classification

### Blockers (prevent execution)

A blocker causes `can_execute = false`. Stop immediately and show user:

| Blocker type | Message | What to do |
|---|---|---|
| **missing_required_input** | "Scaffold doesn't exist. Run `/architect:scaffold` first." | Run prerequisite command |
| **invalid_state_syntax** | "_state.json is corrupted (invalid JSON). Run `/architect:check-state --fix` to repair." | Fix state file |
| **critical_conflict** | "Design token contradiction detected. Run `/architect:validate-consistency --fix` first." | Resolve conflicts |
| **cascading_failure** | "`scaffold` command failed last time. Fix and rerun it before trying this command." | Rerun prerequisite |
| **codebase_error** | "Codebase has 15 syntax errors. Fix these before generating tests." | Fix syntax errors |
| **missing_dependency** | "Python is not installed. This command requires Python 3.8+." | Install dependency |

### Warnings (proceed with caution)

A warning allows execution (`can_execute = true`) but shows user:

| Warning type | Message | Impact |
|---|---|---|
| **stale_output** | "Cost estimate is 30 days old and may be inaccurate." | Estimates might be off |
| **partial_prerequisite** | "`scaffold-component` only partially succeeded. Some components may be incomplete." | Generated output may be incomplete |
| **state_age** | "_state.json last updated 45 days ago. Consider running `/architect:check-state` to validate." | State might be stale |
| **minor_conflict** | "One design token doesn't match state. Output will use state colors." | Output might differ from expectations |
| **recommended_rerun** | "`blueprint` hasn't run in 14 days. Consider rerunning to check for updates." | Architecture might have changed |

---

## Per-Command Validation Rules

### `/architect:scaffold`

**Blockers:**
- ❌ No SDL (`solution.sdl.yaml`) and no state (`_state.json`)
- ❌ State has no `project.name` or `tech_stack`

**Warnings:**
- ⚠️ State is older than 30 days
- ⚠️ No design tokens (will use defaults)

---

### `/architect:scaffold-component`

**Blockers:**
- ❌ No existing scaffold (`src/` directory)
- ❌ Component name already exists in scaffold

**Warnings:**
- ⚠️ Design tokens outdated (>14 days)

---

### `/architect:generate-tests`

**Blockers:**
- ❌ No scaffold source files to test
- ❌ No test framework specified

**Warnings:**
- ⚠️ Codebase has untested syntax errors
- ⚠️ No entities defined (tests will be generic)

---

### `/architect:design-system`

**Blockers:**
- ❌ No `_state.json` with design section

**Warnings:**
- ⚠️ State colors are very different from current tokens (large change)

---

### `/architect:setup-monitoring`

**Blockers:**
- ❌ No scaffold service structure
- ❌ No monitoring provider specified in state

**Warnings:**
- ⚠️ State has no integrations list (monitoring provider not in tech stack)

---

### `/architect:generate-data-model`

**Blockers:**
- ❌ No entities defined in SDL or state

**Warnings:**
- ⚠️ Existing schema is very different from proposed entities

---

### `/architect:cost-estimate`

**Blockers:**
- ❌ No tech stack specified

**Warnings:**
- ⚠️ State has no components (estimate will be blank)

---

### `/architect:blueprint`

**Blockers:**
- ❌ None (can run on empty project)

**Warnings:**
- ⚠️ None

---

## Validation Timing

When to run validation:

| Scenario | When to validate |
|---|---|
| User runs `/architect:command` | Before starting command execution |
| User runs `/architect:command --force` | Validate, but allow override |
| Pre-commit hook | Validate before allowing commit |
| CI/CD pipeline | Validate at build start |

---

## Implementation Integration

### In Command Handlers

```pseudo
function execute_command(command_name, options):
  1. Call validate_pre_execution(command_name, state, activity_log)
  2. If validation.can_execute == false:
     - Print blockers to user
     - Show remediation steps
     - Exit with code 1
  3. If validation.can_execute == true and validation.warnings:
     - Print warnings to user
     - If --force flag not provided:
       - Ask user to confirm? Yes/No
       - If No: exit
     - Continue execution
  4. Execute command
```

### Error Messages

When validation fails, show user:

```
❌ Cannot run /architect:generate-tests

Blocker: Scaffold doesn't exist (required for testing code)

What to do:
1. Run /architect:scaffold
2. Wait for scaffold to complete (est. 15 minutes)
3. Then run /architect:generate-tests again

Why this matters:
Tests require source code to analyze. Scaffold generates the initial code structure
that tests will verify.

Questions? Run /architect:next-steps for command recommendations.
```

---

## State Health Metrics

Calculate "state health" score (0-1.0) to indicate overall project state validity:

```javascript
state_health = 0.0;

// Syntax
state_health += state_json_valid ? 0.2 : 0.0;

// Schema compliance
state_health += state_matches_schema ? 0.2 : 0.0;

// No critical conflicts
state_health += no_critical_conflicts ? 0.2 : 0.0;

// Recent updates
state_health += days_since(last_update) < 7 ? 0.2 : 0.0;

// Consistency pass
state_health += consistency_report.critical == 0 ? 0.2 : 0.0;

return state_health;
```

**Health interpretation:**
- **0.9-1.0:** Excellent
- **0.7-0.9:** Good
- **0.5-0.7:** Fair (has issues)
- **<0.5:** Poor (needs fixes)

Display in command output:
```
Project Health: 0.87 (Good) ✅
- State syntax: ✅
- Schema compliance: ✅
- No conflicts: ✅ (0 critical)
- Recently updated: ✅ (3 days ago)
- Consistency: ✅ (no violations)

Ready to proceed.
```

---

## Related Commands

- `/architect:check-state` — validates state schema (different from pre-execution validation)
- `/architect:validate-consistency` — checks for conflicts (part of pre-execution checks)
- `/architect:next-steps` — recommends commands to fix blockers
- All other `/architect:` commands — call pre-execution validation at start
