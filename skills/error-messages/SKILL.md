# Error Messages Skill

Provides clear, actionable error messages that help users understand what went wrong, why it matters, and how to fix it. Better error messages reduce debugging time and user frustration.

## Error Message Structure

Every error should follow this 4-part template:

```
❌ [WHAT WENT WRONG]

[WHY THIS MATTERS]

[HOW TO FIX IT]

[OPTIONAL CONTEXT]
```

### Part 1: What Went Wrong

Clear, specific statement of the error. No jargon unless unavoidable.

**Bad:**
```
Error: ENOENT: no such file or directory, open '_state.json'
```

**Good:**
```
❌ State file not found (_state.json)
```

**Better:**
```
❌ State file not found (_state.json)
Project state required to generate tests.
```

### Part 2: Why This Matters

1-2 sentences explaining impact. What breaks if user ignores this?

**Bad:**
```
(skipped — no explanation)
```

**Good:**
```
Without state, I can't determine your project's tech stack, components, or design tokens.
This means tests won't know what framework to use or what components to test.
```

### Part 3: How to Fix It

Actionable steps to resolve. Start with the simplest fix.

**Bad:**
```
(skipped — vague)
```

**Good:**
```
How to fix:
1. Run /architect:blueprint to create initial project state
   (Estimated time: 20 minutes)
2. Once complete, try this command again: /architect:generate-tests
```

### Part 4: Optional Context

Links to related commands, documentation, or debugging info. Skip if irrelevant.

**Good addition:**
```
Want to understand the prerequisite chain? Run /architect:next-steps
```

---

## Error Categories & Examples

### 1. Missing Prerequisites

**Trigger:** User tries to run command X, but required input for X doesn't exist.

**Template:**
```
❌ [COMMAND] requires [PREREQUISITE], which hasn't been created yet.

[PREREQUISITE] is necessary because [WHY].

How to fix:
1. Run /architect:[FIX_COMMAND] (estimated X min)
2. Once complete, try /architect:[COMMAND] again

Questions? Run /architect:next-steps to see all recommendations.
```

**Example 1: Missing scaffold**
```
❌ /architect:generate-tests requires scaffolded code, which doesn't exist yet.

Tests need source files to analyze. Without a scaffold, there's nothing to test.

How to fix:
1. Run /architect:scaffold (estimated 45 minutes)
   - This generates your initial project structure
   - Installs dependencies
   - Creates component stubs
2. Once scaffold completes, try /architect:generate-tests again

Tip: Watch for any build errors during scaffold — fix those before continuing.
```

**Example 2: Missing design tokens**
```
❌ /architect:scaffold-component requires design tokens (from /architect:design-system).

Design tokens define colors, fonts, spacing for your UI. Without them, new components
won't match your existing design system.

How to fix:
1. Run /architect:design-system (estimated 15 minutes)
   - This generates design tokens, Tailwind config, CSS variables
2. Run /architect:scaffold-component again

Optional: Check existing components to see design tokens in action
  grep -r "className" src/components/ | head -5
```

**Example 3: Missing SDL**
```
❌ /architect:scaffold requires a project specification (solution.sdl.yaml).

The SDL tells me your tech stack, components, data model, and more. Without it,
I can't scaffold a project that matches your vision.

How to fix:
Option A (recommended): Generate SDL from architecture blueprint
1. Run /architect:blueprint (estimated 20 minutes)
   - This creates initial project definition
2. Then run /architect:scaffold

Option B (advanced): Import from existing codebase
1. Run /architect:import --scan-existing-codebase (estimated 10 minutes)
   - This reverse-engineers SDL from your existing code

Questions? Run /architect:blueprint --help to see available options.
```

---

### 2. Invalid State

**Trigger:** State file exists but has errors (syntax, schema, conflicts).

**Template:**
```
❌ Project state is invalid: [SPECIFIC_ERROR]

[EXPLAIN WHY THIS BREAKS THINGS]

How to fix:
[OPTION A] (if auto-fixable):
1. Run /architect:check-state --fix (estimated 5 minutes)
   - This repairs common issues automatically
2. Verify: jq '.KEY' architecture-output/_state.json | head -5
3. Try your command again

[OPTION B] (if manual fix needed):
1. Identify the problem:
   jq '.[PATH]' architecture-output/_state.json
2. Fix it:
   jq '.[PATH] = NEWVALUE' _state.json > _state.json.tmp && mv _state.json.tmp _state.json
3. Validate:
   /architect:check-state
```

**Example 1: Corrupted JSON**
```
❌ Project state is corrupted: _state.json is not valid JSON

This prevents every command from running. The state file is the foundation for all
architecture operations.

How to fix:
1. Attempt auto-repair:
   /architect:check-state --fix
   - Creates backup (see _state.json.backup.TIMESTAMP)
   - Fixes common issues

2. If auto-fix succeeds:
   Validate the repair:
   /architect:check-state
   Expected output: "✅ State is valid"

3. If auto-fix fails:
   Restore from backup and file a bug:
   mv _state.json.backup.TIMESTAMP _state.json
   Report: https://github.com/.../issues/new

4. Alternative: Start fresh
   rm architecture-output/_state.json
   Run /architect:blueprint to create new state
```

**Example 2: Type error in state**
```
❌ Project state has a type error: components[0].port should be number, is string "3000"

Port numbers must be integers (3000, 3001, etc.), not strings. This breaks local
development setup and deployment scripts.

How to fix:
1. Run auto-fix:
   /architect:check-state --fix
   - Converts string ports to numbers
   - Creates backup first

2. Verify fix:
   jq '.components[].port' architecture-output/_state.json
   Expected: 3000, 3001, 3002 (no quotes)

3. Try your command again

Advanced: manually fix
  jq '.components[0].port = 3000' _state.json > _state.json.tmp && mv _state.json.tmp _state.json
```

**Example 3: Conflicting state**
```
❌ Project state has critical conflict: component "api-server" claims port 3000,
but "web-app" also uses port 3000

Two services can't use the same port. This will crash your local dev server with
"EADDRINUSE: port already in use".

How to fix:
1. List all components and their ports:
   jq '.components[] | {name, port}' architecture-output/_state.json

2. Pick which component should keep port 3000, which should move

3. Update the component that's changing:
   jq '.components[] | select(.name=="worker-service").port = 3001' _state.json > _state.json.tmp && mv _state.json.tmp _state.json

4. Verify no more conflicts:
   jq '.components[].port' _state.json | sort | uniq -d
   Expected: (empty output — no duplicates)

5. Try your command again

Pro tip: Use the range 3000-3010 for services, 5000-5010 for APIs, 8000-8010 for workers
```

---

### 3. Cascading Failures

**Trigger:** Previous command failed, current command can't run because of that.

**Template:**
```
❌ Cannot proceed: /architect:[PREVIOUS_COMMAND] failed earlier

[PREVIOUS_COMMAND] creates [OUTPUT] that [CURRENT_COMMAND] depends on.
Since [PREVIOUS_COMMAND] failed, that [OUTPUT] doesn't exist.

How to fix:
1. Investigate why /architect:[PREVIOUS_COMMAND] failed:
   - Read the error message above
   - Check: ls -la [OUTPUT_PATH]
   - If output missing or incomplete: previous command didn't succeed

2. Fix the root cause:
   [specific fixes based on previous error]

3. Re-run /architect:[PREVIOUS_COMMAND]
   - Wait for success ("✅ Completed successfully")
   - Check output exists: ls -la [OUTPUT_PATH]

4. Now try /architect:[CURRENT_COMMAND] again
```

**Example 1: Scaffold failed, tests can't run**
```
❌ Cannot generate tests: /architect:scaffold failed last time

Scaffold creates source files that tests analyze. Since scaffold didn't succeed,
there are no source files for tests to work with.

How to fix:
1. Check what went wrong with scaffold:
   Look at the error output from the previous /architect:scaffold run
   Common causes: missing dependencies, invalid project structure, Node.js version

2. Fix the issue:
   - If "npm install failed": Check package.json is valid, run npm install manually
   - If "build failed": Fix TypeScript/syntax errors, run npm run build
   - If "Node.js v18 required, have v16": Upgrade Node.js

3. Re-run scaffold:
   /architect:scaffold
   
   Watch for the success message:
   ✅ Scaffold complete: 8 components generated, dependencies installed, build passed

4. Verify scaffold succeeded:
   ls -la src/components/ | wc -l  # should show directories

5. Now try tests:
   /architect:generate-tests
```

**Example 2: Design system outdated, components don't match**
```
❌ Cannot proceed: /architect:design-system is outdated

Scaffold generates components using design tokens. Design tokens were last generated
30 days ago. They might not match current colors, fonts, or spacing in _state.json.

Result: newly generated components won't match existing components (inconsistent UI).

How to fix:
1. Regenerate design tokens:
   /architect:design-system --regenerate
   (estimated 15 minutes)

2. Check tokens are up-to-date:
   jq '.design' architecture-output/_state.json | head -10
   ls -l architecture-output/design-system/design-tokens.json

3. Regenerate scaffold with new tokens:
   /architect:scaffold --regenerate
   (estimated 45 minutes)

4. Try your command:
   /architect:scaffold-component --name [name]
```

---

### 4. Consistency Violations

**Trigger:** Consistency check found conflicts that prevent command from running.

**Template:**
```
❌ Consistency check failed: [N] conflicts detected

Conflicts prevent reliable code generation. Outputs from different commands contradict
each other, which would create broken or inconsistent results.

Critical conflicts to fix:
[LIST 1-3 MOST IMPORTANT]

How to fix:
1. See full conflict report:
   cat architecture-output/consistency-report.md

2. Fix conflicts in order (critical first):
   /architect:validate-consistency --fix
   - Auto-fixes safe conflicts
   - Shows manual fixes needed for complex conflicts

3. Re-run conflict check:
   /architect:validate-consistency
   Expected: "✅ Pass Rate: 52/52 outputs consistent (100%)"

4. Try your command again
```

**Example 1: Design token mismatch**
```
❌ Consistency check failed: 1 critical conflict (design colors don't match)

Design tokens file has primary color #0ea5e9, but _state.json says #f97316.
This means some components use one color, others use the different color → inconsistent UI.

Critical conflicts:
1. Design token contradiction: _state.json.design.primary (#f97316) ≠ tokens.json.primary (#0ea5e9)

How to fix:
1. View full conflict report:
   cat architecture-output/consistency-report.md | grep -A 10 "CONF-001"

2. Decide which color is correct:
   Option A: Keep state color (#f97316, from latest blueprint)
     → Run /architect:design-system --regenerate
   Option B: Keep token color (#0ea5e9, older)
     → Revert blueprint change

3. Re-check consistency:
   /architect:validate-consistency
   Expected: ✅ All consistent

4. Try your command again
```

**Example 2: Stale outputs**
```
❌ Consistency check failed: 3 warnings about stale outputs

Cost estimate is 30 days old (state has changed), design system hasn't regenerated,
and blueprint was updated but scaffold wasn't. Outputs are outdated.

Stale outputs to refresh:
1. /architect:cost-estimate (30 days old, 25% undercounting new components)
2. /architect:design-system (14 days old, colors changed since then)

How to fix:
1. Regenerate stale outputs:
   /architect:design-system
   /architect:cost-estimate
   (combined estimated time: 30 minutes)

2. Re-check consistency:
   /architect:validate-consistency
   Expected: ✅ All consistent

3. Try your command again
```

---

### 5. Blockers (Can't execute due to external factors)

**Trigger:** User environment is missing tools, permissions, or external services.

**Template:**
```
❌ Cannot execute: [BLOCKER_NAME]

[EXPLAIN THE BLOCKER AND WHY IT'S REQUIRED]

How to fix:
[STEP 1]
[STEP 2]
...

Verification:
[HOW TO CONFIRM THE FIX WORKED]
```

**Example 1: Missing Node.js**
```
❌ Cannot scaffold: Node.js v18+ is required, but not installed

Scaffold generates Node.js/TypeScript projects. Without Node.js, we can't:
- Install dependencies (npm install)
- Run the build process (npm run build)
- Verify the generated code

How to fix:
1. Install Node.js 18 or later:
   https://nodejs.org/
   (choose LTS version: 20.x or later)

2. Verify installation:
   node --version  # should output v18.x.x or higher
   npm --version   # should output 9.x or higher

3. Try scaffold again:
   /architect:scaffold

Still stuck? Check:
  which node
  ls -la ~/.nvm/versions/  (if using nvm)
  brew list node            (if using brew on macOS)
```

**Example 2: Missing Git**
```
❌ Cannot setup CI/CD: Git is required, but not installed

CI/CD pipeline integrates with Git (GitHub, GitLab, etc.). Without git, we can't:
- Create GitHub Actions workflows
- Setup GitLab CI pipelines
- Generate deployment configurations

How to fix:
1. Install Git:
   macOS: brew install git
   Ubuntu: sudo apt-get install git
   Windows: https://git-scm.com/download/win

2. Initialize git repository:
   git init
   git config user.name "Your Name"
   git config user.email "your.email@example.com"

3. Verify:
   git --version

4. Try again:
   /architect:setup-cicd
```

**Example 3: No internet connection (for external API calls)**
```
❌ Cannot complete: Network unavailable

This command needs to fetch [RESOURCE] from [SERVICE]. Without internet, that request fails.

How to fix:
1. Check network connection:
   ping github.com
   (should show responses, not "Host unreachable")

2. Check service availability:
   Open in browser: [SERVICE_URL]
   If service is down: wait for it to recover

3. If behind corporate firewall:
   Configure proxy: export https_proxy=proxy.company.com:8080

4. Retry:
   /architect:[COMMAND]
```

---

### 6. Warnings (Proceed with caution)

**Trigger:** Command can execute, but output quality will be degraded.

**Template:**
```
⚠️  Warning: [WHAT_IS_SUBOPTIMAL]

Impact: [WHY THIS MATTERS]

Recommendation:
Option A: Fix now (estimated X minutes) → better results
Option B: Proceed as-is → results will be suboptimal, can fix later

Run command with --force to proceed at own risk:
  /architect:[COMMAND] --force
```

**Example 1: Incomplete data model**
```
⚠️  Warning: Data model is incomplete

You have 3 entities defined (User, Post, Comment) but no relationships.
Tests will be generic and won't validate complex entity interactions.

Recommendation:
Option A: Run /architect:generate-data-model to complete schema (10 min)
  → tests will include relationship validation
  → higher-quality, more realistic test coverage

Option B: Generate tests now with incomplete model
  → tests will work, but miss important edge cases
  → recommend fixing later before launch

Proceed with tests?
  Yes: /architect:generate-tests
  No: First run /architect:generate-data-model, then tests
```

**Example 2: Outdated blueprint**
```
⚠️  Warning: Blueprint is 30 days old

A lot can change in 30 days — new components, changed tech stack, updated design.
Your tests will be based on old architecture.

Recommendation:
Option A: Refresh blueprint first (20 min)
  /architect:blueprint --regenerate
  → tests will match current architecture
  → catch new components, removed features

Option B: Use current blueprint
  → tests might miss new components
  → might test removed features
  → recommend checking before commit

Proceed with tests?
  Yes: /architect:generate-tests
  No: First run /architect:blueprint --regenerate, then tests
```

---

## Error Message Best Practices

### 1. Be Specific
**Bad:** "Error occurred"
**Good:** "Cannot scaffold: Node.js v18+ required, but have v16.2.0"

### 2. Explain Why
**Bad:** "Missing _state.json"
**Good:** "Cannot generate tests: state file (_state.json) not found. State defines your project's tech stack, components, and design — tests need this info to know what framework/patterns to test."

### 3. Show How to Fix
**Bad:** (just showing error)
**Good:** 
```
How to fix:
1. Run /architect:blueprint (20 min)
2. Try generate-tests again
```

### 4. Include Context When Helpful
**Bad:** "Failed"
**Good:**
```
❌ Scaffold generation failed at step 3/6: "npm install"

Error: npm ERR! 404  Not Found - GET https://registry.npmjs.org/@custom/library
This package isn't published or isn't accessible in the registry.

How to fix:
- Update package.json to remove @custom/library
- Use npm publish to publish it first
- Or use local path: "@custom/library": "file:../libraries/custom"
```

### 5. Offer Next Steps
**Bad:** "Done with error"
**Good:**
```
✅ Scaffold complete with 1 warning

Warning: TypeScript strict mode is not enabled.
This is optional, but recommended for better type safety.

To enable:
1. Update tsconfig.json: "strict": true
2. Run npm run build to check for new type errors
3. Fix any errors

Want to see what changed? git diff tsconfig.json
```

---

## Command-Specific Error Messages

### `/architect:scaffold`

Common errors:

```
❌ No SDL found

How to fix:
  /architect:blueprint
  /architect:sdl --generate

---

❌ Scaffold directory already exists (src/, package.json, etc.)

How to fix:
  Option A: Backup and remove old scaffold
    mv src src.backup
    mv package.json package.json.backup
    /architect:scaffold

  Option B: Use different directory
    /architect:scaffold --output-dir new-src

---

❌ npm install failed

How to fix:
  Manual steps:
  1. Check package.json syntax: npm ls
  2. Install again: npm install --verbose
  3. Check Node version: node --version
  4. Clear cache: npm cache clean --force
  5. Try again: npm install

  If still failing:
    npm audit fix
    npm install
```

### `/architect:generate-tests`

Common errors:

```
❌ No source files found to test

How to fix:
  /architect:scaffold

---

❌ Test framework not specified

How to fix:
  Add to _state.json:
  "test_suite": {
    "unit_framework": "jest",
    "e2e_framework": "playwright"
  }

  Or regenerate:
  /architect:blueprint --regenerate
  /architect:generate-tests

---

❌ TypeScript errors prevent test generation

How to fix:
  Fix TypeScript errors:
  npx tsc --noEmit
  Fix listed errors, then retry:
  /architect:generate-tests
```

---

## User Experience Guidelines

### Tone

- **Friendly, not condescending** — user is trying to accomplish something
- **Direct, not verbose** — respect their time
- **Actionable, not theoretical** — give specific steps
- **Honest, not optimistic** — if it's hard, say so

**Bad tone:**
```
You clearly didn't run the prerequisite command. Obviously you need to bootstrap first before you can proceed. This is basic architecture workflow.
```

**Good tone:**
```
⚠️  Note: generate-tests needs source code to test.
Run /architect:scaffold first to create the project structure.
Estimated time: 45 minutes.
```

### Timing

- **Fail fast** — check prerequisites at start, not midway
- **Report early** — don't wait 30 minutes to fail
- **Stream output** — show progress while running
- **Report results** — not just "done", tell them what was created

**Bad:**
```
(30 minutes of silent processing, then sudden error)
Failed: something went wrong
```

**Good:**
```
[1/6] Loading project state... ✅ (2 sec)
[2/6] Generating test fixtures... ✅ (8 sec)
[3/6] Creating unit tests... ⏳ (45 sec remaining)
...
[6/6] Writing output files... ✅ (3 sec)

✅ Complete: 847 test cases generated across 12 components
Coverage target: 75% (check with: npm test -- --coverage)
```

### Recovery

- **Always provide a fix** — no dead-end errors
- **Show expected behavior** — "after you fix this, you should see X"
- **Offer alternatives** — "run Y instead of X" or "skip this part"

---

## Testing Error Messages

Before shipping a command, test the error paths:

1. **Test missing prerequisite:**
   ```bash
   # Delete required file, run command, verify error message
   rm _state.json
   /architect:scaffold-component  # should fail gracefully
   ```

2. **Test invalid state:**
   ```bash
   # Corrupt _state.json, run command, verify guidance
   jq '.project.stage = 999' _state.json > temp.json && mv temp.json _state.json
   /architect:scaffold  # should show specific error + how to fix
   ```

3. **Test missing tool:**
   ```bash
   # Hide npm, run command, verify error message
   alias npm=/bin/false
   /architect:scaffold  # should detect npm missing + how to install
   ```

---

## Related Skills

- `pre-execution-validation/SKILL.md` — validates before command runs (catches errors early)
- `conflict-resolution/SKILL.md` — helps resolve conflicts after detected
- `blocker-detection/SKILL.md` — identifies blockers that become errors
