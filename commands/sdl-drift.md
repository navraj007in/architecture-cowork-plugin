---
description: Detect architecture drift — compare current codebase against committed SDL and surface topology changes
---

# /architect:sdl:drift

## Trigger

`/architect:sdl:drift [--repos <path,...>] [--sdl <path>]`

Optional flags:
- `--repos` — Comma-separated repo paths to scan (default: current working directory)
- `--sdl` — Path to the reference SDL (default: auto-detect `solution.sdl.yaml` or `sdl/`)

## Purpose

Compare the current state of the codebase against a committed SDL specification to surface architecture drift — topology changes that have happened in code but haven't been reflected in the SDL yet.

Use this command:
- After a sprint or major feature delivery to keep SDL in sync
- Before a quarterly architecture review
- As part of CI/CD to detect unreviewed topology changes
- After an `/architect:import` to validate what drifted since last import

## Workflow

### Step 1: Load Reference SDL

Locate and load the reference SDL:

1. If `--sdl` was provided, read from that path.
2. Otherwise, look for `solution.sdl.yaml` in the current directory.
3. If not found, look for `sdl/README.md` and load the modular SDL directory.
4. If still not found, abort with:
   > "No committed SDL found. Run `/architect:import` first to generate a baseline SDL."

Parse the SDL to extract the reference topology:
- All components in `architecture.projects.*[]` (names, types, frameworks)
- All dependencies in `architecture.projects.*[].dependsOn[]`
- All services in `architecture.services[]` (if present)
- All datastores: `data.primaryDatabase`, `data.secondaryDatabases[]`, `data.cache`, `data.queues`
- All integrations in `integrations.*`
- Deployment targets in `deployment.*` and `environments[]`

### Step 2: Scan Current Codebase

Perform a targeted scan of the repos (same evidence sources as `/architect:import` Step 2, but read only architecturally significant files — not a full deep analysis):

**Manifest scan (HIGH confidence evidence):**
- `package.json`, `go.mod`, `pom.xml`, `Cargo.toml`, `*.csproj`, `requirements.txt` — detect components and tech stack
- `docker-compose.yml`, `docker-compose.*.yml` — detect services, dependencies, exposed ports
- Kubernetes manifests (`*.yaml` in `k8s/`, `deploy/`, `infra/`) — detect services, ingress, config
- Terraform/Bicep/Pulumi files — detect cloud resources
- `.github/workflows/*.yml`, `.gitlab-ci.yml`, `azure-pipelines.yml` — detect CI/CD targets and environments

**Code scan (HIGH/MEDIUM confidence evidence):**
- Entry points and route registrations — detect API surface changes
- `dependsOn` signals: cross-service HTTP calls, SDK imports, queue producers/consumers
- Database ORM schemas and migration files — detect new/removed entities
- Environment variable files (`.env.example`) — detect new integrations

**Monorepo detection:** If `pnpm-workspace.yaml`, `package.json workspaces`, or `nx.json` detected, enumerate workspace packages and treat each as a potential component.

### Step 3: Classify Changes

Compare the scanned topology against the reference SDL. Classify every entity:

| Classification | Meaning |
|---------------|---------|
| `added` | Present in codebase, absent from SDL |
| `removed` | Present in SDL, no longer evidenced in codebase |
| `modified` | Present in both, but key attributes differ (e.g. framework changed, dependency added/removed, port changed) |
| `unchanged` | Present in both with matching attributes |

**Detect breaking changes** — flag as `breaking: true` when:
- A component is `removed` and other components `dependsOn` it
- A dependency edge is `removed` but the dependent service still references it
- A datastore is `removed` that multiple components depend on
- An environment URL has changed (may break CI/CD or consumers)

**Detect renames** — if a component appears removed AND a new component with similar stack/port/routes is added, flag as a probable rename with `probable_rename: true` for human confirmation.

### Step 4: Calculate Drift Score

```
drift_score = (added + removed + modified) / total_reference_entities * 10
```

Thresholds:
- `0.0 – 1.9` — Minimal drift (cosmetic or additive changes)
- `2.0 – 4.9` — Moderate drift (SDL update recommended)
- `5.0 – 7.9` — Significant drift (SDL is noticeably stale)
- `8.0 – 10.0` — Critical drift (SDL no longer reflects the system)

### Step 5: Generate Outputs

#### 5.1 — Write `architecture-output/drift-report.md`

```markdown
# Architecture Drift Report: {Project Name}
Generated: {ISO-8601}
Reference SDL: {path} (last modified: {date if available})
Drift Score: {X.X}/10 — {Minimal | Moderate | Significant | Critical}

## Summary

| Category | Count |
|----------|-------|
| Added (in code, not in SDL) | N |
| Removed (in SDL, not in code) | N |
| Modified (changed attributes) | N |
| Unchanged | N |
| **Total reference entities** | **N** |
| **Breaking changes** | **N** |

{IF drift_score >= 5.0:}
> ⚠ SDL is significantly stale. Run `/architect:import` to regenerate, or manually
> update the affected SDL modules listed below.

## Added Components (not in SDL)

{For each added component:}
- **{name}** ({type}, {framework}) — {evidence file}
  - Suggested SDL location: `architecture.projects.{category}[]`
  - Confidence: HIGH | MEDIUM

## Removed Components (in SDL, not in code)

{For each removed component:}
- **{name}** — last seen in SDL as `{sdl_path}`
  - Breaking: YES | NO
  {IF breaking:} ⚠ {N} other components depend on this: {list}
  {IF probable_rename:} ↔ Probable rename → **{candidate name}** (confirm manually)

## Modified Components

{For each modified component:}
- **{name}**
  | Attribute | SDL (reference) | Current (code) |
  |-----------|----------------|---------------|
  | {field} | {old value} | {new value} |
  {IF breaking:} ⚠ Breaking change: {reason}

## Added Dependencies

{New dependsOn[] edges not in SDL:}
- `{source}` → `{target}` ({type}: http | event | import | queue) — confidence: HIGH | MEDIUM

## Removed Dependencies

{dependsOn[] edges in SDL but no longer evidenced:}
- `{source}` ↛ `{target}` — {confidence of absence}
  {IF breaking:} ⚠ May be breaking: {source} still references {target} in code

## Datastore Changes

{New or removed databases, caches, queues:}
- {added | removed}: **{type}** ({provider}) — {evidence}

## Integration Changes

{New or removed external integrations:}
- {added | removed}: **{name}** — {evidence: env var / SDK import}

## Deployment & Environment Changes

{Changes to environments, URLs, ports:}
- {component} {environment}: {old URL/port} → {new URL/port}

---

## Recommended Actions

{For each added component:}
1. Add `{name}` to `solution.sdl.yaml → architecture.projects.{category}[]`

{For each removed component:}
1. Remove `{name}` from SDL {IF probable_rename: OR rename to `{candidate}`}

{For each modified component:}
1. Update `{sdl_path}.{field}` from `{old}` to `{new}`

{IF any breaking changes:}
> ⚠ **Breaking changes detected.** Review these before deploying:
> {list breaking changes with SDL paths to update}

**Fastest path to sync:** Run `/architect:import` to regenerate the SDL from scratch,
then diff against the committed SDL using `/architect:sdl diff`.
```

#### 5.2 — Write `architecture-output/drift.json`

Machine-readable drift data:

```json
{
  "generated": "{ISO-8601}",
  "reference_sdl": "{path}",
  "drift_score": 0.0,
  "drift_label": "minimal | moderate | significant | critical",
  "summary": {
    "added": 0,
    "removed": 0,
    "modified": 0,
    "unchanged": 0,
    "total_reference": 0,
    "breaking_changes": 0
  },
  "components": {
    "added": [
      {
        "name": "{name}",
        "type": "frontend | backend | worker | library",
        "framework": "{detected framework}",
        "confidence": "high | medium | low",
        "evidence": ["{file path}"],
        "suggested_sdl_path": "architecture.projects.{category}[]"
      }
    ],
    "removed": [
      {
        "name": "{name}",
        "sdl_path": "{path in SDL}",
        "breaking": false,
        "dependents": [],
        "probable_rename": false,
        "rename_candidate": null
      }
    ],
    "modified": [
      {
        "name": "{name}",
        "changes": [
          {
            "field": "{sdl field path}",
            "reference_value": "{old}",
            "current_value": "{new}",
            "breaking": false
          }
        ]
      }
    ]
  },
  "dependencies": {
    "added": [],
    "removed": []
  },
  "datastores": {
    "added": [],
    "removed": []
  },
  "integrations": {
    "added": [],
    "removed": []
  }
}
```

#### 5.3 — Print In-Conversation Summary

After writing files, print directly in the conversation:

```
────────────────────────────────────────────────────
Drift analysis: {Project Name}
Drift score: {X.X}/10 — {label}
Added: {N} · Removed: {N} · Modified: {N} · Unchanged: {N}
{IF breaking_changes > 0:} ⚠ {N} breaking change(s) detected
────────────────────────────────────────────────────
{IF added > 0:}
New components (not in SDL)
  {one line per: name · type · framework · evidence file}

{IF removed > 0:}
Removed from codebase
  {one line per: name · breaking: YES/NO}

{IF modified > 0:}
Changed components
  {one line per: name · field changed · old → new}

{IF drift_score == 0:}
✅ SDL is up to date — no drift detected.

Full report → architecture-output/drift-report.md
Machine data → architecture-output/drift.json
────────────────────────────────────────────────────
```

#### 5.4 — Log Activity

Append to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"sdl-drift","outcome":"completed","files":["architecture-output/drift-report.md","architecture-output/drift.json"],"summary":"Drift score: <X.X>/10 (<label>). Added: <N>, removed: <N>, modified: <N>, breaking: <N>."}
```

## Output Rules

- Always generate both `drift-report.md` and `drift.json`
- If drift score is 0.0, still write the files (confirmation that SDL is current is valuable)
- Never modify the SDL during a drift run — drift is read-only analysis
- If the user wants to apply changes, direct them to `/architect:import` (full regeneration) or `/architect:sdl` (manual edit mode)
- `--mode inventory` of `/architect:import` can be used as input for a lower-noise baseline

## Related Commands

- `/architect:import` — Regenerate SDL from codebase (full rewrite)
- `/architect:sdl validate` — Validate SDL syntax and semantic rules
- `/architect:sdl diff` — Diff two SDL documents side-by-side
