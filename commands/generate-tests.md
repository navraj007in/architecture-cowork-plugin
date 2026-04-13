---
description: Generate unit, integration, and e2e test suites from scaffolded project with framework-appropriate coverage
---

# /architect:generate-tests

## Trigger

`/architect:generate-tests` — generate all test types (default).

`/architect:generate-tests [type:X]` — generate one test type only.

`/architect:generate-tests [types:X,Y]` — generate a named subset.

### Test types

| Type | What it generates |
|------|------------------|
| `unit` | Unit tests per module (pure functions, services, utils) |
| `integration` | Integration tests per service (DB, API, queue interactions) |
| `e2e` | End-to-end tests per critical user flow |

**Examples:**
```
/architect:generate-tests [type:unit]
/architect:generate-tests [types:unit,integration]
/architect:generate-tests [type:e2e] [non_interactive:true]
```

When a `[type:...]` or `[types:...]` tag is present, generate **only** the named test types and skip all others. When absent, generate all types.

### Options

- `[non_interactive:true]` — skip all questions, derive from SDL and existing project
- `[coverage_target:NN]` — override coverage target (default: 80)

## Purpose

After `/architect:scaffold` creates a project, services have no test coverage. This command generates production-ready test suites with unit tests (per module), integration tests (per service), and e2e tests (per critical flow). Scaffolds follow testing-strategy skill conventions: AAA structure, mock patterns, fixture setup, and coverage thresholds by stage.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context--check-for-scaffolded-project) · [Step 1.5](#step-15-detect-test-frameworks) |
| **Configuration** | [Step 2](#step-2-ask-configuration-questions) · [Step 2.5](#step-25-read-testing-skill) |
| **Generation** | [Step 3](#step-3-delegate-to-test-generator-agent) · [Step 3.5](#step-35-verify-test-structure) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 4.5](#step-45-update-_statejson) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context & Check for Scaffolded Project

ℹ️ **CONTEXT LOADING:** _state.json → SDL → scaffolded components

**First**, read `architecture-output/_state.json` if it exists. Extract:
- `project.name`, `project.stage` (MVP/growth/enterprise)
- `tech_stack.backend`, `tech_stack.frontend` (language + framework per component)
- `components[]` (list of services, their types, and directories)
- `entities[]` (domain entity names for test fixtures)

**Then**, check if a blueprint with SDL exists:
- Look for `solution.sdl.yaml` first; if absent, check `sdl/README.md` + module files
- Extract `testing:` section if present (unit.framework, e2e.framework, coverage.target)
- Extract `architecture.projects[]` for component list

**Check for scaffolded projects:**
- Walk the parent directory; for each component in the manifest, verify `<component-name>/` exists
- For each existing component, detect the runtime and installed test framework:
  - Node.js: check `package.json` for `jest`, `vitest`, `mocha`, `cypress`, `playwright`
  - Python: check `requirements.txt` or `pyproject.toml` for `pytest`, `unittest`
  - Go: standard `*_test.go` pattern (no framework install needed)
  - .NET: check `.csproj` for `xunit`, `nunit`, `mstest`
  - Java: check `pom.xml` or `build.gradle` for `junit`, `testng`

**If no scaffolded components found**, respond:

> "I need a scaffolded project to generate tests for. Run `/architect:scaffold` first, then come back here."

### Step 1.5: Detect Test Frameworks

❓ **DECISION POINT:** Framework detection and version compatibility

For each component, detect the test framework already installed:
- Node.js: prioritize `jest` > `vitest` > `mocha` (in order of detection)
- Python: `pytest` (preferred) > `unittest`
- Go: always use standard `testing` package
- .NET: prioritize `xunit` > `nunit`

If no framework is installed, default based on stage and language:
| Runtime | MVP | Growth | Enterprise |
|---------|-----|--------|------------|
| Node.js | Jest | Jest | Jest + Cypress |
| Python | pytest | pytest | pytest + Playwright |
| Go | testing | testing | testing + go-fuzz |
| .NET | xunit | xunit | xunit + FluentValidation tests |

### Step 2: Ask Configuration Questions

❓ **DECISION POINT:** Interactive mode questions (skip if `[non_interactive:true]`)

**If not in non-interactive mode**, ask:

1. **Coverage Target** (default from SDL or 80%):
   > "What's your target code coverage? (default: 80%)"
   > - 70% (MVP minimum)
   > - 80% (recommended for growth)
   > - 90% (strict)

2. **E2E Framework** (if any frontend components exist):
   > "Which e2e testing tool for frontends?"
   > - Playwright (recommended, cross-browser)
   > - Cypress (interactive debugging)
   > - Selenium (legacy)
   > - Skip e2e tests for now

3. **Database Testing** (if data.schema exists):
   > "How should we test database code?"
   > - Real test database (slower, more realistic)
   > - In-memory mocks (faster, unit test only)
   > - Both (integration + unit)

If `[non_interactive:true]`, derive answers from SDL:
- `testing.coverage.target` → use directly
- `testing.e2e.framework` → use directly
- `data.schema` → default to real test database for integration

### Step 2.5: Read Testing Skill

🔄 **SKILL LOAD:** Read testing-strategy/SKILL.md

Before delegating, read `skills/testing-strategy/SKILL.md` in full. This skill is the authoritative guide for:
- File organization and naming conventions (co-locate vs tests/ dir)
- Arrange-Act-Assert structure and naming best practices
- Framework-specific setup (jest.config.js, pytest.ini, etc.)
- Mocking strategies (in-memory DB, HTTP mocks, fixtures, factories)
- Coverage thresholds by stage
- Async/await patterns
- CI/CD integration

The test-generator agent will reference this skill for all code generation.

### Step 3: Delegate to test-generator Agent

🔄 **AGENT DELEGATION:** Launch test-generator agent (autonomous, file-generating)

Pass the following to the **test-generator** agent:

- **Component list** from `_state.json.components[]`:
  - name, type, directory path, language, framework
  - source directories (src/, app/, lib/, packages/)

- **Test configuration**:
  - coverage_target (from Step 2 or SDL)
  - unit_framework (detected or defaulted)
  - e2e_framework (if applicable)
  - database_approach ('real' | 'mock' | 'both')

- **Test data**:
  - `_state.json.entities[]` — entity names for fixture generation
  - `_state.json.project.stage` — MVP/growth/enterprise (affects stub depth)
  - SDL entity definitions (fields, relationships)

- **Reference materials**:
  - Path to `skills/testing-strategy/SKILL.md` — agent will read and follow

- **Auth context** (from SDL):
  - `auth.strategy` — affects mock auth setup in tests
  - `auth.serviceTokenModel` — JWT vs API key mocking

**The agent MUST:**
1. Generate `__tests__/` or `tests/` directory per project structure
2. Create framework config files (jest.config.js, pytest.ini, .xunitrc, etc.)
3. Generate unit test stubs for each service/controller/class
4. Generate integration tests for database layer (if applicable)
5. Generate e2e test stubs for critical user flows
6. Create fixture and factory files for reusable test data
7. Add test scripts to `package.json` / `Makefile` / equivalent
8. Add CI/CD test step to `.github/workflows/ci.yml` (or equivalent)
9. Log generated files to activity log

**The agent MUST NOT:**
- Modify any existing source files
- Delete or overwrite existing tests
- Generate tests for external dependencies (third-party libraries)

### Step 3.5: Verify Test Structure

✅ **QUALITY GATE:** Check generated files before proceeding

After the agent completes, verify the test structure:

For each component:
1. Check that `jest.config.js` (or equivalent) exists and has `coverageThreshold` set to `coverage_target`
2. Check that unit tests exist for each source file (by glob: if `src/services/user.ts` exists, `src/services/__tests__/user.test.ts` should exist)
3. Check that `package.json` has a `test` script (or `Makefile` has `test` target)
4. For frontends: check that `cypress.json` or `playwright.config.ts` exists if e2e was requested

If verification fails:
- Report the missing files to the user
- Do NOT block completion — the user can fix manually or re-run
- Continue to Step 4

### Step 4: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"generate-tests","outcome":"completed","components":["api-server","web-app"],"frameworks":{"unit":"jest","e2e":"playwright"},"coverage_target":80,"files_generated":["jest.config.js","tests/__tests__/user.test.ts","cypress.json"],"summary":"Generated test suites for 2 components: jest unit (70 test files), playwright e2e (5 flows). Coverage target: 80%."}
```

For each component, also append to `<component-name>/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"generate-tests","framework":"jest","status":"created","files_created":["jest.config.js","src/__tests__/","tests/integration/","e2e/"],"summary":"Test scaffold: jest unit (10 files), integration (3 files), e2e (2 files). Fixtures and factories generated."}
```

### Step 4.5: Update _state.json

Read existing `architecture-output/_state.json` (or start with `{}`).

Merge ONLY the `test_suite` field:

```json
{
  "test_suite": {
    "generated_at": "<ISO-8601>",
    "coverage_target": 80,
    "unit_framework": "jest",
    "e2e_framework": "playwright",
    "suites": {
      "api-server": {
        "unit_test_count": 40,
        "integration_test_count": 12,
        "e2e_test_count": 3
      }
    },
    "files_generated": 68
  }
}
```

Write back to `architecture-output/_state.json` without overwriting other fields.

### Step 5: Signal Completion

🚀 **COMPLETION MARKER:** Emit [GENERATE_TESTS_DONE]

Emit the completion marker:

```
[GENERATE_TESTS_DONE]
```

This ensures the test generation phase is marked as complete in the project state.

## Error Handling

### Missing Scaffolded Project

If no scaffolded components exist:
> "I need a scaffolded project to generate tests for. Run `/architect:scaffold` first, then come back here."

### Test Framework Not Installed

If a required testing framework (jest, pytest, xunit, go test) is not installed in a component:
- Report: "Testing framework not installed for [component]. Run `npm install --save-dev jest@latest` (or equivalent) first."
- Do NOT proceed — let user install and re-run

### Existing Test Files

If tests already exist for a module (detected via glob: `__tests__/`, `tests/`, `*_test.py`, `*_test.go`):
- Report: "Existing tests found for [module]; I'll augment instead of overwriting"
- Append new tests rather than replacing file

### Source File Parsing Fails

If a source file has syntax errors and cannot be analyzed:
- Log warning: `"parse_failed_<file>"`
- Generate stub test file with TODO comments
- Continue to next component

**Example stub:**
```typescript
describe('[Module]', () => {
  // TODO: Verify module exports and generate tests accordingly
  it('should be defined', () => {
    // Add test case
  });
});
```

### Unable to Write Test Files

If `__tests__/`, `tests/`, or equivalent directory cannot be created due to permissions:
- Stop execution
- Report: "Cannot create test directory: [error]. Check file permissions."
- Do NOT emit completion marker

## Output Rules

- Use the **founder-communication** skill for tone
- Generated test files MUST follow the testing-strategy skill exactly (AAA structure, naming conventions, framework configs)
- Do NOT modify source files — only generate test files
- Write all files into the component directories (jest.config.js in root, tests/ in subdirs)
- If any component already has tests, append new tests instead of overwriting
- Do NOT include the CTA footer
- For large test suites (>100 test files), create an index file: `tests/TEST_INDEX.md` listing all test suites by component
- If coverage target cannot be met due to external dependencies, document in `tests/COVERAGE_GAPS.md` with explanation
- Test output should be runnable immediately: `npm test` or `pytest` or `go test ./...` should work without setup
