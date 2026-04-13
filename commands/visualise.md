---
description: Generate an interactive architecture visualisation with component topology and data flow
---

# /architect:visualise

## Trigger

`/architect:visualise` — generate the full canonical diagram set.

`/architect:visualise [diagram:name]` — regenerate one specific diagram only.

`/architect:visualise [diagrams:name1,name2,...]` — regenerate a specific subset.

### Diagram names (for targeted generation)

| Name | File generated |
|------|---------------|
| `solution-architecture` | `solution-architecture.mmd` |
| `deployment` | `deployment.mmd` |
| `sequence-auth` | `sequence-auth.mmd` |
| `er-diagram` | `er-diagram.mmd` |
| `service-communication` | `service-communication.mmd` |
| `agent-flow` | `agent-flow.mmd` |
| `sequence-payment` | `sequence-payment.mmd` |

**Examples:**
```
/architect:visualise [diagram:er-diagram]
/architect:visualise [diagrams:deployment,sequence-auth]
```

When a `[diagram:...]` or `[diagrams:...]` tag is present, generate **only** the named diagrams and skip all others. Still follow all the same rules (max 12 nodes, short labels, diagram-patterns templates). Still log activity and write only the generated files to `architecture-output/diagrams/`.

## Purpose

Generate rich visual representations of the architecture. Creates annotated topology diagrams, ER diagrams, sequence flows, and deployment maps that can be explored in the Archon desktop app's Diagrams tab or exported for presentations.

## Workflow

### Step 1: Read Architecture

**First**, check `architecture-output/_state.json`. If it exists, read it in full — it provides instant access to `project`, `tech_stack`, `components`, `design`, `entities`, and `personas` without reading larger files. Use its values directly where available; fall back to SDL (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files) only for detail not in `_state.json`.

Read the SDL and extract (check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module files):
- All components with their type, runtime, framework, port, dependencies
- Data section (databases, cache, queues)
- Auth strategy
- Deployment targets
- Core flows from `product.coreFlows`

### Step 2: Load Skills

Load:
- **diagram-patterns** skill — for Mermaid templates
- **founder-communication** skill — for clear labels and descriptions

### Step 3: Generate the Canonical Diagram Set

**Output folder: `architecture-output/diagrams/`** — write every diagram as an individual `.mmd` file using the exact canonical filenames below. Follow the **diagram-patterns** skill for all templates, color conventions, and rules (max 12 nodes, short labels, no C4 Mermaid types, flat node declarations).

Generate diagrams in this order:

#### 3.1 — `solution-architecture.mmd` (always)

Full system topology using `graph TB` with subgraphs following the Solution Architecture template in diagram-patterns:
- Colour-coded nodes: frontend=blue (`#4a90d9`), backend=green (`#5cb85c`), database=orange (`#f0ad4e`), external=purple (`#9b59b6`), queue=teal (`#1abc9c`), AI=red (`#e74c3c`), gateway=light-blue (`#d4e6f1`)
- Edge labels showing protocols (REST, WebSocket, gRPC, async/queue)
- External systems in their own subgraph
- Cloud provider or hosting tier as subgraph labels
- If the system has >12 components: produce `solution-architecture.mmd` for the core layer (frontend + backend + primary data) and `solution-architecture-infra.mmd` for the infra/external layer

#### 3.2 — `deployment.mmd` (always)

Where each component runs using `graph TB` following the Deployment Diagram template:
- Cloud provider subgraphs (e.g. "Vercel", "Railway", "AWS us-east-1") as the top-level groupings
- Each component inside its hosting subgraph
- Managed services (RDS, ElastiCache, S3) as nodes within their provider
- External third-party services in a separate subgraph
- Max 12 nodes — group minor infra together if needed

#### 3.3 — `sequence-auth.mmd` (always)

Authentication flow using `sequenceDiagram` following the Authentication Sequence template in diagram-patterns:
- Shows login → token issuance → API call → refresh flow
- If using OAuth/SSO: show the redirect + callback steps
- Max 6 participants — collapse internal services where possible

#### 3.4 — `er-diagram.mmd` (when system has a relational database)

Entity relationship diagram using `erDiagram` following the ER Diagram template in diagram-patterns:
- Core domain entities only (max 8) — omit audit logs, config tables, join tables without meaningful fields
- Key fields per entity: PK, FKs, status/type enums, 1–2 key data fields — not every column
- Relationship cardinality and foreign key name on each line

#### 3.5 — `service-communication.mmd` (when 2+ backend services or modular-monolith with 3+ modules)

Inter-service communication using `graph LR` following the Service Communication Diagram template:
- Every service-to-service connection labelled with protocol + endpoint/event name
- Sync vs async calls in separate subgraphs
- Databases shown per service to indicate ownership boundaries

#### 3.6 — `agent-flow.mmd` (when system has AI agents or LLM orchestration)

Agent flow using `graph TD` following the Agent Flow Diagram template:
- Input → router → agents → tools → guardrails → output
- Label every tool call and decision path

#### 3.7 — `sequence-payment.mmd` (when system has payment processing)

Payment flow using `sequenceDiagram`:
- User → frontend → API → payment provider → webhook → order fulfillment
- Show both success and failure paths
- Max 6 participants

#### 3.8 — Component Relationship Matrix

Write `architecture-output/component-matrix.md` — a markdown table showing which components depend on which:

| Component | Depends On | Protocol | Direction |
|-----------|-----------|----------|-----------|
| web-app | api-server | REST | → |
| api-server | primary-db | TCP | → |

### Step 4: Output

Write all diagram files to `architecture-output/diagrams/` using the canonical filenames defined in Step 3. Write the component matrix to `architecture-output/component-matrix.md`.

Summary of files written:
```
architecture-output/diagrams/
├── solution-architecture.mmd         (always)
├── deployment.mmd                    (always)
├── sequence-auth.mmd                 (always)
├── er-diagram.mmd                    (when relational DB exists)
├── service-communication.mmd         (when 2+ backend services)
├── agent-flow.mmd                    (when AI agents exist)
├── sequence-payment.mmd              (when payments exist)
└── solution-architecture-infra.mmd   (when >12 nodes in core diagram)
architecture-output/component-matrix.md
```

### Final Step: Log Activity

After writing all output files, append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"visualise","outcome":"completed","files":["architecture-output/diagrams/solution-architecture.mmd","architecture-output/diagrams/deployment.mmd","architecture-output/diagrams/sequence-auth.mmd","architecture-output/component-matrix.md"],"summary":"Visualisation generated: <N> diagrams in architecture-output/diagrams/ — solution architecture, deployment, auth sequence, <and others as applicable>."}
```

List all generated files in the `files` array.

## Error Handling

### Missing SDL or Blueprint

If SDL is missing or incomplete:
> "I need an SDL with architecture and dependencies to visualize. Run `/architect:blueprint` or `/architect:sdl` first, then come back here."

### Mermaid Syntax Error

If a Mermaid diagram has syntax errors and fails to render:
- Log warning: `"mermaid_render_failed"` 
- Write the `.mmd` file anyway (text is valid)
- Report: "Diagram [X] has rendering issues. You can edit the `.mmd` file or check Mermaid syntax."
- Continue with other diagrams

### Unable to Write Visualization Files

If `architecture-output/` directory cannot be written due to permissions:
- Stop execution
- Report: "Cannot write visualization files: [error]. Check file permissions."
- Do NOT emit completion marker

### Circular Dependencies Detected

If architecture has circular dependencies between services:
- Report: "Circular dependency detected: [A] → [B] → [A]. Consider architectural refactoring."
- Still generate diagram (highlight the cycle)
- Continue normally

## Output Rules

- All `.mmd` files go to `architecture-output/diagrams/<canonical-filename>.mmd` — never embed diagrams inside markdown
- Use **diagram-patterns** skill for all templates, color conventions, and rules
- **NEVER use C4 Mermaid types** — use `graph TB/LR/TD`, `sequenceDiagram`, `erDiagram` only
- **Max 12 nodes per diagram** — split into additional files rather than cramming more in
- **Short labels**: ≤ 5 words per node, technology on a second line with `<br/><i>Tech</i>`
- Use **founder-communication** skill — labels understandable by non-engineers
- Do NOT ask questions — infer all relationships from SDL dependencies
