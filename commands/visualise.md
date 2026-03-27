---
description: Generate an interactive architecture visualisation with component topology and data flow
---

# /architect:visualise

## Trigger

`/architect:visualise` — run after blueprint to generate visual architecture assets.

## Purpose

Generate rich visual representations of the architecture that go beyond static diagrams. Creates interactive-ready data files, annotated topology diagrams, and data flow visualisations that can be explored in the Archon desktop app's Architecture Map view or exported for presentations.

## Workflow

### Step 1: Read Architecture

Read the SDL file and extract:
- All components with their type, runtime, framework, port, dependencies
- Data section (databases, cache, queues)
- Auth strategy
- Deployment targets
- Core flows from `product.coreFlows`

### Step 2: Load Skills

Load:
- **diagram-patterns** skill — for Mermaid templates
- **founder-communication** skill — for clear labels and descriptions

### Step 3: Generate Visualisation Assets

#### 3.1 — Solution Topology (Mermaid C4 Container)
Enhanced C4 Container diagram with:
- Colour-coded nodes by category (frontend=green, backend=blue, mobile=purple, AI=orange, infra=amber)
- Edge labels showing protocols (REST, WebSocket, gRPC, async/queue)
- External system boundaries
- Cloud provider grouping

#### 3.2 — Data Flow Diagrams (per core flow)
For each `product.coreFlow`:
- Sequence diagram showing the request path through components
- Data transformations at each step
- Latency-critical paths marked

#### 3.3 — Deployment Topology
- Where each component runs (cloud provider, service, region)
- Network boundaries (VPC, subnets if applicable)
- CDN and edge locations

#### 3.4 — Component Relationship Matrix
Markdown table showing which components depend on which:

| Component | Depends On | Protocol | Direction |
|-----------|-----------|----------|-----------|
| web-app | api-server | REST | → |
| api-server | primary-db | TCP | → |

### Step 4: Output

Write all visualisations to `architecture-output/`:
- `architecture-output/topology.mmd` — C4 Container diagram
- `architecture-output/data-flows/` — one `.mmd` per core flow
- `architecture-output/deployment-topology.mmd` — deployment diagram
- `architecture-output/component-matrix.md` — relationship table

Also render diagrams to PNG/SVG if Mermaid CLI is available.

## Output Rules

- Use **diagram-patterns** skill for consistent Mermaid syntax
- Use **founder-communication** skill — labels should be understandable by non-engineers
- Colour-code consistently: frontend=green, backend=blue, database=amber, cache=cyan
- Do NOT ask questions — infer relationships from SDL dependencies
