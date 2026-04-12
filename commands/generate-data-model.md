---
description: Generate ORM schemas (Prisma, SQLAlchemy, Mongoose, Drizzle) from blueprint shared types and database definitions
---

# /architect:generate-data-model

## Trigger

`/architect:generate-data-model`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the shared types (deliverable 4d) and database definitions from the manifest and generates real, working ORM schemas. Turns type stubs into Prisma schemas, SQLAlchemy models, Mongoose schemas, or Drizzle tables — with relationships, indexes, enums, and seed data.

## Workflow

## Quick Navigation

| Phase | Steps |
|-------|-------|
| **Setup** | [Step 1](#step-1-read-context--check-for-shared-types) · [Step 2](#step-2-ask-configuration) · [Step 3](#step-3-identify-databases--split-by-type) |
| **Generation** | [Step 3.5](#step-35-delegate-to-data-model-generator-agent) · [Step 3.6](#step-36-generate-database-creation-scripts) · [Step 3.7](#step-37-generate-migration-scripts) |
| **Completion** | [Step 4](#step-4-print-summary) · [Step 5](#step-5-update-_statejson) · [Step 5.5](#step-55-docs-publish-optional) |

### Step 1: Read Context & Detect Mode

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` → product name for display
- `tech_stack` → ORM, database type, and framework — use to pre-fill Step 2 ORM question and skip asking if already obvious (e.g. `tech_stack.backend` includes "Prisma" → pre-select Prisma)
- `entities` → if present, these are already-generated entity summaries; do NOT regenerate ORM schemas that duplicate them — but if the user is running this command, they want fresh schema files regardless
- `components` → component directory names for knowing where to place schema files

**Then**, check if a blueprint with shared types (deliverable 4d) and database definitions exists earlier in the conversation.

**Detect mode — CRITICAL:**

Check for evidence of a scaffolded codebase:
- Does `solution.sdl.yaml` exist with a populated `domain.entities[]` section?
- Do component directories with `package.json` or equivalent build files exist?

**If NO scaffold evidence (ideation/pre-blueprint mode):**
→ Switch to **conceptual mode** — generate `architecture-output/data-model.md` only (entity table, relationships, ER diagram). Skip all ORM file generation entirely.
→ Do NOT write `prisma/schema.prisma`, `db/schema.ts`, migration files, or seed scripts.
→ Proceed directly to the conceptual output step below — skip Steps 2, 3, 3.5, 3.6, 3.7.

**Conceptual mode output** (write to `architecture-output/data-model.md`):
- Entity table: name, description, key fields, relationships
- Mermaid ER diagram showing entity relationships
- Data storage recommendations (what database type suits each entity group)
- Note at top: "This is a conceptual data model. ORM schemas will be generated after `/architect:scaffold` sets up your project structure."
- Write `entities` to `_state.json` with field names extracted from the conceptual model
- Emit `[DATA_MODEL_DONE]`, log activity, and stop

**If scaffold evidence exists (post-scaffold mode):**
→ Continue with Steps 2 onward (full ORM generation).

If no shared types exist and no `_state.json` with project context, respond:

> "I need shared types and database definitions to generate from. Run `/architect:blueprint` first to define your data model, then come back here to generate ORM schemas."

### Step 2: Ask Configuration

Ask the user:

> "Which ORM should I generate for?"
>
> - **Prisma** (default for TypeScript) — Type-safe PostgreSQL/MySQL ORM
> - **Drizzle** — Lightweight TypeScript ORM
> - **SQLAlchemy** (default for Python) — Python SQL toolkit
> - **Mongoose** — MongoDB ODM for Node.js
>
> "Which project should I add the schema to?" (path to scaffolded project)
>
> "Should I run the initial migration?" (yes/no — requires database connection)

### Step 3: Identify Databases & Split by Type

**Before delegating, analyze the data architecture:**

1. **Read the `data:` section from SDL** to extract all database definitions
   - Database types: relational (PostgreSQL, MySQL), NoSQL (MongoDB, DynamoDB), cache (Redis), search (Elasticsearch), etc.
   - Entity assignments: which entities belong to which database
   - Example:
     ```yaml
     data:
       databases:
         - name: primary
           type: PostgreSQL
           entities: [User, Order, Product, Review]
         - name: sessions
           type: Redis
           entities: [Session, Cache]
         - name: documents
           type: MongoDB
           entities: [Document, Comment, Attachment]
     ```

2. **Map entities to databases** — ensure every entity has a clear home
   - Relational entities → one relational database (usually)
   - Document/unstructured entities → MongoDB or similar
   - Session/ephemeral → Redis or cache
   - If an entity references another, both should be in same database (or use cross-database keys)

3. **Plan schema files per database:**
   - PostgreSQL: `schema-relational.prisma` (or `schema.prisma`)
   - MongoDB: `schema-document.prisma` (if using Prisma) or `schema-document.json` (schema validation)
   - Redis: `schema-cache.ts` (type definitions only; no schema file)

### Step 3.5: Delegate to Data Model Generator Agent

Pass the following to the **data-model-generator** agent:

- Shared types from the manifest (name, fields, used_by)
- **Database definitions from SDL** — ALL databases and their mapped entities
- Entities grouped by database type (relational entities, document entities, cache entities, etc.)
- ORM choice (Prisma, SQLAlchemy, Mongoose, etc.) — if multi-database, may need multiple ORMs
- Project directory path
- Tech stack context

### Step 3.6: Generate Database Creation Scripts

After ORM schemas are generated, create **native creation scripts** for each database type:

**For each database in the solution:**

1. **PostgreSQL / MySQL (Relational):**
   - Generate `db/schema-relational.sql` with `CREATE TABLE`, `CREATE INDEX`, constraints
   - Include all entities mapped to this database
   - Example:
     ```sql
     CREATE TABLE users (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       email VARCHAR(255) UNIQUE NOT NULL,
       role VARCHAR(50) NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
     );
     CREATE INDEX idx_users_email ON users(email);
     ```

1a. **SQL Server (Relational):**
   - Generate `db/schema-sqlserver.sql` with T-SQL `CREATE TABLE`, `CREATE INDEX`, constraints
   - Include all entities mapped to SQL Server
   - Example:
     ```sql
     CREATE TABLE users (
       id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
       email VARCHAR(255) UNIQUE NOT NULL,
       role VARCHAR(50) NOT NULL,
       created_at DATETIME DEFAULT GETUTCDATE(),
       updated_at DATETIME DEFAULT GETUTCDATE()
     );
     CREATE INDEX idx_users_email ON users(email);
     ```

2. **MongoDB (Document/NoSQL):**
   - Generate `db/schema-document.js` with collection creation and validators
   - Include all entities mapped to MongoDB
   - Example:
     ```js
     db.createCollection("documents", {
       validator: {
         $jsonSchema: {
           bsonType: "object",
           required: ["title", "owner_id"],
           properties: {
             _id: { bsonType: "objectId" },
             title: { bsonType: "string" },
             owner_id: { bsonType: "objectId" },
             content: { bsonType: "string" },
             created_at: { bsonType: "date" }
           }
         }
       }
     });
     db.documents.createIndex({ owner_id: 1, created_at: -1 });
     ```

3. **Redis (Cache/Sessions):**
   - Generate `db/schema-cache.ts` with TypeScript type definitions and key patterns
   - Example:
     ```ts
     // Cache schema — no DDL needed, but document key patterns:
     // sessions:{sessionId} → Session object (TTL: 24h)
     // user-cache:{userId} → User object (TTL: 1h)
     // rate-limit:{userId} → counter (TTL: 1m)
     ```

4. **Elasticsearch / Search Indexes:**
   - Generate `db/schema-search.json` with index mappings
   - Define analyzers, field types, shards

5. **Prisma Migrations** (if using Prisma as the ORM):
   - Generate `prisma/migrations/001_initial/migration.sql` with DDL statements
   - Works across relational + document databases Prisma supports

**Scripts are grouped in `db/` directory:**
```
db/
├── schema-index.md              ← Lists all databases and their entities
├── schema-relational.sql        ← PostgreSQL/MySQL tables
├── schema-sqlserver.sql         ← SQL Server (T-SQL) tables
├── schema-document.js           ← MongoDB collections
├── schema-cache.ts              ← Redis keys and patterns
├── schema-search.json           ← Elasticsearch mappings
└── seed-data.sql                ← (Optional) sample inserts for testing
```

### Step 3.7: Generate Migration Scripts

📦 **MIGRATION GENERATION:** ORM-specific migration files for production schema evolution

After generating schema files, create ORM-specific migration scripts. These are used to evolve the database schema safely over time in development, staging, and production environments.

**For each ORM in use:**

1. **Prisma (TypeScript/Node.js):**
   - Generate `prisma/schema.prisma` with datasource, generator, and all model definitions
   - Generate initial migration: `prisma/migrations/001_initial/migration.sql`
   - Add to `package.json` scripts:
     ```json
     {
       "scripts": {
         "db:migrate:dev": "prisma migrate dev",
         "db:migrate:deploy": "prisma migrate deploy",
         "db:generate": "prisma generate",
         "db:push": "prisma db push --skip-generate"
       }
     }
     ```
   - Example `prisma/schema.prisma`:
     ```prisma
     datasource db {
       provider = "postgresql"
       url      = env("DATABASE_URL")
     }

     generator client {
       provider = "prisma-client-js"
     }

     model User {
       id    Int     @id @default(autoincrement())
       email String  @unique
       name  String
       createdAt DateTime @default(now())
       updatedAt DateTime @updatedAt
     }
     ```

2. **Alembic (Python/SQLAlchemy):**
   - Generate `alembic/` directory with config
   - Generate `alembic.ini` with database URL placeholder
   - Create initial migration: `alembic/versions/001_initial.py`
   - Add to `Makefile` or `pyproject.toml`:
     ```makefile
     db-migrate-dev:
       alembic upgrade head

     db-migrate-new:
       alembic revision --autogenerate -m "migration description"
     ```
   - Example migration file:
     ```python
     from alembic import op
     import sqlalchemy as sa

     revision = '001'
     down_revision = None
     branch_labels = None
     depends_on = None

     def upgrade():
         op.create_table('users',
             sa.Column('id', sa.Integer(), nullable=False),
             sa.Column('email', sa.String(255), unique=True),
             sa.Column('name', sa.String(255)),
             sa.Column('created_at', sa.DateTime(), default=sa.func.now()),
             sa.PrimaryKeyConstraint('id')
         )
         op.create_index('idx_users_email', 'users', ['email'])

     def downgrade():
         op.drop_index('idx_users_email')
         op.drop_table('users')
     ```

3. **Drizzle (TypeScript):**
   - Generate `drizzle/` directory with schema files
   - Generate `drizzle.config.ts` with database connection
   - Create initial migration: `drizzle/0001_initial.sql`
   - Add to `package.json`:
     ```json
     {
       "scripts": {
         "db:generate": "drizzle-kit generate:pg",
         "db:migrate": "drizzle-kit migrate"
       }
     }
     ```

4. **EF Core (.NET):**
   - Generate initial DbContext: `Data/ApplicationDbContext.cs`
   - Create initial migration: `Data/Migrations/001_Initial.cs`
   - Add to `.csproj`:
     ```xml
     <ItemGroup>
       <DotNetCliToolReference Include="Microsoft.EntityFrameworkCore.Tools.DotNet" Version="2.0.0" />
     </ItemGroup>
     ```
   - Add to scripts or document:
     ```bash
     dotnet ef database update
     dotnet ef migrations add AddUsersTable
     ```

**Important header in all migration files:**
```
-- WARNING: Verify this migration before running in production.
-- Test in staging environment first.
-- Backup database before applying to production.
-- Generated by /architect:generate-data-model
```

**Directory structure after migrations:**
```
<project>/
├── prisma/                              (Prisma)
│   ├── schema.prisma
│   └── migrations/
│       └── 001_initial/migration.sql
├── alembic/                            (SQLAlchemy)
│   ├── alembic.ini
│   ├── env.py
│   └── versions/
│       └── 001_initial.py
├── drizzle/                            (Drizzle)
│   ├── drizzle.config.ts
│   ├── 0001_initial.sql
│   └── migration.ts
├── Data/Migrations/                    (.NET EF Core)
│   └── 001_Initial.cs
└── db/                                 (Reference scripts)
    ├── schema-index.md
    └── schema-*.sql/js/ts
```

### Step 4: Print Summary

```
Data model generated for multi-database architecture!

Databases & Models:

1. PostgreSQL (Relational)
   | Model | Fields | Indexes |
   |-------|--------|---------|
   | User | 6 | email (unique) |
   | Order | 7 | userId, status |
   | Product | 8 | sellerId, status |
   Total: 3 entities, 8 tables

2. SQL Server (Relational)
   | Table | Columns | Indexes |
   |-------|---------|---------|
   | User | 6 | email (unique) |
   | Order | 7 | userId, status |
   Total: 2 entities, 2 tables

3. MongoDB (Document)
   | Collection | Validator | Indexes |
   |-----------|-----------|---------|
   | Document | 5 fields | owner_id, created_at |
   | Comment | 4 fields | document_id |
   Total: 2 entities, 2 collections

4. Redis (Cache)
   | Key Pattern | TTL | Purpose |
   |------------|-----|---------|
   | sessions:{id} | 24h | Session storage |
   | user-cache:{id} | 1h | User data cache |
   Total: 2 cache schemas

Creation scripts generated:
  ✅ db/schema-relational.sql — PostgreSQL/MySQL DDL (15 statements)
  ✅ db/schema-sqlserver.sql — SQL Server T-SQL DDL (12 statements)
  ✅ db/schema-document.js — MongoDB validators + indexes
  ✅ db/schema-cache.ts — Redis key patterns and TTLs
  ✅ db/schema-index.md — Entity → database mapping guide
  ✅ prisma/migrations/001_initial/migration.sql — Prisma migration

Enums: Role (3), OrderStatus (5)
Seed file: db/seed-data.sql (sample inserts)

Next: Run the appropriate script when you set up each database:
  • PostgreSQL: psql -U postgres -d mydb < db/schema-relational.sql
  • MongoDB: mongosh < db/schema-document.js
  • Redis: Manual key patterns (see db/schema-cache.ts for documentation)
```

### Step 5: Update _state.json

After generating ORM schemas, update `architecture-output/_state.json` with a compact entity summary and database info:

1. Read existing `_state.json` (or start with `{}`)
2. For each generated model/entity, extract: name + field names only (not types, not constraints)
3. Record which database each entity belongs to
4. Merge into the `entities` array and write back:

```json
{
  "entities": [
    { "name": "User", "fields": ["id", "email", "name", "role", "createdAt", "updatedAt"], "owner": "<component>", "database": "postgresql" },
    { "name": "Order", "fields": ["id", "userId", "total", "status", "createdAt", "updatedAt"], "owner": "<component>", "database": "sqlserver" },
    { "name": "Document", "fields": ["_id", "title", "ownerId", "content", "createdAt"], "owner": "<component>", "database": "mongodb" }
  ],
  "databases": [
    { "type": "postgresql", "entity_count": 1, "script": "db/schema-relational.sql" },
    { "type": "sqlserver", "entity_count": 1, "script": "db/schema-sqlserver.sql" },
    { "type": "mongodb", "entity_count": 1, "script": "db/schema-document.js" },
    { "type": "redis", "entity_count": 2, "script": "db/schema-cache.ts" }
  ]
}
```

This allows `scaffold-component` to know entity shapes and which database they live in.

### Step 5.5: Docs Publish (Optional)

After updating `_state.json`, silently probe both Confluence and Notion to check which (if any) is connected.

**Check Confluence** — attempt `search_content` with a lightweight query (e.g. `query: "test", limit: 1`):
- If connected: ask the user "Publish data model to Confluence? (space key + optional parent page ID)"
- If the user confirms: delegate to the **confluence-publisher** agent with `artifact: "data-model"`, `projectName`, `spaceKey`, `parentPageId`, `projectDir`

**Check Notion** — attempt `notion_search` with `query: ""`, `page_size: 1`:
- If connected: ask the user "Publish data model to Notion? (optional parent page ID or database ID)"
- If the user confirms: delegate to the **notion-publisher** agent with `artifact: "data-model"`, `projectName`, `parentPageId` or `databaseId`, `projectDir`

If neither MCP server is connected, skip silently.

### Final Step: Log Activity

Append one line to `architecture-output/_activity.jsonl`:

```json
{"ts":"<ISO-8601>","phase":"generate-data-model","outcome":"completed","files":["db/schema-relational.sql","db/schema-sqlserver.sql","db/schema-document.js","db/schema-cache.ts","db/schema-index.md"],"databases":["postgresql","sqlserver","mongodb","redis"],"entityCount":9,"summary":"Data model generated: 9 entities across 4 databases (PostgreSQL, SQL Server, MongoDB, Redis). Creation scripts ready in db/ directory."}
```

Include:
- `files`: list all generated schema and script files
- `databases`: array of database types (e.g., ["postgresql", "mongodb", "redis"])
- `entityCount`: total entities across all databases
- `summary`: one sentence covering all databases, entity count, and status

### Signal Completion

Emit the completion marker:

```
[DATA_MODEL_DONE]
```

This ensures the generate-data-model phase is marked as complete in the project state.

## Error Handling

### Missing SDL or Data Section

If SDL is missing or does not have a `data:` section:
> "I need an SDL with data model to generate schemas from. Run `/architect:blueprint` first, then come back here."

### Malformed Entity Definitions

If an entity in SDL has no fields or invalid field types:
- Log warning: `"entity_X_malformed"` 
- Generate stub with TODO comments
- Continue with other entities

**Example stub:**
```
// TODO: Verify entity definition in SDL
// Entity: {name} has no fields defined
export interface {name} {
  id: string;
  // Add fields based on business requirements
}
```

### Missing or Unwritable Database Directory

If `<component>/db/` directory cannot be created due to permissions:
- Stop execution
- Report: "Cannot create db/ directory: [error]. Check file permissions."
- Do NOT emit completion marker

### Conflicting Existing Schemas

If schema files already exist for a database:
- Detect via glob: if `schema.prisma` or `db/schema-*.sql` exists
- Report: "Existing schemas found; I'll augment them instead of overwriting"
- Merge new entities instead of replacing file

## Output Rules

- Use the **founder-communication** skill for tone
- **CRITICAL: Read `data:` section from SDL to identify ALL databases (relational, NoSQL, cache, search)**
- **Split entities by database type:** assign each entity to its correct database based on SDL `data.databases[].entities` mapping
- **Generate ORM schemas for each database type:**
  - Relational (PostgreSQL/MySQL/SQL Server): Prisma `schema.prisma` or raw SQL/T-SQL
  - Document (MongoDB): Mongoose schemas or MongoDB validator JSON
  - Cache (Redis): TypeScript type definitions with key patterns
  - Search (Elasticsearch): JSON mappings
- **Generate native creation scripts** for each database type in `db/` directory:
  - `db/schema-relational.sql` — PostgreSQL/MySQL DDL
  - `db/schema-sqlserver.sql` — SQL Server T-SQL DDL
  - `db/schema-{database-type}.js` or `.ts` — native validator/definition syntax
  - `db/schema-index.md` — lists all databases and their entities
- **Never mix different database syntaxes** in one file — PostgreSQL DDL in `schema-relational.sql`, SQL Server T-SQL in `schema-sqlserver.sql`, MongoDB validators in `schema-document.js`
- Always generate a seed file (`db/seed-data.sql` or equivalent) with realistic test data
- Always add timestamps (createdAt, updatedAt) to every entity
- Always add indexes on foreign keys and frequently-queried fields
- **Always apply soft-delete** (Production Hardening Pattern 8): add `deletedAt DateTime?` field + index for relational; `deletedAt` field + query filter for document stores
- Infer relationships from field names and manifest context
- **Derive entity names from `domain.entities[]` in SDL** — authoritative entity inventory. The `data:` section defines storage infrastructure (which database types exist), not entity names. For field details, cross-reference manifest and any existing migration files
- If multiple services with distinct data domains: write `db/schema-index.md` listing which entities are in which database and which service owns them
- Use tables for structured data (entities, indexes, database mappings)
- Do NOT include the CTA footer
