---
description: Cross-command consistency validator — detects conflicts between outputs from different /architect: commands
---

# /architect:validate-consistency

Scans all architecture-output files and detects conflicts between outputs from different commands (e.g., scaffold creates a component that blueprint says shouldn't exist, or design tokens contradict _state.json colors). Reports severity-categorized conflicts and suggests resolution order.

## Trigger

```
/architect:validate-consistency
/architect:validate-consistency [--fix]      # auto-fix simple conflicts
/architect:validate-consistency [--detailed] # show conflict reasoning
/architect:validate-consistency [--rules <rule-set>]  # validate against specific rule set
```

## Purpose

When 54+ commands write to the same architecture-output directory over weeks of work, inconsistencies accumulate:

1. **Drift:** blueprint says component X has feature Y, but scaffold doesn't generate Y
2. **Contradictions:** design-system sets primary color to #f97316, but _state.json.design.primary is #0ea5e9
3. **Stale outputs:** cost-estimate ran 30 days ago with 8 components, but scaffold now has 12 components
4. **Schema violations:** component in scaffold.json has port "3000" (string), but _state.json expects number
5. **Missing links:** entities in _state.json reference fields that don't exist in data-model output

This command scans the entire state + architecture-output and reports all conflicts with clear remediation.

## Input

No required input. Reads:
- `architecture-output/_state.json`
- `architecture-output/_activity.jsonl`
- `architecture-output/*.md` (all generated docs)
- `architecture-output/contracts/` (if present)
- `architecture-output/design-system/` (if present)
- Project source files (if scaffolded)

## Output Files

**1. `architecture-output/consistency-report.md`** (always generated)

```markdown
# Consistency Validation Report

**Generated:** 2026-04-24 14:32:10  
**Project:** my-startup  
**Scan scope:** 52 files analyzed, 8 conflicting findings

---

## Summary

✅ **Pass Rate:** 44/52 outputs consistent (85%)  
❌ **Critical Conflicts:** 1  
⚠️  **Warnings:** 3  
ℹ️  **Info:** 4

**Bottom Line:** One critical conflict that must be fixed before launch. Three warnings that should be addressed this sprint.

---

## Critical Conflicts

### CONF-001: Design Token Contradiction (design)

**Conflict:** `_state.json.design.primary` (#0ea5e9) ≠ `design-tokens.json.primary` (#f97316)  
**Scope:** Affects all UI components using primary color  
**Root cause:** design-system command ran on 2026-04-20 with one palette, but blueprint ran on 2026-04-24 with updated palette. design-tokens.json was not regenerated.  
**Impact:** Components generated after 2026-04-20 use old color (#0ea5e9); new scaffold will use blueprint color (#f97316); inconsistent UI.

**Remediation:**
1. Decide which color is correct: old (#0ea5e9) or new (#f97316)?
   - Option A: Keep new (#f97316) — aligns with latest blueprint
   - Option B: Keep old (#0ea5e9) — revert blueprint change
2. If keeping new: Run `/architect:design-system --force-regenerate` to update tokens
3. If keeping old: Run `/architect:blueprint` with old color, then regenerate design tokens
4. Verify: `jq '.design.primary' _state.json` matches `jq '.primary' design-system/design-tokens.json`

**Time to fix:** 10 minutes

---

## Warnings

### WARN-001: Stale cost-estimate (cost_estimate)

**Conflict:** `cost-estimate` last ran 2026-04-10 (14 days ago) with 8 components. Current scaffold has 12 components.  
**Scope:** Cost projections are outdated  
**Impact:** Budget estimates are 33% incomplete  

**Remediation:**
1. Run `/architect:cost-estimate --regenerate` to refresh estimates
2. Compare with old estimate and validate architecture hasn't changed significantly
3. Update budget if needed

**Time to fix:** 5 minutes

---

### WARN-002: Missing entity references in schema (entities)

**Conflict:** `_state.json.entities[]` references field `user.profile_url`, but `data-model/schema.prisma` does not define this field.  
**Scope:** One field missing from schema  
**Impact:** ORM schema and state mismatch; future scaffold might not include this field

**Remediation:**
1. Decide: is `profile_url` a real field that should be in schema?
   - Option A: Yes → Run `/architect:generate-data-model --add-field User.profile_url`
   - Option B: No → Remove from _state.json: `jq 'del(.entities[] | select(.name=="User") | .fields[] | select(.name=="profile_url"))'`
2. Regenerate schema: `jq '.entities' _state.json > entities-for-schema.json` and pass to data-model
3. Verify all entities match schema

**Time to fix:** 15 minutes

---

### WARN-003: Component port collision (components)

**Conflict:** Two components claim the same port: `api-server` (port 3000) and `worker-service` (port 3000 in fallback env)  
**Scope:** Port conflict when running locally  
**Impact:** `npm run dev` will fail with "EADDRINUSE: port 3000 already in use"

**Remediation:**
1. Check scaffold output for port assignments: `grep -r "PORT" . --include="*.env.example"`
2. Reassign: worker-service should use port 3001 (or configurable)
3. Update _state.json: `jq '.components[] | select(.name=="worker-service").port = 3001'`
4. Verify no more collisions: `jq '.components[].port' _state.json | sort | uniq -d`

**Time to fix:** 10 minutes

---

### WARN-004: Tech stack version mismatch (tech_stack)

**Conflict:** `_state.json.tech_stack.backend` lists "Node.js 18", but scaffold `package.json` requires "Node.js ^20"  
**Scope:** Node.js version specification  
**Impact:** Developers using Node 18 will see build errors; CI/CD might use wrong node version

**Remediation:**
1. Update `package.json` in scaffold to match state or vice versa
2. Option A: Update _state.json to "Node.js ^20"
3. Option B: Update package.json to `"engines": { "node": ">=18" }`
4. Choose one source of truth and stick with it

**Time to fix:** 5 minutes

---

## Info (Suggestions, Not Blocking)

### INFO-001: Design personality unused (design)

**Info:** `_state.json.design.personality` is "bold-commercial", but scaffold doesn't use this personality in component naming/structure.  
**Suggestion:** If personality is intentional, add it to component metadata for design consistency

---

### INFO-002: Market research outdated (market_research)

**Info:** `market_research` field in _state.json was last updated 2026-04-15 (9 days ago).  
**Suggestion:** Consider refreshing market research every 2 weeks; rerun `/architect:deep-research` if market has shifted

---

### INFO-003: Multiple design system outputs

**Info:** Both `design-system/design-tokens.json` and `design-tokens-legacy.json` exist.  
**Suggestion:** Remove legacy file to reduce confusion: `rm design-tokens-legacy.json`

---

### INFO-004: No monitoring setup yet

**Info:** Scaffold complete, but `/architect:setup-monitoring` hasn't run yet.  
**Suggestion:** Add monitoring before launch; currently no observability in place

---

## Conflict Categories

All conflicts fit one of these categories:

| Category | Example | Severity | Auto-fixable |
|----------|---------|----------|--------------|
| **State contradictions** | design.primary in _state.json ≠ design-tokens.json.primary | Critical | Partial (choose source) |
| **Stale outputs** | cost-estimate is 30 days old | Warning | No (requires rerun) |
| **Schema violations** | component.port is string "3000" not number | Critical | Yes (type coercion) |
| **Missing references** | entity references field not in schema | Warning | No (requires investigation) |
| **Duplicates** | Two components with same name | Critical | No (requires choice) |
| **Naming inconsistencies** | Component slug in scaffold ≠ _state.json name | Warning | Partial (normalize) |
| **Version mismatches** | Tech stack version ≠ package.json engines | Warning | No (choose source) |
| **Unused outputs** | Old tokens file exists alongside new one | Info | Yes (delete) |

---

## Rules Applied

Validation uses 23 rules (see `/architect:validate-consistency --detailed` for full list):

**State Rules (6):**
- RULE-S-001: Design colors must be valid hex (#RRGGBB)
- RULE-S-002: Component ports must be unique
- RULE-S-003: Entity names must match schema (if schema exists)
- RULE-S-004: Tech stack versions must parse as valid semver
- RULE-S-005: Persona IDs must be unique
- RULE-S-006: All referenced entities must exist

**Output Rules (8):**
- RULE-O-001: Design tokens file must match _state.json colors
- RULE-O-002: Scaffold files must match component names in _state.json
- RULE-O-003: Cost estimate must be based on current component count
- RULE-O-004: Test coverage % must not exceed 100%
- RULE-O-005: Compliance rules must reference existing entities
- RULE-O-006: Monitoring metrics must align with tech stack
- RULE-O-007: Load test scenarios must use valid endpoints
- RULE-O-008: Documentation must reference existing components

**Cross-Command Rules (9):**
- RULE-X-001: No component should exist in both removed and added lists
- RULE-X-002: Design personality must be consistent across scaffold + design-system
- RULE-X-003: Entity count in _state.json ≥ entity count in schema (or equal)
- RULE-X-004: Blueprint architecture must match scaffold service layout
- RULE-X-005: Tech stack languages must match codebase (.ts/.py/.go/etc.)
- RULE-X-006: Monitoring observability provider must be listed in tech_stack.integrations
- RULE-X-007: Compliance frameworks must be supported by chosen tech stack
- RULE-X-008: Load test target RPS must be realistic for tech stack
- RULE-X-009: All referenced external services must exist in tech_stack.integrations

---

## Conflict Resolution Order

When multiple conflicts exist, fix in this order to avoid cascading issues:

1. **Critical state contradictions** (CONF-001, CONF-002, etc.)
   - Impact: Foundation of entire project; everything else depends on consistent state
   - Example: design color mismatch
   - Fix time: 5-15 min each

2. **Critical schema violations** (CONF-003, etc.)
   - Impact: Breaks type safety and code generation
   - Example: component.port is string not number
   - Fix time: 3-10 min each

3. **Warnings about missing outputs** (WARN-001, WARN-002, etc.)
   - Impact: Incomplete architecture; might miss important design decisions
   - Example: stale cost-estimate; missing entity in schema
   - Fix time: 5-20 min each

4. **Warnings about mismatches** (WARN-003, WARN-004, etc.)
   - Impact: Local dev/deploy might fail; CI/CD might use wrong config
   - Example: port collisions; version mismatches
   - Fix time: 5-15 min each

5. **Info suggestions** (INFO-001, INFO-002, etc.)
   - Impact: Nice-to-have; doesn't block anything
   - Example: outdated market research; unused design personality
   - Fix time: 1-5 min each

---

## Auto-Fix Behavior (`--fix` flag)

When `--fix` is enabled, only safe conflicts are auto-fixed:

✅ **Auto-fixed:**
- Type coercion (string port → number)
- Removing duplicate files (`design-tokens-legacy.json`)
- Normalizing component names (kebab-case consistency)
- Adding missing _state_version field
- Fixing color format (add # prefix if missing)

❌ **Not auto-fixed (requires user choice):**
- Design color contradictions (which color is correct?)
- Port collisions (which service keeps the port?)
- Missing entities in schema (add or remove field?)
- Stale outputs (rerun or accept old data?)
- Version mismatches (upgrade tech stack or revert?)

For non-auto-fixable conflicts, `--fix` shows remediation steps and stops, waiting for user to resolve.

---

## Detailed Mode (`--detailed` flag)

Shows extended reasoning for each conflict:

```markdown
### CONF-001: Design Token Contradiction (design)

**Conflict Type:** State vs. Output Contradiction  
**Severity:** Critical (affects UI rendering)  
**Affected Rules:** RULE-O-001, RULE-X-002  
**Data Points:**
- _state.json.design.primary: #0ea5e9
- design-tokens.json.primary: #f97316
- _activity.jsonl shows design-system ran on 2026-04-20
- _activity.jsonl shows blueprint ran on 2026-04-24
- Last update to _state.json.design: 2026-04-24 14:32:10 (blueprint command)

**Why this matters:** 
Primary color is used in >100 CSS rules across components. Mismatch means:
- Older components (generated before 2026-04-20) will have #0ea5e9
- Newer components (after blueprint update) will have #f97316
- Inconsistent brand appearance across UI

**Remediation Priority:** High (affects visual consistency)

**Suggested Fix:**
1. Review blueprint changes from 2026-04-24 — why did color change?
2. If intentional: run design-system --force-regenerate (5 min)
3. If mistake: revert blueprint to 2026-04-20 version (10 min)
```

---

## Rule Sets (`--rules` flag)

Filter validation to specific rule categories:

```bash
/architect:validate-consistency --rules state      # only state rules (S-xxx)
/architect:validate-consistency --rules output     # only output rules (O-xxx)
/architect:validate-consistency --rules cross      # only cross-command rules (X-xxx)
/architect:validate-consistency --rules critical   # only critical severity
/architect:validate-consistency --rules warnings   # only warnings + critical
```

---

## Activity Log Entry

```json
{"ts":"2026-04-24T14:32:10Z","phase":"validate-consistency","outcome":"warning","conflicts":{"critical":1,"warning":3,"info":4},"rules_applied":23,"summary":"Consistency check: 1 critical conflict (design colors), 3 warnings. Fix design tokens first, then address stale outputs."}
```

---

## Behavior

### Step 1: Scan inputs
- Check if `_state.json` exists (if not, skip state validation)
- Check if scaffold exists (if yes, validate scaffold against state)
- List all `.md` files in `architecture-output/` for content scanning

### Step 2: Load all artifacts
- Read `_state.json` (if exists)
- Read `_activity.jsonl` to see command history + timestamps
- Read architecture-output files (design-tokens.json, contracts, etc.)
- Read scaffold source if it exists

### Step 3: Apply state rules (6 rules)
For each field in `_state.json`:
- ✅ Valid type? (string, number, array, object)
- ✅ Valid format? (hex for colors, semver for versions, unique ports)
- ✅ References exist? (entities referenced in another field)
- Report as CRITICAL if violated

### Step 4: Apply output rules (8 rules)
For each file in architecture-output:
- ✅ Design tokens match _state.json colors?
- ✅ Scaffold matches component definitions?
- ✅ Cost estimates based on current architecture?
- ✅ Test coverage < 100%?
- Report as CRITICAL or WARNING if violated

### Step 5: Apply cross-command rules (9 rules)
- ✅ No component in both created and removed lists?
- ✅ Design personality consistent?
- ✅ Entity counts match or increase?
- ✅ Blueprint architecture matches scaffold?
- ✅ Codebase languages match tech stack?
- ✅ Monitoring provider in integrations?
- ✅ All external services defined?
- Report as CRITICAL or WARNING if violated

### Step 6: Categorize and sort conflicts
- Sort by severity (critical → warning → info)
- Within each severity, sort by impact
- Show resolution order

### Step 7: Generate report
- Write comprehensive markdown report
- Show conflict details with remediation steps
- Include summary table
- List rule set used
- Add activity log entry

### Step 8: Exit status
- Exit 0 if no conflicts or only info-level
- Exit 0 if `--fix` successfully resolved conflicts
- Exit 1 if critical conflicts exist and not fixed

---

## Related Commands

- `/architect:check-state` — Validates _state.json schema (this command validates cross-file consistency)
- `/architect:next-steps` — Uses consistency check to identify blockers
- `/architect:production-readiness` — Requires consistency pass before launch gate
- `skills/blocker-detection` — Identifies missing prerequisites (similar concept, different focus)

---

## Examples

### Example 1: Growing Project (Mixed Conflicts)

```
Project at growth stage with 4 weeks of work:

✅ design-tokens.json created by design-system, matches _state.json colors — PASS
✅ Scaffold components match _state.json names — PASS
✅ Tech stack versions are consistent — PASS
❌ Cost estimate is 14 days old, 33% undercounting components — WARN
❌ Entity in _state.json not in schema — WARN
❌ Two components claim port 3000 — CRITICAL

Recommendation: Fix port collision first (blocks local dev), then refresh cost estimate, then add missing entity to schema.
```

### Example 2: Fresh Scaffold (No Conflicts)

```
Project just scaffolded (Day 1):

✅ All checks pass: _state.json, scaffold, design tokens are all in sync
✅ No stale outputs (all created today)
✅ No contradictions
✅ No duplicates

Recommendation: You're in a clean state. Build away!
```

### Example 3: Post-Refactor (Schema Cleanup)

```
After major data model refactoring:

❌ CRITICAL: Entity names changed (User → AuthUser) but not updated in scaffold
❌ CRITICAL: Three old schema files still exist (schema-old.prisma, schema-v1.prisma)
❌ WARNING: cost-estimate references old entity names
⚠️ INFO: Migration scripts not yet run

Recommendation: Update all references to use new entity names, delete old schema files, regenerate cost estimate, then run schema migration.
```

---

## Notes

- This command is read-only by default; use `--fix` for write access
- Creates backup before any writes: `_state.json.backup.<timestamp>`
- Safe to run before production-readiness gate
- Recommended: run weekly during active development to catch drift early
- Scan takes 2-5 seconds for typical project
- Report is always generated even if no conflicts found (useful for auditing)
