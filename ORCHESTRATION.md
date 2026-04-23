---
name: Agent Orchestration & Recovery Rules
description: Defines agent dependencies, error recovery chains, timeouts, and fallback strategies
---

# Agent Orchestration & Recovery Rules

This document specifies how the 18 delegated agents interact, coordinate, and recover from failures. It is the authoritative source for multi-agent orchestration patterns in the plugin.

---

## Agent Dependency Graph

```
┌─────────────────────────────────────────────────────────────────┐
│ AGENT DEPENDENCIES (directed graph, read as "requires")        │
└─────────────────────────────────────────────────────────────────┘

blueprint (orchestrator)
  ├── design-system (for design tokens)
  ├── data-model-generator (for entity schemas)
  └── (others: helpers, not blocking)

scaffold / scaffold-component
  └── scaffolder (engine)
      ├── design-system (if design missing)
      └── data-model-generator (if entities missing)

implement
  └── scaffolder (code generation engine)

review / security-scan / well-architected
  └── reviewer (code analysis engine)

generate-tests
  └── test-generator (multi-framework test suite)

generate-docs
  └── docs-generator (runbooks, ADRs, playbooks)

compliance
  └── compliance-scanner (remediation mapping)

setup-monitoring
  └── monitoring-setup (observability config)

setup-cicd
  └── cicd-deployer (pipeline generation)

load-test
  └── load-test-generator (scenario generation)

sync-backlog
  └── backlog-sync (Jira/Azure DevOps push)

prototype / wireframes
  └── figma-agent (design to code)

publish-api-docs
  └── api-docs-publisher (Swagger/Redoc)

export-diagrams
  └── diagram-exporter (Mermaid to PNG/SVG)

Other agents (no explicit dependencies):
  - env-setup (account setup validation)
  - data-model-generator (ORM schema generation)
  - monitoring-setup (observability stack)
  - cicd-deployer (CI/CD pipeline)
```

---

## Error Recovery Chains

### Tier 1: High-Priority Agent Failures (Block User)

**If `scaffolder` fails:**
- Affects: `scaffold`, `scaffold-component`, `implement`
- Recovery:
  1. Log error with component name + error details to `_activity.jsonl`
  2. Surface to user: "Scaffold failed for {component}: {error}. Try running `/architect:check-env` to verify dependencies."
  3. Do NOT cascade to dependent commands (implement, etc.)
  4. User must fix and retry `/architect:scaffold` manually
- Timeout: 30 minutes (scaffold should complete within this; if not, assume stuck)

**If `reviewer` fails:**
- Affects: `review`, `security-scan`, `well-architected`
- Recovery:
  1. Log error with file path + error details
  2. Surface: "Review failed for {file}: {error}. Check file syntax and try again."
  3. Do NOT block subsequent reviews in batch mode
  4. User must address and retry
- Timeout: 10 minutes per file

**If `test-generator` fails:**
- Affects: `generate-tests`
- Recovery:
  1. Log partial results (tests generated so far)
  2. Surface: "Tests generated for {X} components, failed on {component}: {error}"
  3. Status: `partial` (not `failed`)
  4. User can manually fix or retry with `--component {component}`
- Timeout: 15 minutes per component

### Tier 2: Medium-Priority Agent Failures (Non-Blocking)

**If `design-system` fails during `blueprint`:**
- Affects: design tokens in blueprint output
- Recovery:
  1. Log warning: "Design system generation failed; using default tokens"
  2. Continue with default design palette
  3. Blueprint completes but design section is generic
  4. User can run `/architect:design-system` separately to override
  5. Activity log: `outcome: "partial"` (not failed)

**If `data-model-generator` fails during `blueprint`:**
- Affects: entity schemas in blueprint
- Recovery:
  1. Log warning: "Data model generation failed; using SDL entities as-is"
  2. Continue with SDL entities (no ORM schema)
  3. User can run `/architect:generate-data-model` separately
  4. Activity log: `outcome: "partial"`

**If `monitoring-setup` fails:**
- Affects: `setup-monitoring` command
- Recovery:
  1. Log which providers failed (Datadog? New Relic?)
  2. Surface: "Monitoring setup incomplete for {provider}: {reason}. Configure manually or try again."
  3. Status: `partial`
  4. User can run again with `--provider {working-provider}` flag

**If `cicd-deployer` fails:**
- Affects: `setup-cicd` command
- Recovery:
  1. Log which platform failed (GitHub Actions? GitLab CI?)
  2. Surface: "CI/CD setup incomplete. Try `/architect:setup-cicd --platform {other-platform}`"
  3. Status: `partial`

### Tier 3: Low-Priority Agent Failures (Continue Gracefully)

**If `api-docs-publisher` fails:**
- Affects: `publish-api-docs` command
- Recovery: Continue, skip API docs generation, user doesn't notice (optional feature)

**If `diagram-exporter` fails:**
- Affects: `export-diagrams` command
- Recovery: Keep `.mmd` files, skip PNG export, user can export manually

**If `figma-agent` fails:**
- Affects: `prototype`, `wireframes`
- Recovery: Generate local spec files, skip Figma sync, user gets local output

**If `backlog-sync` fails:**
- Affects: `sync-backlog` command  
- Recovery: Generate backlog markdown, skip Jira/Azure DevOps push, user can push manually

---

## Timeout Rules

| Agent | Timeout | Rationale | Recovery |
|-------|---------|-----------|----------|
| `scaffolder` | 30 min | Generates 50-200 files, installs deps, runs build | Log timeout, ask user to check disk/network |
| `test-generator` | 15 min/component | Generates 100-500 tests per component | Log partial, allow skip to next component |
| `docs-generator` | 10 min | Generates 10-20 markdown files | Log timeout, continue with available docs |
| `reviewer` | 10 min/file | Analyzes code + patterns + SDL | Log timeout, skip to next file |
| `compliance-scanner` | 5 min | Framework checklist + remediation | Log timeout, user can retry |
| `monitoring-setup` | 3 min | Config generation (no external calls) | Log timeout, user can retry |
| `cicd-deployer` | 3 min | YAML generation | Log timeout, user can retry |
| `design-system` | 2 min | Token generation | Log timeout, use defaults |
| `data-model-generator` | 2 min | Schema generation | Log timeout, use SDL entities |
| `api-docs-publisher` | 1 min | Spec formatting | Log timeout, skip |
| `diagram-exporter` | 1 min | PNG rendering | Log timeout, skip |
| `figma-agent` | 1 min | Figma spec generation | Log timeout, skip |
| `backlog-sync` | 1 min | JSON format | Log timeout, skip |

**Global rule:** If agent doesn't respond after timeout, force-kill and treat as error. Never wait indefinitely.

---

## Fallback Strategies

### No Fallback (User Must Fix)
- `scaffolder` — generates core project structure; no fallback exists
- `reviewer` — analyzes custom code; no generic fallback

### Use Previous Output (If Available)
- If `design-system` fails but previous design tokens exist in `_state.json.design`: use those
- If `data-model-generator` fails but SDL entities exist: use those  
- If `monitoring-setup` fails but previous config exists: use previous

### Use Defaults (Minimal but Functional)
- `design-system` fails → use Next.js Tailwind defaults (white bg, blue primary, sans-serif)
- `test-generator` fails → generate skeleton test files (user fills in)
- `docs-generator` fails → generate markdown template (user fills in)
- `compliance-scanner` fails → return generic checklist (not customized)

### Skip Feature Gracefully
- `api-docs-publisher` fails → skip, user has OpenAPI spec already
- `diagram-exporter` fails → skip, user can export `.mmd` manually
- `figma-agent` fails → skip, user gets local JSON spec
- `backlog-sync` fails → skip, user can copy-paste into Jira

---

## Cascade Prevention Rules

**Never cascade failures between independent agents:**
- If `test-generator` fails, `generate-docs` should still run
- If `compliance-scanner` fails, `setup-monitoring` should still proceed
- Batch operations process all items even if some fail (report `partial`)

**Explicit blocking dependencies only:**
- `scaffold` depends on `scaffolder` — scaffold fails if scaffolder fails
- `blueprint` SOFT-depends on `design-system` — continues if design-system fails
- `implement` depends on `scaffolder` — implement fails if scaffolder fails

---

## State Management During Agent Execution

### Pre-Execution
1. Read current `_state.json`
2. Log activity entry: `{"phase":"<agent-name>","status":"starting"}`

### During Execution
1. Agent runs (isolated, no access to other agents)
2. Agent returns structured result: `{success: true|false, output: {...}, errors: [...]}`

### Post-Execution (Success)
1. Merge agent output into `_state.json`
2. Only merge fields this command owns (per CLAUDE.md)
3. Log activity: `{"phase":"<agent-name>","status":"success"}`

### Post-Execution (Failure)
1. Do NOT merge partial state
2. Log activity: `{"phase":"<agent-name>","status":"failed","error":"<reason>"}`
3. Decide: block or continue (per recovery chain above)

---

## Multi-Agent Orchestration Example: Blueprint Command

```
/architect:blueprint
  ├─ Load _state.json (if exists) + solution.sdl.yaml
  ├─ Generate blueprint structure (local, no agent needed)
  ├─ (PARALLEL) Orchestrate agents:
  │  ├─ Agent: design-system
  │  │  ├─ Input: SDL design section
  │  │  ├─ Timeout: 2 min
  │  │  ├─ Failure: skip, use defaults
  │  │  └─ Output: design tokens → merge into _state.json.design
  │  │
  │  ├─ Agent: data-model-generator
  │  │  ├─ Input: SDL entities
  │  │  ├─ Timeout: 2 min
  │  │  ├─ Failure: skip, use SDL as-is
  │  │  └─ Output: ORM schemas → write to architecture-output/schema-*.prisma
  │  │
  │  └─ Agent: (any others needed for blueprint)
  │
  ├─ Wait for all agents to complete (or timeout)
  ├─ Merge results into blueprint.json
  └─ Log activity: outcome="success|partial"
```

**Key points:**
- Agents run in parallel (no sequential blocking)
- Blueprint continues even if design-system or data-model-generator fail
- Each failure is logged independently
- If ANY agent times out, continue with defaults/previous values

---

## Monitoring & Observability

### Activity Log Format (Per Command)

```json
{
  "ts": "2026-04-24T14:32:10Z",
  "command": "blueprint",
  "agents_dispatched": ["design-system", "data-model-generator"],
  "agent_results": {
    "design-system": {"status": "success", "duration_ms": 1200},
    "data-model-generator": {"status": "failed", "error": "no entities in SDL", "fallback": "used SDL defaults"}
  },
  "outcome": "partial",
  "summary": "Blueprint generated with default design tokens (design-system failed)"
}
```

### Health Checks

Monitor these metrics over time:
1. **Agent success rate** — "design-system fails 5% of the time" (normal)
2. **Timeout frequency** — "scaffolder timeouts 2% of the time" (investigate if >5%)
3. **Fallback usage** — "blueprint uses design defaults 10% of the time" (normal)
4. **Recovery effectiveness** — "After retry, 90% of failed commands succeed" (good sign)

---

## Future Enhancements (Phase 2+)

1. **Adaptive timeout** — Adjust timeout based on recent performance
2. **Intelligent retry** — Retry failed agents with modified parameters
3. **Circuit breaker** — If agent fails >N times, disable it and show warning
4. **Parallel agent limiting** — Don't spin up more than 5 agents simultaneously
5. **Cost tracking** — Track LLM token usage per agent, alert if exceeds budget

