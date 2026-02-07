# Multi-Tenant B2B SaaS Architecture Depth

## Tenant Isolation Design

### Database Strategy: Shared Schema with Row-Level Security (RLS)

**Recommended for 95% of Multi-Tenant SaaS**:

```sql
-- Every table has tenant_id
CREATE TABLE projects (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,  -- ⚠️ CRITICAL: Every table needs this
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row-Level Security
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their tenant's data
CREATE POLICY tenant_isolation ON projects
  FOR ALL
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

-- Create index on tenant_id for ALL tables
CREATE INDEX idx_projects_tenant ON projects(tenant_id);
```

**How It Works**:
1. User logs in → JWT includes `tenant_id`
2. API middleware extracts `tenant_id` from JWT
3. Middleware sets PostgreSQL session variable: `SET app.current_tenant_id = 'uuid'`
4. All queries automatically filtered by RLS policy
5. **Zero risk of cross-tenant data leaks** (enforced at database level)

**Pros**:
- ✅ Strong isolation (database-enforced, not app-layer)
- ✅ Cost-effective (one database for all tenants)
- ✅ Easy backups (single database)
- ✅ Simpler ops than separate databases

**Cons**:
- ❌ Noisy neighbor risk (one tenant's heavy query affects others)
- ❌ Not suitable for HIPAA (requires separate DBs per tenant)

---

### Alternative: Separate Database Per Tenant

**When to Use**:
- HIPAA/healthcare (PHI isolation required)
- Enterprise contracts requiring dedicated infrastructure
- Very high-value customers (willing to pay 10x premium)

**Architecture**:
```
Tenant A → database_tenant_a (dedicated RDS instance)
Tenant B → database_tenant_b (dedicated RDS instance)
Tenant C → database_tenant_c (dedicated RDS instance)
```

**Routing Logic**:
```typescript
// Middleware determines which database to connect to
const tenantDb = getTenantDatabase(tenantId)
const pool = new Pool({ database: tenantDb })
```

**Cost**:
- **Shared schema**: $100/month (one RDS instance for 100 tenants)
- **Separate DBs**: $10,000/month ($100/tenant × 100 tenants)
- **100x more expensive** → Only for compliance or mega-contracts

**Recommendation**:
- **Default**: Shared schema with RLS
- **HIPAA**: Separate databases
- **Hybrid**: Shared for SMBs, separate for enterprise (different pricing tiers)

---

## Tenant Context Propagation

### JWT Claims Strategy

**Include tenant_id in JWT**:
```json
{
  "sub": "user-uuid",
  "email": "alice@company.com",
  "tenant_id": "tenant-uuid",  // ⚠️ CRITICAL
  "role": "admin",
  "iat": 1612345678
}
```

**Why in JWT?**
- ✅ No database lookup needed (fast)
- ✅ Stateless authentication
- ✅ Can't be tampered (signed by server)

**Middleware Sets Tenant Context**:
```typescript
// Express middleware
app.use((req, res, next) => {
  const token = req.headers.authorization.split(' ')[1]
  const decoded = jwt.verify(token, process.env.JWT_SECRET)

  // Set tenant context for this request
  req.tenantId = decoded.tenant_id

  // For PostgreSQL RLS
  await pool.query(`SET app.current_tenant_id = '${decoded.tenant_id}'`)

  next()
})
```

---

### API Endpoint Enforcement

**Every endpoint checks tenant context**:
```typescript
// ❌ BAD: Trusting client-provided tenant_id
app.get('/projects/:id', async (req, res) => {
  const project = await db.query(
    'SELECT * FROM projects WHERE id = $1',
    [req.params.id]
  )
  return res.json(project)
})

// ✅ GOOD: Using JWT tenant_id + RLS
app.get('/projects/:id', async (req, res) => {
  // RLS automatically filters by tenant_id
  const project = await db.query(
    'SELECT * FROM projects WHERE id = $1',
    [req.params.id]
  )
  // If project belongs to different tenant, RLS returns null
  if (!project) return res.status(404).json({ error: 'Not found' })
  return res.json(project)
})
```

**Defense in Depth**:
```typescript
// Even with RLS, explicitly filter in app layer
const project = await db.query(
  'SELECT * FROM projects WHERE id = $1 AND tenant_id = $2',
  [req.params.id, req.tenantId]
)
```

---

## Tenant-Scoped Data Storage

### File Storage (S3)

**Option 1: Shared Bucket with Prefixes** (Recommended)
```
s3://myapp-uploads/
  tenant-uuid-1/
    files/
      document.pdf
    images/
      logo.png
  tenant-uuid-2/
    files/
      report.xlsx
```

**S3 Policy Enforces Isolation**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::myapp-uploads/${tenant_id}/*"
    }
  ]
}
```

**Signed URLs Include Tenant Prefix**:
```typescript
const uploadUrl = s3.getSignedUrl('putObject', {
  Bucket: 'myapp-uploads',
  Key: `${tenantId}/files/${fileId}.pdf`,
  Expires: 3600
})
```

**Pros**:
- ✅ Cost-effective (one bucket)
- ✅ Easy to manage
- ✅ S3 policy enforces isolation

**Option 2: Separate Bucket Per Tenant**
- **When**: Enterprise contracts requiring dedicated infrastructure
- **Cost**: $0.023/GB/month per tenant (adds up fast)

---

### Cache Keys Include Tenant ID

**Always prefix cache keys with tenant_id**:
```typescript
// ❌ BAD: Cache key without tenant_id
const cacheKey = `user:${userId}`

// ✅ GOOD: Cache key includes tenant_id
const cacheKey = `tenant:${tenantId}:user:${userId}`
```

**Why?**
- Prevents cache leaks across tenants
- Different tenants may have users with same UUID

---

## Per-Tenant Feature Flags & Quotas

### Feature Flags by Subscription Tier

**Database Schema**:
```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  subscription_tier TEXT NOT NULL,  -- free, starter, pro, enterprise
  feature_flags JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Example feature flags
{
  "api_access": true,
  "sso_enabled": true,
  "custom_domain": true,
  "white_labeling": false
}
```

**Middleware Checks Features**:
```typescript
app.post('/api/v1/data', checkFeature('api_access'), async (req, res) => {
  // This endpoint only works if tenant has api_access enabled
})

function checkFeature(feature: string) {
  return (req, res, next) => {
    const tenant = await db.query(
      'SELECT feature_flags FROM tenants WHERE id = $1',
      [req.tenantId]
    )
    if (!tenant.feature_flags[feature]) {
      return res.status(403).json({
        error: `Upgrade to Pro to access ${feature}`
      })
    }
    next()
  }
}
```

---

### Usage Quotas

**Track Usage Per Tenant**:
```sql
CREATE TABLE tenant_usage (
  tenant_id UUID PRIMARY KEY,
  api_calls_this_month INT NOT NULL DEFAULT 0,
  storage_bytes BIGINT NOT NULL DEFAULT 0,
  users_count INT NOT NULL DEFAULT 0,
  reset_at TIMESTAMPTZ NOT NULL  -- Next month reset
);

CREATE TABLE subscription_limits (
  tier TEXT PRIMARY KEY,  -- free, starter, pro, enterprise
  max_api_calls INT,      -- 1000, 10000, 100000, NULL (unlimited)
  max_storage_gb INT,     -- 1, 10, 100, NULL
  max_users INT           -- 5, 25, 100, NULL
);
```

**Quota Enforcement Middleware**:
```typescript
app.use(async (req, res, next) => {
  const usage = await db.query(
    'SELECT * FROM tenant_usage WHERE tenant_id = $1',
    [req.tenantId]
  )
  const limits = await db.query(
    'SELECT * FROM subscription_limits WHERE tier = $1',
    [req.tenant.subscription_tier]
  )

  if (usage.api_calls_this_month >= limits.max_api_calls) {
    return res.status(429).json({
      error: 'API quota exceeded. Upgrade to increase limit.'
    })
  }

  // Increment usage
  await db.query(
    'UPDATE tenant_usage SET api_calls_this_month = api_calls_this_month + 1 WHERE tenant_id = $1',
    [req.tenantId]
  )

  next()
})
```

**Monthly Reset Cron Job**:
```typescript
// Reset usage counters every month
cron.schedule('0 0 1 * *', async () => {
  await db.query(
    'UPDATE tenant_usage SET api_calls_this_month = 0, reset_at = NOW() + INTERVAL \'1 month\''
  )
})
```

---

## Tenant Provisioning Flow

### New Tenant Signup

**Step 1: Create Workspace**
```typescript
app.post('/signup', async (req, res) => {
  const { companyName, email, password } = req.body

  // 1. Create tenant
  const tenant = await db.query(
    'INSERT INTO tenants (id, name, subscription_tier) VALUES ($1, $2, $3) RETURNING *',
    [uuidv4(), companyName, 'free']
  )

  // 2. Create first user (workspace owner)
  const user = await db.query(
    'INSERT INTO users (id, tenant_id, email, password_hash, role) VALUES ($1, $2, $3, $4, $5) RETURNING *',
    [uuidv4(), tenant.id, email, await bcrypt.hash(password, 10), 'owner']
  )

  // 3. Create default resources (e.g., #general channel)
  await db.query(
    'INSERT INTO channels (id, tenant_id, name) VALUES ($1, $2, $3)',
    [uuidv4(), tenant.id, 'general']
  )

  // 4. Initialize usage tracking
  await db.query(
    'INSERT INTO tenant_usage (tenant_id, reset_at) VALUES ($1, NOW() + INTERVAL \'1 month\')',
    [tenant.id]
  )

  // 5. Generate JWT
  const token = jwt.sign(
    { sub: user.id, tenant_id: tenant.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  )

  res.json({ token, tenant, user })
})
```

---

### Subdomain Routing

**Each tenant gets subdomain**:
- Tenant A: `company-a.myapp.com`
- Tenant B: `company-b.myapp.com`

**Nginx Config**:
```nginx
server {
  listen 80;
  server_name ~^(?<subdomain>.+)\.myapp\.com$;

  location / {
    proxy_pass http://backend;
    proxy_set_header X-Tenant-Subdomain $subdomain;
  }
}
```

**Backend Resolves Tenant from Subdomain**:
```typescript
app.use(async (req, res, next) => {
  const subdomain = req.headers['x-tenant-subdomain']

  const tenant = await db.query(
    'SELECT * FROM tenants WHERE subdomain = $1',
    [subdomain]
  )

  if (!tenant) return res.status(404).send('Tenant not found')

  req.tenant = tenant
  next()
})
```

**Database Schema**:
```sql
ALTER TABLE tenants ADD COLUMN subdomain TEXT UNIQUE NOT NULL;
```

---

## Enterprise Features

### SSO/SAML Configuration Per Tenant

**Each tenant can configure their own SAML IdP**:

```sql
CREATE TABLE tenant_sso_config (
  tenant_id UUID PRIMARY KEY,
  sso_provider TEXT NOT NULL,  -- okta, azure-ad, google-workspace
  saml_entity_id TEXT NOT NULL,
  saml_sso_url TEXT NOT NULL,
  saml_certificate TEXT NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT false
);
```

**SAML Login Flow**:
```
1. User visits company-a.myapp.com/login
2. Backend checks if tenant has SSO enabled
3. If yes, redirect to tenant's SAML IdP
4. User authenticates with company's Okta/Azure AD
5. IdP redirects back with SAML assertion
6. Backend validates assertion, creates JWT
7. User logged in
```

**Implementation**:
- **Library**: `passport-saml` (Node.js) or `python-saml` (Python)
- **Cost**: $0 (just config, no per-user licensing)
- **Pricing**: Charge enterprise customers for SSO (adds $500-2000/month to contract)

---

### Custom Domains Per Tenant

**Enterprise customers get custom domain**:
- Instead of `company-a.myapp.com` → `app.company-a.com`

**DNS Setup**:
```
Customer creates CNAME:
  app.company-a.com → proxy.myapp.com
```

**Backend Routing**:
```sql
ALTER TABLE tenants ADD COLUMN custom_domain TEXT UNIQUE;
```

```typescript
app.use(async (req, res, next) => {
  const host = req.headers.host  // app.company-a.com

  const tenant = await db.query(
    'SELECT * FROM tenants WHERE custom_domain = $1 OR subdomain = $2',
    [host, host.split('.')[0]]
  )

  req.tenant = tenant
  next()
})
```

**SSL Certificates**:
- **Option 1**: Let's Encrypt wildcard cert (`*.myapp.com`)
- **Option 2**: AWS ACM auto-provisions cert for custom domains
- **Library**: `greenlock-express` (automated Let's Encrypt)

---

## Billing & Metering

### Subscription Management

**Stripe Integration**:
```typescript
// Create Stripe customer when tenant signs up
const stripeCustomer = await stripe.customers.create({
  email: user.email,
  metadata: { tenant_id: tenant.id }
})

await db.query(
  'UPDATE tenants SET stripe_customer_id = $1 WHERE id = $2',
  [stripeCustomer.id, tenant.id]
)

// Create subscription
const subscription = await stripe.subscriptions.create({
  customer: stripeCustomer.id,
  items: [{ price: 'price_pro_monthly' }]  // Stripe price ID
})
```

**Webhook Handling**:
```typescript
app.post('/webhooks/stripe', async (req, res) => {
  const event = req.body

  if (event.type === 'invoice.payment_succeeded') {
    // Mark tenant as active
    await db.query(
      'UPDATE tenants SET subscription_status = $1 WHERE stripe_customer_id = $2',
      ['active', event.data.object.customer]
    )
  }

  if (event.type === 'invoice.payment_failed') {
    // Suspend tenant
    await db.query(
      'UPDATE tenants SET subscription_status = $1 WHERE stripe_customer_id = $2',
      ['suspended', event.data.object.customer]
    )
  }

  res.json({ received: true })
})
```

---

### Usage-Based Pricing

**Metered Billing Example (API calls)**:
```typescript
// Report usage to Stripe
await stripe.subscriptionItems.createUsageRecord(
  subscriptionItemId,
  {
    quantity: apiCallsThisMonth,
    timestamp: Math.floor(Date.now() / 1000),
    action: 'set'  // Replace previous value
  }
)
```

**Stripe Price Setup**:
- Base fee: $49/month
- Metered: $0.01 per API call over 10,000

---

## Noisy Neighbor Prevention

### Per-Tenant Rate Limiting

**Redis-Based Rate Limiter**:
```typescript
import rateLimit from 'express-rate-limit'
import RedisStore from 'rate-limit-redis'

const limiter = rateLimit({
  store: new RedisStore({ client: redisClient }),
  keyGenerator: (req) => `rate-limit:${req.tenantId}`,  // Key per tenant
  max: 1000,  // 1000 requests
  windowMs: 15 * 60 * 1000  // per 15 minutes
})

app.use(limiter)
```

**Why Per-Tenant?**
- Prevents one tenant's heavy usage from affecting others
- Each tenant gets fair share of API capacity

---

### Database Query Timeouts

**Prevent long-running queries**:
```sql
-- Set statement timeout per session
SET statement_timeout = '5s';
```

```typescript
// In middleware
await pool.query('SET statement_timeout = $1', ['5s'])
```

**Why?**
- One tenant's expensive query can't lock tables for others
- Fails fast instead of blocking

---

## Security Checklist

- [ ] All tables have `tenant_id` column
- [ ] Row-Level Security (RLS) policies enabled on all tables
- [ ] Indexes on `tenant_id` for performance
- [ ] JWT includes `tenant_id` claim
- [ ] Middleware sets tenant context on every request
- [ ] S3 paths prefixed with `tenant_id`
- [ ] Cache keys include `tenant_id`
- [ ] Feature flags checked in middleware
- [ ] Usage quotas enforced per tenant
- [ ] Per-tenant rate limiting
- [ ] Database query timeouts
- [ ] Audit logs include `tenant_id`
- [ ] Stripe customer metadata includes `tenant_id`
- [ ] Subdomain or custom domain routing configured
- [ ] SSO config stored per tenant (if enterprise feature)

---

## Cost Implications

**Shared Schema (Recommended)**:
- **Database**: $100-500/month (one RDS instance, scales to 1000 tenants)
- **Redis**: $50-200/month (caching + rate limiting)
- **Total**: ~$150-700/month for infrastructure

**Separate Databases (HIPAA/Enterprise)**:
- **Database**: $100/tenant/month minimum
- **Only for**: Healthcare, high-value enterprise contracts

**Feature-Based Pricing**:
- Free: $0/month (limited features, quotas)
- Starter: $29/month (5 users, 10K API calls)
- Pro: $99/month (25 users, 100K API calls, API access)
- Enterprise: $499/month (unlimited, SSO, custom domain)
