---
description: Intelligent next-steps guide — recommends 3 highest-ROI commands based on project stage, completion status, and blockers
---

# /architect:next-steps

Analyzes your project state (`_state.json` + `_activity.jsonl`) and recommends the 3 most impactful next commands to run. Saves ramp-up time, prevents wrong-sequencing, unblocks progress.

## Trigger

```
/architect:next-steps
/architect:next-steps [--verbose]  # show detailed reasoning
/architect:next-steps [--all]      # show top 10 (not just 3)
```

## Purpose

With 54 commands, users often ask: **"What do I run next?"**

This command answers it by:
1. **Detecting project stage** (concept → mvp → growth → enterprise)
2. **Identifying what's done** (from activity log history)
3. **Spotting blockers** (missing prerequisites, stale outputs)
4. **Ranking by ROI** (impact × urgency × dependency chain)
5. **Showing ETAs** (estimated time to complete)

**Example outputs:**
```
Your project is at GROWTH stage. Next 3 commands:

1. 🔴 CRITICAL: /architect:generate-tests
   → Reason: Tests enable scaling confidence; currently missing for 8 components
   → Blocked by: Nothing (scaffold already done)
   → Est. time: 45 min
   → Why now: You've been implementing for 3 weeks without tests; technical debt risk high

2. 🟡 HIGH: /architect:design-system
   → Reason: Unify UI; colors/fonts inconsistent across team
   → Blocked by: Nothing (can run anytime)
   → Est. time: 15 min
   → Why now: Many new UI PRs; design tokens will reduce review friction

3. 🟢 MEDIUM: /architect:setup-monitoring
   → Reason: Observe production before launch; catch issues early
   → Blocked by: /architect:setup-cicd (deploy pipeline needed first)
   → Est. time: 20 min
   → Why now: You're 4 weeks from launch target; monitoring setup is critical path
```

## Output

**`architecture-output/next-steps-guide.md`** (always generated)

```markdown
# Next Steps Guide

**Generated:** 2026-04-24 14:32:10  
**Project:** my-startup  
**Current Stage:** growth  
**Activity:** 47 commands run, 44 successful (94% success rate)

---

## Your Next 3 Priorities

### 1. 🔴 CRITICAL: /architect:generate-tests

**Reason:** Tests missing for 8 components; team velocity blocked by manual testing; tech debt risk high after 3 weeks of implementation

**What it does:**
- Generate unit, integration, e2e test suites
- 3 test frameworks supported (Jest, Vitest, Mocha)
- Auto-detect from scaffold structure
- Outputs ~500 test cases across components

**Prerequisites:** ✅ All met
- ✅ Scaffolded project exists
- ✅ SDL has entity definitions
- ✅ Source files exist (will be analyzed)

**Estimated time:** 45 minutes

**ROI:** 
- Blocks: `/architect:production-readiness` (needs 80% test coverage)
- Enables: Confident refactoring, safer deployments
- Value: Reduce regressions 60-70%, catch bugs before production

**Next command after this:** `/architect:security-scan` (verify test patterns don't have holes)

**Run it:**
```bash
/architect:generate-tests
# Then commit, run tests, verify coverage
npm test  # or similar
```

---

### 2. 🟡 HIGH: /architect:design-system

**Reason:** UI inconsistent across 4 new PRs this week; design tokens missing; team needs shared color/font palette

**What it does:**
- Generate 11 design system personalities (bold-commercial, serene-health, vivid-edtech, etc.)
- Create design tokens (colors, typography, spacing, shadows)
- Generate Tailwind config patch + CSS variables
- Output to `architecture-output/design-system/`

**Prerequisites:** ✅ All met
- ✅ SDL has design section defined
- ✅ Scaffold already created (can integrate tokens)

**Estimated time:** 15 minutes

**ROI:**
- Blocks: `/architect:prototype`, `/architect:wireframes` (need design consistency)
- Enables: Faster UI development, consistent brand
- Value: Reduce design review cycles 50%, developer ramp-up faster

**Next command after this:** `/architect:scaffold-component` (generate new components with design tokens applied)

**Run it:**
```bash
/architect:design-system
# Then integrate tokens into existing scaffold
# Update tailwind.config.ts with patch
```

---

### 3. 🟢 MEDIUM: /architect:setup-monitoring

**Reason:** 4 weeks to production launch; observability critical path; currently zero metrics/logs/traces

**What it does:**
- Configure observability stack (Datadog, New Relic, Prometheus)
- Set up metrics collection, distributed tracing, log aggregation
- Create dashboards, alert rules, SLOs
- Outputs Terraform + config files

**Prerequisites:** ⚠️  Partially met
- ✅ SDL has observability section
- ⚠️  **Needs:** `/architect:setup-cicd` to be run first (deploy pipeline required)
  - ETA to unblock: 20 minutes
  - Then add monitoring: 20 minutes total
  - Combined ETA: 40 minutes

**Estimated time:** 20 minutes (after CICD is set up)

**ROI:**
- Blocks: `/architect:production-readiness` (requires observability to pass)
- Enables: Production incident response, capacity planning
- Value: Reduce MTTR (mean time to recovery) 90%, catch issues before users see them

**Dependency chain:**
```
setup-cicd (20min)
    ↓
setup-monitoring (20min)
    ↓
launch-check (5min)
    ↓
production-readiness (30min)
```

**Run it after CICD:**
```bash
/architect:setup-monitoring
# Wire up your observability provider credentials
# Verify dashboards working
```

---

## Why These 3?

**Scoring algorithm:**
1. **Impact (0-10):** How much does this unblock? How critical for your stage?
   - Generate-tests: 9/10 (enables safe scaling)
   - Design-system: 7/10 (improves UX consistency)
   - Setup-monitoring: 8/10 (critical path to production)

2. **Urgency (0-10):** How soon do you need this?
   - Generate-tests: 10/10 (3 weeks of unreviewed code)
   - Design-system: 6/10 (nice-to-have, not blocking)
   - Setup-monitoring: 9/10 (4 weeks to launch)

3. **Dependency cost (0-5):** How many blockers?
   - Generate-tests: 0 (independent)
   - Design-system: 0 (independent)
   - Setup-monitoring: 1 (needs CICD first)

**Combined score (impact + urgency - dependency_cost):**
- Generate-tests: 9 + 10 - 0 = 19 ✅ CRITICAL
- Setup-monitoring: 8 + 9 - 1 = 16 ✅ HIGH (after CICD)
- Design-system: 7 + 6 - 0 = 13 ✅ MEDIUM

**Others you can skip for now:**
- ❌ `/architect:cost-estimate` — You did this 2 weeks ago; rerun only if architecture changes
- ❌ `/architect:load-test` — Premature; do after MVP launch
- ❌ `/architect:seo` — Not applicable (backend service, not public web)

---

## What's Done (Project Status)

✅ **Completed (in order):**
1. problem-validation (Apr 20)
2. blueprint (Apr 20)
3. design-system (Apr 20)
4. scaffold (Apr 21)
5. generate-data-model (Apr 21)
6. implement (Apr 22, Apr 23, Apr 24 — 3 features)
7. check-state (Apr 24 — validated state)

⏭️  **Missing (critical path to launch):**
1. generate-tests (needed for production-readiness gate)
2. setup-cicd (deploy pipeline)
3. setup-monitoring (production observability)
4. launch-check (operational readiness scan)
5. production-readiness (final sign-off)

---

## Stage Detection

Your project is **GROWTH** stage because:
- ✅ Has complete SDL (concept requires none)
- ✅ Has scaffolded components (mvp minimum)
- ✅ Has 12 entities defined (growth requires this)
- ✅ Has design system drafted (growth requires this)
- ✅ Has blueprint (growth requires this)
- ❌ Missing tests (growth should have)
- ⚠️  Missing monitoring (enterprise requires; growth should have)

**Stage path forward:** Growth → Enterprise (in 3 months when you hit 5+ services, 100+ tests, full observability)

---

## Tips

1. **Run in order:** Top recommendation first; order matters (some have dependencies)
2. **Verify after each:** Check output exists before running next command
3. **Don't skip:** If a command looks optional, read the "Why now?" section; usually there's a good reason
4. **Use --verbose:** See detailed scoring rationale: `next-steps --verbose`
5. **Re-run weekly:** Project state changes; recommendations update

## Related Commands

- `/architect:check-state` — Diagnose why recommended commands might fail
- `/architect:validate-consistency` — Verify outputs from past commands are compatible
- `/architect:production-readiness` — Final sign-off before launch
```

## Behavior

### Step 1: Load project context
- Read `_state.json` (if exists)
- Read `_activity.jsonl` (if exists)
- Detect project stage based on state fields

### Step 2: Detect stage
```
if not project.name:
  stage = "concept"  # No project yet
elif not tech_stack or not components:
  stage = "mvp"  # Basic shell, no architecture
elif not entities or not blueprint:
  stage = "growth"  # Complex, designing scale
elif monitoring and compliance:
  stage = "enterprise"  # Production-hardened
```

### Step 3: Identify blockers
For each command:
- Check prerequisites (SDL section exists? Scaffold done? Entities defined?)
- If blocker found, mark as "blocked by X" with time to unblock
- Calculate dependency chain (which unblocks what)

### Step 4: Score top 10 candidates
For each command not yet completed:
```
score = impact(0-10) + urgency(0-10) - dependency_cost(0-5)

impact = how much does this unblock? (higher for critical path)
urgency = how soon do you need this? (higher if time-sensitive)
dependency_cost = how many blockers? (penalize complex dependency chains)
```

### Step 5: Recommend top 3
- Sort by score descending
- Show top 3 with:
  - What it does (one paragraph)
  - Prerequisites (check marks for met, X for missing)
  - Estimated time
  - ROI (what it unblocks, what it enables)
  - Next command after this one
  - Why now (context specific to this project)

### Step 6: Generate report
- Write `next-steps-guide.md` with full context
- Show what's done, what's missing
- Explain stage detection logic
- List "skip for now" commands with reasons
- Activity log: stage detection, top 3 recommendations, success rate

## Flags

### `--verbose`
Show detailed scoring:
```
Scoring /architect:generate-tests
  impact: 9/10 (blocks production-readiness, critical for growth)
  urgency: 10/10 (3 weeks of untested code)
  dependency_cost: 0 (no blockers)
  score: 19 ✅ CRITICAL

Scoring /architect:cost-estimate
  impact: 3/10 (already ran 2 weeks ago, only refresh if architecture changed)
  urgency: 2/10 (not time-sensitive unless planning feature)
  dependency_cost: 0
  score: 5 ❌ SKIP FOR NOW
```

### `--all`
Show top 10 instead of top 3 (for power users wanting full roadmap)

## Example Flow

1. **Day 1:** User runs `/architect:next-steps`
   - Gets recommendation: generate-tests, design-system, setup-monitoring
   
2. **Day 2:** User runs `/architect:generate-tests`
   - Tests generated, added to codebase
   
3. **Day 2 (later):** User runs `/architect:next-steps` again
   - New recommendation: setup-cicd, setup-monitoring, security-scan
   - (generate-tests no longer in top 3, now done)
   
4. **Day 3:** User runs `/architect:setup-cicd`
   - Unblocks setup-monitoring
   
5. **Day 4:** User follows dependency chain:
   - setup-monitoring → launch-check → production-readiness
   - Ready to ship!

## Notes

- This command is read-only (no state modifications)
- Safe to run before any other command
- Recommended: run at start of day, week, or milestone
- Works with projects at any stage (concept through enterprise)
- Respects project-specific constraints (SDL, team size, timeline)
