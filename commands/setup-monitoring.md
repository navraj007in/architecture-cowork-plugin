---
description: Configure observability stack with metrics, tracing, logging, alerts, and dashboards
---

# /architect:setup-monitoring

## Trigger

`/architect:setup-monitoring [options]`

Options:
- `[non_interactive:true]` — skip all questions, derive from SDL and existing project
- `[provider:<name>]` — override metrics provider (e.g., `[provider:datadog]`)

## Purpose

After `/architect:scaffold` creates services, they have no observability wired end-to-end. This command generates a production-ready monitoring stack with metrics collection (Prometheus/Datadog/New Relic), distributed tracing (OpenTelemetry), structured logging (Loki/CloudWatch), alerting rules, and Grafana dashboards. Follows observability-skill patterns: RED method, USE method, golden signals, SLO templates, and stage-appropriate alert thresholds.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context--check-for-scaffolded-project) · [Step 1.5](#step-15-detect-monitoring-stack) |
| **Configuration** | [Step 2](#step-2-ask-configuration-questions) · [Step 2.5](#step-25-read-observability-skill) |
| **Generation** | [Step 3](#step-3-delegate-to-monitoring-setup-agent) · [Step 3.5](#step-35-verify-monitoring-structure) |
| **Completion** | [Step 4](#step-4-log-activity) · [Step 4.5](#step-45-update-_statejson) · [Step 5](#step-5-signal-completion) |

### Step 1: Read Context & Check for Scaffolded Project

ℹ️ **CONTEXT LOADING:** _state.json → SDL → scaffolded components

**First**, read `architecture-output/_state.json` if it exists. Extract:
- `project.name`, `project.stage` (MVP/growth/enterprise)
- `tech_stack.backend`, `tech_stack.frontend` (frameworks per component)
- `components[]` (list of services, types, directories, frameworks)

**Then**, check if a blueprint with SDL exists:
- Look for `solution.sdl.yaml` first; if absent, check `sdl/README.md` + module files
- Extract `nonFunctional.observability:` section if present (provider, tracing, logging, alerting preferences)
- Extract `integrations.monitoring:` section if present (existing dashboards, provider details)

**Check for scaffolded projects:**
- Walk the parent directory; for each component in the manifest, verify `<component-name>/` exists
- For each existing component, check if `src/lib/` contains `metrics.ts`, `tracing.ts`, or `logger.ts` (might already be partially instrumented by scaffold)

**If no scaffolded components found**, respond:

> "I need a scaffolded project to set up monitoring for. Run `/architect:scaffold` first, then come back here."

### Step 1.5: Detect Monitoring Stack

❓ **DECISION POINT:** Framework detection and provider compatibility

For each component, detect if monitoring is already partially configured:
- Check `package.json` (Node.js) for installed packages: `prometheus-client`, `@opentelemetry/api`, `prom-client`, `datadog`, `newrelic`, `winston`, `pino`
- Check `requirements.txt` (Python) for `prometheus-client`, `opentelemetry-api`, `dd-trace`, `newrelic`, `structlog`
- Check `go.mod` (Go) for `prometheus/client_golang`, `go.opentelemetry.io/otel`
- Check `.csproj` (C#) for `OpenTelemetry.*`, `Datadog.*`

If observability is already partially configured (some packages detected):
- Report: "Partial monitoring detected in [component]. I'll enhance it with missing pieces."
- Continue to Step 2

If no observability packages found, this is a fresh setup → proceed to Step 2

### Step 2: Ask Configuration Questions

❓ **DECISION POINT:** Interactive mode questions (skip if `[non_interactive:true]`)

**If not in non-interactive mode**, ask:

1. **Metrics Provider** (default: Prometheus if self-hosted, Datadog if company has account):
   > "Which metrics provider for RED/USE signals?"
   > - Prometheus + Grafana (recommended: self-hosted, full control)
   > - Datadog (recommended: managed, APM included)
   > - New Relic (managed, strong tracing)
   > - AWS CloudWatch (if on AWS)
   > - None (skip metrics for now)

2. **Distributed Tracing** (if stage is growth or enterprise):
   > "Enable distributed tracing for request flows?"
   > - OpenTelemetry + Jaeger (recommended: vendor-neutral)
   > - Datadog APM (if Datadog selected above)
   > - New Relic APM (if New Relic selected above)
   > - Skip tracing for now

3. **Error & Exception Tracking** (optional):
   > "Wire error tracking?"
   > - Sentry (recommended: free tier generous)
   > - Rollbar (production-focused)
   > - Built-in (use structured logs only)
   > - None

4. **Log Aggregation** (if stage is growth or enterprise):
   > "Aggregate logs to a central system?"
   > - Loki + Grafana (recommended: lightweight, part of Prometheus stack)
   > - ELK Stack (Elasticsearch + Kibana; heavier)
   > - Datadog Logs (if Datadog selected above)
   > - CloudWatch Logs (if on AWS)
   > - Structured logs only (no aggregation)

5. **Alert Severity** (default from stage):
   > "Alert aggressiveness?"
   > - MVP: Alert on service down only (minimal noise)
   > - Growth: Alert on errors, latency, resource usage (moderate)
   > - Enterprise: SLO-based alerts + error budget burn (strict)

**If `[non_interactive:true]`**, derive answers from SDL:
- `nonFunctional.observability.metrics.provider` → use directly
- `nonFunctional.observability.tracing.enabled` → decide OpenTelemetry
- `nonFunctional.observability.errors.provider` → use directly
- `nonFunctional.observability.logs.aggregation` → use directly
- `project.stage` → map to alert severity

### Step 2.5: Read Observability Skill

🔄 **SKILL LOAD:** Read skills/observability/SKILL.md

Before delegating, read `skills/observability/SKILL.md` in full. This skill is the authoritative guide for:
- RED method (rate, errors, duration) and USE method (utilization, saturation, errors)
- Golden signals and thresholds
- OpenTelemetry semantic conventions and trace propagation
- Structured logging field names (trace_id, user_id, entity_id, etc.)
- Alert thresholds by stage (MVP < Growth < Enterprise)
- SLO/SLA templates and error budget calculation
- Dashboard design patterns (Prometheus/Grafana/Datadog)
- Multi-cloud observability SDKs

The monitoring-setup agent will reference this skill for all code and config generation.

### Step 3: Delegate to monitoring-setup Agent

🔄 **AGENT DELEGATION:** Launch monitoring-setup agent (autonomous, config-generating)

Pass the following to the **monitoring-setup** agent:

- **Component list** from `_state.json.components[]`:
  - name, type, directory path, language, framework, port

- **Monitoring configuration**:
  - metrics_provider (Prometheus / Datadog / NewRelic / CloudWatch / none)
  - tracing_enabled (true/false)
  - tracing_provider (OpenTelemetry / Datadog / NewRelic / none)
  - error_tracking_provider (Sentry / Rollbar / none)
  - log_aggregation (Loki / ELK / Datadog / CloudWatch / none)
  - alert_severity (MVP / Growth / Enterprise)

- **Project context**:
  - `_state.json.project.stage` — MVP/growth/enterprise (affects alert thresholds)
  - `_state.json.tech_stack` — languages and frameworks per component
  - SDL `nonFunctional.observability` section

- **Reference materials**:
  - Path to `skills/observability/SKILL.md` — agent will read and follow

**The agent MUST:**
1. Generate `src/lib/metrics.ts` (or equivalent) per component with RED/USE signal collection
2. Generate `src/lib/tracing.ts` with OpenTelemetry initialization and semantic conventions
3. Generate `src/lib/logger.ts` with structured logging setup (Winston/pino/structlog/serilog)
4. Create `monitoring/` directory with config files:
   - `prometheus.yml` (if Prometheus selected)
   - `grafana/dashboards/` — pre-built RED, USE, golden signals dashboards (JSON)
   - `monitoring/alerts/rules.yaml` — alert rules per stage
5. Create `docker-compose.monitoring.yml` with Prometheus + Grafana + optional Loki stack
6. Generate `monitoring/runbooks/` — markdown playbooks for each alert (how to respond, debugging steps)
7. Create `monitoring/slo/` — SLO template per component with availability/latency/error targets
8. Update `package.json` / `Makefile` / `requirements.txt` with observability dependencies
9. Add middleware/hooks to inject trace IDs and structured logging context into all request handlers
10. Log generated files to activity log

**The agent MUST NOT:**
- Modify any existing source files outside `src/lib/`
- Modify `.env` files or credentials
- Delete or overwrite existing monitoring configs
- Generate cloud-provider-specific infrastructure (that's an IaC concern, not observability)

### Step 3.5: Verify Monitoring Structure

✅ **QUALITY GATE:** Check generated files before proceeding

After the agent completes, verify the monitoring structure:

For each component:
1. Check that `src/lib/metrics.ts` (or equivalent) exists and exports RED/USE metrics
2. Check that `src/lib/tracing.ts` exists and initializes OpenTelemetry with service name
3. Check that `src/lib/logger.ts` exists with structured log format (JSON with trace_id, user_id, etc.)
4. Check that `monitoring/alerts/rules.yaml` exists and has alert thresholds matching the selected stage
5. Check that `monitoring/slo/` has at least one SLO template
6. Check that `docker-compose.monitoring.yml` exists if Prometheus was selected
7. Check that `package.json` (or equivalent) has observability dependencies added

If verification fails:
- Report the missing files to the user
- Do NOT block completion — the user can fix manually or re-run
- Continue to Step 4

### Step 4: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"setup-monitoring","outcome":"completed","components":["api-server","web-app"],"provider":"prometheus","tracing":"opentelemetry","alerts":"growth","slos_defined":2,"files_generated":22,"summary":"Monitoring stack configured: Prometheus + Grafana + OpenTelemetry tracing + structured logs. 2 SLOs defined. Alert thresholds: growth stage."}
```

For each component, also append to `<component-name>/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"setup-monitoring","metrics_provider":"prometheus","tracing":"enabled","status":"configured","files_created":["src/lib/metrics.ts","src/lib/tracing.ts","src/lib/logger.ts"],"summary":"Instrumented with RED metrics, OpenTelemetry traces, structured logs (Winston). Trace ID propagation via W3C headers."}
```

### Step 4.5: Update _state.json

Read existing `architecture-output/_state.json` (or start with `{}`).

Merge ONLY the `monitoring` field:

```json
{
  "monitoring": {
    "generated_at": "<ISO-8601>",
    "metrics_provider": "prometheus",
    "tracing": "opentelemetry",
    "error_tracking": "sentry",
    "log_aggregation": "loki",
    "alert_severity": "growth",
    "dashboards": {
      "red_metrics": "monitoring/grafana/dashboards/red-metrics.json",
      "use_metrics": "monitoring/grafana/dashboards/use-metrics.json",
      "slo_status": "monitoring/grafana/dashboards/slo-status.json"
    },
    "alert_rules": "monitoring/alerts/rules.yaml",
    "slos": {
      "api-server": {
        "availability": 0.995,
        "latency_p99_ms": 200,
        "error_rate": 0.005
      }
    },
    "files_generated": 22
  }
}
```

Write back to `architecture-output/_state.json` without overwriting other fields.

### Step 5: Signal Completion

🚀 **COMPLETION MARKER:** Emit [SETUP_MONITORING_DONE]

Emit the completion marker:

```
[SETUP_MONITORING_DONE]
```

This ensures the monitoring setup phase is marked as complete in the project state.

## Error Handling

### Missing Scaffolded Project

If no scaffolded components exist:
> "I need a scaffolded project to set up monitoring for. Run `/architect:scaffold` first, then come back here."

### Observability Skill Not Available

If `skills/observability/SKILL.md` cannot be read:
- Stop execution
- Report: "Observability skill not found. Skill file is required for generating alert rules and SLO templates."
- Do NOT emit completion marker

### Metrics Provider Authentication Fails

If selected provider (Datadog, New Relic) authentication fails:
- Report: "Cannot authenticate to [provider]: [error]. Check API key/token in environment."
- Fall back to Prometheus stack if available
- Log as `outcome: "partial"`

### Unable to Create Monitoring Directory

If `monitoring/` directory cannot be created due to permissions:
- Stop execution
- Report: "Cannot create monitoring directory: [error]. Check file permissions."
- Do NOT emit completion marker

### Docker Compose Not Available

If user selects Prometheus stack but Docker Compose is not installed:
- Report: "Docker Compose not installed. Install via: https://docs.docker.com/compose/install/"
- Still generate config files (user can install Docker later)
- Continue normally

### Conflicting Existing Configs

If monitoring configs already exist (prometheus.yml, grafana configs, etc.):
- Report: "Existing monitoring configs found; I'll augment with missing pieces."
- Merge new dashboards and alert rules instead of overwriting

## Output Rules

- Use the **founder-communication** skill for tone
- Generated config files MUST follow the observability-strategy skill exactly (RED/USE methods, semantic conventions, alert thresholds by stage, SLO templates)
- Do NOT modify source files outside `src/lib/` — only generate new monitoring-specific code
- Write all monitoring config into `monitoring/` directory; code into `src/lib/`
- If Prometheus was selected, include a working `docker-compose.monitoring.yml` with Prometheus, Grafana, and optional Loki
- All alert rules must be stage-appropriate: MVP alerts only on service down; Growth adds latency/error/resource alerts; Enterprise adds SLO-based and error budget burn alerts
- SLO templates must include availability, latency (p95/p99), and error rate targets with monthly error budget calculations
- Generated dashboards must include RED metrics (rate, errors, duration), golden signals (latency p50/p95/p99, traffic, errors, saturation), and SLO status
- Dashboard JSON files must be directly importable into Grafana without manual configuration
- Test that trace IDs and user IDs propagate through the request flow via structured logs (spot-check one request end-to-end)
- Do NOT include the CTA footer
