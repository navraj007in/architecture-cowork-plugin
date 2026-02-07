---
name: generate-data-model
description: Convert database schemas from architecture blueprints to production-ready ORM code (Prisma, Drizzle, TypeORM). Includes all tables, relationships, indexes, constraints, and Row-Level Security policies.
---

# Data Model Generator

Convert your architecture blueprint's **database schema** into production-ready ORM code with migrations, indexes, and security policies.

**Perfect for**: Project setup, database initialization, schema-first development, team synchronization

---

## When to Use This Skill

Use this skill when you need to:
- Convert blueprint database schema to Prisma/Drizzle/TypeORM code
- Generate migration files from architecture design
- Create type-safe database access layer
- Implement Row-Level Security policies
- Set up database indexes for performance
- Share schema with frontend/backend teams
- Initialize database for new project

**Input**: Architecture blueprint (Section 4: Database Schema)
**Output**: ORM schema files, migration files, seed data

---

## Supported ORMs

### 1. Prisma (Recommended for Next.js, Node.js)

**Output**: `prisma/schema.prisma`, `prisma/migrations/`

**Why Prisma**:
- Best TypeScript support (auto-generated types)
- Excellent developer experience (Prisma Studio GUI)
- Works with PostgreSQL, MySQL, SQLite, MongoDB
- Automatic migration generation
- Built-in connection pooling

**Example Output**:
```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Tenant {
  id        String   @id @default(cuid())
  name      String
  domain    String   @unique
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relationships
  users     User[]
  tickets   Ticket[]

  @@index([domain])
  @@map("tenants")
}

model User {
  id         String   @id @default(cuid())
  tenantId   String
  email      String
  name       String?
  role       UserRole @default(AGENT)
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  // Relationships
  tenant     Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  tickets    Ticket[] @relation("AssignedTickets")

  @@unique([tenantId, email])
  @@index([tenantId])
  @@index([email])
  @@map("users")
}

enum UserRole {
  ADMIN
  AGENT
  VIEWER
}

model Ticket {
  id          String       @id @default(cuid())
  tenantId    String
  title       String
  description String       @db.Text
  status      TicketStatus @default(OPEN)
  priority    Priority     @default(MEDIUM)
  assigneeId  String?
  createdBy   String
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt

  // Relationships
  tenant      Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  assignee    User?        @relation("AssignedTickets", fields: [assigneeId], references: [id])
  comments    Comment[]

  @@index([tenantId, status])
  @@index([assigneeId])
  @@index([createdAt])
  @@map("tickets")
}

enum TicketStatus {
  OPEN
  IN_PROGRESS
  RESOLVED
  CLOSED
}

enum Priority {
  LOW
  MEDIUM
  HIGH
  URGENT
}
```

### 2. Drizzle ORM (Recommended for Edge, Serverless)

**Output**: `db/schema.ts`, `db/migrations/`

**Why Drizzle**:
- Lightweight (perfect for serverless/edge)
- SQL-like syntax (easier for SQL developers)
- Works with Vercel Postgres, Neon, PlanetScale
- TypeScript-first with excellent type inference

**Example Output**:
```typescript
// db/schema.ts
import { pgTable, text, timestamp, pgEnum, index, uniqueIndex } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const userRoleEnum = pgEnum('user_role', ['ADMIN', 'AGENT', 'VIEWER']);
export const ticketStatusEnum = pgEnum('ticket_status', ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']);
export const priorityEnum = pgEnum('priority', ['LOW', 'MEDIUM', 'HIGH', 'URGENT']);

export const tenants = pgTable('tenants', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  name: text('name').notNull(),
  domain: text('domain').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  domainIdx: uniqueIndex('tenants_domain_idx').on(table.domain),
}));

export const users = pgTable('users', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  tenantId: text('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
  email: text('email').notNull(),
  name: text('name'),
  role: userRoleEnum('role').default('AGENT').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  tenantEmailIdx: uniqueIndex('users_tenant_email_idx').on(table.tenantId, table.email),
  tenantIdx: index('users_tenant_idx').on(table.tenantId),
  emailIdx: index('users_email_idx').on(table.email),
}));

export const tickets = pgTable('tickets', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  tenantId: text('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  description: text('description').notNull(),
  status: ticketStatusEnum('status').default('OPEN').notNull(),
  priority: priorityEnum('priority').default('MEDIUM').notNull(),
  assigneeId: text('assignee_id').references(() => users.id),
  createdBy: text('created_by').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  tenantStatusIdx: index('tickets_tenant_status_idx').on(table.tenantId, table.status),
  assigneeIdx: index('tickets_assignee_idx').on(table.assigneeId),
  createdAtIdx: index('tickets_created_at_idx').on(table.createdAt),
}));

// Relations
export const tenantsRelations = relations(tenants, ({ many }) => ({
  users: many(users),
  tickets: many(tickets),
}));

export const usersRelations = relations(users, ({ one, many }) => ({
  tenant: one(tenants, { fields: [users.tenantId], references: [tenants.id] }),
  assignedTickets: many(tickets),
}));

export const ticketsRelations = relations(tickets, ({ one, many }) => ({
  tenant: one(tenants, { fields: [tickets.tenantId], references: [tenants.id] }),
  assignee: one(users, { fields: [tickets.assigneeId], references: [users.id] }),
  comments: many(comments),
}));
```

### 3. TypeORM (For Enterprise, Java-like patterns)

**Output**: `src/entities/`, `src/migrations/`

**Why TypeORM**:
- Mature, battle-tested in enterprise
- Decorator-based (familiar to Java/Spring developers)
- Advanced features (multi-database, replication)
- Works with TypeScript and JavaScript

### 4. SQL (Raw migrations)

**Output**: `db/migrations/001_initial_schema.sql`

**Why SQL**:
- Maximum control and flexibility
- No ORM overhead
- Works with any language/framework
- Easier to review and optimize

---

## How It Works

### Step 1: Parse Database Schema from Blueprint

Extract from **Section 4: Database Schema**:

```markdown
## Database Schema

### Entities

#### Tenant
- `id` (UUID, PK)
- `name` (String, required)
- `domain` (String, unique, required)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Relationships**:
- Has many Users
- Has many Tickets

**Indexes**:
- `domain` (unique)

#### User
- `id` (UUID, PK)
- `tenant_id` (UUID, FK → Tenant, required)
- `email` (String, required)
- `name` (String, optional)
- `role` (Enum: ADMIN, AGENT, VIEWER, default: AGENT)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**Relationships**:
- Belongs to Tenant
- Has many Tickets (as assignee)

**Indexes**:
- `(tenant_id, email)` (unique composite)
- `tenant_id`
- `email`

**Constraints**:
- ON DELETE CASCADE (when tenant deleted, delete users)
```

### Step 2: Detect ORM from Tech Stack

Check **Section 3: Tech Stack Decisions** for ORM choice:
- Next.js + Vercel → Prisma (default)
- Edge/Serverless → Drizzle
- Enterprise/Java background → TypeORM
- Not specified → Ask user or default to Prisma

### Step 3: Convert Schema to ORM Syntax

For each entity:
1. **Map data types**: Blueprint types → ORM types
   - `UUID` → `@id @default(cuid())` (Prisma) or `text('id').primaryKey()` (Drizzle)
   - `String` → `String` or `text()`
   - `Timestamp` → `DateTime` or `timestamp()`
   - `Enum` → `enum` or `pgEnum()`

2. **Add relationships**: Foreign keys, one-to-many, many-to-many
   - `tenant_id FK → Tenant` → `@relation(fields: [tenantId], references: [id])`

3. **Add indexes**: Performance optimization
   - Single column: `@@index([column])`
   - Composite: `@@index([col1, col2])`
   - Unique: `@@unique([column])`

4. **Add constraints**: Cascades, checks, defaults
   - `onDelete: Cascade` for multi-tenant isolation
   - `@default(now())` for timestamps
   - `@default(AGENT)` for enums

### Step 4: Generate Row-Level Security Policies

If **multi-tenant B2B SaaS** detected, add RLS:

**PostgreSQL RLS (SQL)**:
```sql
-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own tenant's data
CREATE POLICY tenant_isolation_policy ON users
  FOR ALL
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE POLICY tenant_isolation_policy ON tickets
  FOR ALL
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Admins can see all tenants (override policy)
CREATE POLICY admin_override_policy ON users
  FOR ALL
  TO admin_role
  USING (true);
```

**Prisma/Drizzle Middleware** (app-level RLS):
```typescript
// prisma/middleware.ts
import { Prisma } from '@prisma/client';

export function tenantMiddleware(tenantId: string) {
  return Prisma.defineExtension((client) => {
    return client.$extends({
      query: {
        $allModels: {
          async $allOperations({ args, query, model }) {
            // Automatically add tenantId filter to all queries
            if ('where' in args) {
              args.where = { ...args.where, tenantId };
            }
            if ('data' in args && model !== 'Tenant') {
              args.data = { ...args.data, tenantId };
            }
            return query(args);
          },
        },
      },
    });
  });
}

// Usage:
const db = prisma.$extends(tenantMiddleware(currentTenantId));
```

### Step 5: Generate Seed Data

Create `prisma/seed.ts` or `db/seed.ts`:

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Create demo tenant
  const tenant = await prisma.tenant.create({
    data: {
      name: 'Acme Corp',
      domain: 'acme.example.com',
    },
  });

  // Create admin user
  const admin = await prisma.user.create({
    data: {
      tenantId: tenant.id,
      email: 'admin@acme.com',
      name: 'Admin User',
      role: 'ADMIN',
    },
  });

  // Create sample ticket
  await prisma.ticket.create({
    data: {
      tenantId: tenant.id,
      title: 'Welcome to the system',
      description: 'This is a sample ticket',
      status: 'OPEN',
      priority: 'LOW',
      createdBy: admin.id,
    },
  });

  console.log('✅ Database seeded successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

**Add to package.json**:
```json
{
  "scripts": {
    "db:seed": "tsx prisma/seed.ts"
  },
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

### Step 6: Generate Initial Migration

**Prisma**:
```bash
npx prisma migrate dev --name init
# Creates: prisma/migrations/20260207000000_init/migration.sql
```

**Drizzle**:
```bash
npx drizzle-kit generate:pg
# Creates: db/migrations/0000_initial_schema.sql
```

**Raw SQL**:
```sql
-- db/migrations/001_initial_schema.sql

-- Create enums
CREATE TYPE user_role AS ENUM ('ADMIN', 'AGENT', 'VIEWER');
CREATE TYPE ticket_status AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');
CREATE TYPE priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- Create tables
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  domain TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX tenants_domain_idx ON tenants(domain);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT,
  role user_role NOT NULL DEFAULT 'AGENT',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, email)
);

CREATE INDEX users_tenant_idx ON users(tenant_id);
CREATE INDEX users_email_idx ON users(email);

[... more tables ...]

-- Enable Row-Level Security
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY tenant_isolation_policy ON users
  FOR ALL USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

[... more policies ...]
```

---

## Output Format

When invoked, generate:

```
🗄️  Generating data model from blueprint...

✅ Detected ORM: Prisma (from Next.js tech stack)
✅ Parsed database schema (5 entities, 12 relationships)
   - Entities: Tenant, User, Ticket, Comment, Attachment
   - Relationships: 8 one-to-many, 4 many-to-many
   - Indexes: 15 (performance optimized)
   - Constraints: 8 cascade deletes

✅ Generated prisma/schema.prisma (287 lines)
✅ Generated prisma/seed.ts (sample data)
✅ Generated prisma/middleware.ts (RLS for multi-tenancy)
✅ Generated db/rls-policies.sql (PostgreSQL RLS)

📦 Next steps to initialize database:

1. Install Prisma:
   npm install prisma @prisma/client
   npm install -D tsx

2. Generate Prisma Client:
   npx prisma generate

3. Run initial migration:
   npx prisma migrate dev --name init

4. Seed database with sample data:
   npm run db:seed

5. Open Prisma Studio (database GUI):
   npx prisma studio

🔒 Multi-tenancy configured:
- All queries automatically scoped by tenant_id
- Row-Level Security policies enabled
- Cascade deletes configured
- Sample middleware for app-level isolation
```

---

## Features

### Type Safety

**Prisma**:
```typescript
// Auto-generated types from schema
import { PrismaClient, User, Ticket, TicketStatus } from '@prisma/client';

const db = new PrismaClient();

// Type-safe queries
const user: User = await db.user.findUnique({
  where: { id: '123' },
  include: { tickets: true }, // Type-safe includes
});

// Type-safe creates
const ticket: Ticket = await db.ticket.create({
  data: {
    tenantId: 'tenant-123',
    title: 'New ticket',
    status: TicketStatus.OPEN, // Enum type
    priority: 'HIGH', // Type error if invalid
  },
});
```

### Performance Indexes

Automatically add indexes for:
- Foreign keys (always indexed)
- Composite unique constraints (tenant_id + email)
- Frequently queried columns (status, created_at)
- Timestamp-based queries (created_at DESC for pagination)

### Migration Management

**Version control for schema changes**:
```
prisma/migrations/
├── 20260207_init/
│   └── migration.sql
├── 20260214_add_priority/
│   └── migration.sql
└── 20260221_add_attachments/
    └── migration.sql
```

**Rollback support**:
```bash
# Rollback last migration
npx prisma migrate resolve --rolled-back 20260221_add_attachments

# Reset database (dev only)
npx prisma migrate reset
```

### Seed Data Templates

Generate realistic seed data based on product type:
- **B2B SaaS**: Multiple tenants, users, workspaces
- **E-commerce**: Products, orders, customers
- **Social Platform**: Users, posts, comments, likes
- **Ticketing**: Tickets, comments, attachments

---

## Error Handling

### If database schema section missing:
- **Action**: Error with guidance
- **Example**: "❌ No database schema found in blueprint. Run `/architect:blueprint` first."

### If ORM not detected:
- **Action**: Prompt user to choose
- **Options**: "1) Prisma (recommended), 2) Drizzle, 3) TypeORM, 4) Raw SQL"

### If relationships ambiguous:
- **Action**: Make reasonable assumptions, document in comments
- **Example**: `// Assuming one-to-many: Tenant has many Users`

### If enum values not specified:
- **Action**: Use common defaults
- **Example**: TicketStatus = OPEN, IN_PROGRESS, RESOLVED, CLOSED

---

## Success Criteria

A successful data model generation should:
- ✅ Include all entities from blueprint
- ✅ Preserve all relationships (FK, one-to-many, many-to-many)
- ✅ Add performance indexes on foreign keys and common queries
- ✅ Include RLS policies for multi-tenant apps
- ✅ Generate seed data for testing
- ✅ Be type-safe (TypeScript types generated)
- ✅ Support migrations (version-controlled schema changes)
- ✅ Include cascade deletes where appropriate
- ✅ Follow ORM best practices
- ✅ Be production-ready (no placeholder/TODO code)

---

## Examples

### Example 1: Prisma (Default)

```bash
/architect:generate-data-model

# Output:
# ✅ Generated prisma/schema.prisma
# ✅ Generated prisma/seed.ts
# ✅ Generated prisma/middleware.ts (RLS)
```

### Example 2: Drizzle (Edge/Serverless)

```bash
/architect:generate-data-model --orm=drizzle

# Output:
# ✅ Generated db/schema.ts
# ✅ Generated db/seed.ts
# ✅ Generated drizzle.config.ts
```

### Example 3: Raw SQL

```bash
/architect:generate-data-model --orm=sql

# Output:
# ✅ Generated db/migrations/001_initial_schema.sql
# ✅ Generated db/seed.sql
# ✅ Generated db/rls-policies.sql
```

### Example 4: With Sample Data

```bash
/architect:generate-data-model --seed

# Output:
# ✅ Generated schema + seed data
# ✅ Created 3 demo tenants, 10 users, 25 tickets
```
