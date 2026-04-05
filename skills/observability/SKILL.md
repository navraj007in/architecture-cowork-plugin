---
name: Observability & Monitoring
description: Patterns for metrics, tracing, logging, alerting, dashboards, and SLO definition
---

# Observability & Monitoring Skill

Comprehensive observability strategy: metrics collection, distributed tracing, structured logging, alerting rules, dashboard design, and SLO/SLA definitions.

## Overview

Observability answers "what is happening in production?" across three pillars:

1. **Metrics** — numeric signals over time (CPU %, error rate, latency p99)
2. **Logs** — structured text events from code (request IDs, decisions, state changes)
3. **Traces** — request flows across services (entry → service A → service B → exit)

This skill provides framework-agnostic patterns and thresholds for building each pillar.

## Pillar 1: Metrics

### RED Method (Request-driven Services)

For services handling requests, collect three metrics per endpoint:

| Metric | Prometheus | Purpose | Query |
|--------|-----------|---------|-------|
| **Rate** | `http_requests_total` | requests per second | `rate(http_requests_total[1m])` |
| **Errors** | `http_requests_total{status=~"5.."}` | failed % | `rate(http_requests_total{status=~"5.."}[1m]) / rate(http_requests_total[1m])` |
| **Duration** | `http_request_duration_seconds` | latency histogram | `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[1m]))` |

**Implementation pattern (Node.js + Prometheus client):**

```typescript
import promClient from 'prom-client';

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request latency in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.001, 0.01, 0.05, 0.1, 0.5, 1, 2, 5]
});

const httpRequestTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware (Express)
app.use((req, res, next) => {
  const startTime = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - startTime) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.url, res.statusCode)
      .observe(duration);
    httpRequestTotal
      .labels(req.method, req.route?.path || req.url, res.statusCode)
      .inc();
  });
  next();
});
```

### USE Method (Resource-driven Services)

For background workers or batch services, collect three metrics per resource:

| Metric | Prometheus | Purpose | Alert threshold |
|--------|-----------|---------|------------------|
| **Utilization** | `process_cpu_seconds_total`, `process_resident_memory_bytes` | % of capacity used | CPU > 70%, Memory > 80% |
| **Saturation** | `job_queue_length`, `db_connection_pool_active` | items waiting | queue > 100 items |
| **Errors** | `task_failures_total`, `db_connection_errors_total` | failed operations | > 1% of operations |

**Example (background worker):**

```typescript
const jobQueueLength = new promClient.Gauge({
  name: 'job_queue_length',
  help: 'Number of jobs waiting in queue'
});

const taskFailures = new promClient.Counter({
  name: 'task_failures_total',
  help: 'Total failed tasks',
  labelNames: ['task_type', 'error_code']
});

// Worker loop
async function processJob(job: Job) {
  try {
    jobQueueLength.set(await queue.length());
    await job.execute();
  } catch (error) {
    taskFailures.labels(job.type, error.code).inc();
    throw error;
  }
}
```

### Golden Signals (All Services)

Monitor these four signals universally:

| Signal | Metric | MVP | Growth | Enterprise |
|--------|--------|-----|--------|------------|
| **Latency** | p50, p95, p99 | p99 < 500ms | p99 < 200ms | p99 < 100ms |
| **Traffic** | requests/sec | > 0 | track trends | auto-scale rule |
| **Errors** | error rate % | < 1% | < 0.5% | < 0.1% |
| **Saturation** | queue depth, CPU % | manual review | alert @ 70% CPU | auto-scale @ 60% |

**Prometheus dashboard queries:**

```promql
# Latency (p99)
histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))

# Request rate
sum(rate(http_requests_total[1m]))

# Error rate
sum(rate(http_requests_total{status=~"5.."}[1m])) / sum(rate(http_requests_total[1m]))

# CPU utilization
rate(process_cpu_seconds_total[1m]) * 100
```

## Pillar 2: Distributed Tracing

### OpenTelemetry Semantic Conventions

Standard attribute names ensure interoperability across tools (Datadog, Jaeger, New Relic, etc.).

**HTTP attributes:**

```
http.request.method          "GET" | "POST" | ...
http.url                     "https://example.com/users?id=123"
http.target                  "/users?id=123" (path + query)
http.host                    "example.com"
http.status_code             200, 404, 500, ...
http.request.body.size       bytes
http.response.body.size      bytes
```

**Database attributes:**

```
db.system                    "postgresql" | "mysql" | "mongodb" | ...
db.name                      "users_db"
db.statement                 "SELECT * FROM users WHERE id = ?"
db.connection_string         "postgresql://..." (scrubbed of credentials)
db.operation                 "SELECT" | "INSERT" | "UPDATE" | "DELETE"
db.rows_affected             N
```

**Service/span attributes:**

```
service.name                 "api-server"
service.version              "0.1.0"
trace.id                     unique identifier
span.id                      unique per span
span.parent_id               parent span ID (or root span has no parent)
span.kind                    "SERVER" | "CLIENT" | "INTERNAL" | "PRODUCER" | "CONSUMER"
span.status                  "OK" | "ERROR" | "UNSET"
```

### Trace Context Propagation

Pass trace IDs across service boundaries for end-to-end visibility.

**HTTP headers (W3C Trace Context standard):**

```http
traceparent: version-traceId-spanId-traceFlags
Example: traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```

**Implementation (Node.js + OpenTelemetry):**

```typescript
import { getTracer } from '@opentelemetry/api';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';

const tracer = getTracer('api-server');

// Outbound HTTP client call
const span = tracer.startSpan('external-api-call', {
  attributes: {
    'http.method': 'GET',
    'http.url': 'https://dependency-api.example.com/data',
    'span.kind': 'CLIENT'
  }
});

// Automatic propagation via fetch or axios with OpenTelemetry instrumentation
const response = await fetch('https://dependency-api.example.com/data');
span.end();
```

### Trace Sampling Rules

Control what fraction of requests are traced (100% tracing is expensive; smart sampling targets slow/errored requests).

**Sampling strategies by stage:**

| Stage | Sampling rule | Example |
|-------|---------------|---------|
| MVP | 100% (trace all) | `ratio=1.0` — smaller user base, capture everything |
| Growth | Error + tail latency | Trace all errors + slowest 5% (`ratio=0.05` for success paths) |
| Enterprise | Intelligent sampling | Datadog intelligent sampling, New Relic tail-based sampling |

**Implementation (Node.js):**

```typescript
import { NodeTracerProvider, BatchSpanProcessor } from '@opentelemetry/node';
import { ProbabilitySampler } from '@opentelemetry/core';

const provider = new NodeTracerProvider({
  sampler: new ProbabilitySampler(0.1) // 10% sampling for growth stage
});
```

**Tail-based sampling rules (Enterprise):**

```yaml
# Example: sample all errors + slowest 1%
tail_sampling:
  policies:
    - name: error-policy
      type: status_code
      status_code:
        status_codes: [ERROR]
    
    - name: latency-policy
      type: latency
      latency:
        threshold_ms: 1000
        upper_threshold_ms: 5000
```

## Pillar 3: Structured Logging

### Log Levels and Guidelines

Use standardized levels consistently:

| Level | When to use | Example |
|-------|------------|---------|
| **DEBUG** | Development only; very detailed state | `db_query_params: {...}`, `cache_hit: true` |
| **INFO** | Notable events in request flow | `"user created"`, `"payment processed"`, `"email sent"` |
| **WARN** | Recoverable issue needing attention | `"retry after 3 failures"`, `"fallback to default value"` |
| **ERROR** | Request/operation failed, needs investigation | `"database connection timeout"`, `"payment gateway returned 500"` |
| **FATAL** | Service cannot continue, immediate human action needed | `"out of disk space"`, `"database unreachable"` |

**Guidelines:**
- Never log at DEBUG in production (disable via config)
- Use ERROR only for actual errors (not every validation failure)
- WARN for things that worked but are sub-optimal
- Include request context (trace ID, user ID) in every log

### Structured Log Fields

Use consistent field names across all services for dashboard aggregation:

**Request context (always include in every log):**

```json
{
  "trace_id": "0af7651916cd43dd",
  "span_id": "b7ad6b716920",
  "request_id": "req-xyz",
  "user_id": "user-123",
  "tenant_id": "org-456",
  "session_id": "sess-789"
}
```

**Business context:**

```json
{
  "entity_type": "order",
  "entity_id": "order-001",
  "action": "create",
  "status": "pending",
  "amount": 123.45,
  "currency": "USD"
}
```

**Execution context:**

```json
{
  "service": "api-server",
  "version": "0.1.0",
  "environment": "production",
  "function": "processPayment",
  "duration_ms": 234
}
```

**Error context (only when level is ERROR or FATAL):**

```json
{
  "error_code": "PAYMENT_TIMEOUT",
  "error_message": "Payment gateway did not respond within 30s",
  "error_stack": "...stack trace...",
  "retry_count": 2,
  "retriable": true
}
```

### Structured Logging Implementation

**Node.js (Winston):**

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  defaultMeta: {
    service: 'api-server',
    version: process.env.APP_VERSION,
    environment: process.env.NODE_ENV
  },
  transports: [
    new winston.transports.Console({
      format: winston.format.simple()
    }),
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      format: winston.format.json()
    })
  ]
});

// Log with context
logger.info('order created', {
  trace_id: req.traceId,
  user_id: req.userId,
  entity_type: 'order',
  entity_id: orderId,
  amount: 123.45,
  duration_ms: Date.now() - startTime
});

logger.error('payment failed', {
  trace_id: req.traceId,
  error_code: error.code,
  error_message: error.message,
  retry_count: retries,
  retriable: error.retriable
});
```

**Python (structlog):**

```python
import structlog

logger = structlog.get_logger()

logger.info(
    "order_created",
    trace_id=trace_id,
    user_id=user_id,
    entity_type="order",
    entity_id=order_id,
    amount=123.45,
    duration_ms=elapsed_time
)

logger.error(
    "payment_failed",
    trace_id=trace_id,
    error_code=error.code,
    error_message=str(error),
    retry_count=retries
)
```

**Log aggregation (Loki/ELK/Datadog):**

All logs are JSON-serialized. Log aggregation systems parse and index these fields automatically.

Example query (Grafana Loki):

```
{service="api-server", level="error"} | json | error_code != ""
```

## Alerting Rules

### Alert Thresholds by Stage

Use these thresholds as baselines; adjust per service's SLA.

**MVP stage:**

| Alert | Threshold | Duration | Action |
|-------|-----------|----------|--------|
| **Service Down** | Status code 5xx > 10% | 1 min | Page on-call |
| **High Latency** | p95 > 500ms | 5 min | Monitor; page if sustained |
| **Error Spike** | 5x baseline error rate | 2 min | Page on-call |

**Growth stage:**

| Alert | Threshold | Duration | Action |
|-------|-----------|----------|--------|
| **Service Down** | Status code 5xx > 5% | 2 min | Page on-call |
| **High Latency** | p95 > 200ms | 10 min | Page on-call |
| **High Latency** | p99 > 500ms | 5 min | Page on-call |
| **Error Spike** | Error rate > 1% | 5 min | Create incident |
| **CPU Saturation** | > 70% for 10 min | 10 min | Auto-scale or page |
| **Memory Leak** | Memory usage rising > 50%/hour | sustained | Page on-call |

**Enterprise stage:**

| Alert | Threshold | Duration | Action |
|-------|-----------|----------|--------|
| **Service Degradation** | Status code 5xx > 0.5% | 1 min | Create incident |
| **Latency SLO Miss** | p99 > SLO target | 5 min | Create incident |
| **Error Budget Burn** | Consumed > 10%/day | realtime | Page on-call |
| **CPU Saturation** | > 60% for 5 min | sustained | Auto-scale |
| **Database Connection Pool** | Active > 80% | 5 min | Page DBA |
| **Disk Space** | Free < 10% | realtime | Critical alert |

### Prometheus Alert Rules (YAML)

**File location:** `monitoring/alerts/rules.yaml` or integrated into Prometheus config

```yaml
groups:
  - name: api-server
    interval: 30s
    rules:
      # MVP threshold
      - alert: HighErrorRate
        expr: |
          (sum(rate(http_requests_total{status=~"5.."}[1m])) 
           / sum(rate(http_requests_total[1m]))) > 0.1
        for: 1m
        annotations:
          summary: "High error rate (>10%) in api-server"
          description: "Error rate: {{ $value | humanizePercentage }}"

      # Growth threshold
      - alert: HighLatencyP95
        expr: |
          histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.2
        for: 10m
        annotations:
          summary: "High latency (p95 > 200ms)"

      # CPU saturation (growth stage)
      - alert: HighCPUUsage
        expr: |
          rate(process_cpu_seconds_total[1m]) > 0.7
        for: 10m
        annotations:
          summary: "CPU utilization > 70%"

      # Memory leak detection
      - alert: MemoryLeak
        expr: |
          rate(process_resident_memory_bytes[1h]) > 52428800  # 50 MiB/hour
        for: 30m
        annotations:
          summary: "Possible memory leak (memory growing > 50 MiB/hour)"
```

## SLO and SLA Definition

### SLO vs SLA

| Term | Means | Owner | Consequence |
|------|-------|-------|------------|
| **SLO** (Service Level Objective) | Internal goal (e.g., "99% uptime") | Engineering team | Guides investment + on-call |
| **SLA** (Service Level Agreement) | Promise to customers; has penalties | Product/Legal | Financial | Compensation if breached |

SLOs are typically **more aggressive** than SLAs (SLO: 99.9%, SLA: 99% — gives 0.9% buffer).

### SLO Template (per service)

```markdown
## [Service Name] SLO

### Availability
- **Target:** 99.5% uptime
- **Budget:** 21.6 minutes downtime/month
- **Measurement:** HTTP status 2xx or 3xx / total requests

### Latency
- **Target:** 95th percentile < 200ms
- **Measurement:** p95(request duration) measured over 1-minute windows

### Error Rate
- **Target:** Error rate < 0.5%
- **Measurement:** 5xx responses / total requests

### Duration & Review
- **Quarter:** Q2 2026 (Apr-Jun)
- **Review:** Monthly; escalate if budget consumed > 33%/month
```

### Error Budget Tracking

Once SLO is defined, calculate "error budget" — how much failure is acceptable:

```
Availability SLO: 99.5%
Allowed downtime per month: (1 - 0.995) × 30 days × 24 hours = ~21.6 minutes

If 5 minutes of unexpected downtime occurs on April 3:
  Remaining budget: 21.6 - 5 = 16.6 minutes for the rest of April
  % consumed: (5 / 21.6) × 100 = 23% of monthly budget
```

**Decision rule:**
- If < 33% budget consumed in first week → proceed with risky changes/deployments
- If > 66% budget consumed → freeze risky changes, focus on stability

## Dashboard Design

### Essential Dashboards (by service type)

**REST API service:**
- RED metrics (rate, errors, duration p50/p95/p99)
- Instance health (CPU, memory, disk)
- Database connection pool (active, idle, wait queue)
- Cache hit rate (if applicable)

**Background worker:**
- USE metrics (utilization, saturation, errors)
- Job queue length and processing time
- Failed job count and retry rate
- Resource trends (CPU/memory over 24h)

**Web frontend:**
- Core Web Vitals (LCP, FID, CLS)
- JavaScript errors (tracked via Sentry/Rollbar)
- User session count and session duration
- Page load performance by route

**Database:**
- Query latency (p95, p99)
- Connection pool (active, idle, max)
- Replication lag (if applicable)
- Disk usage trend
- Slow query count

### Prometheus + Grafana Setup

**Prometheus configuration** (`prometheus.yml`):

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'api-server'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'database'
    static_configs:
      - targets: ['localhost:9187']  # postgres_exporter
```

**Grafana dashboard (JSON):**

```json
{
  "dashboard": {
    "title": "API Server — RED Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [{
          "expr": "sum(rate(http_requests_total[1m]))"
        }]
      },
      {
        "title": "Error Rate",
        "targets": [{
          "expr": "sum(rate(http_requests_total{status=~\"5..\"}[1m])) / sum(rate(http_requests_total[1m]))"
        }]
      },
      {
        "title": "Latency P99",
        "targets": [{
          "expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))"
        }]
      }
    ]
  }
}
```

## Multi-Cloud Observability

### Provider-Specific SDKs

Integrate with cloud-native observability platforms for rich integrations.

**Datadog:**

```typescript
import { datadogRum } from '@datadog/browser-rum';
import tracer from 'dd-trace';

// Backend
tracer.init(); // Auto-instruments HTTP, DB, cache
tracer.trace('custom-operation', () => {
  // custom logic
});

// Frontend
datadogRum.init({
  applicationId: 'app-id',
  clientToken: 'token',
  site: 'datadoghq.com',
  service: 'web-app',
  env: 'production',
  sessionSampleRate: 100,
  sessionReplaySampleRate: 20,
  trackUserInteractions: true
});
```

**New Relic:**

```typescript
const newrelic = require('newrelic');

newrelic.instrumentLoadedModule('pg', new newrelic.API.QuerySpec({
  operation: 'query'
}));

newrelic.startSegment('custom-segment', false, () => {
  // custom logic
});
```

**AWS CloudWatch:**

```typescript
import { CloudWatchClient, PutMetricDataCommand } from "@aws-sdk/client-cloudwatch";

const client = new CloudWatchClient({ region: 'us-east-1' });
await client.send(new PutMetricDataCommand({
  Namespace: 'api-server',
  MetricData: [{
    MetricName: 'RequestCount',
    Value: 1,
    Unit: 'Count'
  }]
}));
```

## Observability Checklist

- [ ] **Metrics**: RED (rate, errors, duration) for all APIs; USE (utilization, saturation, errors) for workers
- [ ] **Tracing**: OpenTelemetry initialized; trace IDs propagated across service boundaries
- [ ] **Logging**: Structured JSON logs with trace_id, user_id, entity_id, service, environment
- [ ] **Alerting**: Alert rules defined per stage (MVP/Growth/Enterprise); on-call escalation path documented
- [ ] **SLO**: Availability, latency, and error rate targets documented; error budget calculated
- [ ] **Dashboards**: RED dashboard, resource dashboard, SLO dashboard created in Grafana/Datadog
- [ ] **Log retention**: Retention policy documented (e.g., 30 days for INFO, 90 days for ERROR)
- [ ] **Privacy**: No PII, API keys, or credentials in logs; sensitive fields masked or hashed
