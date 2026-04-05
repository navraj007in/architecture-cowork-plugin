---
name: Multi-Tenancy Patterns and Design Models
description: Data isolation strategies, SDL configuration, tenant onboarding flows, and design tradeoffs
---

# Multi-Tenancy Design Patterns

Complete guide to building multi-tenant SaaS: isolation models, scope management, tenant onboarding, and workspace/organization patterns.

## Overview

Multi-tenancy allows a single application instance to serve multiple independent customers (tenants), each with their own isolated data. Three primary isolation models exist, each with performance/cost/complexity tradeoffs.

## Isolation Models

### 1. Row-Level Security (RLS) — Shared Database, Shared Schema

**Architecture:** Single database, single schema; rows tagged with `tenant_id` column; database-level RLS policies prevent cross-tenant access.

```sql
-- Every table has tenant_id column
CREATE TABLE users (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  email VARCHAR NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- RLS policy: each tenant sees only their own rows
CREATE POLICY tenant_isolation_policy ON users
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

**Middleware to set tenant context:**
```typescript
app.use((req, res, next) => {
  const tenantId = req.headers['x-tenant-id'];
  // Set PostgreSQL session variable
  db.query(`SET app.current_tenant_id = '${tenantId}'`);
  next();
});
```

**Tradeoffs:**

| Aspect | Pro | Con |
|--------|-----|-----|
| **Cost** | Lowest (1 DB, 1 schema) | — |
| **Latency** | Minimal overhead | RLS enforcement on every query |
| **Isolation** | Strong (database-enforced) | Shared schema, one schema vulnerability = all tenants exposed |
| **Scaling** | Scales until single DB maxes out (~1000 tenants) | Single point of failure |
| **Debugging** | Simple (all data in one place) | Hard to debug RLS edge cases |

**Best For:** Early-stage SaaS (< 100 tenants), high trust environment, mature RDBMS (PostgreSQL/SQL Server).

**Not Recommended For:** Healthcare/finance (separate DB legally required), extremely multi-tenant (> 10,000 tenants).

---

### 2. Schema Per Tenant — Shared Database, Multiple Schemas

**Architecture:** Single database; each tenant gets a separate schema; schema-specific passwords/connections isolate data.

```sql
-- Admin schema
CREATE SCHEMA admin;

-- Tenant A schema
CREATE SCHEMA tenant_a;
CREATE TABLE tenant_a.users (
  id UUID PRIMARY KEY,
  email VARCHAR NOT NULL
);
CREATE TABLE tenant_a.orders (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES tenant_a.users(id)
);

-- Tenant B schema
CREATE SCHEMA tenant_b;
CREATE TABLE tenant_b.users (
  id UUID PRIMARY KEY,
  email VARCHAR NOT NULL
);
```

**Application code:**
```typescript
app.use((req, res, next) => {
  const tenantId = req.headers['x-tenant-id'];
  
  // Route all queries through tenant schema
  const schemaName = `tenant_${tenantId}`;
  req.db = new Database({
    ...config,
    schema: schemaName
  });
  next();
});

// All queries automatically use tenant schema
const users = await req.db.query('SELECT * FROM users');
```

**Tradeoffs:**

| Aspect | Pro | Con |
|--------|-----|-----|
| **Cost** | Moderate (1 DB, N schemas) | Schema per tenant = schema overhead |
| **Latency** | Good (no RLS overhead) | Schema switching overhead |
| **Isolation** | Very strong (schema-level) | Shared database still one vulnerability = all schemas accessible |
| **Scaling** | Better than RLS (can shard by tenant) | Schema management complexity (migrations per-tenant) |
| **Debugging** | Easy (data isolated by schema) | Multiple schemas to manage |
| **Tenant Onboarding** | Create schema + initial tables | Requires running migrations per-tenant |

**Best For:** Growing SaaS (100–1,000 tenants), need to isolate per-tenant customizations (custom fields, extensions), monthly billing.

**Not Recommended For:** High-frequency tenant creation (schema creation is slow), single-region (sharding harder).

---

### 3. Database Per Tenant — Separate Database Per Tenant

**Architecture:** Each tenant gets a dedicated database; complete data, infrastructure, and backup isolation.

```yaml
# Terraform config
resource "aws_db_instance" "tenant_database" {
  for_each = var.tenants
  
  identifier = "db-${each.value.id}"
  database_name = "app_db"
  instance_class = "db.t3.micro"
  
  tags = {
    tenant_id = each.value.id
    tier = each.value.plan # starter, growth, enterprise
  }
}
```

**Application code:**
```typescript
const getTenantDatabaseConfig = async (tenantId: string) => {
  const tenant = await db.tenant.findUnique({ where: { id: tenantId } });
  
  return {
    host: tenant.database.endpoint,
    username: tenant.database.username,
    password: await secretsManager.get(`db-password-${tenantId}`),
    database: tenant.database.name
  };
};

app.use(async (req, res, next) => {
  const tenantId = req.headers['x-tenant-id'];
  const config = await getTenantDatabaseConfig(tenantId);
  req.db = new Database(config);
  next();
});
```

**Tradeoffs:**

| Aspect | Pro | Con |
|--------|-----|-----|
| **Cost** | Highest (N DBs, N backups, N maintenance) | ~10x cost of RLS model |
| **Latency** | Good (dedicated resources) | Connection pool per-tenant overhead |
| **Isolation** | Strongest (complete DB isolation) | Operational complexity, each DB needs monitoring |
| **Scaling** | Unlimited (each tenant independent) | Resource fragmentation (small tenants waste $$) |
| **Debugging** | Very easy (data isolated completely) | Need to connect to per-tenant DB for debugging |
| **Customization** | Maximum (tenant can run different schema versions) | Migration management nightmare |
| **High-Value Tenants** | Can right-size resources | Cost overheads for small tenants |

**Best For:** Enterprise SaaS (high-value tenants), regulated industries (PCI/HIPAA require data separation), multi-region deployment.

**Not Recommended For:** Low-cost SaaS, high-frequency tenant creation, resource-constrained environments.

---

## Comparison Matrix

| Criterion | RLS | Schema-Per-Tenant | DB-Per-Tenant |
|-----------|-----|-------------------|-----------------|
| Database Cost | $$$ | $$$ | $$$$$$$ |
| Operational Overhead | ⭐ Low | ⭐⭐ Medium | ⭐⭐⭐ High |
| Isolation Strength | ⭐⭐⭐ Strong | ⭐⭐⭐⭐ Stronger | ⭐⭐⭐⭐⭐ Strongest |
| Scaling Limit | 1,000 tenants | 10,000 tenants | Unlimited |
| Tenant Onboarding | Instant (1 row insert) | Minutes (schema creation) | Hours (DB provisioning) |
| Multi-Region Support | Easy (RLS applies globally) | Moderate (schema replication) | Hard (DB replication) |
| Migration Complexity | High (shared schema) | Medium (per-tenant migrations) | Low (tenant-specific) |
| Right-Sizing Resources | Difficult (shared) | Moderate | Easy (per-tenant tuning) |

---

## SDL Configuration

### Declare Multi-Tenancy Intent

Add to SDL:

```yaml
nonFunctional:
  multiTenancy:
    enabled: true
    isolationModel: "row-level-security" # or "schema-per-tenant" or "db-per-tenant"
    tenantIdField: "tenant_id"
    tenantOnboarding: "self-service" # or "manual"
    customizationsPerTenant: false
```

### Enable Data Model Generation

When `nonFunctional.multiTenancy.enabled: true`, data model generator adds:
- `tenant_id` column to all entities
- `TENANT_ID NOT NULL` constraint
- RLS policies (if isolation model is row-level-security)
- Schema prefixes (if isolation model is schema-per-tenant)

---

## Tenant Onboarding Flows

### Self-Service Signup

```typescript
// User signs up; system automatically creates tenant
app.post('/api/signup', async (req, res) => {
  const { email, company, password } = req.body;
  
  // Create tenant (organization)
  const tenant = await db.tenant.create({
    data: {
      name: company,
      slug: company.toLowerCase().replace(/\s+/g, '-'),
      plan: 'starter',
      status: 'active'
    }
  });
  
  // Create initial user (tenant owner)
  const user = await db.user.create({
    data: {
      tenant_id: tenant.id,
      email,
      password: hashPassword(password),
      role: 'admin'
    }
  });
  
  // For schema-per-tenant: create schema
  if (ISOLATION_MODEL === 'schema-per-tenant') {
    await db.raw(`CREATE SCHEMA tenant_${tenant.id}`);
    await runMigrations(`tenant_${tenant.id}`);
  }
  
  res.json({ tenant, user, token: generateJWT(user) });
});
```

### Admin-Provisioned Tenants

```typescript
// Admin creates tenant in dashboard
app.post('/api/admin/tenants', @RequireRole('super-admin'), async (req, res) => {
  const { name, email, plan } = req.body;
  
  const tenant = await db.tenant.create({
    data: { name, plan, status: 'active' }
  });
  
  // For db-per-tenant: provision database
  if (ISOLATION_MODEL === 'db-per-tenant') {
    await provisionTenantDatabase(tenant.id, plan);
  }
  
  // Send invite email
  await sendEmail({
    to: email,
    template: 'tenant-invitation',
    data: { tenant, plan }
  });
  
  res.json(tenant);
});
```

---

## Workspace vs. Organization vs. Tenant

**Tenant** (top-level, billing unit): One company, one subscription, multiple users.

```typescript
interface Tenant {
  id: UUID;
  name: string; // "Acme Corp"
  plan: 'starter' | 'growth' | 'enterprise';
  status: 'active' | 'suspended' | 'deleted';
  createdAt: Date;
}
```

**Organization** (optional sub-division): If tenant needs internal org structure.

```typescript
interface Organization {
  id: UUID;
  tenant_id: UUID; // Which tenant
  name: string; // "Engineering Dept"
  parent_id?: UUID; // Nested orgs
}

interface User {
  id: UUID;
  tenant_id: UUID;
  organization_id?: UUID;
  email: string;
  role: 'admin' | 'user' | 'viewer';
}
```

**Workspace** (optional context switch): If users work in multiple contexts within tenant.

```typescript
interface Workspace {
  id: UUID;
  tenant_id: UUID;
  name: string; // "Q1 Planning"
  members: UUID[]; // User IDs
}
```

**Decision Rule:**
- Simple SaaS (teams, invoices) → No organizations/workspaces
- Complex SaaS (enterprise) → Organizations + optional workspaces
- Very complex (spreadsheets, design tools) → Workspaces primary

---

## Common Pitfalls

### 1. Forgetting `tenant_id` on a Column

**Mistake:**
```typescript
// Forgot tenant_id
const user = await db.user.create({
  data: { email: 'user@example.com' }
});
```

**Fix:**
```typescript
const user = await db.user.create({
  data: {
    tenant_id: req.headers['x-tenant-id'],
    email: 'user@example.com'
  }
});
```

**Prevention:** Add middleware to auto-inject tenant_id:
```typescript
app.use((req, res, next) => {
  const tenantId = req.headers['x-tenant-id'];
  req.db.user.create = async (data) => {
    return await db.user.create({
      data: { ...data, tenant_id: tenantId }
    });
  };
  next();
});
```

### 2. RLS Not Enabled on All Tables

**Mistake:** Create RLS policy on `users` but not `orders`.

**Fix:** Run migration to enable RLS on all tables:
```sql
DO $$
DECLARE
  t text;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END
$$;
```

### 3. Using Wrong Isolation Model

**Mistake:** Start with RLS for 10 tenants, hit scaling limits at 2,000 tenants. Migrating from RLS → schema-per-tenant requires schema extraction (complex).

**Fix:** Start with the model matching your business plan:
- Freemium (hundreds of users) → RLS
- Mid-market (dozens of companies) → Schema-per-tenant
- Enterprise (few high-value customers) → DB-per-tenant

### 4. Leaking Tenant Context in Logs/Errors

**Mistake:**
```typescript
logger.error(`User lookup failed for user ${userId} in tenant ${tenantId}`);
// If log is shared across tenants, tenant B can see tenant A's user IDs
```

**Fix:** Log only non-sensitive identifiers, or mark logs as tenant-specific:
```typescript
auditLog.error({
  action: 'USER_LOOKUP_FAILED',
  user_id: userId,
  tenant_id: tenantId,
  message: 'User not found'
});
// Stored in tenant-specific table
```

---

## Testing Multi-Tenancy

### Unit Tests (Isolation)

```typescript
describe('Multi-Tenancy Isolation', () => {
  it('should prevent tenant A from accessing tenant B data', async () => {
    const tenantA = await db.tenant.create({ data: { name: 'Tenant A' } });
    const tenantB = await db.tenant.create({ data: { name: 'Tenant B' } });
    
    const userA = await db.user.create({
      data: { tenant_id: tenantA.id, email: 'user-a@test.com' }
    });
    const userB = await db.user.create({
      data: { tenant_id: tenantB.id, email: 'user-b@test.com' }
    });
    
    // Set session to tenantA
    await db.query(`SET app.current_tenant_id = '${tenantA.id}'`);
    
    // Query from tenantA context should only see userA
    const users = await db.user.findMany();
    expect(users).toHaveLength(1);
    expect(users[0].id).toBe(userA.id);
  });
});
```

### Integration Tests (Cross-Tenant Attack)

```typescript
it('should prevent API access across tenants', async () => {
  const tenantA = await createTenant();
  const tenantB = await createTenant();
  const userB = await createUser(tenantB);
  
  // Try to access tenant B user as tenant A
  const res = await request(app)
    .get(`/api/users/${userB.id}`)
    .set('x-tenant-id', tenantA.id);
  
  expect(res.status).toBe(404); // User not found (not 200 with data)
});
```

---

## Resources

- PostgreSQL RLS: https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- AWS Multi-Tenancy Best Practices: https://aws.amazon.com/solutions/multi-tenant-saas/
- Stripe Multi-Tenant Architecture: https://stripe.com/docs/connect/multi-tenant-onboarding
