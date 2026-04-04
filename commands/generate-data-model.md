---
description: Generate ORM schemas (Prisma, SQLAlchemy, Mongoose, Drizzle) from blueprint shared types and database definitions
---

# /architect:generate-data-model

## Trigger

`/architect:generate-data-model`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the shared types (deliverable 4d) and database definitions from the manifest and generates real, working ORM schemas. Turns type stubs into Prisma schemas, SQLAlchemy models, Mongoose schemas, or Drizzle tables — with relationships, indexes, enums, and seed data.

## Workflow

### Step 1: Read Context & Check for Shared Types

**First**, check for `architecture-output/_state.json`. If it exists, read it in full and extract:
- `project.name` → product name for display
- `tech_stack` → ORM, database type, and framework — use to pre-fill Step 2 ORM question and skip asking if already obvious (e.g. `tech_stack.backend` includes "Prisma" → pre-select Prisma)
- `entities` → if present, these are already-generated entity summaries; do NOT regenerate ORM schemas that duplicate them — but if the user is running this command, they want fresh schema files regardless
- `components` → component directory names for knowing where to place schema files

**Then**, check if a blueprint with shared types (deliverable 4d) and database definitions exists earlier in the conversation.

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
├── schema-index.md          ← Lists all databases and their entities
├── schema-relational.sql    ← PostgreSQL/MySQL tables
├── schema-document.js       ← MongoDB collections
├── schema-cache.ts          ← Redis keys and patterns
├── schema-search.json       ← Elasticsearch mappings
└── seed-data.sql            ← (Optional) sample inserts for testing
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

2. MongoDB (Document)
   | Collection | Validator | Indexes |
   |-----------|-----------|---------|
   | Document | 5 fields | owner_id, created_at |
   | Comment | 4 fields | document_id |
   Total: 2 entities, 2 collections

3. Redis (Cache)
   | Key Pattern | TTL | Purpose |
   |------------|-----|---------|
   | sessions:{id} | 24h | Session storage |
   | user-cache:{id} | 1h | User data cache |
   Total: 2 cache schemas

Creation scripts generated:
  ✅ db/schema-relational.sql — PostgreSQL DDL (15 statements)
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
    { "name": "Order", "fields": ["id", "userId", "total", "status", "createdAt", "updatedAt"], "owner": "<component>", "database": "postgresql" },
    { "name": "Document", "fields": ["_id", "title", "ownerId", "content", "createdAt"], "owner": "<component>", "database": "mongodb" }
  ],
  "databases": [
    { "type": "postgresql", "entity_count": 2, "script": "db/schema-relational.sql" },
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
{"ts":"<ISO-8601>","phase":"generate-data-model","outcome":"completed","files":["db/schema-relational.sql","db/schema-document.js","db/schema-cache.ts","db/schema-index.md"],"databases":["postgresql","mongodb","redis"],"entityCount":8,"summary":"Data model generated: 8 entities across 3 databases (PostgreSQL, MongoDB, Redis). Creation scripts ready in db/ directory."}
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

## Output Rules

- Use the **founder-communication** skill for tone
- **CRITICAL: Read `data:` section from SDL to identify ALL databases (relational, NoSQL, cache, search)**
- **Split entities by database type:** assign each entity to its correct database based on SDL `data.databases[].entities` mapping
- **Generate ORM schemas for each database type:**
  - Relational (PostgreSQL/MySQL): Prisma `schema.prisma` or raw SQL
  - Document (MongoDB): Mongoose schemas or MongoDB validator JSON
  - Cache (Redis): TypeScript type definitions with key patterns
  - Search (Elasticsearch): JSON mappings
- **Generate native creation scripts** for each database type in `db/` directory:
  - `db/schema-{database-type}.sql` or `.js` or `.ts` — native DDL/validator syntax
  - `db/schema-index.md` — lists all databases and their entities
- **Never mix different database syntaxes** in one file — PostgreSQL DDL in `schema-relational.sql`, MongoDB validators in `schema-document.js`
- Always generate a seed file (`db/seed-data.sql` or equivalent) with realistic test data
- Always add timestamps (createdAt, updatedAt) to every entity
- Always add indexes on foreign keys and frequently-queried fields
- **Always apply soft-delete** (Production Hardening Pattern 8): add `deletedAt DateTime?` field + index for relational; `deletedAt` field + query filter for document stores
- Infer relationships from field names and manifest context
- **Derive entity names from `domain.entities[]` in SDL** — authoritative entity inventory. The `data:` section defines storage infrastructure (which database types exist), not entity names. For field details, cross-reference manifest and any existing migration files
- If multiple services with distinct data domains: write `db/schema-index.md` listing which entities are in which database and which service owns them
- Use tables for structured data (entities, indexes, database mappings)
- Do NOT include the CTA footer
