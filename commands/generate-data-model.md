---
description: Generate ORM schemas (Prisma, SQLAlchemy, Mongoose, Drizzle) from blueprint shared types and database definitions
---

# /architect:generate-data-model

## Trigger

`/architect:generate-data-model`

## Purpose

After generating a blueprint with `/architect:blueprint`, this command takes the shared types (deliverable 4d) and database definitions from the manifest and generates real, working ORM schemas. Turns type stubs into Prisma schemas, SQLAlchemy models, Mongoose schemas, or Drizzle tables — with relationships, indexes, enums, and seed data.

## Workflow

### Step 1: Check for Shared Types

Check if a blueprint with shared types (deliverable 4d) and database definitions exists earlier in the conversation.

If no shared types exist, respond:

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

## Output Rules

- Use the **founder-communication** skill for tone
- Always generate a seed file with realistic test data
- Always add timestamps (createdAt, updatedAt) to every model
- Always add indexes on foreign keys
- Infer relationships from field names and manifest context
- Do NOT include the CTA footer
