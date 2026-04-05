---
description: Generate load testing scenarios (k6/Locust) from API contracts with realistic traffic patterns
---

# /architect:load-test

## Trigger

`/architect:load-test [options]`

Options:
- `[tool:k6|locust|artillery]` — specify load testing tool (default: k6)
- `[non_interactive:true]` — skip all questions, derive from SDL performance targets
- `[rps:100]` — override requests per second (default: from SDL or 10)

## Purpose

Before production launch, verify APIs handle expected load. This command generates load testing scenarios from OpenAPI contracts with realistic traffic patterns: smoke tests (baseline), load tests (target RPS), stress tests (2x), and spike tests (sudden 10x surge). Uses k6, Locust, or Artillery depending on preference.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context-and-detect-contracts) · [Step 1.5](#step-15-detect-load-testing-tool) |
| **Configuration** | [Step 2](#step-2-ask-configuration-questions) |
| **Generation** | [Step 3](#step-3-delegate-to-load-test-generator) · [Step 3.5](#step-35-verify-load-test-scripts) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 4.5](#step-45-update-_statejson) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context and Detect Contracts

ℹ️ **CONTEXT LOADING:** _state.json → SDL → OpenAPI contracts

**First**, read `architecture-output/_state.json` if it exists. Extract:
- `project.name`, `project.stage` (MVP/growth/enterprise)
- `tech_stack.backend` (which services to test)
- `components[]` with port numbers

**Then**, check for API contracts:
- Look for `architecture-output/contracts/*.openapi.yaml`
- If contracts don't exist, respond:
  > "I need API contracts to generate load tests from. Run `/architect:scaffold` (which generates contracts in Step 3.7), then come back here."

**For each contract**, extract:
- All endpoints (GET, POST, PUT, DELETE, etc.)
- Request body schemas (for POST/PUT)
- Response schemas
- Status codes (200, 400, 404, 500, etc.)

### Step 1.5: Detect Load Testing Tool

❓ **DECISION POINT:** Tool and framework selection

Detect if load testing tools are already installed:
- Node.js: check `package.json` for `k6`, `artillery`
- Python: check `requirements.txt` for `locust`
- Go: check `go.mod` for `k6` (k6 is written in Go)

If `[tool:X]` specified, use that tool.
Otherwise, default to k6 (most popular, cross-platform, JavaScript-based).

### Step 2: Ask Configuration Questions

❓ **DECISION POINT:** Load profile and thresholds

**If not in non-interactive mode**, ask:

1. **Target load** (requests per second):
   > "What's your target RPS (requests per second)?"
   > - Default suggestion: Based on SDL `nonFunctional.performance` or 10 RPS
   > - User input: e.g., 50, 100, 500

2. **Test duration**:
   > "How long should load tests run?"
   > - Smoke test: 30 seconds (quick validation)
   > - Load test: 5 minutes (sustained load)
   > - Stress test: 10 minutes (find breaking point)

3. **Ramp-up period**:
   > "How quickly to ramp up to target load?"
   > - Immediate (0 seconds) — spike test
   > - Linear (1 minute) — gradual ramp
   > - Stepped (30 seconds per stage) — staged ramp

**If `[non_interactive:true]`**, derive:
- Target RPS from SDL `nonFunctional.performance.maxRps` (or 10)
- Duration from stage: MVP (2 min), Growth (5 min), Enterprise (15 min)
- Ramp-up: always 1 minute (standard practice)

### Step 3: Delegate to load-test-generator Agent

🔄 **AGENT DELEGATION:** Launch load-test-generator agent (autonomous, scenario-generating)

Pass the following to the **load-test-generator** agent:

- **Load testing configuration**:
  - tool: k6 / locust / artillery
  - target_rps: number (requests per second)
  - test_duration_seconds: number
  - ramp_up_seconds: number

- **API contracts**:
  - Path to `architecture-output/contracts/` directory
  - For each contract: endpoints, methods, schemas

- **Service info**:
  - Service names and endpoints (http://localhost:3000, etc.)
  - Which endpoints are public vs. authenticated

- **Thresholds**:
  - From stage: MVP (p95 < 1s), Growth (p95 < 500ms), Enterprise (p95 < 200ms)
  - Error rate limits: MVP (< 5%), Growth (< 1%), Enterprise (< 0.5%)

**The agent MUST:**
1. For each API service, generate load test scenarios:
   - **Smoke**: 1 VU, 30 seconds (baseline)
   - **Load**: Ramp to target RPS over 1 minute, sustain 5 minutes, ramp down 1 minute
   - **Stress**: Ramp to 2x target RPS, sustain 10 minutes
   - **Spike**: 10x target RPS for 30 seconds, then back to normal
2. Create `load-tests/<service>/scenarios/` with scenario files per tool
3. Generate `load-tests/<service>/thresholds.json` with pass/fail criteria
4. Create `load-tests/<service>/config.json` with target endpoints
5. Create `load-tests/run.sh` — orchestration script to run all scenarios
6. Log generated files to activity log

**The agent MUST NOT:**
- Modify any source code
- Execute actual load tests (only generate scripts)
- Make real HTTP requests to services during generation

### Step 3.5: Verify Load Test Scripts

✅ **QUALITY GATE:** Check generated files before proceeding

After the agent completes, verify the load test structure:

For each service:
1. Check that `load-tests/<service>/scenarios/smoke.js` (or .py) exists
2. Check that `load-tests/<service>/thresholds.json` exists with p95/p99/error rate targets
3. Check that `load-tests/run.sh` has execution permissions and mentions all services
4. Spot-check one scenario file for realistic traffic patterns (not just GET requests)

If verification fails:
- Report missing files to the user
- Do NOT block completion — user can add scenarios manually
- Continue to Step 4

### Step 4: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"load-test","outcome":"completed","tool":"k6","target_rps":100,"services":["api-server","worker"],"scenarios":["smoke","load","stress","spike"],"files_generated":12,"summary":"Load test scenarios generated for 2 services. Target: 100 RPS. Thresholds: p95<500ms, error<1%."}
```

### Step 4.5: Update _state.json

Read existing `architecture-output/_state.json` (or start with `{}`).

Merge ONLY the `load_testing` field:

```json
{
  "load_testing": {
    "generated_at": "<ISO-8601>",
    "tool": "k6",
    "target_rps": 100,
    "services": ["api-server"],
    "scenarios": ["smoke", "load", "stress", "spike"],
    "thresholds": {
      "p95_latency_ms": 500,
      "p99_latency_ms": 1000,
      "error_rate_percent": 1
    },
    "files_generated": 12
  }
}
```

Write back to `architecture-output/_state.json` without overwriting other fields.

### Step 5: Signal Completion

🚀 **COMPLETION MARKER:** Emit [LOAD_TEST_DONE]

Emit the completion marker:

```
[LOAD_TEST_DONE]
```

This ensures the load-test generation phase is marked as complete in the project state.

## Error Handling

### Missing API Contracts

If no OpenAPI contracts exist in `architecture-output/contracts/`:
> "I need API contracts to generate load tests from. Run `/architect:scaffold` first (which generates contracts in Step 3.7), then come back here."

### Unsupported Load Testing Tool

If user requests a tool that's not available (e.g., k6 but k6 CLI not installed):
- Report: "Tool [X] not installed. Install via: [instructions]"
- Fall back to default tool (k6)
- Continue with generation

### Invalid Target RPS

If user specifies RPS that's unrealistic (e.g., 1000000):
- Report: "Target RPS of 1M may exhaust resources. Recommend starting with 100-1000 RPS."
- Still generate (user may have good reason)

### Unable to Write Test Files

If `load-tests/` directory cannot be created due to permissions:
- Stop execution
- Report: "Cannot write load test files: [error]. Check file permissions."
- Do NOT emit completion marker

### Contract Schema Parsing Fails

If an OpenAPI schema is malformed and cannot be parsed:
- Log warning: `"contract_parse_failed_<service>"`
- Skip that contract, continue with others
- Report: "Could not parse contract for [service]; skipped from load tests"

## Output Rules

- Use the **founder-communication** skill for tone
- Generated test scenarios MUST be immediately runnable: `k6 run scenarios/smoke.js` or `locust -f locustfile.py`
- Realistic traffic patterns: mix GET/POST/DELETE, use realistic payloads from contract schemas
- Thresholds must match stage (MVP more lenient, Enterprise strict)
- Include documentation: comments in scripts explaining what each scenario tests
- All endpoints from contract should be represented in scenarios (at least smoke test coverage)
- Provide example run commands in README
- Do NOT include the CTA footer
