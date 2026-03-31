---
name: infrastructure-generators
description: SDL generators for Docker Compose, Kubernetes, Monitoring, Nginx, and Deploy Diagram
---

# Infrastructure Generators

SDL-driven, deterministic generators that produce production-ready infrastructure configs. Same input always produces identical output.

**Input**: Compiled SDL document
**Output**: YAML/JSON config files in `artifacts/` directory

---

## Docker Compose Generator

Generates a `docker-compose.yml` for local development with all services, databases, caches, queues, and search.

**API**: `POST /api/sdl/docker-compose` — `{ yaml: string }`

**Output files**:
- `artifacts/docker/docker-compose.yml` — complete service orchestration
- `artifacts/docker/.env` — environment variable template

**SDL sections used**:
- `architecture.projects.frontend[]` / `backend[]` — service definitions
- `data.primaryDatabase.type` — database container (postgres, mysql, mongodb, sqlserver)
- `data.secondaryDatabases[]` — additional database containers
- `data.cache.type` — Redis container
- `data.queues.provider` — queue container (rabbitmq, kafka, redis)
- `data.search.provider` — search container (elasticsearch, meilisearch, typesense)
- `auth.identityProvider` — auth env vars (Auth0, Clerk, Cognito, Firebase)
- `solution.name` — container naming

**What it includes per service**:
- Multi-stage Dockerfile build context
- Framework-aware port assignment (Node=3000, FastAPI=8000, Go=8080, .NET=5000, Spring=8080, Rails=3000, Laravel=9000)
- Database URLs injected as env vars
- Redis URL if cache enabled
- Inter-service URLs using Docker service names
- Health checks with `service_healthy` depends_on
- Volume mounts for live reload
- Named volumes for data persistence
- Custom network

---

## Kubernetes Generator

Generates production-ready K8s manifests with Deployments, Services, HPA, Ingress, ConfigMap, and Namespace.

**API**: `POST /api/sdl/kubernetes` — `{ yaml: string }`

**Output files** (in `artifacts/k8s/`):
- `namespace.yaml` — namespace scoped to solution name
- `configmap.yaml` — shared config (NODE_ENV, DB_TYPE, AUTH_PROVIDER, REDIS_ENABLED)
- Per backend: `backend-{name}-deployment.yaml`, `-service.yaml`, `-hpa.yaml`
- Per frontend: `frontend-{name}-deployment.yaml`, `-service.yaml`
- `ingress.yaml` — HTTPS routing with cert-manager

**SDL sections used**:
- `architecture.projects.backend[]` / `frontend[]` — deployments and services
- `nonFunctional.scaling.expectedUsersYear1` — replica count (>50k=5, >10k=3, else=2)
- `solution.domain` — ingress hostname (defaults to `{slug}.example.com`)
- `nonFunctional.security.encryptionInTransit` — TLS/cert-manager annotations
- `data.primaryDatabase.type` — ConfigMap DB_TYPE
- `data.cache.type` — ConfigMap REDIS_ENABLED
- `auth.identityProvider` — ConfigMap AUTH_PROVIDER

**Resource limits**:

| Tier | CPU Request | CPU Limit | Memory Request | Memory Limit |
|------|------------|-----------|----------------|--------------|
| Backend | 100m | 500m | 128Mi | 512Mi |
| Frontend | 50m | 200m | 64Mi | 256Mi |

**HPA**: Scales on 70% CPU / 80% memory utilization, max replicas = min × 3

**Probes**: HTTP GET `/health` — readiness (5s initial, 10s period), liveness (15s initial, 20s period)

---

## Monitoring Generator

Generates Prometheus scrape config, alert rules, and a Grafana dashboard JSON.

**API**: `POST /api/sdl/monitoring` — `{ yaml: string }`

**Output files** (in `artifacts/monitoring/`):
- `prometheus.yml` — scrape config with per-service job definitions + node-exporter
- `alert-rules.yml` — alerting rules derived from NFRs
- `grafana-dashboard.json` — complete dashboard with per-service panels

**SDL sections used**:
- `architecture.projects.backend[]` / `frontend[]` — per-service scrape targets and panels
- `nonFunctional.availability.target` — error budget calculation for HighErrorRate threshold
- `nonFunctional.performance.apiResponseTime` — P95 latency alert threshold
- `data.primaryDatabase.type` — database connection pool alert (postgres/mysql/sqlserver only)
- `integrations.monitoring.provider` — metadata only

**Alert rules generated**:

| Alert | Trigger | Severity |
|-------|---------|----------|
| HighErrorRate | 5xx rate exceeds error budget | critical |
| HighLatency | P95 > apiResponseTime target | warning |
| ServiceDown_{name} | `up{job}` == 0 for 1m | critical |
| HighCpuUsage | CPU > 85% for 10m | warning |
| HighMemoryUsage | Memory > 90% for 5m | warning |
| DatabaseConnectionPoolHigh | Pool > 80% for 5m | warning |

**Grafana panels**: Request rate, error rate, P95 latency, service uptime, per-service CPU/memory, per-service request duration percentiles (P50/P95/P99), database connections.

---

## Nginx Generator

Generates a reverse proxy config with SSL, gzip, rate limiting, and security headers.

**API**: `POST /api/sdl/nginx` — `{ yaml: string }`

**Output files** (in `artifacts/nginx/`):
- `nginx.conf` — complete reverse proxy configuration
- `mime.types.conf` — MIME type mappings
- `docker-compose.nginx.yml` — Docker Compose snippet to add nginx service

**SDL sections used**:
- `architecture.projects.backend[]` / `frontend[]` — upstream definitions
- `solution.domain` — server_name for HTTPS block
- Backend framework → port mapping (same as Docker Compose)

**Features**:
- HTTP → HTTPS redirect
- SSL/TLS config (TLSv1.2/1.3, session cache)
- Gzip compression (6 content types)
- Rate limiting: 30 req/s per IP, burst 50
- Security headers: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy
- WebSocket support (Upgrade/Connection headers)
- Per-backend API locations (single backend → `/api`, multiple → `/api/{name}`)
- Frontend fallback at `/`
- Health check endpoint at `/health`

---

## Deploy Diagram Generator

Generates a Mermaid deployment topology diagram from a deployment plan.

**Not exposed via dedicated API route** — used programmatically by the deploy-planner module.

**Input**: `DeployDiagramInput` (not an SDL document directly):
- `strategy` — deployment strategy name
- `services[]` — array of `{ name, platform, tier?, estimatedCost, config? }`
- `monthlyCost?` — `{ min, max, typical }`

**Output**: `diagrams/deployment-topology.mmd` — Mermaid flowchart

**Features**:
- Services grouped into subgraphs by platform (AWS, Azure, GCP, etc.)
- Categorized by role: frontend (cyan), backend (purple), data (amber)
- User → Frontend → Backend → Data flow edges
- Cost labels per service (`$X/mo`)
- Tier labels when specified

---

## When to Use

- **Docker Compose**: After scaffolding — gives developers a one-command local dev setup
- **Kubernetes**: When deploying to K8s clusters — production-ready manifests
- **Monitoring**: When setting up observability — alerts tuned to SDL availability/performance targets
- **Nginx**: When adding a reverse proxy — SSL, routing, rate limiting preconfigured
- **Deploy Diagram**: When visualizing deployment topology — auto-generated from deploy planner output
