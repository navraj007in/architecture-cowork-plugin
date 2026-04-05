---
name: Monitoring Setup
description: Generate observability stack config, metrics/tracing/logging code, dashboards, alerts, and SLO templates
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
model: inherit
---

# Monitoring Setup Agent

Autonomous infrastructure agent that configures complete observability pipeline: metrics instrumentation, distributed tracing, structured logging, alert rules, dashboards, SLO definitions, and runbooks.

## Input

The `/architect:setup-monitoring` command passes:

```json
{
  "components": [
    {
      "name": "api-server",
      "type": "backend",
      "language": "typescript",
      "framework": "express",
      "directory": "/path/to/project/api-server",
      "port": 3000
    }
  ],
  "monitoring_config": {
    "metrics_provider": "prometheus",
    "tracing_enabled": true,
    "tracing_provider": "opentelemetry",
    "error_tracking": "sentry",
    "log_aggregation": "loki",
    "alert_severity": "growth"
  },
  "project": {
    "name": "example-app",
    "stage": "growth"
  },
  "tech_stack": {
    "backend": ["Node.js", "Express"],
    "database": "PostgreSQL"
  }
}
```

## Process

### Step 1: Detect Existing Instrumentation

For each component, use Glob to check if monitoring code already exists:
- `src/lib/metrics.ts`, `src/lib/tracing.ts`, `src/lib/logger.ts` (Node.js)
- `src/lib/metrics.py`, `src/lib/tracing.py`, `src/lib/logger.py` (Python)
- `pkg/metrics.go`, `pkg/tracing.go`, `pkg/logger.go` (Go)

If files exist, check if they are stubs (empty or placeholder) or fully implemented:
- Stubs: append missing instrumentation
- Fully implemented: skip and report "already instrumented"

### Step 2: Generate Metrics Instrumentation

Per component and language, generate `src/lib/metrics.ts` (or equivalent) with:

**For Node.js (Express + Prometheus client):**
```typescript
// src/lib/metrics.ts
import promClient from 'prom-client';

// RED method: Rate, Errors, Duration
export const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request latency in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.001, 0.01, 0.05, 0.1, 0.5, 1, 2, 5]
});

export const httpRequestTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

export const httpRequestErrors = new promClient.Counter({
  name: 'http_request_errors_total',
  help: 'Total HTTP request errors',
  labelNames: ['method', 'route', 'error_code']
});

// USE method: Utilization, Saturation, Errors (for background workers)
export const dbConnectionPoolActive = new promClient.Gauge({
  name: 'db_connection_pool_active',
  help: 'Active database connections'
});

export const jobQueueLength = new promClient.Gauge({
  name: 'job_queue_length',
  help: 'Number of jobs in queue'
});

// Middleware for auto-instrumentation
export function metricsMiddleware(req, res, next) {
  const startTime = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - startTime) / 1000;
    const route = req.route?.path || req.url;
    
    httpRequestDuration.labels(req.method, route, res.statusCode).observe(duration);
    httpRequestTotal.labels(req.method, route, res.statusCode).inc();
    
    if (res.statusCode >= 400) {
      httpRequestErrors.labels(req.method, route, res.statusCode).inc();
    }
  });
  next();
}

// Export metrics endpoint
export function registerMetricsEndpoint(app) {
  app.get('/metrics', async (req, res) => {
    res.set('Content-Type', promClient.register.contentType);
    res.end(await promClient.register.metrics());
  });
}
```

**For Python (prometheus_client):**
```python
# src/lib/metrics.py
from prometheus_client import Counter, Histogram, Gauge
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

# RED metrics
REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'route', 'status_code'],
    buckets=[0.001, 0.01, 0.05, 0.1, 0.5, 1, 2, 5]
)

REQUEST_TOTAL = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'route', 'status_code']
)

REQUEST_ERRORS = Counter(
    'http_request_errors_total',
    'Total HTTP errors',
    ['method', 'route', 'error_code']
)

# USE metrics
DB_CONNECTIONS_ACTIVE = Gauge(
    'db_connection_pool_active',
    'Active database connections'
)

JOB_QUEUE_LENGTH = Gauge(
    'job_queue_length',
    'Number of jobs queued'
)

# Flask middleware
def metrics_middleware(f):
    import functools
    import time
    
    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            response = f(*args, **kwargs)
            return response
        finally:
            duration = time.time() - start_time
            # Record metrics
    return wrapper
```

### Step 3: Generate Tracing Instrumentation

Per component, generate `src/lib/tracing.ts` (or equivalent) with OpenTelemetry initialization:

**For Node.js (OpenTelemetry):**
```typescript
// src/lib/tracing.ts
import { NodeTracerProvider } from '@opentelemetry/node';
import { JaegerExporter } from '@opentelemetry/exporter-jaeger';
import { BatchSpanProcessor, ProbabilitySampler } from '@opentelemetry/core';
import { registerInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const provider = new NodeTracerProvider({
  sampler: new ProbabilitySampler(
    process.env.OTEL_TRACES_SAMPLER_ARG
      ? parseFloat(process.env.OTEL_TRACES_SAMPLER_ARG)
      : 0.1 // 10% sampling for growth stage
  )
});

// Jaeger exporter (can swap for Datadog, New Relic, etc.)
const jaegerExporter = new JaegerExporter({
  serviceName: process.env.SERVICE_NAME || 'api-server',
  maxPacketSize: 65000
});

provider.addSpanProcessor(new BatchSpanProcessor(jaegerExporter));

// Auto-instrument common libraries (HTTP, DB, cache)
registerInstrumentations({
  instrumenters: ['@opentelemetry/instrumentation-http']
});

provider.register();

export const tracer = require('@opentelemetry/api').trace.getTracer('api-server');

export function recordCustomSpan(name: string, attributes: Record<string, any>, fn: () => void) {
  const span = tracer.startSpan(name, { attributes });
  try {
    fn();
  } finally {
    span.end();
  }
}
```

**Semantic conventions (attributes) to include in traces:**

```
service.name: "api-server"
service.version: "0.1.0"
http.method: "GET" | "POST" | ...
http.url: "https://example.com/users?id=123"
http.target: "/users?id=123"
http.status_code: 200
http.request.body.size: bytes
http.response.body.size: bytes
db.system: "postgresql"
db.statement: "SELECT * FROM users WHERE id = ?"
span.kind: "SERVER" | "CLIENT" | "INTERNAL"
span.status: "OK" | "ERROR"
trace.id: (auto-generated by OpenTelemetry)
```

### Step 4: Generate Structured Logging

Per component, generate `src/lib/logger.ts` (or equivalent):

**For Node.js (Winston):**
```typescript
// src/lib/logger.ts
import winston from 'winston';
import { v4 as uuidv4 } from 'uuid';

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  defaultMeta: {
    service: process.env.SERVICE_NAME || 'api-server',
    version: process.env.APP_VERSION || '0.1.0',
    environment: process.env.NODE_ENV || 'development'
  },
  transports: [
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error'
    }),
    new winston.transports.File({
      filename: 'logs/combined.log'
    })
  ]
});

// Request context middleware
export function contextMiddleware(req, res, next) {
  const trace_id = req.headers['traceparent']?.split('-')[1] || uuidv4();
  const span_id = req.headers['traceparent']?.split('-')[2] || uuidv4();
  
  req.context = {
    trace_id,
    span_id,
    request_id: uuidv4(),
    user_id: req.user?.id,
    tenant_id: req.user?.tenant_id
  };
  
  res.locals.context = req.context;
  next();
}

// Helper to log with context
export function logInfo(message: string, meta: Record<string, any>) {
  logger.info(message, {
    ...meta,
    // Context fields from request automatically injected by middleware
  });
}

export function logError(message: string, error: Error, meta: Record<string, any>) {
  logger.error(message, {
    error_code: error.code,
    error_message: error.message,
    error_stack: error.stack,
    ...meta
  });
}
```

### Step 5: Create Prometheus Configuration

Generate `monitoring/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'prod'

# Alert rules
rule_files:
  - 'alerts/rules.yaml'

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

scrape_configs:
  - job_name: 'api-server'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

### Step 6: Generate Alert Rules

Generate `monitoring/alerts/rules.yaml` per stage (MVP/Growth/Enterprise):

**MVP stage (minimal alerts):**
```yaml
groups:
  - name: api-server-mvp
    interval: 30s
    rules:
      - alert: ServiceDown
        expr: up{job="api-server"} == 0
        for: 1m
        annotations:
          summary: "api-server is down"
          severity: "critical"
```

**Growth stage (moderate alerts):**
```yaml
groups:
  - name: api-server-growth
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: |
          (sum(rate(http_requests_total{status=~"5.."}[1m])) 
           / sum(rate(http_requests_total[1m]))) > 0.01
        for: 5m
        annotations:
          summary: "Error rate > 1%"
          severity: "warning"
      
      - alert: HighLatencyP99
        expr: |
          histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 0.2
        for: 10m
        annotations:
          summary: "p99 latency > 200ms"
          severity: "warning"
      
      - alert: HighCPUUsage
        expr: rate(process_cpu_seconds_total[1m]) > 0.7
        for: 10m
        annotations:
          summary: "CPU > 70%"
          severity: "warning"
```

**Enterprise stage (strict SLO-based alerts):**
```yaml
groups:
  - name: api-server-enterprise
    interval: 30s
    rules:
      - alert: SLOLatencyMiss
        expr: |
          histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 0.1
        for: 5m
        annotations:
          summary: "p99 latency SLO miss (> 100ms)"
          severity: "critical"
      
      - alert: ErrorBudgetBurnHigh
        expr: |
          (rate(http_requests_total{status=~"5.."}[5m]) / 
           (sum(rate(http_requests_total[5m])) * 0.001)) > 2.5
        annotations:
          summary: "Error budget burn rate > 2.5x (consuming monthly budget in days)"
          severity: "critical"
```

### Step 7: Generate Grafana Dashboards

Create `monitoring/grafana/dashboards/` with JSON dashboard definitions:

**RED metrics dashboard** (`red-metrics.json`):
```json
{
  "dashboard": {
    "title": "API Server — RED Metrics",
    "tags": ["api-server", "red"],
    "panels": [
      {
        "title": "Request Rate (RPS)",
        "targets": [{"expr": "sum(rate(http_requests_total[1m]))"}],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [{"expr": "sum(rate(http_requests_total{status=~\"5..\"}[1m])) / sum(rate(http_requests_total[1m]))"}],
        "type": "graph"
      },
      {
        "title": "Latency p99",
        "targets": [{"expr": "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))"}],
        "type": "graph"
      }
    ]
  }
}
```

**SLO status dashboard** (`slo-status.json`):
```json
{
  "dashboard": {
    "title": "SLO Status",
    "tags": ["slo"],
    "panels": [
      {
        "title": "Availability SLO (99.5%)",
        "targets": [{"expr": "1 - (sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])))"}],
        "type": "stat"
      },
      {
        "title": "Monthly Error Budget Remaining",
        "targets": [{"expr": "..."}],
        "type": "gauge"
      }
    ]
  }
}
```

### Step 8: Generate SLO Templates

Create `monitoring/slo/<component>.md` for each component:

```markdown
## [Component] SLO

### Availability
- **Target:** 99.5% uptime (MVP: 99%, Growth: 99.5%, Enterprise: 99.9%)
- **Budget:** 21.6 minutes downtime/month
- **Measurement:** (sum(http_requests_total{status!~"5.."}) / sum(http_requests_total)) over 30-day window
- **Calculation:** 1 - (5xx_requests / total_requests)

### Latency
- **Target (p95):** 200ms (MVP: 500ms, Growth: 200ms, Enterprise: 100ms)
- **Target (p99):** 500ms (MVP: 1000ms, Growth: 500ms, Enterprise: 200ms)
- **Measurement:** p95(request_duration), p99(request_duration)

### Error Rate
- **Target:** < 0.5% (MVP: < 1%, Growth: < 0.5%, Enterprise: < 0.1%)
- **Measurement:** 5xx_requests / total_requests

### Review Cadence
- **Quarterly:** Review SLO targets and alert thresholds
- **Monthly:** Calculate error budget consumption
- **Weekly:** Review incidents that caused SLO breaches
- **Daily:** Monitor dashboard for trends

### Error Budget Allocation
- **Monthly budget:** (1 - 0.995) × 30 days × 24 hours × 60 min = 21.6 minutes
- **Alert if consumed:** > 33% in first week → review deployments
- **Freeze changes if consumed:** > 66% in month → focus on stability only
```

### Step 9: Generate Runbooks

Create `monitoring/runbooks/` with playbooks for each alert:

**Example: `HIGH_ERROR_RATE.md`**

```markdown
# Alert: High Error Rate

**Threshold:** Error rate > 1% for 5 minutes
**Severity:** Warning (Growth), Critical (Enterprise)
**SLA Response:** < 5 minutes (Growth), < 2 minutes (Enterprise)

## Debugging Steps

1. **Check recent deployments**
   ```
   kubectl rollout history deployment/api-server
   kubectl get events -n production --sort-by='.lastTimestamp' | grep -E 'api-server|error'
   ```

2. **Check error logs** (via Loki or aggregation tool)
   ```
   {service="api-server", level="error"}
   ```

3. **Identify error pattern**
   - Same error code? → Application bug
   - Random errors? → Infrastructure issue (DB, cache, network)
   - Specific endpoint? → Endpoint-specific bug
   - All endpoints? → Global issue (auth, middleware, database)

4. **If recent deployment** → Rollback:
   ```
   kubectl rollout undo deployment/api-server -n production
   kubectl rollout status deployment/api-server -n production
   ```

5. **If infrastructure issue** → Check dependent services:
   ```
   # Check database
   psql $DATABASE_URL -c "SELECT 1;"
   
   # Check cache (Redis)
   redis-cli ping
   
   # Check external services
   curl https://dependency-api.example.com/health
   ```

6. **If code issue** → Follow incident response process (see docs/incident-response.md)

## Escalation

- < 5% error rate: Monitor, no action
- 5–10% error rate: Page on-call engineer
- > 10% error rate: Page on-call manager + engineering lead
```

### Step 10: Create Docker Compose Monitoring Stack

Generate `docker-compose.monitoring.yml`:

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./monitoring/alerts:/etc/prometheus/alerts
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
    depends_on:
      - prometheus

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "6831:6831/udp"
      - "16686:16686"
    environment:
      - COLLECTOR_ZIPKIN_HTTP_PORT=9411

volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

### Step 11: Update Dependencies

Update `package.json` (Node.js) or `requirements.txt` (Python) or equivalent:

**Node.js additions:**
```json
{
  "dependencies": {
    "prom-client": "^14.0.0",
    "@opentelemetry/api": "^1.4.0",
    "@opentelemetry/sdk-node": "^0.35.0",
    "@opentelemetry/instrumentation-http": "^0.35.0",
    "@opentelemetry/exporter-trace-jaeger": "^1.8.0",
    "winston": "^3.8.0"
  }
}
```

**Python additions:**
```
prometheus-client>=0.16.0
opentelemetry-api>=1.15.0
opentelemetry-sdk>=1.15.0
opentelemetry-exporter-jaeger>=1.15.0
structlog>=22.1.0
```

### Step 12: Generate Setup Instructions

Create `monitoring/README.md`:

```markdown
# Monitoring Setup

## Quick Start

```bash
# Start the monitoring stack
docker-compose -f docker-compose.monitoring.yml up -d

# Access dashboards
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin)
# Jaeger: http://localhost:16686
```

## Integrate with Your Services

1. Import dashboards in Grafana (Settings → Data Sources → Add Prometheus)
2. Update service `.env`:
   ```
   OTEL_EXPORTER_JAEGER_AGENT_HOST=localhost
   OTEL_EXPORTER_JAEGER_AGENT_PORT=6831
   OTEL_TRACES_SAMPLER=parentbased_always_on
   LOG_LEVEL=info
   ```
3. Restart services
4. Send a test request and verify traces appear in Jaeger
```

## Error Handling

### Missing Observability Packages
If a required package is not installed:
- Report to user: "Package X not installed. Run `npm install --save-dev X` first."
- Do NOT proceed — let user install and re-run

### Existing Monitoring Code
If monitoring code already exists for a module:
- Detect by glob: if `src/lib/metrics.ts` exists, check if it has RED metrics
- If implemented: skip generation, report "metrics already instrumented"
- If stub: enhance with missing metrics

### Provider Unavailability
If optional MCP server is unavailable (Datadog, New Relic):
- Skip that provider integration, continue
- Report: "Provider X unavailable; using Prometheus instead"

### File Write Failures
If a required write fails (e.g., `monitoring/` directory creation):
- Stop, report error, do not emit completion marker
- User must fix and re-run

## Rules

- **Never modify existing source code** — only add to `src/lib/` and `monitoring/`
- **Follow observability skill exactly** — RED/USE methods, semantic conventions, alert thresholds, SLO templates
- **Stage-aware thresholds** — MVP alerts minimal; Growth balanced; Enterprise strict
- **Trace propagation** — Always include W3C Trace Context headers (traceparent)
- **Log structure** — JSON format with trace_id, user_id, entity_id, service, environment
- **Dashboard ready** — Generated Grafana dashboards must be immediately importable
- **SLO calculation** — Include monthly error budget calculation (30-day window)
- **Privacy first** — Never log PII, credentials, or sensitive API keys
- **Generated configs must be immediately runnable** — `docker-compose monitoring.yml up` should work without setup
