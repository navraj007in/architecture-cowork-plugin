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

### Step 3: Delegate to Data Model Generator Agent

Pass the following to the **data-model-generator** agent:

- Shared types from the manifest (name, fields, used_by)
- Database definitions from the manifest (type, purpose, key collections)
- ORM choice
- Project directory path
- Whether to run initial migration
- Tech stack context

### Step 4: Print Summary

```
Data model generated!

ORM: Prisma (PostgreSQL)

| Model | Fields | Relations | Indexes |
|-------|--------|-----------|---------|
| User | 6 | products, orders, reviews | email (unique) |
| Product | 8 | seller, orderItems, reviews | sellerId, status |
| Order | 7 | buyer, items | buyerId, status |
| Review | 6 | product, user | productId |

Enums: Role (3), ProductStatus (4), OrderStatus (5)
Seed file: prisma/seed.ts (20 test records)
Migration: Applied (init)

Files created:
  prisma/schema.prisma
  prisma/seed.ts

Next: Run `npx prisma db seed` to populate test data
```

### Step 5: Update _state.json

After generating ORM schemas, update `architecture-output/_state.json` with a compact entity summary:

1. Read existing `_state.json` (or start with `{}`)
2. For each generated model/entity, extract: name + field names only (not types, not constraints)
3. Merge into the `entities` array and write back:

```json
{
  "entities": [
    { "name": "User", "fields": ["id", "email", "name", "role", "createdAt", "updatedAt"], "owner": "<component name>" },
    { "name": "Order", "fields": ["id", "userId", "total", "status", "createdAt", "updatedAt"], "owner": "<component name>" }
  ]
}
```

This allows `scaffold-component` to know entity shapes without parsing ORM schema files.

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
{"ts":"<ISO-8601>","phase":"generate-data-model","outcome":"completed","files":["architecture-output/data-model.md"],"summary":"Data model generated: <N> entities, <orm> ORM, <database> database."}
```

If the data model was split across multiple files, list all generated files in the `files` array.

### Signal Completion

Emit the completion marker:

```
[DATA_MODEL_DONE]
```

This ensures the generate-data-model phase is marked as complete in the project state.

## Output Rules

- Use the **founder-communication** skill for tone
- Always generate a seed file with realistic test data
- Always add timestamps (createdAt, updatedAt) to every model
- Always add indexes on foreign keys
- **Always apply soft-delete to every model** (Production Hardening Pattern 8): add `deletedAt DateTime?` field + `@@index([deletedAt])` index; for Prisma include transparent middleware in `src/lib/prisma.ts` that filters `deletedAt: null` on all queries and converts `delete` to `update { deletedAt: new Date() }`; for SQLAlchemy use a `deleted_at` column with a query filter mixin; for EF Core use a global query filter in `OnModelCreating`; for Mongoose add a `deletedAt` field and a pre-find hook
- Infer relationships from field names and manifest context
- Derive entity names from `domain.entities[]` in the SDL — this is the authoritative entity inventory. Check `solution.sdl.yaml` first; if absent, read `sdl/README.md` then the relevant module (typically `sdl/data.yaml` or `sdl/domain.yaml`). The `data:` section defines storage infrastructure (database types, cache, queues), not entity names. For field details, cross-reference the manifest, README, and any existing migration files
- If the SDL defines multiple services with distinct data domains, split schemas by domain: one `schema-{domain}.prisma` per service (e.g. `schema-auth.prisma`, `schema-orders.prisma`, `schema-inventory.prisma`). Write `schema-index.md` listing which entities are in each file and which service owns them. For single-service projects, one `schema.prisma` is fine regardless of size
- If a single schema file exceeds ~15KB (unusual for a domain-split schema), split further into numbered parts and write a `*-index.md`
- Use tables instead of prose for structured data (entities, endpoints, config)
- Do NOT include the CTA footer
