---
description: Coordinated architecture refactor — change database, cloud provider, or framework with full SDL consistency
---

# /architect:refactor-stack

## Trigger

`/architect:refactor-stack [change description]`

Examples:
- `/architect:refactor-stack postgres to mongodb`
- `/architect:refactor-stack express to fastapi`
- `/architect:refactor-stack vercel to railway`
- `/architect:refactor-stack add postgres replica`

## Purpose

When an architecture component needs to change (database engine, framework, cloud provider, ORM), this command performs a **coordinated refactor** across the entire SDL. It rewrites all affected sections consistently, validates the new architecture against all 20+ SDL rules, flags what downstream artifacts need regeneration, and produces a detailed change report.

This prevents the fragmentation that happens when only a few SDL fields are updated without checking side effects.

## Workflow

### Step 1: Read Existing SDL & Validate

Check for `solution.sdl.yaml` in the current working directory.

If absent, respond:
> "No SDL found. Run `/architect:blueprint` first to design your architecture, then come back to refactor it."

If present, read it in full (or if multi-file, read `sdl/README.md` then merge the modules).

Store the **original SDL** in memory for comparison after refactoring.

### Step 2: Parse the Change Request

Extract what's being changed from the user's input. Use natural language understanding:

**Change patterns to recognize:**

| User Input | Parsed Change | Impact |
|---|---|---|
| "postgres to mongodb" | `data.primaryDatabase.type: postgres → mongodb` | Database, ORM, entities, migrations |
| "add postgres read replica" | `data.secondaryDatabases += { type: postgres, ... }` | Deployment, cost, replication config |
| "express to fastapi" | `architecture.projects[].{framework, language, runtime}` | Backend service, ORM, migrations, deployment |
| "vercel to railway" | `deployment.cloud: vercel → railway` | Deployment, CI/CD, regions, cost |
| "add elasticsearch" | `data.search: { type: elasticsearch }` | Data architecture, integrations, deployment |
| "jwt to oauth2" | `auth.strategy: jwt → oauth2` | Auth, dependencies, integrations, complexity |

If the change is ambiguous, ask ONE clarifying question:
> "Changing from Express to FastAPI — should I also update the ORM from Prisma to SQLAlchemy, or keep it as-is?"

### Step 3: Plan the Refactor

Based on the detected change, determine **all affected SDL sections**:

**Example: Postgres → MongoDB**

```
CHANGE: Database engine swap

Directly affected sections:
  ✓ data.primaryDatabase.type
  ✓ data.databases[] (if multi-database)
  ✓ domain.entities[] (SQL schema → document schema)
  
Dependent sections:
  ✓ architecture.projects[].orm (prisma → mongoose)
  ✓ architecture.projects[].language (may stay same)
  ✓ architecture.projects[].runtime (may stay same)
  ✓ environments[].components (port changes possible)
  ✓ deployment.regions (some regions may not support MongoDB)
  ✓ data.cache (if using Redis for sessions, keep it; if using Postgres sessions, update)
  
Must regenerate:
  ⚠️ Domain model (schema-relational.sql → schema-document.js)
  ⚠️ Data model artifacts (db/schema-*.sql → db/schema-*.js)
  ⚠️ DevOps blueprint (migration tools, init scripts)
  ⚠️ Cost estimate (infrastructure costs differ)
  ⚠️ Setup-env guide (connection strings, client libraries)
```

Present the plan to the user:
> "Understood. Refactoring PostgreSQL → MongoDB will affect:
> - Database config (type, connection, hosting)
> - ORM (Prisma → Mongoose)
> - Entity definitions (relational → document model)
> - Deployment (regions, cost)
> 
> Should regenerate: data-model, cost-estimate, setup-env, devops-blueprint
> 
> Continue? (yes/no)"

If user says no, stop.

### Step 4: Validate Against New SDL Constraints

Before writing changes, validate the **proposed new SDL** against the 20+ conditional rules.

**Check:**
1. ORM-Database compatibility (Mongoose only with MongoDB, EF Core only with relational, etc.)
2. Framework-Language compatibility
3. Cloud region support for new provider
4. Impact on auth, integrations, caching
5. Team capability (microservices with 1-person team = warning)

If validation fails:
> "This change introduces a conflict:
> • Mongoose (proposed ORM) only works with MongoDB, but your architecture also references Prisma for PostgreSQL.
> 
> Options:
> 1. Migrate ALL relational databases to MongoDB (breaking change)
> 2. Use Prisma for PostgreSQL, Mongoose for MongoDB (multi-ORM setup — adds complexity)
> 3. Keep PostgreSQL and use Prisma
> 
> Which approach?"

### Step 5: Rewrite Affected SDL Sections

Based on the change plan, systematically rewrite each affected section.

**For each section:**
1. Read current value
2. Apply the transformation
3. Validate the new value
4. Store for later writing

**Example: Postgres → MongoDB**

```yaml
# Original
data:
  primaryDatabase:
    type: postgres
    hosting: managed

# Changed to
data:
  primaryDatabase:
    type: mongodb
    hosting: managed
```

```yaml
# Original
architecture:
  projects:
    backend:
      - name: api
        orm: prisma

# Changed to
architecture:
  projects:
    backend:
      - name: api
        orm: mongoose
```

**Update domain.entities format** if changing SQL ↔ document:

For MongoDB (documents):
- Remove `primaryKey: true` (MongoDB uses `_id` automatically)
- Convert `relationships` from foreign keys to document references
- Update field types (UUID → ObjectId, etc.)

```yaml
# From SQL
- name: User
  fields:
    - name: id
      type: uuid
      primaryKey: true
    - name: email
      type: string

# To MongoDB
- name: User
  fields:
    - name: _id
      type: ObjectId
    - name: email
      type: string
```

### Step 6: Write Updated SDL

Write the updated sections back to the SDL file(s):

1. If single-file (`solution.sdl.yaml`):
   - Preserve all unchanged sections
   - Overwrite changed sections with updated values
   - Preserve `x-*` extension fields

2. If multi-file (`sdl/` directory):
   - Update affected module files
   - Preserve unaffected modules
   - Update imports list if sections added/removed

Create a **changelog** file `architecture-output/_refactor-changelog.md`:

```markdown
# Architecture Refactor — [Date]

## Change
PostgreSQL → MongoDB

## Sections Modified

### data.primaryDatabase
- type: `postgres` → `mongodb`
- hosting: unchanged (managed)

### architecture.projects[backend]
- orm: `prisma` → `mongoose`

### domain.entities
- 5 entities converted to document model
- ObjectId used for primary keys
- Foreign keys converted to document references

## Validation
✓ Mongoose-MongoDB compatibility verified
✓ All components have valid paths
✓ No circular dependencies
✓ Regions support MongoDB (AWS, GCP, Azure all support)

## Warnings
⚠️ Cross-database joins no longer possible if other services use PostgreSQL
⚠️ ACID transactions limited (MongoDB has multi-document transactions, but less mature)
⚠️ Migration from SQL to document model requires data transformation

## Impact on Generated Artifacts

| Artifact | Status | Action |
|----------|--------|--------|
| schema-relational.sql | ❌ Outdated | Regenerate with /architect:generate-data-model |
| schema-document.js | ✅ New | Will be created with /architect:generate-data-model |
| cost-estimate.md | ⚠️ Outdated | Regenerate (MongoDB ~15% cheaper than managed PostgreSQL) |
| devops-blueprint.md | ⚠️ Outdated | Regenerate (migration tools, connection strings) |
| setup-env.md | ⚠️ Outdated | Regenerate (MongoDB client libraries, connection syntax) |
| executive-summary.md | ⚠️ Partial | Review tech stack description |
| data-model-*.md | ⚠️ Outdated | Regenerate (document model documentation) |

## Next Steps

1. **Review** the updated `solution.sdl.yaml` to verify changes
2. **Regenerate data model:**
   ```
   /architect:generate-data-model
   ```
3. **Regenerate affected deliverables:**
   ```
   /architect:blueprint
   ```
4. **Test locally:**
   ```
   /architect:setup-env
   ```
5. **Commit changes:**
   ```
   git add solution.sdl.yaml sdl/ architecture-output/
   git commit -m "refactor: Migrate from PostgreSQL to MongoDB"
   ```

## Rollback

To revert this change:
```bash
git checkout HEAD~1 solution.sdl.yaml sdl/
/architect:generate-data-model  # Regenerate for original DB
/architect:blueprint  # Regenerate affected docs
```
```

### Step 7: Log Activity

Append to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"refactor-stack","outcome":"completed","files":["solution.sdl.yaml","architecture-output/_refactor-changelog.md"],"change":"postgresql → mongodb","sections_modified":["data","architecture.projects[backend]","domain.entities"],"artifacts_to_regenerate":["data-model","cost-estimate","devops-blueprint","setup-env"],"summary":"Architecture refactored: PostgreSQL → MongoDB. Updated ORM from Prisma to Mongoose. 5 entities converted to document model. Review changelog and regenerate: data-model, blueprint, setup-env."}
```

### Step 8: Signal Completion

Emit the completion marker:

```
[REFACTOR_DONE]
```

### Step 9: Print Summary to User

Display the changelog with clear next steps:

```
✅ Architecture Refactored — PostgreSQL → MongoDB

Updated Sections:
  ✓ data.primaryDatabase.type: postgres → mongodb
  ✓ architecture.projects[backend].orm: prisma → mongoose
  ✓ domain.entities: converted to document model (5 entities)

Validation:
  ✓ Mongoose-MongoDB compatible
  ✓ All regions support MongoDB
  ✓ No circular dependencies

⚠️ Artifacts to Regenerate (in order):

1. Data Model (required — schemas changed)
   /architect:generate-data-model

2. Blueprint (cost & DevOps changed)
   /architect:blueprint

3. Setup Guide (connection strings, libraries)
   /architect:setup-env

Full changelog: architecture-output/_refactor-changelog.md

Rollback: git checkout HEAD~1 solution.sdl.yaml sdl/
```

## Output Rules

- **Always read the existing SDL first** — never infer architecture from code
- **Validate proposed change against all 20+ SDL rules** before writing
- **Preserve all unchanged sections** — never touch unrelated SDL parts
- **Track all affected artifacts** — list everything that needs regeneration
- **Provide rollback instructions** — include git commands to revert
- **Explain impact clearly** — use a table to show what changed and why
- **Generate changelog markdown** — human-readable record of architectural decision
- **Log to activity.jsonl** — include `artifacts_to_regenerate` array for downstream automation

## Common Refactors & Impact

| Change | Affects | Regenerate |
|--------|---------|------------|
| `postgres → mongodb` | data, ORM, entities, deployment | data-model, blueprint, setup-env |
| `express → fastapi` | framework, language, runtime, ORM, deployment | scaffold, setup-env, devops-blueprint |
| `vercel → railway` | cloud, CI/CD, regions, cost | blueprint, devops-blueprint, cost-estimate |
| `jwt → oauth2` | auth, integrations, complexity, cost | blueprint, security-architecture |
| `single-backend → microservices` | architecture.style, complexity, deployment | scaffold, blueprint, devops-blueprint, cost-estimate |
| `add postgres replica` | data, deployment, cost, resilience | devops-blueprint, cost-estimate, backup-dr |

