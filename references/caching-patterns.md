---
name: Advanced Caching Patterns and Strategies
description: Cache-aside, write-through, TTL policies, invalidation strategies, CDN configuration
---

# Advanced Caching Patterns

Complete guide to caching: strategies (cache-aside, write-through), TTL policies, invalidation patterns, distributed caching (Redis), and CDN configuration.

## Caching Layers

Modern applications use caching at multiple layers:

```
Client → CDN (Cloudflare, CloudFront) → Browser Cache → App Cache (Redis) → Database
         (Static assets)                 (HTTP headers)   (Sessions, hot data)  (Authoritative)
```

## Strategy 1: Cache-Aside (Lazy Loading)

**Flow:** App checks cache first; if miss, fetch from DB and populate cache.

```typescript
async function getUser(userId: string) {
  // Try cache first
  const cached = await redis.get(`user:${userId}`);
  if (cached) return JSON.parse(cached);
  
  // Cache miss: fetch from DB
  const user = await db.user.findUnique({ where: { id: userId } });
  
  // Populate cache
  await redis.set(`user:${userId}`, JSON.stringify(user), 'EX', 3600); // 1 hour TTL
  
  return user;
}
```

**Pros:**
- Simple to implement
- Only cache hot data (misses don't add overhead)
- No cache consistency issues (lazy sync)

**Cons:**
- First request always misses (slow)
- Stale data possible (need TTL)

**Best For:** Read-heavy workloads, non-critical data (recommendations, leaderboards)

---

## Strategy 2: Write-Through

**Flow:** App writes to cache AND DB simultaneously; reads from cache.

```typescript
async function updateUser(userId: string, updates: any) {
  // Write to DB first (authoritative source)
  const user = await db.user.update({
    where: { id: userId },
    data: updates
  });
  
  // Update cache immediately
  await redis.set(`user:${userId}`, JSON.stringify(user));
  
  return user;
}

async function getUser(userId: string) {
  // Read from cache (assume it's always fresh)
  const cached = await redis.get(`user:${userId}`);
  if (cached) return JSON.parse(cached);
  
  // Fallback to DB if cache is empty
  const user = await db.user.findUnique({ where: { id: userId } });
  return user;
}
```

**Pros:**
- Cache always in sync with DB
- No stale data
- Fast reads

**Cons:**
- Slower writes (must hit both cache and DB)
- Cache miss on startup requires seeding

**Best For:** Critical data (user profiles, payment info, config), write-heavy workloads

---

## Strategy 3: Write-Behind (Write-Back)

**Flow:** App writes to cache only; background job flushes to DB periodically.

```typescript
// Write to cache only (fast)
async function updateUserCache(userId: string, updates: any) {
  await redis.set(`user:${userId}:pending`, JSON.stringify(updates));
}

// Background job (every 5 minutes)
setInterval(async () => {
  const keys = await redis.keys('user:*:pending');
  
  for (const key of keys) {
    const updates = await redis.get(key);
    const userId = key.split(':')[1];
    
    // Flush to DB
    await db.user.update({
      where: { id: userId },
      data: JSON.parse(updates)
    });
    
    // Clear pending flag
    await redis.del(key);
  }
}, 5 * 60 * 1000);
```

**Pros:**
- Fastest writes (cache only)
- Good throughput (batch flushes)

**Cons:**
- Risk of data loss (if Redis crashes before flush)
- Complex to implement correctly
- Requires crash recovery logic

**Best For:** Non-critical data (analytics, telemetry), very write-heavy (logging, events)

---

## TTL (Time-To-Live) Policies

Set cache expiration based on data volatility:

```typescript
const TTL_POLICY = {
  // User profile: changes infrequently, user-specific
  'user:': 3600, // 1 hour
  
  // Product catalog: changes daily, accessed frequently
  'product:': 86400, // 24 hours
  
  // Session: short-lived, security-sensitive
  'session:': 1800, // 30 minutes
  
  // Config: stable, rarely changes
  'config:': 604800, // 7 days
  
  // Leaderboard: refreshes frequently, non-critical
  'leaderboard:': 300, // 5 minutes
  
  // API response cache: depends on endpoint
  'api:response:': 60 // 1 minute (varies per endpoint)
};

// Usage
async function cacheWithPolicy(key: string, value: any) {
  const ttl = findTTL(key); // Match pattern to TTL_POLICY
  await redis.set(key, JSON.stringify(value), 'EX', ttl);
}
```

**TTL Decision Matrix:**

| Data Type | Frequency | TTL | Strategy |
|-----------|-----------|-----|----------|
| User profile | Infrequent | 1-2 hours | Cache-aside |
| Session | Frequent | 30 min | Write-through |
| Product catalog | Rare | 24 hours | Cache-aside |
| Shopping cart | Frequent | 1 hour | Write-through |
| Leaderboard | Very frequent | 5-30 min | Write-behind |
| Config | Very rare | 7 days | Cache-aside |
| Analytics | Continuous | No cache | Write-behind/logs |

---

## Invalidation Strategies

### 1. Time-Based (Passive)

Expire cache after fixed TTL. Simplest but may serve stale data.

```typescript
// Data expires after 1 hour
await redis.set(key, value, 'EX', 3600);
```

### 2. Event-Based (Active)

Invalidate cache when data changes.

```typescript
// When user is updated
async function updateUser(userId: string, updates: any) {
  const user = await db.user.update({
    where: { id: userId },
    data: updates
  });
  
  // Invalidate related caches
  await redis.del(`user:${userId}`);
  await redis.del(`user:${userId}:posts`);
  await redis.del(`leaderboard`); // If user rank affects leaderboard
  
  return user;
}
```

### 3. Version-Based (Smart)

Add version number to cache key; bump version on changes.

```typescript
// Cache key includes version
const cacheKey = `product:${productId}:v${product.version}`;
await redis.get(cacheKey); // Cache hit only if version matches

// On update, version auto-increments
await db.product.update({
  where: { id: productId },
  data: { ...updates, version: { increment: 1 } }
});
// Old cache key `v1` is orphaned; new key `v2` is used
```

### 4. Bloom Filter-Based (Sophisticated)

Use Bloom filter to detect if item exists before cache lookup (reduces cache lookups for non-existent items).

```typescript
// On update, add to Bloom filter
const bloomFilter = new BloomFilter();
bloomFilter.add(`product:${productId}`);

// On read, check Bloom filter first
if (!bloomFilter.has(`product:${productId}`)) {
  // Item definitely doesn't exist; skip cache lookup
  return null;
}

// Item might exist; check cache
const cached = await redis.get(`product:${productId}`);
```

---

## Distributed Caching (Redis)

### Connection Pooling

Reuse connections to avoid overhead:

```typescript
import redis from 'redis';

const redisPool = redis.createPool({
  max: 10,           // Max connections
  min: 2,            // Min (idle) connections
  idleTimeoutMillis: 30000
});

async function getCached(key: string) {
  const conn = await redisPool.acquire();
  try {
    return await conn.get(key);
  } finally {
    await redisPool.release(conn);
  }
}
```

### Sharding (Horizontal Scaling)

Partition data across multiple Redis instances:

```typescript
const REDIS_NODES = [
  'redis1.internal:6379',
  'redis2.internal:6379',
  'redis3.internal:6379'
];

function getNode(key: string) {
  // Hash key to determine which node
  const hash = hashFunction(key) % REDIS_NODES.length;
  return REDIS_NODES[hash];
}

async function set(key: string, value: any) {
  const node = getNode(key);
  const redis = redisClients[node];
  await redis.set(key, JSON.stringify(value));
}
```

### Replication (HA)

Redis master-replica setup for high availability:

```
Master (write)
├── Replica 1 (read-only)
└── Replica 2 (read-only)

Failover: If master dies, promote Replica 1 to master
```

---

## CDN Caching (Static Assets)

### HTTP Header Configuration

Control caching at CDN level:

```typescript
// Express middleware
app.use((req, res, next) => {
  if (req.url.match(/\.(js|css|png|jpg|gif)$/)) {
    // Cache static assets for 1 year (safe because filename includes hash)
    res.set('Cache-Control', 'public, max-age=31536000, immutable');
  } else if (req.url.match(/^\/api\//)) {
    // Don't cache API responses (or vary by auth)
    res.set('Cache-Control', 'private, no-cache');
  } else {
    // Cache HTML for 1 hour
    res.set('Cache-Control', 'public, max-age=3600');
  }
  next();
});
```

### Cloudflare Rules

Cache rules for specific URL patterns:

```
Cache Level: Cache Everything
Browser Cache TTL: 30 minutes
CDN Cache TTL: 24 hours

For /api/*: Cache Level OFF (never cache)
For /*.js, /*.css: Cache TTL 30 days
For /images/*: Cache TTL 365 days
```

### Invalidation (Cache Purge)

Purge CDN cache when content changes:

```typescript
import Cloudflare from 'cloudflare';

const cf = new Cloudflare();

async function purgeCDN(urls: string[]) {
  await cf.zones.purgeCache(zoneId, {
    files: urls  // or: { tags: ['product'] }
  });
}

// On product update
await updateProduct(productId, updates);
await purgeCDN([
  `https://cdn.example.com/products/${productId}`,
  `https://cdn.example.com/products` // Purge listing too
]);
```

---

## Cache Warming (Proactive Population)

Pre-populate cache on startup or after deployment:

```typescript
async function warmCache() {
  // Popular products
  const topProducts = await db.product.findMany({
    where: { featured: true },
    take: 100
  });
  
  for (const product of topProducts) {
    await redis.set(
      `product:${product.id}`,
      JSON.stringify(product),
      'EX',
      86400
    );
  }
  
  console.log(`Warmed ${topProducts.length} products`);
}

// Run on server startup
warmCache().catch(console.error);
```

---

## Cache Stampede Prevention

**Problem:** When cache expires, all requests hit DB simultaneously (thundering herd).

**Solution 1: Soft Expiration**

```typescript
async function getWithSoftExpiry(key: string) {
  const cached = await redis.get(key);
  if (cached) {
    const data = JSON.parse(cached);
    
    // Check soft expiry (before hard expiry)
    if (data.expiresAt > Date.now() + 60000) {
      // Still fresh enough
      return data.value;
    }
    
    // Expired but return stale data while refreshing
    refreshInBackground(key); // Async update
    return data.value;
  }
  
  // Cache miss: fetch and populate
  const value = await db.getData(key);
  await redis.set(key, JSON.stringify({
    value,
    expiresAt: Date.now() + 3600000
  }));
  
  return value;
}
```

**Solution 2: Lock-Based Refresh**

```typescript
async function getWithLock(key: string) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  
  // Try to acquire refresh lock
  const lockKey = `${key}:refresh`;
  const acquired = await redis.set(lockKey, '1', 'NX', 'EX', 10);
  
  if (acquired) {
    // I own the refresh lock; fetch fresh data
    const value = await db.getData(key);
    await redis.set(key, JSON.stringify(value));
    await redis.del(lockKey);
    return value;
  } else {
    // Wait for other request to refresh
    for (let i = 0; i < 10; i++) {
      const refreshed = await redis.get(key);
      if (refreshed) return JSON.parse(refreshed);
      await new Promise(r => setTimeout(r, 100));
    }
    
    // Timeout; fall back to DB
    return db.getData(key);
  }
}
```

---

## Performance Tuning

### Memory Management

Monitor and limit cache size:

```typescript
const redis = redisClient();

// Set max memory policy
await redis.config('SET', 'maxmemory', '256mb');
await redis.config('SET', 'maxmemory-policy', 'allkeys-lru');
// Evict least-recently-used keys when max memory reached
```

### Hit Ratio Monitoring

Track cache effectiveness:

```typescript
let hits = 0, misses = 0;

async function getWithMetrics(key: string) {
  const cached = await redis.get(key);
  if (cached) {
    hits++;
    return JSON.parse(cached);
  }
  
  misses++;
  const value = await db.getData(key);
  await redis.set(key, JSON.stringify(value));
  
  return value;
}

// Report metrics
setInterval(() => {
  const hitRatio = hits / (hits + misses);
  console.log(`Cache hit ratio: ${(hitRatio * 100).toFixed(2)}%`);
}, 60000);
```

---

## Checklist

- [ ] Caching strategy chosen (cache-aside, write-through, write-behind)
- [ ] TTL policy defined per data type
- [ ] Invalidation strategy implemented
- [ ] Redis connection pooling configured
- [ ] Cache warming on startup (if applicable)
- [ ] Stampede prevention enabled
- [ ] Hit ratio monitoring in place
- [ ] Memory limits set on Redis
- [ ] CDN cache headers configured (for static assets)
- [ ] Cache purge script ready (for manual updates)
