# Conflict Resolution Guide

Step-by-step remediation procedures for each of the 23 consistency rules. Used by `/architect:validate-consistency --fix` to auto-fix safe conflicts, and by users to manually resolve complex conflicts.

## Quick Reference

For each conflict type, this guide provides:
1. **Root cause** — why the conflict happened
2. **Impact** — what goes wrong if not fixed
3. **Auto-fix approach** — if `/architect:validate-consistency --fix` can handle it
4. **Manual fix steps** — for when user judgment is needed

---

## State Conflicts (RULE-S-001 through RULE-S-006)

### RULE-S-001: Invalid design color format

**Conflict:** Design color field is not a valid hex code.

**Root cause:** Typo when editing _state.json, or pasted from color picker in wrong format.

**Impact:** Design token generation fails or produces broken CSS variables.

#### Auto-Fix
- ✅ If color is "f97316" (missing #), add prefix → "#f97316"
- ✅ If color is "rgb(249, 115, 22)", convert to nearest hex
- ✅ If color is "#F97316" (wrong case), normalize to lowercase
- ✅ If color has alpha like "#f97316ff", strip alpha → "#f97316"

#### Manual Fix

**If auto-fix rejected the color:**

```bash
# 1. Identify which color field is invalid
jq '.design | to_entries[] | select(.value | test("^#?[0-9a-fA-F]{6}$") | not)' _state.json

# 2. Pick a valid hex color using a color picker:
#    https://htmlcolorcodes.com
#    (copy the 6-digit hex, e.g., f97316)

# 3. Update the field
jq '.design.primary = "#<new-hex>"' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 4. Verify
jq '.design.primary' _state.json  # should output "#<new-hex>"

# 5. Regenerate design tokens
/architect:design-system --regenerate
```

---

### RULE-S-002: Duplicate or invalid component ports

**Conflict:** Two components claim the same port, or port is not numeric.

**Root cause:** Copy-pasted component without changing port, or manually edited _state.json with invalid value.

**Impact:** Local dev server fails with "EADDRINUSE: port already in use".

#### Auto-Fix
- ✅ If port is string "3000", convert to number 3000
- ❌ Cannot auto-fix duplicate ports (requires user choice)
- ❌ Cannot auto-fix out-of-range ports (1024-65535) without knowing what port to use

#### Manual Fix

**For duplicate ports:**

```bash
# 1. List all component ports
jq '.components[] | {name, port}' _state.json | sort

# 2. Identify duplicates (same port appears twice)

# 3. Reassign one component to an unused port:
#    Free ports: check what's not in the list
#    Common ports: 3000 (web), 3001, 5000 (api), 5001, 8000, 8001, 9000

# 4. Update the component
jq '.components[] | select(.name=="worker-service").port = 3001' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 5. Verify no more duplicates
jq '.components[].port' _state.json | sort | uniq -d  # should output nothing
```

**For out-of-range ports:**

```bash
# 1. Identify invalid ports
jq '.components[] | select(.port < 1024 or .port > 65535) | {name, port}' _state.json

# 2. Reassign to valid range (1024-65535)
jq '.components[] | select(.name=="api-server").port = 3000' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify
jq '.components[].port' _state.json | awk '$1 < 1024 || $1 > 65535 { print "INVALID:", $0 }'
```

---

### RULE-S-003: Entity in state but not in schema

**Conflict:** `_state.json.entities[]` references entity not defined in data model schema.

**Root cause:** Entity added to state manually, but schema wasn't regenerated.

**Impact:** Future scaffold code generation will miss this entity's ORM definition.

#### Auto-Fix
- ❌ Cannot auto-fix (requires investigating: is entity real or mistake?)

#### Manual Fix

**Option A: Add entity to schema**

```bash
# 1. Verify the entity is real (intentional)
jq '.entities[] | select(.name=="Order")' _state.json

# 2. Run generate-data-model to create schema for this entity
/architect:generate-data-model --regenerate

# 3. Verify entity is now in schema
grep -A 20 "model Order" architecture-output/data-model/schema.prisma

# 4. Re-run validate-consistency to confirm fix
/architect:validate-consistency
```

**Option B: Remove entity from state** (if it's a mistake)

```bash
# 1. Confirm entity should be removed
jq '.entities[] | select(.name=="Order")' _state.json

# 2. Remove from _state.json
jq 'del(.entities[] | select(.name=="Order"))' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify removed
jq '.entities[] | select(.name=="Order")' _state.json  # should output nothing

# 4. Run validate-consistency
/architect:validate-consistency
```

---

### RULE-S-004: Invalid tech stack version format

**Conflict:** Version string doesn't parse as valid semver.

**Root cause:** Typo like "Node.js v18" or "latest" instead of numeric version.

**Impact:** Deployment scripts can't pin versions correctly.

#### Auto-Fix
- ✅ If version is "v18", remove 'v' → "18"
- ✅ If version is "18.2", treat as 18.2.0
- ✅ If version has extra parts like "18.2.1.5", use first 3 parts → "18.2.1"
- ❌ Cannot auto-fix non-numeric like "latest"

#### Manual Fix

```bash
# 1. Find invalid versions
jq '.tech_stack | to_entries[]' _state.json | grep -v '[0-9]'

# 2. Update to valid semver format
jq '.tech_stack.backend[0] = "Node.js 18.2.1"' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify format
jq '.tech_stack.backend[0]' _state.json

# 4. Re-validate
/architect:validate-consistency
```

---

### RULE-S-005: Duplicate persona or decision IDs

**Conflict:** Two personas/decisions share the same ID.

**Root cause:** Copy-pasted entry without updating ID.

**Impact:** Tracking and decision audit is ambiguous; unclear which entry is meant.

#### Auto-Fix
- ❌ Cannot auto-fix (would require renumbering, which breaks references)

#### Manual Fix

```bash
# 1. Find duplicates
jq '.personas[].id' _state.json | sort | uniq -d

# 2. Assign new IDs to duplicates
#    Schema: P-NNN for personas, D-NNN for decisions
#    Pattern: increment from highest existing ID
#
#    Current: P-001, P-002, P-003
#    New: P-004 for the duplicate

# 3. Update the duplicate entry
jq '.personas[] |= if .id == "P-003" and .name == "Secondary Persona" then .id = "P-004" else . end' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 4. Verify no more duplicates
jq '.personas[].id' _state.json | sort | uniq -d  # should output nothing

# 5. Re-validate
/architect:validate-consistency
```

---

### RULE-S-006: Broken references in state

**Conflict:** One field references another field that doesn't exist.

**Root cause:** Deleted a field but didn't clean up references, or typo in field name.

**Impact:** Downstream commands that expect reference to resolve will fail.

#### Auto-Fix
- ✅ If reference is null/undefined, remove it
- ✅ If reference is typo (close match), suggest correction
- ❌ If reference is legitimately broken, requires investigation

#### Manual Fix

```bash
# 1. Identify broken reference
# Example: Entity references skill that doesn't exist
jq '.personas[] | select(.skills[]? == "unknown_skill")' _state.json

# 2. Fix by either:
#    A. Add the referenced item:
jq '.skills += ["unknown_skill"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

#    B. Remove the broken reference:
jq '.personas[] |= .skills |= map(select(. != "unknown_skill"))' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify fixed
jq '.personas[].skills[]' _state.json

# 4. Re-validate
/architect:validate-consistency
```

---

## Output Conflicts (RULE-O-001 through RULE-O-008)

### RULE-O-001: Design tokens don't match state colors

**Conflict:** `_state.json.design.primary` is #f97316, but `design-tokens.json.primary` is #0ea5e9.

**Root cause:** Blueprint updated state colors, but design-system command didn't regenerate tokens.

**Impact:** New components use one color, old components use another → inconsistent UI.

#### Auto-Fix
- ✅ If tokens file is older than state file, use state colors
- ❌ If both are recent, ask user which source is correct

#### Manual Fix

**Decide which color is right:**

```bash
# 1. Compare the two sources
echo "State color:" && jq '.design.primary' _state.json
echo "Token color:" && jq '.primary' design-system/design-tokens.json

# 2. Check git history to see which is more recent
git log --oneline _state.json | head -3
git log --oneline design-system/design-tokens.json | head -3

# 3. Option A: Keep state colors (more recent blueprint)
/architect:design-system --regenerate

# 4. Option B: Keep token colors (revert blueprint)
git show <blueprint-commit>:_state.json | jq '.design.primary' > old_color.txt
# then manually update _state.json to this color

# 5. Verify match
echo "After fix:" && jq '.design.primary' _state.json && jq '.primary' design-system/design-tokens.json
```

---

### RULE-O-002: Scaffold missing components from state

**Conflict:** `_state.json` defines component "auth-service", but no `src/services/auth-service/` folder exists.

**Root cause:** Component added to state, but scaffold not regenerated.

**Impact:** Incomplete project structure; dev expects service to exist.

#### Auto-Fix
- ❌ Cannot auto-fix (requires running scaffold or scaffold-component)

#### Manual Fix

```bash
# 1. List missing components
jq '.components[].name' _state.json | while read c; do
  c_kebab=$(echo "$c" | sed 's/[A-Z]/-\L&/g')
  if [ ! -d "src/services/$c_kebab" ] && [ ! -d "src/components/$c_kebab" ]; then
    echo "Missing: $c"
  fi
done

# 2. Regenerate entire scaffold
/architect:scaffold

# OR: Add individual components
/architect:scaffold-component --name auth-service

# 3. Verify components now exist
ls -la src/services/ | grep auth-service
ls -la src/components/ | grep auth-service

# 4. Re-validate
/architect:validate-consistency
```

---

### RULE-O-003: Cost estimate is stale

**Conflict:** Cost estimate was generated 30 days ago with 8 components; state now has 12 components.

**Root cause:** Cost estimate wasn't regenerated after architecture changed.

**Impact:** Budget projections are 25% undercounted.

#### Auto-Fix
- ✅ Can detect staleness, but regeneration requires running command

#### Manual Fix

```bash
# 1. Identify stale estimate
ls -la architecture-output/cost-estimate.md

# 2. Regenerate
/architect:cost-estimate --regenerate

# 3. Compare old vs new
echo "Old estimate:" && grep -A 5 "monthly" cost-estimate.md.backup
echo "New estimate:" && grep -A 5 "monthly" architecture-output/cost-estimate.md

# 4. Update budget if needed
# Use new numbers for planning

# 5. Re-validate
/architect:validate-consistency
```

---

### RULE-O-004: Invalid test coverage percentage

**Conflict:** Test coverage is reported as 150% (impossible).

**Root cause:** Bug in test command, or manual edit of coverage field.

**Impact:** Dashboards break; coverage metrics are nonsensical.

#### Auto-Fix
- ✅ Clamp to 0-100 range
- ✅ If >100, use 100; if <0, use 0

#### Manual Fix

```bash
# 1. Identify invalid coverage
jq '.test_suite.coverage' architecture-output/_state.json

# 2. If >100, set to 100:
jq '.test_suite.coverage = 100' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. If <0, set to 0:
jq '.test_suite.coverage = 0' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 4. Verify
jq '.test_suite.coverage' _state.json

# 5. Re-generate test suite if needed
/architect:generate-tests --regenerate
```

---

### RULE-O-005: Compliance rule references nonexistent entity

**Conflict:** Compliance rule says "encrypt User entity data", but no User entity in state.

**Root cause:** Compliance plan generated for wrong project, or entity was deleted.

**Impact:** Compliance checklist includes impossible tasks.

#### Auto-Fix
- ❌ Cannot auto-fix (requires investigation)

#### Manual Fix

```bash
# 1. List entities
jq '.entities[].name' _state.json

# 2. Find compliance rules referencing nonexistent entities
jq '.compliance.controls[] | select(.applies_to_entity)' architecture-output/_state.json

# 3. Option A: Add the missing entity
jq '.entities += [{name: "User", fields: ["id", "email"]}]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 4. Option B: Remove or update the rule
# Edit compliance report manually:
vi architecture-output/compliance-report.md
# Remove rule or change "User" to existing entity name

# 5. Verify
jq '.compliance.controls[]' architecture-output/_state.json

# 6. Re-validate
/architect:validate-consistency
```

---

### RULE-O-006: Monitoring metrics reference unavailable services

**Conflict:** Monitoring plan includes Kafka metrics, but tech stack is RabbitMQ.

**Root cause:** Monitoring plan copied from different project, or tech stack changed without updating monitoring.

**Impact:** Monitoring won't work; can't monitor services that don't exist.

#### Auto-Fix
- ❌ Cannot auto-fix (requires choosing monitoring provider)

#### Manual Fix

```bash
# 1. Check tech stack
jq '.tech_stack.backend' _state.json | grep -i kafka

# 2. List monitoring services
jq '.monitoring.metrics[].service' architecture-output/_state.json | sort | uniq

# 3. Align one to other:
#    Option A: Change tech stack to add Kafka
jq '.tech_stack.backend += ["Kafka"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

#    Option B: Change monitoring to use RabbitMQ
# Edit monitoring plan:
sed -i 's/kafka/rabbitmq/g' architecture-output/monitoring.md

# 4. Verify alignment
echo "Tech stack:" && jq '.tech_stack.backend[]' _state.json
echo "Monitoring:" && jq '.monitoring.metrics[].service' architecture-output/_state.json

# 5. Re-validate
/architect:validate-consistency
```

---

### RULE-O-007: Load test references nonexistent endpoints

**Conflict:** Load test scenario requests `GET /api/orders`, but API contract doesn't define this endpoint.

**Root cause:** Load test copied from template, endpoints changed, or API wasn't scaffolded yet.

**Impact:** Load tests won't run; endpoints don't exist.

#### Auto-Fix
- ❌ Cannot auto-fix (requires either adding endpoint or removing test scenario)

#### Manual Fix

```bash
# 1. List valid endpoints
jq '.paths | keys[]' contracts/api-server.openapi.yaml | sort

# 2. Find invalid endpoint in load test
grep -n "/api/orders" architecture-output/load-test.md

# 3. Option A: Add the endpoint to API
# Edit scaffold or blueprint to include /api/orders endpoint

# 4. Option B: Remove from load test
# Edit load-test.md, remove scenario or change endpoint to valid one

# 5. Verify load test only references real endpoints
grep -o '/api/[a-z/]*' architecture-output/load-test.md | sort | uniq

# 6. Cross-check against contract
jq '.paths | keys[]' contracts/api-server.openapi.yaml

# 7. Re-validate
/architect:validate-consistency
```

---

### RULE-O-008: Documentation references deleted components

**Conflict:** API docs mention "auth-service" component, but component was removed.

**Root cause:** Component removed from project, docs not updated.

**Impact:** Docs are outdated and confusing.

#### Auto-Fix
- ❌ Cannot auto-fix (requires manual doc updates)

#### Manual Fix

```bash
# 1. List current components
jq '.components[].name' _state.json

# 2. Find stale references in docs
grep -r "auth-service" architecture-output/ | grep -v "\.json"

# 3. Either:
#    A. Re-add the component (restore it)
jq '.components += [{name: "auth-service"}]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

#    B. Update docs to remove references
sed -i '/auth-service/d' architecture-output/api-docs.md

# 4. Verify no more stale references
grep -r "auth-service" architecture-output/

# 5. Re-validate
/architect:validate-consistency
```

---

## Cross-Command Conflicts (RULE-X-001 through RULE-X-009)

### RULE-X-001: Component in both created and removed lists

**Conflict:** Component "worker-service" was scaffolded, but also appears in deprecated list.

**Root cause:** Component removed from project, but state wasn't fully updated.

**Impact:** Architectural ambiguity; unclear if service should exist.

#### Auto-Fix
- ❌ Cannot auto-fix (requires deciding: keep or remove?)

#### Manual Fix

```bash
# 1. Identify the conflict
jq '.components[] | select(.name=="worker-service")' _state.json
jq '.deprecated_components[]' _state.json | grep worker-service

# 2. Option A: Keep the component (remove from deprecated)
jq '.deprecated_components -= ["worker-service"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Option B: Remove the component (delete from components array)
jq '.components |= map(select(.name != "worker-service"))' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 4. Verify resolved
jq '.components[].name' _state.json | grep -c worker-service  # should be 0 or 1, not both
```

---

### RULE-X-002: Design personality inconsistency

**Conflict:** State personality is "bold-commercial", but scaffold components use "serene-health" styling.

**Root cause:** Design personality changed in state, but scaffold wasn't regenerated.

**Impact:** Visual inconsistency; brand confusion.

#### Auto-Fix
- ❌ Cannot auto-fix (requires regenerating scaffold with new personality)

#### Manual Fix

```bash
# 1. Confirm desired personality
jq '.design.personality' _state.json

# 2. Regenerate design system
/architect:design-system --regenerate

# 3. Regenerate scaffold with new tokens
/architect:scaffold --regenerate

# 4. Verify components now match personality
grep -r "personality\|className" src/components/ | head -5

# 5. Re-validate
/architect:validate-consistency
```

---

### RULE-X-003: Entity count decreased

**Conflict:** State had 8 entities last week, now has 5 (3 were deleted).

**Root cause:** Refactoring or mistake; entities were removed without audit trail.

**Impact:** Unclear what happened to old entities; backward compatibility issues.

#### Auto-Fix
- ❌ Cannot auto-fix (requires investigating why entities disappeared)

#### Manual Fix

```bash
# 1. Check git history to see what changed
git log --oneline -- _state.json | head -5
git diff HEAD~1 _state.json | grep -A 2 "entities"

# 2. Identify missing entities
git show HEAD~1:_state.json | jq '.entities[].name' > old_entities.txt
jq '.entities[].name' _state.json > new_entities.txt
diff old_entities.txt new_entities.txt

# 3. Decide: restore entities or intentional removal?

#    Option A: Restore removed entities
git show HEAD~1:_state.json | jq '.entities' > entities_backup.json
jq '.entities = input' _state.json entities_backup.json > _state.json.tmp && mv _state.json.tmp _state.json

#    Option B: Document intentional removal (create a decision record)
jq '.decisions += [{id: "D-NNN", title: "Remove X entity for simplification", made_by_command: "manual", timestamp: "2026-04-24T..."}]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 4. Verify
jq '.entities[].name' _state.json

# 5. Re-validate
/architect:validate-consistency
```

---

### RULE-X-004: Blueprint and scaffold architecture mismatch

**Conflict:** Blueprint describes 3 services (api-server, web-app, worker), but scaffold only has 2 (api-server, web-app).

**Root cause:** Blueprint updated, or scaffold wasn't regenerated.

**Impact:** Implementation doesn't match architecture; developer confusion.

#### Auto-Fix
- ❌ Cannot auto-fix (requires deciding which is correct)

#### Manual Fix

```bash
# 1. Compare
echo "Blueprint services:" && jq '.blueprint.services[].name' _state.json
echo "Scaffold components:" && jq '.components[].name' _state.json

# 2. Option A: Add missing component to scaffold
/architect:scaffold-component --name worker-service

# 3. Option B: Remove from blueprint (if service not needed)
# Edit blueprint.md or _state.json to remove worker-service

# 4. Verify alignment
# Both lists should match

# 5. Re-validate
/architect:validate-consistency
```

---

### RULE-X-005: Tech stack language doesn't match codebase

**Conflict:** Tech stack lists "Python", but codebase has only .ts (TypeScript) files.

**Root cause:** Tech stack auto-detected wrong, or codebase changed after tech stack was set.

**Impact:** Deployment, CI/CD, and documentation use wrong tooling.

#### Auto-Fix
- ✅ Can suggest correction based on file extension analysis

#### Manual Fix

```bash
# 1. Detect codebase languages
find src -name "*.ts" -o -name "*.tsx" | wc -l  # TypeScript files
find src -name "*.py" | wc -l                  # Python files
find src -name "*.go" | wc -l                  # Go files

# 2. Update tech stack to match
jq '.tech_stack.backend = ["Node.js", "TypeScript"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify
jq '.tech_stack.backend' _state.json

# 4. Re-validate
/architect:validate-consistency
```

---

### RULE-X-006: Monitoring provider not in tech stack

**Conflict:** Monitoring setup uses "Datadog", but tech_stack.integrations doesn't list Datadog.

**Root cause:** Added monitoring without updating tech stack.

**Impact:** Minor (monitoring will still work, but tech stack list is incomplete).

#### Auto-Fix
- ✅ Add monitoring provider to integrations list

#### Manual Fix

```bash
# 1. Check monitoring provider
jq '.monitoring.provider' architecture-output/_state.json

# 2. Add to tech stack
jq '.tech_stack.integrations += ["Datadog"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify
jq '.tech_stack.integrations[] | select(. == "Datadog")' _state.json

# 4. Re-validate
/architect:validate-consistency
```

---

### RULE-X-007: Compliance framework unsupported by tech stack

**Conflict:** Compliance plan requires HIPAA (health data), but tech stack uses AWS free tier (no HIPAA support).

**Root cause:** Compliance requirements and tech stack chosen independently.

**Impact:** Compliance impossible; tech stack needs upgrade or requirements need revision.

#### Auto-Fix
- ❌ Cannot auto-fix (major architectural decision)

#### Manual Fix

**Option A: Upgrade tech stack to support compliance**

```bash
# 1. Identify required changes
# HIPAA requires: BAA with provider, encryption at rest/transit, audit logs, etc.
# AWS free tier doesn't support this → need paid tier

jq '.tech_stack.backend += ["AWS Enterprise Support"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 2. Update cost estimates
/architect:cost-estimate --regenerate

# 3. Verify now supported
jq '.tech_stack.backend' _state.json
```

**Option B: Reduce compliance scope**

```bash
# 1. Remove unsupported framework
jq '.compliance.frameworks -= ["HIPAA"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 2. Update compliance plan
# Remove HIPAA-specific controls

# 3. Verify
jq '.compliance.frameworks' _state.json
```

---

### RULE-X-008: Load test target RPS unrealistic for tech stack

**Conflict:** Load test targets 100k RPS, but tech stack is single-threaded Python (achieves ~500 RPS).

**Root cause:** Copy-pasted load test goals from different project, or underestimated complexity.

**Impact:** Load test goals are impossible; wasted time on unreachable targets.

#### Auto-Fix
- ✅ Can suggest realistic RPS based on tech stack

#### Manual Fix

```bash
# 1. Estimate achievable RPS for tech stack
# Node.js: 10k-50k RPS per instance
# Python: 1k-5k RPS per instance
# Go: 100k+ RPS per instance

echo "Tech stack:" && jq '.tech_stack.backend' _state.json

# 2. Set realistic target
jq '.load_testing.target_rps = 5000' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Update load test plan
/architect:load-test --target-rps 5000 --regenerate

# 4. Verify
jq '.load_testing.target_rps' _state.json
jq '.load_testing.target_rps' architecture-output/_state.json
```

---

### RULE-X-009: External service not in tech stack integrations

**Conflict:** Blueprint mentions Stripe payment integration, but tech_stack.integrations doesn't list Stripe.

**Root cause:** Service added to blueprint, tech stack list not updated.

**Impact:** Cost estimation and deployment scripts miss this service.

#### Auto-Fix
- ✅ Add service to integrations list

#### Manual Fix

```bash
# 1. Find services referenced in blueprint
grep -i "stripe\|sendgrid\|auth0" architecture-output/blueprint.md

# 2. Add to integrations
jq '.tech_stack.integrations += ["Stripe", "SendGrid"]' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

# 3. Verify added
jq '.tech_stack.integrations[]' _state.json | grep -i stripe

# 4. Re-validate
/architect:validate-consistency
```

---

## Fixing Multiple Conflicts

When `/architect:validate-consistency` reports multiple conflicts, follow this order:

### Step 1: Fix state conflicts first (RULE-S-xxx)
- These are the foundation
- All other checks depend on valid state
- **Time:** 5-30 min total

### Step 2: Fix output conflicts (RULE-O-xxx)
- Design, cost, test, compliance
- Depends on valid state
- **Time:** 10-45 min total

### Step 3: Fix cross-command conflicts (RULE-X-xxx)
- Blueprint, scaffold, tech stack alignment
- Depends on valid state + outputs
- **Time:** 15-60 min total

### Step 4: Re-run validate-consistency
- Confirm all conflicts resolved
- Fix any cascading issues
- **Time:** 2 min

---

## Conflict Resolution Workflow

```bash
# 1. Generate consistency report
/architect:validate-consistency

# 2. Review conflicts in report
# Read: architecture-output/consistency-report.md

# 3. Fix critical conflicts first
# Follow remediation steps for each conflict

# 4. Try auto-fix for remaining conflicts
/architect:validate-consistency --fix

# 5. Manually fix any conflicts that auto-fix couldn't resolve
# Follow manual fix steps above

# 6. Re-run to confirm all resolved
/architect:validate-consistency

# Expected output:
# ✅ Pass Rate: 52/52 outputs consistent (100%)
# ❌ Critical Conflicts: 0
# ⚠️  Warnings: 0
```

---

## When to Ask for Help

If you hit a conflict you can't resolve:

1. **Read the conflict reasoning** in detailed mode:
   ```bash
   /architect:validate-consistency --detailed | grep -A 10 "CONFLICT-XXX"
   ```

2. **Check what changed recently:**
   ```bash
   git log --oneline -10 -- architecture-output/_state.json
   git diff HEAD~1 _state.json | grep -A 5 "key-that-changed"
   ```

3. **Ask for guidance:**
   - "I have a conflict in X — should I keep version A or B?"
   - "Two components claim port 3000 — which should move?"
   - "Entity was deleted — should I restore or update docs?"

The root cause is usually:
- **State changed, outputs didn't** → regenerate output
- **Outputs changed, state didn't** → update state
- **User choice needed** → decide and implement

---

## Related Commands

- `/architect:validate-consistency` — detects conflicts
- `/architect:validate-consistency --fix` — auto-fixes safe conflicts
- `/architect:check-state` — validates state schema (different from consistency)
- `/architect:next-steps` — recommends commands to fix conflicts
